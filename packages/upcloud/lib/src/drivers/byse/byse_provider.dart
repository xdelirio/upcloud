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
import 'package:upcloud/src/drivers/byse/byse_api.dart';
import 'package:upcloud/src/drivers/byse/byse_driver.dart';
import 'package:upcloud/src/drivers/byse/byse_mappers.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// A connection to a Byse (https://byse.sx) account.
///
/// Usually created by `byseDriver` for the `byse` registry entry, or
/// directly with the constructor.
///
/// The Byse API has no endpoints to rename or delete files, nor to rename,
/// move or delete folders: those methods throw
/// [UnsupportedOperationException].
///
/// Files get their share link in [CloudFile.pageUrl]: the one returned by
/// the API, or one built from [ProviderDefinition.fileUrlTemplate]
/// (`{id}` is the file code), or the watch page of the website
/// ([byseFileUrlTemplate], `https://byse.sx/d/{id}`).
final class ByseProvider
    implements
        FolderBrowsing,
        FolderManaging,
        FileManaging,
        FileSearching,
        FileUploading,
        RemoteUploading,
        AccountInfoProviding {
  /// Creates a provider authenticated with the API key in [credentials].
  ///
  /// [definition] defaults to [byseFallbackDefinition].
  ///
  /// Throws [AuthenticationException] when the API key is missing.
  factory ByseProvider({
    required Credentials credentials,
    ProviderOptions options = const ProviderOptions(),
    ProviderDefinition? definition,
  }) {
    final def = definition ?? byseFallbackDefinition;
    final apiKey = credentials.apiKey;
    final limits = def.limitsFor(options);
    final dio = createDio(
      baseUrl: def.baseUrlFor(options) ?? byseApiBaseUrl,
      options: options,
      limits: limits,
    );
    return ByseProvider._(
      info: def.info,
      limits: limits,
      fileUrlTemplate: switch (def.fileUrlTemplate?.trim()) {
        final template? when template.isNotEmpty => template,
        _ => byseFileUrlTemplate(def.info.website),
      },
      api: ByseApi(dio, apiKey),
      ownsDio: options.dio == null,
    );
  }

  ByseProvider._({
    required this.info,
    required this.limits,
    required this._fileUrlTemplate,
    required this._api,
    required this._ownsDio,
  });

  @override
  final ProviderInfo info;

  @override
  final ProviderLimits limits;

  /// Link of the files whose link the API does not return, `{id}` is the
  /// file code.
  final String _fileUrlTemplate;

  /// Byse can create folders but not rename, move or delete them, and can
  /// move files but not rename or delete them.
  @override
  Set<Capability> get capabilities => byseCapabilities;

  final ByseApi _api;
  final bool _ownsDio;

  // Keys of the upload request context.
  static const _nameKey = 'name';
  static const _sizeKey = 'size';
  static const _folderKey = 'folderId';

  /// Remote uploads queued by this instance. Byse has no endpoint that lists
  /// them, so [remoteUploads] queries each one.
  final Set<String> _remoteJobs = {};

  /// Closes the HTTP client, unless it was given in
  /// [ProviderOptions.dio].
  @override
  void close() {
    if (_ownsDio) _api.dio.close();
  }

  // --- Account -------------------------------------------------------------

  @override
  Future<AccountInfo> accountInfo() async {
    final json = await _api.get('account/info');
    final result = readMap(json['result']);
    if (result == null) {
      throw ProviderException('Byse returned no account data', response: json);
    }
    return byseAccountFromJson(result);
  }

  // --- Folders -------------------------------------------------------------

  /// Lists subfolders (`/folder/list`, first page only) followed by the files
  /// of [folderId] (`/file/list`, paginated).
  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) async {
    final folders = page.page <= 1
        ? await _subfolders(folderId)
        : const <CloudFolder>[];
    final files = await _fileList(
      folderId: byseFolderParam(folderId),
      page: page,
    );
    final totalFiles = files.totalItems;
    return PagedResult<CloudEntry>(
      items: [...folders, ...files.items],
      request: page,
      totalItems: totalFiles == null ? null : totalFiles + folders.length,
      totalPages: files.totalPages,
      hasMoreHint: files.hasMore,
    );
  }

  Future<List<CloudFolder>> _subfolders(FolderId? parentId) async {
    final json = await _api.get(
      'folder/list',
      query: {'fld_id': byseFolderParam(parentId)},
    );
    return [
      for (final item in readList(readMap(json['result'])?['folders']))
        if (readMap(item) case final map?)
          ?byseFolderFromJson(map, parentId: parentId),
    ];
  }

  @override
  Future<CloudFolder> createFolder(String name, {FolderId? parentId}) async {
    final json = await _api.get(
      'folder/create',
      query: {'name': name, 'parent_id': byseFolderParam(parentId)},
    );
    final id = byseFolderId(
      readMap(json['result'])?['fld_id'] ?? json['fld_id'],
    );
    if (id == null) {
      throw ProviderException(
        'Byse did not return the id of the new folder',
        response: json,
      );
    }
    return CloudFolder(id: id, name: name, parentId: parentId);
  }

  /// Not supported by the Byse API.
  @override
  Future<void> renameFolder(FolderId id, String name) =>
      _unsupported('renaming folders');

  /// Not supported by the Byse API.
  @override
  Future<void> moveFolder(FolderId id, FolderId? parentId) =>
      _unsupported('moving folders');

  /// Not supported by the Byse API.
  @override
  Future<void> deleteFolder(FolderId id) => _unsupported('deleting folders');

  // --- Files ---------------------------------------------------------------

  @override
  Future<CloudFile> fileInfo(FileId id) async {
    final json = await _api.get('file/info', query: {'file_code': id.value});
    for (final item in _resultList(json)) {
      final code = byseFileCode(item);
      if (code != null && code.toLowerCase() != id.value.toLowerCase()) {
        continue;
      }
      final status = readInt(item['status']);
      if (status != null && status != 200) {
        throw byseApiException(
          status,
          readString(item['msg']) ?? 'File ${id.value} not found',
          response: json,
        );
      }
      return byseFileFromJson({
        ...item,
        'file_code': id.value,
      }, fileUrlTemplate: _fileUrlTemplate)!;
    }
    throw NotFoundException('File ${id.value} not found');
  }

  /// Not supported by the Byse API.
  @override
  Future<void> renameFile(FileId id, String name) =>
      _unsupported('renaming files');

  /// Moves the file with `/file/set_folder`.
  @override
  Future<void> moveFile(FileId id, FolderId? folderId) async {
    await _api.get(
      'file/set_folder',
      query: {'file_code': id.value, 'fld_id': byseFolderParam(folderId)},
    );
  }

  /// Not supported by the Byse API.
  @override
  Future<void> deleteFile(FileId id) => _unsupported('deleting files');

  /// Searches file titles with the `title` filter of `/file/list`.
  @override
  Future<PagedResult<CloudFile>> searchFiles(
    String query, {
    FolderId? folderId,
    PageRequest page = PageRequest.first,
  }) => _fileList(folderId: folderId?.value, title: query, page: page);

  Future<PagedResult<CloudFile>> _fileList({
    required PageRequest page,
    String? folderId,
    String? title,
  }) async {
    final json = await _api.get(
      'file/list',
      query: {
        'fld_id': folderId,
        'title': title,
        'page': page.page,
        'per_page': page.perPage,
      },
    );
    final data = byseFilePageFromJson(json['result']);
    return PagedResult(
      items: [
        for (final item in data.files)
          ?byseFileFromJson(item, fileUrlTemplate: _fileUrlTemplate),
      ],
      request: page,
      totalItems: data.totalItems,
      totalPages: data.totalPages,
    );
  }

  // --- Uploads -------------------------------------------------------------

  /// Gets an upload server (`/upload/server`, HTTPS only) and prepares a
  /// multipart request with the API key and the folder (`fld_id`).
  ///
  /// The file is checked against [limits] first. The title, description,
  /// visibility, adult flag and tags are sent with the XVideoSharing field
  /// names (`file_title`, `file_descr`, `file_public`, `file_adult`,
  /// `tags`), which Byse may ignore, followed by [UploadOptions.fields].
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
        _rejectionMessage(file.name, rejection),
        reason: rejection,
      );
    }
    final server = await _uploadServer();
    return UploadRequest(
      url: server,
      fields: {
        'key': _api.apiKey,
        'fld_id': ?options.folderId?.value,
        'file_title': ?options.title,
        'file_descr': ?options.description,
        if (options.isPublic case final isPublic?)
          'file_public': isPublic ? '1' : '0',
        if (options.isAdult case final isAdult?)
          'file_adult': isAdult ? '1' : '0',
        if (options.tags.isNotEmpty) 'tags': options.tags.join(','),
        ...options.fields,
      },
      context: {
        _nameKey: options.title ?? file.name,
        _sizeKey: ?length?.toString(),
        _folderKey: ?options.folderId?.value,
      },
    );
  }

  /// Reads the code of the uploaded file and returns the file with its
  /// share link. Byse still processes it, so [CloudFile.isReady] is false.
  @override
  Future<CloudFile> completeUpload(
    UploadRequest request,
    UploadResponse response,
  ) async {
    final uploaded = _uploadedFile(
      parseByseUploadResponse(response),
      response.statusCode,
    );
    final code = byseFileCode(uploaded)!;
    final context = request.context;
    final length = int.tryParse(context[_sizeKey] ?? '');
    final folder = context[_folderKey];
    return CloudFile(
      id: FileId(code),
      name: context[_nameKey] ?? code,
      folderId: folder == null ? null : FolderId(folder),
      size: length == null ? null : DataSize(length),
      pageUrl:
          readUri(uploaded['link']) ??
          ProviderConfig.expandFileUrl(_fileUrlTemplate, code),
      isReady: false,
      extra: {'filename': ?readString(uploaded['filename'])},
    );
  }

  Future<Uri> _uploadServer() async {
    final json = await _api.get('upload/server');
    final url =
        readUri(json['result']) ?? readUri(readMap(json['result'])?['url']);
    if (url == null) {
      throw ProviderException(
        'Byse did not return an upload server',
        response: json,
      );
    }
    // The API key is sent to this server: never over plain HTTP.
    if (url.scheme != 'https') {
      throw ProviderException(
        'Refusing to send the API key to a non-HTTPS upload server: '
        '${url.host}',
        response: json,
      );
    }
    return url;
  }

  /// Returns the first entry of `files` or throws the upload error with
  /// the HTTP status of the response, [httpStatus].
  Map<String, Object?> _uploadedFile(
    Map<String, Object?> json,
    int httpStatus,
  ) {
    final files = [
      for (final item in readList(json['files'] ?? json['result']))
        ?readMap(item),
    ];
    final file = files.isEmpty ? readMap(json['result']) : files.first;
    if (file != null && byseFileCode(file) != null) return file;

    // XVS upload servers report errors as `0:0:0:<message>`.
    final status = readString(file?['status'] ?? file?['file_status']);
    final message = status?.replaceFirst(RegExp('^0:0:0:?'), '').trim();
    throw byseApiException(
      httpStatus,
      message == null || message.isEmpty
          ? readString(json['msg']) ?? 'Byse did not return the uploaded file'
          : message,
      response: json,
    );
  }

  // --- Remote uploads ------------------------------------------------------

  /// Queues [url] with `/remote/add`. The job id is the code of the future
  /// file.
  @override
  Future<RemoteUploadJob> uploadFromUrl(
    Uri url, {
    UploadOptions options = const UploadOptions(),
  }) async {
    final json = await _api.get(
      'remote/add',
      query: {'url': url.toString(), 'fld_id': options.folderId?.value},
    );
    final result = readMap(json['result']);
    final code = result == null ? null : byseFileCode(result);
    if (code == null) {
      throw ProviderException(
        'Byse did not return the remote upload code',
        response: json,
      );
    }
    _remoteJobs.add(code);
    return RemoteUploadJob(
      id: code,
      fileId: FileId(code),
      sourceUrl: url,
      folderId: options.folderId,
    );
  }

  /// Status of the remote upload [jobId] (`/remote/status`).
  ///
  /// Works for any job of the account, including those not queued by this
  /// instance.
  @override
  Future<RemoteUploadJob> remoteUploadStatus(String jobId) async {
    final json = await _api.get('remote/status', query: {'file_code': jobId});
    final result = _resultList(json);
    return byseRemoteJobFromJson(jobId, result.isEmpty ? const {} : result[0]);
  }

  /// Status of the remote uploads queued by this instance.
  ///
  /// Byse cannot list remote uploads, so jobs queued elsewhere (or before
  /// the provider was created) are not included; use [remoteUploadStatus]
  /// for them. Jobs Byse no longer knows are dropped.
  @override
  Future<List<RemoteUploadJob>> remoteUploads() async {
    final jobs = <RemoteUploadJob>[];
    for (final id in _remoteJobs.toList()) {
      try {
        jobs.add(await remoteUploadStatus(id));
      } on NotFoundException {
        _remoteJobs.remove(id);
      }
    }
    return jobs;
  }

  @override
  Future<void> cancelRemoteUpload(String jobId) async {
    await _api.get('remote/remove', query: {'file_code': jobId});
    _remoteJobs.remove(jobId);
  }

  // --- Helpers -------------------------------------------------------------

  Future<Never> _unsupported(String operation) async =>
      throw UnsupportedOperationException(
        'The Byse API does not support $operation',
      );
}

/// Reads `result` as a list of objects (a single object becomes a list).
List<Map<String, Object?>> _resultList(Map<String, Object?> json) {
  final result = json['result'];
  final items = result is List ? result : [result];
  return [for (final item in items) ?readMap(item)];
}

String _rejectionMessage(String name, UploadRejection reason) =>
    switch (reason) {
      FileTooLarge(:final size, :final maxSize) =>
        '"$name" is $size, Byse accepts files up to $maxSize',
      ExtensionNotAllowed(:final extension, :final allowed) =>
        '"$name": Byse does not accept '
            '${extension.isEmpty ? 'files without extension' : '.$extension'}'
            ' (allowed: ${(allowed.toList()..sort()).join(', ')})',
      NotEnoughStorage(:final size, :final available) =>
        '"$name" is $size but only $available are left',
    };
