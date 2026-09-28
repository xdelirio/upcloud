import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/account_info.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/paging.dart';
import 'package:upcloud/src/core/models/remote_upload.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/models/upload_request.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_api.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_driver.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_dtos.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_mappers.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_uploader.dart';

/// Credential keys and helpers for [MediaFireProvider].
///
/// MediaFire authenticates with the account email and password plus the id
/// of a MediaFire application (Account Settings > Developers). The
/// application secret key is only needed when the application has "Require
/// Secret Key" enabled.
abstract final class MediaFireCredentials {
  /// Key of the account email.
  static const email = 'email';

  /// Key of the account password.
  static const password = 'password';

  /// Key of the MediaFire application id.
  static const applicationId = 'application_id';

  /// Key of the (optional) application secret key.
  static const String apiKey = CredentialField.apiKeyId;

  /// Where to create an application and get its id and key.
  static final Uri helpUrl = Uri.parse(
    'https://www.mediafire.com/developers/getting_started/',
  );

  /// Fields of the MediaFire login form.
  static final CredentialSchema schema = CredentialSchema([
    const CredentialField(
      id: email,
      label: 'Email',
      kind: CredentialInputKind.email,
    ),
    const CredentialField(
      id: password,
      label: 'Password',
      kind: CredentialInputKind.secret,
    ),
    CredentialField(
      id: applicationId,
      label: 'Application ID',
      hint: 'Create an app in Account Settings > Developers',
      helpUrl: helpUrl,
    ),
    CredentialField(
      id: apiKey,
      label: 'API key',
      kind: CredentialInputKind.secret,
      isRequired: false,
      hint: 'Only if the app has "Require Secret Key" enabled',
      helpUrl: helpUrl,
    ),
  ]);

  /// Builds [Credentials] for a MediaFire account.
  static Credentials create({
    required String email,
    required String password,
    required String applicationId,
    String? apiKey,
  }) => Credentials({
    MediaFireCredentials.email: email,
    MediaFireCredentials.password: password,
    MediaFireCredentials.applicationId: applicationId,
    if (apiKey != null && apiKey.trim().isNotEmpty)
      MediaFireCredentials.apiKey: apiKey,
  });
}

/// [MediaFire](https://www.mediafire.com) storage, through the Core API 1.5.
///
/// Authentication uses version 1 session tokens (ten minute lifespan), which
/// are renewed and re-created transparently; see [MediaFireApi].
///
/// Notes:
///
/// * Folder ids are MediaFire folder keys and file ids are quickkeys. The
///   root folder (`null`) is sent as `myfiles`.
/// * Deleting moves files and folders to the MediaFire trash.
/// * Uploads (`upload/simple`) send the file as the raw request body and
///   keep both files when the name already exists in the destination
///   (`action_on_duplicate=keep`, overridable through
///   [UploadOptions.fields]); [UploadOptions.title] is ignored, the file
///   keeps the source name.
/// * Free accounts accept files up to 5 GB (`mediaFireLimits`).
/// * Searches need at least three characters and return up to 100 results.
/// * Web uploads cannot be cancelled through the API.
final class MediaFireProvider
    implements
        FolderBrowsing,
        FolderManaging,
        FileManaging,
        FileSearching,
        FileUploading,
        RemoteUploading,
        AccountInfoProviding {
  /// Creates a provider for the account in [credentials] (see
  /// [MediaFireCredentials]).
  ///
  /// [info], [limits] and [baseUrl] default to the values of
  /// [mediaFireFallbackDefinition].
  /// Uploaded files are polled every [pollInterval] for up to
  /// [pollTimeout] until MediaFire processed them. [clock] replaces
  /// `DateTime.now` (tests).
  ///
  /// Throws [AuthenticationException] if a required credential is missing.
  factory MediaFireProvider({
    required Credentials credentials,
    ProviderOptions options = const ProviderOptions(),
    ProviderInfo? info,
    ProviderLimits? limits,
    Uri? baseUrl,
    Duration pollInterval = const Duration(seconds: 2),
    Duration pollTimeout = const Duration(minutes: 10),
    DateTime Function()? clock,
  }) {
    final email = credentials.require(MediaFireCredentials.email);
    // Validates presence; the raw value keeps meaningful whitespace.
    credentials.require(MediaFireCredentials.password);
    final password = credentials[MediaFireCredentials.password]!;
    final applicationId = credentials.require(
      MediaFireCredentials.applicationId,
    );
    final apiKey = credentials[MediaFireCredentials.apiKey]?.trim();

    final resolvedLimits =
        limits ?? mediaFireFallbackDefinition.limitsFor(options);
    final dio = createDio(
      baseUrl:
          baseUrl ??
          mediaFireFallbackDefinition.baseUrlFor(options) ??
          mediaFireDefaultBaseUrl,
      options: options,
      limits: resolvedLimits,
    );
    final api = MediaFireApi(
      dio,
      email: email,
      password: password,
      applicationId: applicationId,
      apiKey: apiKey == null || apiKey.isEmpty ? null : apiKey,
      clock: clock,
    );
    return MediaFireProvider._(
      info: info ?? mediaFireFallbackDefinition.info,
      limits: resolvedLimits,
      dio: dio,
      ownsDio: options.dio == null,
      api: api,
      uploader: MediaFireUploader(
        api,
        pollInterval: pollInterval,
        pollTimeout: pollTimeout,
      ),
    );
  }

  MediaFireProvider._({
    required this.info,
    required this.limits,
    required this._dio,
    required this._ownsDio,
    required this._api,
    required this._uploader,
  });

  /// Items per `folder/get_content` chunk (MediaFire's default and the
  /// maximum reported by `system/get_limits`).
  static const _chunkSize = 100;

  // Keys of the upload request context.
  static const _folderKey = 'folderId';
  static const _descriptionKey = 'description';
  static const _publicKey = 'isPublic';

  @override
  final ProviderInfo info;

  @override
  final ProviderLimits limits;

  @override
  Set<Capability> get capabilities => mediaFireCapabilities;

  final Dio _dio;
  final bool _ownsDio;
  final MediaFireApi _api;
  final MediaFireUploader _uploader;

  /// Logs in now instead of on the first call. Throws
  /// [AuthenticationException] when the credentials are rejected.
  Future<void> signIn() => _api.sessionToken();

  @override
  void close() {
    _api.close();
    if (_ownsDio) _dio.close(force: true);
  }

  // ---------------------------------------------------------------------------
  // FolderBrowsing

  /// Lists [folderId] with `folder/get_content`: folders first, then files.
  ///
  /// MediaFire pages folders and files separately in chunks of 100 items;
  /// they are stitched together so [page] addresses the combined list.
  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) async {
    final key = mediaFireFolderKey(folderId);
    final perPage = math.max(1, page.perPage);
    final start = math.max(0, page.page - 1) * perPage;
    final end = start + perPage;
    final items = <CloudEntry>[];

    // There is no cheap folder count, so walk the folder chunks until the
    // page is filled or they run out.
    int? folderTotal;
    for (var chunk = 1; ; chunk++) {
      final content = await _content(key, 'folders', chunk);
      final offset = (chunk - 1) * _chunkSize;
      final folders = content.folders;
      for (var i = 0; i < folders.length; i++) {
        final index = offset + i;
        if (index >= start && index < end) {
          items.add(folders[i].toCloudFolder(parentKey: key));
        }
      }
      final seen = offset + folders.length;
      if (!(content.moreChunks ?? false) || folders.isEmpty) {
        folderTotal = seen;
        break;
      }
      if (seen >= end) break;
    }
    if (folderTotal == null) {
      return PagedResult(items: items, request: page, hasMoreHint: true);
    }

    // Range of files that falls in this page.
    final fileStart = math.max(0, start - folderTotal);
    final fileEnd = end - folderTotal;
    if (fileEnd <= 0) {
      return PagedResult(
        items: items,
        request: page,
        // With exactly `end` folders, files may still follow.
        hasMoreHint: folderTotal > end ? true : null,
      );
    }

    int? fileTotal;
    var moreFiles = false;
    final lastChunk = (fileEnd - 1) ~/ _chunkSize + 1;
    for (var chunk = fileStart ~/ _chunkSize + 1; chunk <= lastChunk; chunk++) {
      final content = await _content(key, 'files', chunk);
      final offset = (chunk - 1) * _chunkSize;
      final files = content.files;
      for (var i = 0; i < files.length; i++) {
        final index = offset + i;
        if (index >= fileStart && index < fileEnd) {
          items.add(files[i].toCloudFile(parentKey: key));
        }
      }
      moreFiles = content.moreChunks ?? false;
      if (!moreFiles) {
        // An empty chunk past the end does not tell the real total.
        if (files.isNotEmpty || chunk == 1) fileTotal = offset + files.length;
        break;
      }
    }
    return PagedResult(
      items: items,
      request: page,
      totalItems: fileTotal == null ? null : folderTotal + fileTotal,
      hasMoreHint: fileTotal == null ? moreFiles : fileEnd < fileTotal,
    );
  }

  Future<MediaFireFolderContentDto> _content(
    String folderKey,
    String contentType,
    int chunk,
  ) async {
    final body = await _api.request(
      'folder/get_content',
      params: {
        'folder_key': folderKey,
        'content_type': contentType,
        'chunk': chunk,
        'chunk_size': _chunkSize,
      },
      retryable: true,
    );
    return MediaFireFolderContentDto.fromJson(
      readMap(body['folder_content']) ?? const {},
    );
  }

  // ---------------------------------------------------------------------------
  // FolderManaging

  @override
  Future<CloudFolder> createFolder(String name, {FolderId? parentId}) async {
    final parentKey = mediaFireFolderKey(parentId);
    final body = await _api.request(
      'folder/create',
      params: {
        'foldername': name,
        'parent_key': parentKey,
        'action_on_duplicate': 'keep',
      },
    );
    final folder = MediaFireFolderDto.fromJson(body);
    if (folder.folderkey == null) {
      throw ProviderException(
        'MediaFire did not create the folder',
        response: body,
      );
    }
    return folder
        .copyWith(name: folder.name ?? name)
        .toCloudFolder(parentKey: folder.parentFolderKey ?? parentKey);
  }

  @override
  Future<void> renameFolder(FolderId id, String name) => _api.request(
    'folder/update',
    params: {'folder_key': id.value, 'foldername': name},
  );

  @override
  Future<void> moveFolder(FolderId id, FolderId? parentId) => _api.request(
    'folder/move',
    params: {
      'folder_key_src': id.value,
      'folder_key_dst': mediaFireFolderKey(parentId),
    },
  );

  /// Moves the folder [id] and its content to the MediaFire trash.
  @override
  Future<void> deleteFolder(FolderId id) =>
      _api.request('folder/delete', params: {'folder_key': id.value});

  // ---------------------------------------------------------------------------
  // FileManaging

  @override
  Future<CloudFile> fileInfo(FileId id) async {
    final body = await _api.request(
      'file/get_info',
      params: {'quick_key': id.value},
      retryable: true,
    );
    final map =
        readMap(body['file_info']) ??
        readMap(readList(body['file_infos']).firstOrNull);
    if (map == null) {
      throw NotFoundException('File ${id.value} not found', cause: body);
    }
    return MediaFireFileDto.fromJson(map).toCloudFile();
  }

  /// Renames the file [id]. MediaFire does not allow changing the extension.
  @override
  Future<void> renameFile(FileId id, String name) => _api.request(
    'file/update',
    params: {'quick_key': id.value, 'filename': name},
  );

  @override
  Future<void> moveFile(FileId id, FolderId? folderId) => _api.request(
    'file/move',
    params: {'quick_key': id.value, 'folder_key': mediaFireFolderKey(folderId)},
  );

  /// Moves the file [id] to the MediaFire trash.
  @override
  Future<void> deleteFile(FileId id) =>
      _api.request('file/delete', params: {'quick_key': id.value});

  // ---------------------------------------------------------------------------
  // FileSearching

  /// Searches file names and descriptions with `folder/search`.
  ///
  /// Without [folderId] the whole account is searched. MediaFire returns up
  /// to 100 results, paginated locally. Throws
  /// [UnsupportedOperationException] for queries shorter than three
  /// characters.
  @override
  Future<PagedResult<CloudFile>> searchFiles(
    String query, {
    FolderId? folderId,
    PageRequest page = PageRequest.first,
  }) async {
    final text = query.trim();
    if (text.length < 3) {
      throw const UnsupportedOperationException(
        'MediaFire searches need at least 3 characters',
      );
    }
    final body = await _api.request(
      'folder/search',
      params: {
        'search_text': text,
        if (folderId != null)
          'folder_key': mediaFireFolderKey(folderId)
        else
          'search_all': 'yes',
      },
      retryable: true,
    );
    final files = [
      for (final item in readList(body['results']))
        if (readMap(item) case final map?
            when readString(map['type']) == 'file')
          MediaFireFileDto.fromJson(map).toCloudFile(),
    ];
    final perPage = math.max(1, page.perPage);
    final start = math.max(0, page.page - 1) * perPage;
    return PagedResult(
      items: files.skip(start).take(perPage).toList(),
      request: page,
      totalItems: files.length,
    );
  }

  // ---------------------------------------------------------------------------
  // FileUploading

  /// Prepares an `upload/simple` request for [UploadOptions.folderId]: the
  /// file is sent as the raw body, with a fresh session token in the URL.
  ///
  /// [UploadOptions.fields] are added to the query, e.g.
  /// `{'action_on_duplicate': 'replace'}` to overwrite a file with the same
  /// name (the default keeps both) or `{'path': 'a/b'}` to upload into a
  /// sub path of the folder.
  @override
  Future<UploadRequest> prepareUpload(
    UploadFileInfo file, {
    UploadOptions options = const UploadOptions(),
  }) async {
    final length = file.size;
    final rejection = limits.check(
      extension: file.extension,
      size: length == null ? null : DataSize(length),
    );
    if (rejection != null) {
      throw UploadRejectedException(
        'MediaFire does not accept this file',
        reason: rejection,
      );
    }
    return await _uploader.prepare(
      file,
      folderKey: mediaFireFolderKey(options.folderId),
      fields: options.fields,
      context: {
        _folderKey: ?options.folderId?.value,
        _descriptionKey: ?options.description,
        if (options.isPublic case final isPublic?) _publicKey: '$isPublic',
      },
    );
  }

  /// Waits until MediaFire processed the upload (`upload/poll_upload`),
  /// applies [UploadOptions.description] and [UploadOptions.isPublic], and
  /// returns the file details.
  @override
  Future<CloudFile> completeUpload(
    UploadRequest request,
    UploadResponse response,
  ) async {
    final upload = await _uploader.complete(request, response);
    final quickkey = upload.quickkey!;
    final context = request.context;
    final description = context[_descriptionKey];
    final isPublic = switch (context[_publicKey]) {
      'true' => true,
      'false' => false,
      _ => null,
    };
    if (description != null || isPublic != null) {
      // Setting the same values again is harmless: safe to retry.
      await _api.request(
        'file/update',
        params: {
          'quick_key': quickkey,
          'description': ?description,
          if (isPublic != null) 'privacy': isPublic ? 'public' : 'private',
        },
        retryable: true,
      );
    }
    try {
      return await fileInfo(FileId(quickkey));
    } on UpCloudException {
      // The file exists: do not fail (and upload it again) for its details.
      final folder = context[_folderKey];
      return CloudFile(
        id: FileId(quickkey),
        name: upload.filename ?? request.headers['x-filename'] ?? quickkey,
        folderId: folder == null ? null : FolderId(folder),
        size: upload.size == null ? null : DataSize(upload.size!),
        isPublic: isPublic,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // RemoteUploading

  /// Queues a web upload with `upload/add_web_upload`.
  ///
  /// The file is named [UploadOptions.title] or, by default, after the last
  /// segment of [url]. [UploadOptions.fields] are sent as extra parameters.
  /// The returned job id is the MediaFire upload key.
  @override
  Future<RemoteUploadJob> uploadFromUrl(
    Uri url, {
    UploadOptions options = const UploadOptions(),
  }) async {
    final filename = _remoteFileName(url, options);
    final body = await _api.request(
      'upload/add_web_upload',
      params: {
        'url': url.toString(),
        'filename': filename,
        'folder_key': mediaFireFolderKey(options.folderId),
        ...options.fields,
      },
    );
    final key = readString(body['upload_key']);
    if (key == null) {
      throw ProviderException(
        'MediaFire did not return an upload key',
        response: body,
      );
    }
    return RemoteUploadJob(
      id: key,
      sourceUrl: url,
      folderId: options.folderId,
      extra: {'filename': filename},
    );
  }

  /// Every web upload of the account (queued, running and finished) from
  /// `upload/get_web_uploads`.
  @override
  Future<List<RemoteUploadJob>> remoteUploads() async {
    final body = await _api.request(
      'upload/get_web_uploads',
      params: {'all_web_uploads': 'yes'},
      retryable: true,
    );
    return [
      for (final item in readList(body['web_uploads']))
        if (readMap(item) case final map?)
          MediaFireWebUploadDto.fromJson(map).toRemoteUploadJob(),
    ];
  }

  /// Looks up [jobId] in `upload/get_web_uploads`.
  @override
  Future<RemoteUploadJob> remoteUploadStatus(String jobId) async {
    final job = (await remoteUploads()).where((j) => j.id == jobId).firstOrNull;
    if (job == null) throw NotFoundException('Web upload $jobId not found');
    return job;
  }

  /// Not supported: MediaFire has no API to cancel web uploads.
  @override
  Future<void> cancelRemoteUpload(String jobId) => Future.error(
    const UnsupportedOperationException(
      'MediaFire does not allow cancelling web uploads',
    ),
  );

  // ---------------------------------------------------------------------------
  // AccountInfoProviding

  @override
  Future<AccountInfo> accountInfo() async {
    final body = await _api.request('user/get_info', retryable: true);
    final map = readMap(body['user_info']);
    if (map == null) {
      throw ProviderException(
        'Unexpected account response from MediaFire',
        response: body,
      );
    }
    return MediaFireUserInfoDto.fromJson(map).toAccountInfo();
  }

  static String _remoteFileName(Uri url, UploadOptions options) {
    final explicit = options.title?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final segment = url.pathSegments.lastWhere(
      (s) => s.trim().isNotEmpty,
      orElse: () => '',
    );
    return segment.isNotEmpty
        ? segment
        : (url.host.isEmpty ? 'file' : url.host);
  }
}
