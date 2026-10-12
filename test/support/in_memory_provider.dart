import 'dart:async';

import 'package:upcloud/src/core/cancellation.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http.dart' show uploadResponseException;
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
import 'package:upcloud/src/registry/cloud_driver.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// A provider that keeps everything in memory.
///
/// Implements every common capability, so it is useful for tests, widget
/// previews and demo modes. [latency] simulates network delays.
///
/// Uploads are prepared as `memory://` requests, which `FakeUploadExecutor`
/// answers successfully; the file is created by [completeUpload].
final class InMemoryProvider
    implements
        FolderBrowsing,
        FolderManaging,
        FileManaging,
        FileSearching,
        FileUploading,
        RemoteUploading,
        AccountInfoProviding {
  /// Creates an empty provider.
  InMemoryProvider({
    this.info = const ProviderInfo(id: 'memory', name: 'In memory'),
    this.limits = ProviderLimits.none,
    this.latency = Duration.zero,
    this.storage = const DataSize.gb(10),
  });

  /// Scheme of the URLs of the upload requests.
  static const uploadScheme = 'memory';

  // Keys of the upload request context.
  static const _nameKey = 'name';
  static const _sizeKey = 'size';
  static const _folderKey = 'folderId';
  static const _publicKey = 'isPublic';

  /// Creates a provider pre-filled with sample folders and files.
  factory InMemoryProvider.sample({
    ProviderInfo info = const ProviderInfo(id: 'memory', name: 'In memory'),
    ProviderLimits limits = ProviderLimits.none,
    Duration latency = const Duration(milliseconds: 300),
  }) {
    final provider = InMemoryProvider(
      info: info,
      limits: limits,
      latency: latency,
    );
    final movies = provider._addFolder('Movies', null);
    final series = provider._addFolder('Series', null);
    provider
      .._addFolder('Season 1', series.id)
      .._addFile('trailer.mp4', null, const DataSize.mb(48))
      .._addFile('intro.mkv', null, const DataSize.mb(230))
      .._addFile('big_buck_bunny.mp4', movies.id, const DataSize.mb(740))
      .._addFile('sintel.webm', movies.id, const DataSize.mb(512));
    for (var i = 1; i <= 60; i++) {
      provider._addFile(
        'episode_${i.toString().padLeft(2, '0')}.mp4',
        series.id,
        DataSize.mb(100 + i),
      );
    }
    return provider;
  }

  @override
  final ProviderInfo info;

  @override
  final ProviderLimits limits;

  /// Delay added to every operation.
  final Duration latency;

  /// Total storage of the fake account.
  final DataSize storage;

  @override
  late final Set<Capability> capabilities = interfaceCapabilities(this);

  final _folders = <FolderId, CloudFolder>{};
  final _files = <FileId, CloudFile>{};
  final _jobs = <String, RemoteUploadJob>{};
  var _nextId = 1;
  var _closed = false;

  /// All files, for assertions in tests.
  List<CloudFile> get files => List.unmodifiable(_files.values);

  /// All folders, for assertions in tests.
  List<CloudFolder> get folders => List.unmodifiable(_folders.values);

  @override
  void close() => _closed = true;

  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) async {
    await _delay();
    if (folderId != null) _folderOrThrow(folderId);
    final entries = <CloudEntry>[
      ..._folders.values.where((f) => f.parentId == folderId),
      ..._files.values.where((f) => f.folderId == folderId),
    ];
    return _page(entries, page);
  }

  @override
  Future<CloudFolder> createFolder(String name, {FolderId? parentId}) async {
    await _delay();
    if (parentId != null) _folderOrThrow(parentId);
    return _addFolder(name, parentId);
  }

  @override
  Future<void> renameFolder(FolderId id, String name) async {
    await _delay();
    _folders[id] = _folderOrThrow(id).copyWith(name: name);
  }

  @override
  Future<void> moveFolder(FolderId id, FolderId? parentId) async {
    await _delay();
    if (parentId != null) _folderOrThrow(parentId);
    _folders[id] = _folderOrThrow(id).copyWith(parentId: parentId);
  }

  @override
  Future<void> deleteFolder(FolderId id) async {
    await _delay();
    _folderOrThrow(id);
    final hasChildren =
        _folders.values.any((f) => f.parentId == id) ||
        _files.values.any((f) => f.folderId == id);
    if (hasChildren) {
      throw const ProviderException('Folder is not empty');
    }
    _folders.remove(id);
  }

  @override
  Future<CloudFile> fileInfo(FileId id) async {
    await _delay();
    return _fileOrThrow(id);
  }

  @override
  Future<void> renameFile(FileId id, String name) async {
    await _delay();
    _files[id] = _fileOrThrow(id).copyWith(name: name);
  }

  @override
  Future<void> moveFile(FileId id, FolderId? folderId) async {
    await _delay();
    if (folderId != null) _folderOrThrow(folderId);
    _files[id] = _fileOrThrow(id).copyWith(folderId: folderId);
  }

  @override
  Future<void> deleteFile(FileId id) async {
    await _delay();
    _fileOrThrow(id);
    _files.remove(id);
  }

  @override
  Future<PagedResult<CloudFile>> searchFiles(
    String query, {
    FolderId? folderId,
    PageRequest page = PageRequest.first,
  }) async {
    await _delay();
    final q = query.toLowerCase();
    final matches = _files.values
        .where((f) => folderId == null || f.folderId == folderId)
        .where((f) => f.name.toLowerCase().contains(q))
        .toList();
    return _page(matches, page);
  }

  /// Checks the limits and the destination folder, and returns a
  /// `memory://` request whose [UploadRequest.context] describes the file.
  @override
  Future<UploadRequest> prepareUpload(
    UploadFileInfo file, {
    UploadOptions options = const UploadOptions(),
  }) async {
    await _delay();
    final rejection = limits.check(
      extension: file.extension,
      size: DataSize(file.size ?? 0),
    );
    if (rejection != null) {
      throw UploadRejectedException('Upload rejected', reason: rejection);
    }
    final folderId = options.folderId;
    if (folderId != null) _folderOrThrow(folderId);
    return UploadRequest(
      url: Uri(scheme: uploadScheme, host: info.id, path: '/upload'),
      fields: {...options.fields},
      context: {
        _nameKey: options.title ?? file.name,
        _sizeKey: '${file.size ?? 0}',
        _folderKey: ?folderId?.value,
        if (options.isPublic case final isPublic?) _publicKey: '$isPublic',
      },
    );
  }

  /// Creates the file described by [request]. Throws
  /// [QuotaExceededException] when it does not fit in [storage].
  @override
  Future<CloudFile> completeUpload(
    UploadRequest request,
    UploadResponse response, {
    CancellationToken? cancelToken,
  }) async {
    await _delay();
    if (!response.isSuccessful) throw uploadResponseException(response);
    final context = request.context;
    final size = DataSize(int.tryParse(context[_sizeKey] ?? '') ?? 0);
    if (size > storage - _used) {
      throw const QuotaExceededException('Not enough storage');
    }
    final folder = context[_folderKey];
    final folderId = folder == null ? null : FolderId(folder);
    if (folderId != null) _folderOrThrow(folderId);
    return _addFile(
      context[_nameKey] ?? 'upload',
      folderId,
      size,
      isPublic: switch (context[_publicKey]) {
        'true' => true,
        'false' => false,
        _ => null,
      },
    );
  }

  @override
  Future<RemoteUploadJob> uploadFromUrl(
    Uri url, {
    UploadOptions options = const UploadOptions(),
  }) async {
    await _delay();
    final name = options.title ?? url.pathSegments.lastOrNull ?? 'remote';
    final file = _addFile(name, options.folderId, const DataSize.mb(1));
    final job = RemoteUploadJob(
      id: file.id.value,
      fileId: file.id,
      sourceUrl: url,
      folderId: options.folderId,
      status: RemoteUploadStatus.completed,
      progress: 1,
    );
    return _jobs[job.id] = job;
  }

  @override
  Future<RemoteUploadJob> remoteUploadStatus(String jobId) async {
    await _delay();
    return _jobs[jobId] ??
        (throw NotFoundException('Remote upload $jobId not found'));
  }

  @override
  Future<List<RemoteUploadJob>> remoteUploads() async {
    await _delay();
    return [..._jobs.values];
  }

  @override
  Future<void> cancelRemoteUpload(String jobId) async {
    await _delay();
    _jobs.remove(jobId);
  }

  @override
  Future<AccountInfo> accountInfo() async {
    await _delay();
    return AccountInfo(
      login: 'demo',
      storageUsed: _used,
      storageLeft: storage - _used,
      filesTotal: _files.length,
    );
  }

  DataSize get _used => _files.values.fold(
    DataSize.zero,
    (sum, f) => sum + (f.size ?? DataSize.zero),
  );

  CloudFolder _addFolder(String name, FolderId? parentId) {
    final id = FolderId('d${_nextId++}');
    return _folders[id] = CloudFolder(
      id: id,
      name: name,
      parentId: parentId,
      createdAt: DateTime.now(),
    );
  }

  CloudFile _addFile(
    String name,
    FolderId? folderId,
    DataSize size, {
    bool? isPublic,
  }) {
    final id = FileId('f${_nextId++}');
    return _files[id] = CloudFile(
      id: id,
      name: name,
      folderId: folderId,
      size: size,
      isPublic: isPublic,
      pageUrl: Uri.https('example.com', '/files/${id.value}'),
      createdAt: DateTime.now(),
      isReady: true,
    );
  }

  CloudFolder _folderOrThrow(FolderId id) =>
      _folders[id] ?? (throw NotFoundException('Folder ${id.value} not found'));

  CloudFile _fileOrThrow(FileId id) =>
      _files[id] ?? (throw NotFoundException('File ${id.value} not found'));

  PagedResult<T> _page<T>(List<T> all, PageRequest page) {
    final start = (page.page - 1) * page.perPage;
    final items = start >= all.length
        ? <T>[]
        : all.sublist(start, (start + page.perPage).clamp(0, all.length));
    return PagedResult(items: items, request: page, totalItems: all.length);
  }

  Future<void> _delay() async {
    _checkOpen();
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  void _checkOpen() {
    if (_closed) throw StateError('Provider was closed');
  }
}

/// A driver that serves [InMemoryProvider.sample] data.
///
/// Not part of the built-in drivers: register it explicitly for demos and
/// UI tests.
final class MemoryDriver extends CloudDriver {
  /// Creates the driver. Prefer the [memoryDriver] instance.
  const MemoryDriver();

  /// Id of this driver in registry entries.
  static const driverId = 'memory';

  @override
  String get id => driverId;

  @override
  String get name => 'In memory';

  @override
  String get description => 'Local sample data, nothing leaves the device.';

  @override
  Set<Capability> get capabilities => const {
    Capability.browseFolders,
    ...Capability.folderManagement,
    ...Capability.fileManagement,
    Capability.search,
    Capability.upload,
    Capability.remoteUpload,
    Capability.accountInfo,
  };

  @override
  bool get requiresApiBase => false;

  @override
  CloudProvider create(
    ProviderDefinition definition,
    Credentials credentials,
    ProviderOptions options,
  ) {
    credentials.apiKey; // Validates that a key is present.
    return InMemoryProvider.sample(
      info: definition.info,
      limits: definition.limitsFor(options),
    );
  }
}

/// The in-memory driver.
const memoryDriver = MemoryDriver();

/// A demo provider backed by [InMemoryProvider.sample].
///
/// Accepts any non-empty API key. Handy for demos and UI tests.
final ProviderDefinition inMemoryDemo = memoryDriver.definitionFor(
  const ProviderConfig(
    id: 'demo',
    name: 'Demo (in memory)',
    driver: MemoryDriver.driverId,
    description: 'Local sample data, nothing leaves the device.',
    limits: LimitsConfig(maxFileSizeMb: 2048),
  ),
);
