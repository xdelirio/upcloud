import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upcloud/src/controllers/cloud_browser_state.dart';
import 'package:upcloud/src/utils/file_kind.dart';
import 'package:upcloud/upcloud.dart';

/// Browses the folders of a [CloudProvider] and runs actions on its entries.
///
/// Like a `TextEditingController`, it can be created by the app and passed
/// to a `CloudBrowser`, or left to the widget. Read [state] and listen for
/// changes:
///
/// ```dart
/// final controller = CloudBrowserController.forAccount(upcloud, accountId);
/// controller.addListener(() => print(controller.state.entries));
/// await controller.openFolder(folder);
/// ```
///
/// Loading errors are stored in [CloudBrowserState.error] and
/// [CloudBrowserState.loadMoreError]. Actions (such as [createFolder] or
/// [delete]) store their error in [CloudBrowserState.actionError] and also
/// throw it as an [UpCloudException].
class CloudBrowserController extends ChangeNotifier {
  /// Creates a controller that browses [provider].
  ///
  /// Pass [upcloud] and [accountId] to enable [upload], whose uploads
  /// go through `UpCloud.transfers`. [initialPath] opens a folder
  /// other than the root. The first page is loaded right away unless
  /// [loadImmediately] is false.
  CloudBrowserController({
    required this.provider,
    this.upcloud,
    this.accountId,
    this.pageSize = 50,
    List<CloudBreadcrumb>? initialPath,
    bool loadImmediately = true,
  }) : assert(
         (upcloud == null) == (accountId == null),
         'Pass both upcloud and accountId, or neither of them',
       ),
       assert(pageSize > 0, 'pageSize must be positive'),
       _state = CloudBrowserState(path: _normalizePath(initialPath)) {
    if (loadImmediately) unawaited(refresh());
  }

  /// Creates a controller for account [accountId] of [upcloud], with
  /// uploads enabled.
  factory CloudBrowserController.forAccount(
    UpCloud upcloud,
    String accountId, {
    int pageSize = 50,
    List<CloudBreadcrumb>? initialPath,
    bool loadImmediately = true,
  }) => CloudBrowserController(
    provider: upcloud.connect(accountId),
    upcloud: upcloud,
    accountId: accountId,
    pageSize: pageSize,
    initialPath: initialPath,
    loadImmediately: loadImmediately,
  );

  /// Provider being browsed.
  final CloudProvider provider;

  /// Instance used to queue uploads, if any.
  final UpCloud? upcloud;

  /// Account of [provider] inside [upcloud], if any.
  final String? accountId;

  /// Number of entries requested per page.
  final int pageSize;

  CloudBrowserState _state;
  PageRequest _nextPage = PageRequest.first;
  var _generation = 0;
  var _busyActions = 0;
  var _disposed = false;
  final _uploadSubscriptions = <StreamSubscription<TransferState>>{};

  /// Current state.
  CloudBrowserState get state => _state;

  // ---------------------------------------------------------------------------
  // Capabilities
  // ---------------------------------------------------------------------------

  /// Whether the provider can list folders.
  bool get canBrowse =>
      provider is FolderBrowsing && provider.supports(Capability.browseFolders);

  /// Whether folders can be created.
  bool get canCreateFolder =>
      provider is FolderManaging && provider.supports(Capability.createFolder);

  /// Whether the provider can search files.
  bool get canSearch =>
      provider is FileSearching && provider.supports(Capability.search);

  /// Whether files can be uploaded with [upload].
  bool get canUpload =>
      provider is FileUploading &&
      provider.supports(Capability.upload) &&
      upcloud != null;

  /// Whether files can be uploaded from a URL with [uploadFromUrl].
  bool get canRemoteUpload =>
      provider is RemoteUploading && provider.supports(Capability.remoteUpload);

  /// Whether [file] has a link to share ([CloudFile.pageUrl]).
  bool canShare(CloudFile file) => file.pageUrl != null;

  /// Whether [entry] can be renamed.
  bool canRename(CloudEntry entry) => _canManage(
    entry,
    file: Capability.renameFile,
    folder: Capability.renameFolder,
  );

  /// Whether [entry] can be deleted.
  bool canDelete(CloudEntry entry) => _canManage(
    entry,
    file: Capability.deleteFile,
    folder: Capability.deleteFolder,
  );

  /// Whether [entry] can be moved to another folder.
  bool canMove(CloudEntry entry) => _canManage(
    entry,
    file: Capability.moveFile,
    folder: Capability.moveFolder,
  );

  bool _canManage(
    CloudEntry entry, {
    required Capability file,
    required Capability folder,
  }) => switch (entry) {
    CloudFile() => provider is FileManaging && provider.supports(file),
    CloudFolder() => provider is FolderManaging && provider.supports(folder),
  };

  // ---------------------------------------------------------------------------
  // Navigation and loading
  // ---------------------------------------------------------------------------

  /// Reloads the first page of the current folder or search.
  ///
  /// Loaded entries stay visible until the new page arrives.
  Future<void> refresh() => _loadFirstPage(keepEntries: true);

  /// Opens [folder], a child of the current folder or search result.
  Future<void> openFolder(CloudFolder folder) =>
      openPath([..._state.path, CloudBreadcrumb.folder(folder)]);

  /// Opens the folder at the end of [path].
  ///
  /// The root breadcrumb is added when [path] does not start with it.
  Future<void> openPath(List<CloudBreadcrumb> path) {
    _state = _state.copyWith(
      path: _normalizePath(path),
      query: null,
      selection: const {},
    );
    return _loadFirstPage(keepEntries: false);
  }

  /// Opens [breadcrumb], one of the folders in [CloudBrowserState.path].
  ///
  /// Opening the current folder while searching closes the search.
  Future<void> goTo(CloudBreadcrumb breadcrumb) {
    final index = _state.path.indexOf(breadcrumb);
    if (index < 0) return Future.value();
    if (index == _state.path.length - 1 && !_state.isSearching) {
      return Future.value();
    }
    return openPath(_state.path.sublist(0, index + 1));
  }

  /// Whether [goUp] can open a parent folder.
  bool get canGoUp => !_state.isRoot;

  /// Opens the parent folder. Does nothing at the root.
  Future<void> goUp() {
    if (!canGoUp) return Future.value();
    return openPath(_state.path.sublist(0, _state.path.length - 1));
  }

  /// Loads the next page, if any. Ignored while another page is loading.
  Future<void> loadMore() async {
    final current = _state;
    if (!current.hasLoaded ||
        !current.hasMore ||
        current.isLoading ||
        current.isLoadingMore) {
      return;
    }
    final generation = _generation;
    _emit(current.copyWith(isLoadingMore: true, loadMoreError: null));
    try {
      final page = await _fetch(_nextPage);
      if (generation != _generation || _disposed) return;
      _nextPage = page.request.next;
      final known = {for (final e in _state.entries) e.selectionKey};
      final added = page.items.where((e) => known.add(e.selectionKey));
      _emit(
        _state.copyWith(
          entries: List.unmodifiable([..._state.entries, ...added]),
          isLoadingMore: false,
          hasMore: page.hasMore && page.items.isNotEmpty,
        ),
      );
    } on Object catch (e, st) {
      if (generation != _generation || _disposed) return;
      _emit(_state.copyWith(isLoadingMore: false, loadMoreError: _wrap(e, st)));
    }
  }

  /// Shows files matching [query] instead of the current folder.
  ///
  /// Requires [FileSearching]. By default the whole account is searched;
  /// set [inCurrentFolder] to limit it to the current folder. An empty
  /// query closes the search.
  Future<void> search(String query, {bool inCurrentFolder = false}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return clearSearch();
    _searchInFolder = inCurrentFolder;
    _state = _state.copyWith(query: trimmed, selection: const {});
    return _loadFirstPage(keepEntries: false);
  }

  var _searchInFolder = false;

  /// Closes the search and shows the current folder again.
  Future<void> clearSearch() {
    if (!_state.isSearching) return Future.value();
    _state = _state.copyWith(query: null, selection: const {});
    return _loadFirstPage(keepEntries: false);
  }

  Future<void> _loadFirstPage({required bool keepEntries}) async {
    final generation = ++_generation;
    final previous = _state;
    _emit(
      previous.copyWith(
        isLoading: true,
        isLoadingMore: false,
        error: null,
        loadMoreError: null,
        entries: keepEntries ? previous.entries : const [],
        hasLoaded: keepEntries && previous.hasLoaded,
        hasMore: keepEntries && previous.hasMore,
      ),
    );
    try {
      final page = await _fetch(PageRequest(perPage: pageSize));
      if (generation != _generation || _disposed) return;
      _nextPage = page.request.next;
      final keys = {for (final e in page.items) e.selectionKey};
      _emit(
        _state.copyWith(
          entries: List.unmodifiable(page.items),
          isLoading: false,
          hasLoaded: true,
          hasMore: page.hasMore && page.items.isNotEmpty,
          selection: _state.selection.intersection(keys),
        ),
      );
    } on Object catch (e, st) {
      if (generation != _generation || _disposed) return;
      _emit(_state.copyWith(isLoading: false, error: _wrap(e, st)));
    }
  }

  Future<_Page> _fetch(PageRequest request) async {
    final query = _state.query;
    final source = provider;
    if (query != null) {
      if (source is! FileSearching) {
        throw UnsupportedOperationException(
          '${provider.info.name} cannot search files',
        );
      }
      final result = await source.searchFiles(
        query,
        folderId: _searchInFolder ? _state.folderId : null,
        page: request,
      );
      return (items: result.items, hasMore: result.hasMore, request: request);
    }
    if (source is! FolderBrowsing) {
      throw UnsupportedOperationException(
        '${provider.info.name} cannot list folders',
      );
    }
    final result = await source.listFolder(_state.folderId, page: request);
    return (items: result.items, hasMore: result.hasMore, request: request);
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  /// Selects or deselects [entry].
  void toggleSelection(CloudEntry entry) =>
      setSelected(entry, selected: !_state.isSelected(entry));

  /// Selects or deselects [entry].
  void setSelected(CloudEntry entry, {required bool selected}) {
    final selection = {..._state.selection};
    final changed = selected
        ? selection.add(entry.selectionKey)
        : selection.remove(entry.selectionKey);
    if (changed) _emit(_state.copyWith(selection: selection));
  }

  /// Selects every loaded entry.
  void selectAll() => _emit(
    _state.copyWith(
      selection: {for (final e in _state.entries) e.selectionKey},
    ),
  );

  /// Deselects everything.
  void clearSelection() {
    if (_state.selection.isNotEmpty) {
      _emit(_state.copyWith(selection: const {}));
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Creates a folder called [name] in the current folder and adds it to
  /// the list. Requires [FolderManaging].
  Future<CloudFolder> createFolder(String name) => _runAction(() async {
    final manager = _require<FolderManaging>('create folders');
    final parentId = _state.folderId;
    final folder = await manager.createFolder(name.trim(), parentId: parentId);
    if (!_state.isSearching && _state.folderId == parentId) _insert(folder);
    return folder;
  });

  /// Renames [entry] to [name]. Requires [FileManaging] for files and
  /// [FolderManaging] for folders.
  Future<void> rename(CloudEntry entry, String name) => _runAction(() async {
    final newName = name.trim();
    switch (entry) {
      case CloudFile(:final id):
        await _require<FileManaging>('rename files').renameFile(id, newName);
      case CloudFolder(:final id):
        await _require<FolderManaging>('rename folders')
            .renameFolder(id, newName);
    }
    _update(entry.selectionKey, (e) => e.copyWith(name: newName));
  });

  /// Deletes [entries] and removes them from the list.
  ///
  /// Every entry is attempted; the first error is thrown at the end.
  Future<void> delete(Iterable<CloudEntry> entries) => _runAction(() async {
    final targets = entries.toList();
    final deleted = <String>{};
    UpCloudException? firstError;
    for (final entry in targets) {
      try {
        switch (entry) {
          case CloudFile(:final id):
            await _require<FileManaging>('delete files').deleteFile(id);
          case CloudFolder(:final id):
            await _require<FolderManaging>('delete folders').deleteFolder(id);
        }
        deleted.add(entry.selectionKey);
      } on UpCloudException catch (e) {
        firstError ??= e;
      }
    }
    _removeKeys(deleted);
    if (firstError != null) throw firstError;
  });

  /// Moves [entries] into [destination] (`null` is the root).
  ///
  /// Moved entries leave the list unless search results are shown.
  Future<void> move(Iterable<CloudEntry> entries, FolderId? destination) =>
      _runAction(() async {
        final targets = entries.toList();
        final moved = <String>{};
        UpCloudException? firstError;
        for (final entry in targets) {
          try {
            switch (entry) {
              case CloudFile(:final id):
                await _require<FileManaging>('move files')
                    .moveFile(id, destination);
              case CloudFolder(:final id):
                await _require<FolderManaging>('move folders')
                    .moveFolder(id, destination);
            }
            moved.add(entry.selectionKey);
          } on UpCloudException catch (e) {
            firstError ??= e;
          }
        }
        if (_state.isSearching) {
          for (final key in moved) {
            _update(
              key,
              (e) => switch (e) {
                CloudFile() => e.copyWith(folderId: destination),
                CloudFolder() => e.copyWith(parentId: destination),
              },
            );
          }
        } else if (destination != _state.folderId) {
          _removeKeys(moved);
        }
        if (firstError != null) throw firstError;
      });

  /// Asks the provider to fetch [url] into the current folder, optionally
  /// saving it as [name].
  ///
  /// Requires [RemoteUploading]. The listing is refreshed when the provider
  /// completes the job immediately.
  Future<RemoteUploadJob> uploadFromUrl(Uri url, {String? name}) =>
      _runAction(() async {
        final remote = _require<RemoteUploading>('upload from URLs');
        final folderId = _state.folderId;
        final job = await remote.uploadFromUrl(
          url,
          options: UploadOptions(folderId: folderId, title: name),
        );
        if (job.status == RemoteUploadStatus.completed &&
            !_disposed &&
            _state.folderId == folderId) {
          unawaited(refresh());
        }
        return job;
      });

  /// Queues the upload of [sources] into the current folder.
  ///
  /// Requires [upcloud], [accountId] and [FileUploading]. Uploaded files are
  /// added to the list when they finish.
  List<UploadTask> upload(
    List<UploadSource> sources, {
    UploadOptions options = const UploadOptions(),
  }) {
    final upcloud = _upcloudOrThrow();
    _require<FileUploading>('upload files');
    final folderId = _state.folderId;
    final tasks = [
      for (final source in sources)
        upcloud.upload(
          accountId!,
          source,
          options: options.copyWith(folderId: folderId),
        ),
    ];
    for (final task in tasks) {
      _watchUpload(task, folderId);
    }
    return tasks;
  }

  void _watchUpload(UploadTask task, FolderId? folderId) {
    late final StreamSubscription<TransferState> subscription;
    subscription = task.changes.listen((state) {
      if (state is! TransferCompleted) return;
      task.result.then((file) => _onUploaded(file, folderId)).ignore();
    }, onDone: () => _uploadSubscriptions.remove(subscription));
    _uploadSubscriptions.add(subscription);
  }

  void _onUploaded(CloudFile file, FolderId? folderId) {
    if (_disposed || _state.isSearching || _state.folderId != folderId) {
      return;
    }
    _insert(file);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<T> _runAction<T>(Future<T> Function() action) async {
    _busyActions++;
    _emit(_state.copyWith(isBusy: true, actionError: null));
    try {
      final result = await action();
      _busyActions--;
      _emit(_state.copyWith(isBusy: _busyActions > 0));
      return result;
    } on Object catch (e, st) {
      _busyActions--;
      final error = _wrap(e, st);
      _emit(_state.copyWith(isBusy: _busyActions > 0, actionError: error));
      if (e is UpCloudException) rethrow;
      Error.throwWithStackTrace(error, st);
    }
  }

  T _require<T extends CloudProvider>(String action) {
    final self = provider;
    if (self is T) return self;
    throw UnsupportedOperationException('${provider.info.name} cannot $action');
  }

  UpCloud _upcloudOrThrow() {
    final upcloud = this.upcloud;
    if (upcloud == null) {
      throw const UnsupportedOperationException(
        'Transfers need a controller created with an UpCloud and accountId',
      );
    }
    return upcloud;
  }

  /// Inserts [entry] after the last folder (folders) or before the first
  /// file (files), unless it is already listed.
  void _insert(CloudEntry entry) {
    final entries = [..._state.entries];
    if (entries.any((e) => e.selectionKey == entry.selectionKey)) return;
    final lastFolder = entries.lastIndexWhere((e) => e is CloudFolder);
    entries.insert(lastFolder + 1, entry);
    _emit(
      _state.copyWith(entries: List.unmodifiable(entries), hasLoaded: true),
    );
  }

  void _update(String key, CloudEntry Function(CloudEntry entry) change) {
    _emit(
      _state.copyWith(
        entries: List.unmodifiable([
          for (final e in _state.entries)
            if (e.selectionKey == key) change(e) else e,
        ]),
      ),
    );
  }

  void _removeKeys(Set<String> keys) {
    if (keys.isEmpty) return;
    _emit(
      _state.copyWith(
        entries: List.unmodifiable(
          _state.entries.where((e) => !keys.contains(e.selectionKey)),
        ),
        selection: _state.selection.difference(keys),
      ),
    );
  }

  UpCloudException _wrap(Object error, StackTrace stackTrace) =>
      error is UpCloudException
      ? error
      : ProviderException('$error', cause: error, stackTrace: stackTrace);

  void _emit(CloudBrowserState state) {
    _state = state;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _uploadSubscriptions) {
      unawaited(subscription.cancel());
    }
    _uploadSubscriptions.clear();
    super.dispose();
  }
}

typedef _Page = ({List<CloudEntry> items, bool hasMore, PageRequest request});

List<CloudBreadcrumb> _normalizePath(List<CloudBreadcrumb>? path) =>
    List.unmodifiable(
      path == null || path.isEmpty
          ? const [CloudBreadcrumb.root]
          : path.first.isRoot
          ? path
          : [CloudBreadcrumb.root, ...path],
    );
