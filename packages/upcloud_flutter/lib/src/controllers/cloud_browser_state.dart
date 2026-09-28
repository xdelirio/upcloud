import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/utils/file_kind.dart';

part 'cloud_browser_state.freezed.dart';

/// A folder in the path shown by a `CloudBrowserController`.
@freezed
abstract class CloudBreadcrumb with _$CloudBreadcrumb {
  /// Creates a breadcrumb for folder [id] (`null` is the root) called
  /// [name].
  const factory CloudBreadcrumb({
    FolderId? id,

    /// Folder name. Empty for the root, which widgets label themselves.
    @Default('') String name,
  }) = _CloudBreadcrumb;

  /// A breadcrumb pointing to [folder].
  factory CloudBreadcrumb.folder(CloudFolder folder) =>
      CloudBreadcrumb(id: folder.id, name: folder.name);

  const CloudBreadcrumb._();

  /// The root folder.
  static const root = CloudBreadcrumb();

  /// Whether this is the root folder.
  bool get isRoot => id == null;
}

/// Immutable state of a `CloudBrowserController`.
@freezed
abstract class CloudBrowserState with _$CloudBrowserState {
  /// Creates a browser state.
  const factory CloudBrowserState({
    /// Folders from the root to the current folder (never empty).
    @Default(<CloudBreadcrumb>[CloudBreadcrumb.root])
    List<CloudBreadcrumb> path,

    /// Loaded entries of the current folder or search.
    @Default(<CloudEntry>[]) List<CloudEntry> entries,

    /// Whether the first page is loading (initial load or refresh).
    @Default(false) bool isLoading,

    /// Whether the next page is loading.
    @Default(false) bool isLoadingMore,

    /// Whether [entries] reflect a completed load of the current listing.
    @Default(false) bool hasLoaded,

    /// Whether another page can be loaded with `loadMore`.
    @Default(false) bool hasMore,

    /// Why the first page could not be loaded.
    UpCloudException? error,

    /// Why the last `loadMore` failed.
    UpCloudException? loadMoreError,

    /// Whether an action (create, rename, delete...) is running.
    @Default(false) bool isBusy,

    /// Error of the last failed action.
    UpCloudException? actionError,

    /// Selection keys (see `CloudEntryUi.selectionKey`) of selected entries.
    @Default(<String>{}) Set<String> selection,

    /// Active search query, `null` when browsing folders.
    String? query,
  }) = _CloudBrowserState;

  const CloudBrowserState._();

  /// The folder being shown.
  CloudBreadcrumb get current => path.last;

  /// Id of the folder being shown, `null` for the root.
  FolderId? get folderId => current.id;

  /// Whether the root folder is shown.
  bool get isRoot => path.length <= 1;

  /// Whether search results are shown instead of a folder.
  bool get isSearching => query != null;

  /// Whether at least one entry is selected.
  bool get isSelecting => selection.isNotEmpty;

  /// Selected entries, in list order.
  List<CloudEntry> get selectedEntries => [
    for (final entry in entries)
      if (selection.contains(entry.selectionKey)) entry,
  ];

  /// Whether [entry] is selected.
  bool isSelected(CloudEntry entry) => selection.contains(entry.selectionKey);

  /// Whether the listing finished loading and has no entries.
  bool get isEmpty => hasLoaded && !isLoading && entries.isEmpty;
}
