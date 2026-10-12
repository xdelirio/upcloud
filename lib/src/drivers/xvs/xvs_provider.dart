import 'package:upcloud/src/core/cancellation.dart';
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
import 'package:upcloud/src/drivers/xvs/xvs_api.dart';
import 'package:upcloud/src/drivers/xvs/xvs_config.dart';
import 'package:upcloud/src/drivers/xvs/xvs_dtos.dart';
import 'package:upcloud/src/drivers/xvs/xvs_mapper.dart';

/// A provider running the XVideoSharing (XVS) script.
///
/// Implements every capability of the XVS API. Clones that disabled some
/// feature list it in [XvsConfig.disabledCapabilities]; the matching
/// methods then throw [UnsupportedOperationException].
///
/// Files get the link returned by the API in [CloudFile.pageUrl], or one
/// built from [ProviderDefinition.fileUrlTemplate] (`{id}` is the file
/// code) when the API returns none.
///
/// Usually created by `xvsDriver` for a registry entry:
///
/// ```dart
/// final provider = registry.definition('streamhg')!.create(
///   Credentials.apiKey('...'),
/// );
/// ```
final class XvsProvider
    implements
        FolderBrowsing,
        FolderManaging,
        FileManaging,
        FileSearching,
        FileUploading,
        RemoteUploading,
        AccountInfoProviding {
  /// Creates a provider for [definition] authenticated with [credentials].
  ///
  /// Throws an [ArgumentError] if neither [definition] nor [options] give
  /// an API base URL. A missing API key is reported as an
  /// [AuthenticationException] by the first request.
  factory XvsProvider({
    required ProviderDefinition definition,
    required Credentials credentials,
    ProviderOptions options = const ProviderOptions(),
    XvsConfig config = const XvsConfig(),
  }) {
    final baseUrl = definition.baseUrlFor(options);
    if (baseUrl == null) {
      throw ArgumentError.value(
        definition,
        'definition',
        'No API base URL; set ProviderOptions.baseUrl',
      );
    }
    final limits = definition.limitsFor(options);
    final dio = createDio(baseUrl: baseUrl, options: options, limits: limits);
    return XvsProvider._(
      info: definition.info,
      limits: limits,
      baseUrl: baseUrl,
      config: config,
      capabilities: definition.capabilities.difference(
        config.disabledCapabilities,
      ),
      fileUrlTemplate: definition.fileUrlTemplate,
      api: XvsApi(dio, () => credentials.apiKey),
      ownsHttpClient: options.dio == null,
    );
  }

  XvsProvider._({
    required this.info,
    required this.limits,
    required this.baseUrl,
    required this.config,
    required this.capabilities,
    required String? fileUrlTemplate,
    required this._api,
    required this._ownsHttpClient,
  }) : _mapper = XvsMapper(fileUrlTemplate: fileUrlTemplate);

  @override
  final ProviderInfo info;

  @override
  final ProviderLimits limits;

  /// API base URL in use (e.g. `https://streamhgapi.com/api`).
  final Uri baseUrl;

  /// Differences of this clone.
  final XvsConfig config;

  /// The capabilities of the definition without the ones disabled in
  /// [config].
  @override
  final Set<Capability> capabilities;

  final XvsApi _api;
  final XvsMapper _mapper;
  final bool _ownsHttpClient;

  // Keys of the upload request context.
  static const _nameKey = 'name';
  static const _titleKey = 'title';
  static const _sizeKey = 'size';
  static const _folderKey = 'folderId';
  static const _publicKey = 'public';

  /// Closes the HTTP client, unless it was provided through
  /// [ProviderOptions.dio].
  @override
  void close() {
    if (_ownsHttpClient) _api.close(force: true);
  }

  // ---------------------------------------------------------------------
  // Browsing and searching
  // ---------------------------------------------------------------------

  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) async {
    _ensure(Capability.browseFolders);
    final (folders, files) = await waitBoth(
      page.page == 1
          ? _subfolders(folderId)
          : Future.value(const <CloudFolder>[]),
      _files(
        page: page,
        folderId: folderId,
        folderParam: XvsMapper.folderParam(folderId),
      ),
    );
    return PagedResult(
      items: [...folders, ...files.items],
      request: page,
      totalPages: files.totalPages,
      hasMoreHint: files.hasMore,
    );
  }

  @override
  Future<PagedResult<CloudFile>> searchFiles(
    String query, {
    FolderId? folderId,
    PageRequest page = PageRequest.first,
  }) async {
    _ensure(Capability.search);
    return await _files(
      page: page,
      folderId: folderId,
      folderParam: folderId?.value,
      title: query,
    );
  }

  Future<List<CloudFolder>> _subfolders(FolderId? parentId) async {
    final result = await _api.get('folder/list', {
      'fld_id': XvsMapper.folderParam(parentId),
    });
    final folders = readMap(result)?['folders'];
    return [
      for (final json in xvsObjects(folders))
        if (_mapper.folder(json, parentId: parentId) case final folder?
            when folder.id != parentId && folder.name != '..')
          folder,
    ];
  }

  Future<PagedResult<CloudFile>> _files({
    required PageRequest page,
    required FolderId? folderId,
    required String? folderParam,
    String? title,
  }) async {
    final result = await _api.get('file/list', {
      'fld_id': folderParam,
      'title': title,
      'page': page.page,
      'per_page': page.perPage,
    });
    final map = readMap(result);
    final files = map == null ? result : map['files'];
    return PagedResult(
      items: [
        for (final json in xvsObjects(files))
          ?_mapper.file(json, folderId: folderId),
      ],
      request: page,
      totalItems: readInt(map?['results_total']),
      totalPages: readInt(map?['pages']),
    );
  }

  // ---------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------

  @override
  Future<CloudFolder> createFolder(String name, {FolderId? parentId}) async {
    _ensure(Capability.createFolder);
    final result = await _api.get('folder/create', {
      'name': name,
      'parent_id': XvsMapper.folderParam(parentId),
    });
    final id = readString(result is Map ? result['fld_id'] : result);
    if (id == null) {
      throw ProviderException(
        'folder/create did not return a folder id',
        response: result,
      );
    }
    return CloudFolder(id: FolderId(id), name: name, parentId: parentId);
  }

  @override
  Future<void> renameFolder(FolderId id, String name) async {
    _ensure(Capability.renameFolder);
    await _api.get('folder/edit', {'fld_id': id.value, 'name': name});
  }

  @override
  Future<void> moveFolder(FolderId id, FolderId? parentId) async {
    _ensure(Capability.moveFolder);
    await _api.get('folder/edit', {
      'fld_id': id.value,
      'parent_id': XvsMapper.folderParam(parentId),
    });
  }

  @override
  Future<void> deleteFolder(FolderId id) async {
    _ensure(Capability.deleteFolder);
    await _api.get('folder/delete', {'fld_id': id.value});
  }

  // ---------------------------------------------------------------------
  // Files
  // ---------------------------------------------------------------------

  @override
  Future<CloudFile> fileInfo(FileId id) async {
    _ensure(Capability.fileInfo);
    return await _fileInfo(id);
  }

  Future<CloudFile> _fileInfo(FileId id) async {
    final result = await _api.get('file/info', {'file_code': id.value});
    final entries = xvsObjects(result);
    // Match by code; a single entry is the answer for the requested code
    // even if the clone spells it differently.
    final json =
        entries
            .where(
              (e) => readString(e['file_code'] ?? e['filecode']) == id.value,
            )
            .firstOrNull ??
        (entries.length == 1 ? entries.single : null);
    final status = readInt(json?['status']);
    final file = json == null ? null : _mapper.file(json);
    if (file == null || status == 404) {
      throw NotFoundException('File ${id.value} not found');
    }
    if (status != null && status != 200) {
      throw xvsError(
        status: status,
        message: 'File ${id.value} is not available (status $status)',
        response: json,
      );
    }
    return file;
  }

  @override
  Future<void> renameFile(FileId id, String name) async {
    _ensure(Capability.renameFile);
    await _api.get('file/edit', {'file_code': id.value, 'file_title': name});
  }

  @override
  Future<void> moveFile(FileId id, FolderId? folderId) async {
    _ensure(Capability.moveFile);
    await _api.get('file/edit', {
      'file_code': id.value,
      'file_fld_id': XvsMapper.folderParam(folderId),
    });
  }

  @override
  Future<void> deleteFile(FileId id) async {
    _ensure(Capability.deleteFile);
    await _api.get('file/delete', {'file_code': id.value});
  }

  /// Details of [id], or [fallback] if they cannot be read (e.g. the file
  /// was just created and is not indexed yet).
  Future<CloudFile> _fileInfoOr(
    FileId id,
    CloudFile Function() fallback,
  ) async {
    try {
      return await _fileInfo(id);
    } on UpCloudException {
      return fallback();
    }
  }

  // ---------------------------------------------------------------------
  // Uploads
  // ---------------------------------------------------------------------

  /// Gets an upload server (`upload/server`) and prepares a multipart
  /// request with the API key, the folder (`fld_id`), title, description,
  /// visibility, adult flag, tags and [UploadOptions.fields].
  @override
  Future<UploadRequest> prepareUpload(
    UploadFileInfo file, {
    UploadOptions options = const UploadOptions(),
  }) async {
    _ensure(Capability.upload);
    final length = file.size;
    limits.ensureAccepts(
      extension: file.extension,
      size: length == null ? null : DataSize(length),
    );
    final server = await _uploadServer();
    return UploadRequest(
      url: server,
      fields: _api.uploadFields({
        'fld_id': options.folderId?.value,
        'file_title': options.title,
        'file_descr': options.description,
        'file_public': _flag(options.isPublic),
        'file_adult': _flag(options.isAdult),
        'tags': options.tags.isEmpty ? null : options.tags.join(', '),
        ...options.fields,
      }),
      context: {
        _nameKey: file.name,
        _titleKey: ?options.title,
        _sizeKey: ?length?.toString(),
        _folderKey: ?options.folderId?.value,
        _publicKey: ?_flag(options.isPublic),
      },
    );
  }

  /// Reads the file code from the upload server response and returns the
  /// file details (`file/info`), or a minimal file with its page link when
  /// they are not available yet.
  @override
  Future<CloudFile> completeUpload(
    UploadRequest request,
    UploadResponse response, {
    CancellationToken? cancelToken,
  }) async {
    _ensure(Capability.upload);
    final envelope = checkUploadResponse(response);
    final uploaded = _uploadedFile(envelope, response.statusCode);
    final code = uploaded.code!;
    final context = request.context;
    final length = int.tryParse(context[_sizeKey] ?? '');
    final size = length == null ? null : DataSize(length);
    final folder = context[_folderKey];
    final file = await _fileInfoOr(
      FileId(code),
      () => CloudFile(
        id: FileId(code),
        name: context[_titleKey] ?? uploaded.name ?? context[_nameKey] ?? code,
        folderId: folder == null ? null : FolderId(folder),
        size: size,
        pageUrl: _mapper.fileUrl(code),
        isPublic: switch (context[_publicKey]) {
          '1' => true,
          '0' => false,
          _ => null,
        },
        isReady: false,
      ),
    );
    return file.size == null && size != null ? file.copyWith(size: size) : file;
  }

  /// URL of the server that receives the next upload.
  ///
  /// The API key is sent to it, so it must use HTTPS when the API does.
  Future<Uri> _uploadServer() async {
    final result = await _api.get('upload/server');
    final url = readUri(result) ?? readUri(readMap(result)?['url']);
    if (url == null) {
      throw ProviderException(
        'upload/server did not return a URL',
        response: result,
      );
    }
    if (baseUrl.scheme == 'https' && url.scheme != 'https') {
      throw ProviderException(
        'Refusing to send the API key to the insecure upload server '
        '${url.host}',
        response: result,
      );
    }
    return url;
  }

  /// The uploaded file of the upload server response, whose HTTP status is
  /// [httpStatus].
  XvsUploadedFileDto _uploadedFile(
    Map<String, Object?> envelope,
    int httpStatus,
  ) {
    final raw = envelope['files'] ?? envelope['result'];
    final nested = raw is Map ? raw['files'] : null;
    final entries = xvsObjects(nested ?? raw);
    if (entries.isEmpty) {
      throw ProviderException(
        'The upload server did not return the uploaded file',
        statusCode: httpStatus,
        response: envelope,
      );
    }
    final dto = XvsUploadedFileDto.fromJson(entries.first);
    final status = dto.status;
    if (status != null &&
        status.toUpperCase() != 'OK' &&
        readInt(status) != 200) {
      // Upload servers prefix errors with codes: `0:0:0:video is too short`.
      final message = status.replaceFirst(RegExp(r'^\d+:\d+:\d+:\s*'), '');
      throw xvsError(
        status: httpStatus,
        message: message.isEmpty ? status : message,
        response: envelope,
      );
    }
    if (dto.code == null) {
      throw ProviderException(
        'The upload server did not return a file code',
        statusCode: httpStatus,
        response: envelope,
      );
    }
    return dto;
  }

  @override
  Future<RemoteUploadJob> uploadFromUrl(
    Uri url, {
    UploadOptions options = const UploadOptions(),
  }) async {
    _ensure(Capability.remoteUpload);
    final result = await _api.get('upload/url', {
      'url': url.toString(),
      'fld_id': options.folderId?.value,
      'file_public': _flag(options.isPublic),
      'file_adult': _flag(options.isAdult),
      'tags': options.tags.isEmpty ? null : options.tags.join(', '),
      ...options.fields,
    });
    final code = readString(
      result is Map ? result['filecode'] ?? result['file_code'] : result,
    );
    if (code == null) {
      throw ProviderException(
        'upload/url did not return a file code',
        response: result,
      );
    }
    return RemoteUploadJob(
      id: code,
      fileId: FileId(code),
      sourceUrl: url,
      folderId: options.folderId,
    );
  }

  @override
  Future<List<RemoteUploadJob>> remoteUploads() async {
    _ensure(Capability.remoteUpload);
    final result = await _api.get('file/url_uploads');
    return [for (final json in xvsObjects(result)) _mapper.remoteUpload(json)];
  }

  @override
  Future<RemoteUploadJob> remoteUploadStatus(String jobId) async {
    _ensure(Capability.remoteUpload);
    final result = await _api.get('file/url_uploads', {
      if (!jobId.contains('://')) 'file_code': jobId,
    });
    final job = [
      for (final json in xvsObjects(result)) _mapper.remoteUpload(json),
    ].where((j) => j.id == jobId).firstOrNull;
    if (job == null) throw NotFoundException('Remote upload $jobId not found');
    return job;
  }

  /// Removes the remote upload whose file code is [jobId].
  ///
  /// Jobs listed without a file code (their id is the source URL) cannot be
  /// removed individually and throw [UnsupportedOperationException].
  @override
  Future<void> cancelRemoteUpload(String jobId) async {
    _ensure(Capability.remoteUpload);
    if (jobId.contains('://')) {
      throw const UnsupportedOperationException(
        'Remote uploads without a file code cannot be cancelled',
      );
    }
    await _api.get('file/url_actions', {'delete_code': jobId});
  }

  // ---------------------------------------------------------------------
  // Account
  // ---------------------------------------------------------------------

  @override
  Future<AccountInfo> accountInfo() async {
    _ensure(Capability.accountInfo);
    final result = readMap(await _api.get('account/info'));
    if (result == null) {
      throw const ProviderException('account/info returned no data');
    }
    return _mapper.account(result);
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  void _ensure(Capability capability) {
    if (!capabilities.contains(capability)) {
      throw UnsupportedOperationException(
        '${info.name} does not support ${capability.name}',
      );
    }
  }

  static String? _flag(bool? value) =>
      value == null ? null : (value ? '1' : '0');
}
