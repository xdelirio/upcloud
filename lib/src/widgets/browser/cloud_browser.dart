import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upcloud/src/controllers/cloud_browser_controller.dart';
import 'package:upcloud/src/controllers/cloud_browser_state.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/theme/upcloud_theme.dart';
import 'package:upcloud/src/utils/file_kind.dart';
import 'package:upcloud/src/widgets/browser/cloud_breadcrumbs.dart';
import 'package:upcloud/src/widgets/browser/cloud_entry_tile.dart';
import 'package:upcloud/src/widgets/browser/folder_picker_dialog.dart';
import 'package:upcloud/src/widgets/common/dialogs.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/upcloud.dart';

/// Returns the files to upload, e.g. using a file picker. An empty list
/// cancels the upload.
typedef PickUploadSources = Future<List<UploadSource>> Function();

/// Builds a custom widget for an entry of a [CloudBrowser].
typedef CloudEntryWidgetBuilder = Widget Function(
  BuildContext context,
  CloudEntryItem item,
);

/// Builds the error state of a [CloudBrowser].
typedef CloudBrowserErrorBuilder = Widget Function(
  BuildContext context,
  UpCloudException error,
  VoidCallback retry,
);

/// An extra action shown in the "New" menu of a [CloudBrowser].
@immutable
class CloudBrowserAction {
  /// Creates an action.
  const CloudBrowserAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// Icon of the menu item.
  final IconData icon;

  /// Text of the menu item.
  final String label;

  /// Called when the item is selected.
  final void Function(BuildContext context, CloudBrowserController controller)
  onPressed;
}

/// An action that can run on a [CloudEntry].
@immutable
class CloudEntryAction {
  /// Creates an entry action.
  const CloudEntryAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.isDestructive = false,
  });

  /// Icon of the menu item.
  final IconData icon;

  /// Text of the menu item.
  final String label;

  /// Called with the entry when the item is selected.
  final void Function(BuildContext context, CloudEntry entry) onSelected;

  /// Whether the action deletes data (shown in the error color).
  final bool isDestructive;
}

/// Everything needed to build an entry of a [CloudBrowser].
@immutable
class CloudEntryItem {
  /// Creates the item data.
  const CloudEntryItem({
    required this.entry,
    required this.layout,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.actions,
    this.menuButton,
  });

  /// The entry to show.
  final CloudEntry entry;

  /// Current layout of the browser.
  final CloudEntryLayout layout;

  /// Whether the entry is selected.
  final bool isSelected;

  /// Whether the browser is in selection mode.
  final bool selectionMode;

  /// Default tap behavior (open folder, toggle selection, file actions).
  final VoidCallback onTap;

  /// Default long-press behavior (toggle selection), if enabled.
  final VoidCallback? onLongPress;

  /// Actions available for the entry.
  final List<CloudEntryAction> actions;

  /// Default popup menu with [actions], `null` when there are none.
  final Widget? menuButton;
}

/// A file manager view of one account: breadcrumbs, pull-to-refresh,
/// infinite scroll, list and grid layouts, multi-selection and actions.
///
/// Actions are only offered when the provider supports them:
///
/// * create folder, rename, move and delete (`FolderManaging`,
///   `FileManaging`);
/// * search (`FileSearching`);
/// * copy the file link ([CloudFile.pageUrl]);
/// * upload from a URL (`RemoteUploading`);
/// * upload files, when [onPickFiles] is set (`FileUploading`).
///
/// Pass either a [controller] or an [accountId] resolved with the
/// [UpCloudScope] above:
///
/// ```dart
/// CloudBrowser(
///   accountId: account.id,
///   onPickFiles: pickFiles,
/// )
/// ```
///
/// Feedback is shown with the closest `ScaffoldMessenger`.
class CloudBrowser extends StatefulWidget {
  /// Creates a browser.
  const CloudBrowser({
    this.controller,
    this.accountId,
    this.pageSize = 50,
    this.onPickFiles,
    this.onFileTap,
    this.layout = CloudEntryLayout.list,
    this.showToolbar = true,
    this.enableSelection = true,
    this.enableSearch = true,
    this.handleBackButton = true,
    this.actions = const [],
    this.entryActions,
    this.entryBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.padding,
    super.key,
  }) : assert(
         controller != null || accountId != null,
         'Pass a controller or an accountId',
       );

  /// Controller to use. When `null`, one is created for [accountId].
  final CloudBrowserController? controller;

  /// Account to browse when no [controller] is given.
  final String? accountId;

  /// Page size of the internal controller.
  final int pageSize;

  /// Picks files to upload. The upload action is hidden when `null`.
  final PickUploadSources? onPickFiles;

  /// Called when a file is tapped outside selection mode.
  ///
  /// Defaults to a bottom sheet with the file actions.
  final ValueChanged<CloudFile>? onFileTap;

  /// Initial layout. The toolbar lets the user switch it.
  final CloudEntryLayout layout;

  /// Whether to show breadcrumbs and actions above the entries.
  final bool showToolbar;

  /// Whether long-pressing an entry selects it.
  final bool enableSelection;

  /// Whether to offer search when the provider supports it.
  final bool enableSearch;

  /// Whether the system back button leaves selection, closes the search or
  /// opens the parent folder before leaving the route.
  final bool handleBackButton;

  /// Extra actions shown in the "New" menu.
  final List<CloudBrowserAction> actions;

  /// Extra actions for an entry, shown after the built-in ones.
  final List<CloudEntryAction> Function(CloudEntry entry)? entryActions;

  /// Replaces the default [CloudEntryTile].
  final CloudEntryWidgetBuilder? entryBuilder;

  /// Replaces the empty folder view.
  final WidgetBuilder? emptyBuilder;

  /// Replaces the error view shown when the folder cannot be loaded.
  final CloudBrowserErrorBuilder? errorBuilder;

  /// Replaces the initial loading indicator.
  final WidgetBuilder? loadingBuilder;

  /// Padding around the entries, below the toolbar. Use it to keep the
  /// last entries clear of floating widgets, e.g. a bottom navigation bar
  /// drawn over the browser.
  final EdgeInsetsGeometry? padding;

  @override
  State<CloudBrowser> createState() => _CloudBrowserState();
}

class _CloudBrowserState extends State<CloudBrowser> {
  CloudBrowserController? _internal;
  UpCloud? _internalUpcloud;
  late CloudEntryLayout _layout = widget.layout;
  var _searchOpen = false;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  var _loadMoreScheduled = false;

  /// Distance to the end of the list that triggers loading the next page.
  static const _loadMoreThreshold = 600.0;

  CloudBrowserController get _controller => widget.controller ?? _internal!;

  UpCloudLocalizations get _l10n => UpCloudLocalizations.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureController();
  }

  @override
  void didUpdateWidget(CloudBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null) {
      _disposeInternal();
    } else if (oldWidget.accountId != widget.accountId ||
        oldWidget.pageSize != widget.pageSize) {
      _disposeInternal();
      _ensureController();
    } else {
      _ensureController();
    }
    if (oldWidget.controller != widget.controller ||
        oldWidget.accountId != widget.accountId) {
      _searchOpen = false;
      _searchController.clear();
    }
  }

  void _ensureController() {
    if (widget.controller != null) return;
    final upcloud = UpCloudScope.of(context);
    if (_internal != null && _internalUpcloud == upcloud) return;
    _disposeInternal();
    _internalUpcloud = upcloud;
    _internal = CloudBrowserController.forAccount(
      upcloud,
      widget.accountId!,
      pageSize: widget.pageSize,
    );
  }

  void _disposeInternal() {
    _internal?.dispose();
    _internal = null;
    _internalUpcloud = null;
  }

  @override
  void dispose() {
    _disposeInternal();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        if (_canLoadMore(state)) _scheduleLoadMoreCheck();
        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showToolbar) _buildToolbar(context, state),
            SizedBox(
              height: 2,
              child: state.isBusy || (state.isLoading && state.hasLoaded)
                  ? const LinearProgressIndicator(minHeight: 2)
                  : null,
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
        if (widget.handleBackButton) {
          final canPop =
              !state.isSelecting &&
              !_searchOpen &&
              !state.isSearching &&
              !_controller.canGoUp;
          content = PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _handleBack();
            },
            child: content,
          );
        }
        return content;
      },
    );
  }

  bool _canLoadMore(CloudBrowserState state) =>
      state.hasMore &&
      !state.isLoading &&
      !state.isLoadingMore &&
      state.loadMoreError == null;

  /// Checks after layout whether the end of the list is close, which also
  /// covers pages that do not fill the viewport.
  void _scheduleLoadMoreCheck() {
    if (_loadMoreScheduled) return;
    _loadMoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreScheduled = false;
      if (!mounted || _scrollController.positions.length != 1) return;
      final position = _scrollController.position;
      if (position.hasContentDimensions) _loadMoreIfNearEnd(position);
    });
  }

  void _loadMoreIfNearEnd(ScrollMetrics metrics) {
    if (metrics.extentAfter < _loadMoreThreshold &&
        _canLoadMore(_controller.state)) {
      unawaited(_controller.loadMore());
    }
  }

  void _handleBack() {
    final state = _controller.state;
    if (state.isSelecting) {
      _controller.clearSelection();
    } else if (_searchOpen || state.isSearching) {
      _closeSearch();
    } else if (_controller.canGoUp) {
      unawaited(_controller.goUp());
    }
  }

  Widget _buildToolbar(BuildContext context, CloudBrowserState state) {
    final scheme = Theme.of(context).colorScheme;
    final Widget bar;
    if (state.isSelecting) {
      bar = _buildSelectionBar(context, state);
    } else if (_searchOpen) {
      bar = _buildSearchBar(context, state);
    } else {
      bar = _buildMainBar(context, state);
    }
    return Material(
      color: state.isSelecting
          ? scheme.secondaryContainer
          : scheme.surfaceContainerLow,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: bar,
        ),
      ),
    );
  }

  Widget _buildMainBar(BuildContext context, CloudBrowserState state) {
    final l10n = _l10n;
    final addItems = _addMenuItems(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 520;
        final layoutButton = _layout == CloudEntryLayout.list
            ? (Icons.grid_view_rounded, l10n.gridView)
            : (Icons.view_list_rounded, l10n.listView);
        return Row(
          children: [
            if (_controller.canGoUp)
              IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                tooltip: l10n.goUp,
                onPressed: () => unawaited(_controller.goUp()),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CloudBreadcrumbs(
                  path: state.path,
                  onSelected: (crumb) => unawaited(_controller.goTo(crumb)),
                ),
              ),
            ),
            if (widget.enableSearch && _controller.canSearch)
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: l10n.search,
                onPressed: () => setState(() => _searchOpen = true),
              ),
            if (wide) ...[
              IconButton(
                icon: Icon(layoutButton.$1),
                tooltip: layoutButton.$2,
                onPressed: _toggleLayout,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: l10n.refresh,
                onPressed: () => unawaited(_controller.refresh()),
              ),
            ],
            if (addItems.isNotEmpty)
              PopupMenuButton<VoidCallback>(
                icon: const Icon(Icons.add_rounded),
                tooltip: l10n.add,
                onSelected: (action) => action(),
                itemBuilder: (context) => addItems,
              ),
            if (!wide)
              PopupMenuButton<VoidCallback>(
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: l10n.moreActions,
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  _menuItem(layoutButton.$1, layoutButton.$2, _toggleLayout),
                  _menuItem(
                    Icons.refresh_rounded,
                    l10n.refresh,
                    () => unawaited(_controller.refresh()),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  List<PopupMenuEntry<VoidCallback>> _addMenuItems(BuildContext context) {
    final l10n = _l10n;
    return [
      if (_controller.canCreateFolder)
        _menuItem(
          Icons.create_new_folder_outlined,
          l10n.newFolder,
          () => unawaited(_createFolder()),
        ),
      if (_controller.canUpload && widget.onPickFiles != null)
        _menuItem(
          Icons.upload_file_rounded,
          l10n.uploadFiles,
          () => unawaited(_uploadFiles()),
        ),
      if (_controller.canRemoteUpload)
        _menuItem(
          Icons.add_link_rounded,
          l10n.uploadFromUrl,
          () => unawaited(_uploadFromUrl()),
        ),
      for (final action in widget.actions)
        _menuItem(
          action.icon,
          action.label,
          () => action.onPressed(context, _controller),
        ),
    ];
  }

  PopupMenuItem<VoidCallback> _menuItem(
    IconData icon,
    String label,
    VoidCallback onSelected, {
    Color? color,
  }) => PopupMenuItem<VoidCallback>(
    value: onSelected,
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: color == null ? null : TextStyle(color: color),
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchBar(BuildContext context, CloudBrowserState state) {
    final l10n = _l10n;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.closeSearch,
          onPressed: _closeSearch,
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              border: InputBorder.none,
            ),
            onSubmitted: (query) => unawaited(_controller.search(query)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: l10n.search,
          onPressed: () =>
              unawaited(_controller.search(_searchController.text)),
        ),
      ],
    );
  }

  void _closeSearch() {
    setState(() => _searchOpen = false);
    _searchController.clear();
    unawaited(_controller.clearSearch());
  }

  Widget _buildSelectionBar(BuildContext context, CloudBrowserState state) {
    final l10n = _l10n;
    final selected = state.selectedEntries;
    final canMove = selected.isNotEmpty && selected.every(_controller.canMove);
    final canDelete =
        selected.isNotEmpty && selected.every(_controller.canDelete);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.clearSelection,
          onPressed: _controller.clearSelection,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            l10n.selectedCount(state.selection.length),
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (state.selection.length < state.entries.length)
          IconButton(
            icon: const Icon(Icons.select_all_rounded),
            tooltip: l10n.selectAll,
            onPressed: _controller.selectAll,
          ),
        if (canMove)
          IconButton(
            icon: const Icon(Icons.drive_file_move_outline),
            tooltip: l10n.move,
            onPressed: () => unawaited(_move(selected)),
          ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.delete,
            onPressed: () => unawaited(_delete(selected)),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, CloudBrowserState state) {
    final error = state.error;
    if (state.isLoading && state.entries.isEmpty && error == null) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }
    final padding = widget.padding;
    // Empty and error views fill the viewport, inside the padding.
    Widget fill(Widget child) => SliverFillRemaining(
      hasScrollBody: false,
      child: padding == null ? child : Padding(padding: padding, child: child),
    );
    final List<Widget> slivers;
    if (error != null && state.entries.isEmpty) {
      slivers = [
        fill(
          widget.errorBuilder?.call(context, error, _retry) ??
              MessageView(
                icon: Icons.cloud_off_rounded,
                title: _l10n.loadFolderFailed,
                message: _l10n.errorMessage(error),
                isError: true,
                action: FilledButton.tonalIcon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(_l10n.retry),
                ),
              ),
        ),
      ];
    } else if (state.isEmpty) {
      final query = state.query;
      slivers = [
        fill(
          widget.emptyBuilder?.call(context) ??
              (query != null
                  ? MessageView(
                      icon: Icons.search_off_rounded,
                      title: _l10n.noSearchResults(query),
                    )
                  : MessageView(
                      icon: Icons.folder_open_rounded,
                      title: _l10n.emptyFolder,
                      message: _controller.canUpload
                          ? _l10n.emptyFolderHint
                          : null,
                    )),
        ),
      ];
    } else {
      final entries = [
        if (error != null)
          SliverToBoxAdapter(
            child: _InlineError(error: error, retry: _retry),
          ),
        _buildEntries(context, state),
        if (state.hasMore || state.isLoadingMore || state.loadMoreError != null)
          SliverToBoxAdapter(child: _buildFooter(context, state)),
      ];
      slivers = padding == null
          ? entries
          : [
              SliverPadding(
                padding: padding,
                sliver: SliverMainAxisGroup(slivers: entries),
              ),
            ];
    }
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              (notification is ScrollUpdateNotification ||
                  notification is ScrollEndNotification)) {
            _loadMoreIfNearEnd(notification.metrics);
          }
          return false;
        },
        child: CustomScrollView(
          key: ValueKey('${state.folderId?.value}|${state.query}'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: slivers,
        ),
      ),
    );
  }

  void _retry() => unawaited(_controller.refresh());

  Widget _buildEntries(BuildContext context, CloudBrowserState state) {
    final entries = state.entries;
    switch (_layout) {
      case CloudEntryLayout.list:
        return SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) =>
              _buildEntry(context, state, entries[index]),
        );
      case CloudEntryLayout.grid:
        final theme = UpCloudTheme.of(context);
        return SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: theme.gridMaxCrossAxisExtent,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _buildEntry(context, state, entries[index]),
          ),
        );
    }
  }

  Widget _buildFooter(BuildContext context, CloudBrowserState state) {
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(_l10n.loadMoreFailed)),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => unawaited(_controller.loadMore()),
              child: Text(_l10n.retry),
            ),
          ],
        ),
      );
    }
    if (!state.isLoadingMore) {
      // Pages load automatically near the end of the list; the button is a
      // fallback (e.g. for keyboard users).
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TextButton(
            onPressed: () => unawaited(_controller.loadMore()),
            child: Text(_l10n.loadMore),
          ),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _buildEntry(
    BuildContext context,
    CloudBrowserState state,
    CloudEntry entry,
  ) {
    final selectionMode = state.isSelecting;
    final isSelected = state.isSelected(entry);
    final actions = _actionsFor(entry);
    void onTap() {
      if (selectionMode) {
        _controller.toggleSelection(entry);
        return;
      }
      switch (entry) {
        case CloudFolder():
          unawaited(_controller.openFolder(entry));
        case CloudFile():
          if (widget.onFileTap case final onFileTap?) {
            onFileTap(entry);
          } else {
            unawaited(_showEntrySheet(entry, actions));
          }
      }
    }

    final onLongPress = widget.enableSelection
        ? () => _controller.toggleSelection(entry)
        : null;
    final menuButton = actions.isEmpty || selectionMode
        ? null
        : PopupMenuButton<CloudEntryAction>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: _l10n.moreActions,
            onSelected: (action) => action.onSelected(this.context, entry),
            itemBuilder: (context) => [
              for (final action in actions)
                PopupMenuItem(
                  value: action,
                  child: _ActionRow(action: action),
                ),
            ],
          );
    final item = CloudEntryItem(
      entry: entry,
      layout: _layout,
      isSelected: isSelected,
      selectionMode: selectionMode,
      onTap: onTap,
      onLongPress: onLongPress,
      actions: actions,
      menuButton: menuButton,
    );
    return widget.entryBuilder?.call(context, item) ??
        CloudEntryTile(
          key: ValueKey(entry.selectionKey),
          entry: entry,
          layout: _layout,
          selected: isSelected,
          selectionMode: selectionMode,
          onTap: onTap,
          onLongPress: onLongPress,
          trailing: menuButton,
        );
  }

  List<CloudEntryAction> _actionsFor(CloudEntry entry) {
    final l10n = _l10n;
    final controller = _controller;
    return [
      if (entry case final CloudFile file when controller.canShare(file))
        CloudEntryAction(
          icon: Icons.link_rounded,
          label: l10n.copyLink,
          onSelected: (_, _) => unawaited(_copyLink(file)),
        ),
      if (controller.canRename(entry))
        CloudEntryAction(
          icon: Icons.drive_file_rename_outline_rounded,
          label: l10n.rename,
          onSelected: (_, _) => unawaited(_rename(entry)),
        ),
      if (controller.canMove(entry))
        CloudEntryAction(
          icon: Icons.drive_file_move_outline,
          label: l10n.move,
          onSelected: (_, _) => unawaited(_move([entry])),
        ),
      if (controller.canDelete(entry))
        CloudEntryAction(
          icon: Icons.delete_outline_rounded,
          label: l10n.delete,
          isDestructive: true,
          onSelected: (_, _) => unawaited(_delete([entry])),
        ),
      ...?widget.entryActions?.call(entry),
    ];
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _toggleLayout() => setState(() {
    _layout = _layout == CloudEntryLayout.list
        ? CloudEntryLayout.grid
        : CloudEntryLayout.list;
  });

  /// Runs [action] and reports [UpCloudException]s with a snack bar.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on UpCloudException catch (e) {
      if (mounted) _snack(_l10n.errorMessage(e), isError: true);
    }
  }

  void _snack(String message, {bool isError = false}) =>
      showUpCloudSnackBar(context, message, isError: isError);

  Future<void> _showEntrySheet(
    CloudEntry entry,
    List<CloudEntryAction> actions,
  ) async {
    final action = await showModalBottomSheet<CloudEntryAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CloudEntryIcon(entry: entry),
              title: Text(entry.name),
              subtitle: Text(describeEntry(context, entry)),
            ),
            if (actions.isNotEmpty) const Divider(),
            for (final action in actions)
              ListTile(
                leading: Icon(
                  action.icon,
                  color: action.isDestructive
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                title: Text(
                  action.label,
                  style: action.isDestructive
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
                ),
                onTap: () => Navigator.of(context).pop(action),
              ),
          ],
        ),
      ),
    );
    if (action != null && mounted) action.onSelected(context, entry);
  }

  Future<void> _createFolder() async {
    final name = await showTextInputDialog(
      context,
      title: _l10n.newFolder,
      label: _l10n.folderName,
      confirmLabel: _l10n.create,
    );
    if (name == null || !mounted) return;
    await _guard(() => _controller.createFolder(name));
  }

  Future<void> _rename(CloudEntry entry) async {
    final name = await showTextInputDialog(
      context,
      title: _l10n.rename,
      label: _l10n.name,
      confirmLabel: _l10n.rename,
      initialValue: entry.name,
    );
    if (name == null || name == entry.name || !mounted) return;
    await _guard(() => _controller.rename(entry, name));
  }

  Future<void> _delete(List<CloudEntry> entries) async {
    if (entries.isEmpty) return;
    final l10n = _l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteConfirmTitle(entries.length),
      message: entries.length == 1
          ? l10n.deleteConfirmMessage(entries.single.name)
          : l10n.deleteManyConfirmMessage(entries.length),
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _guard(() => _controller.delete(entries));
  }

  Future<void> _move(List<CloudEntry> entries) async {
    if (entries.isEmpty) return;
    final state = _controller.state;
    final destination = await showCloudFolderPicker(
      context,
      provider: _controller.provider,
      initialPath: state.isSearching ? null : state.path,
      excluded: {
        for (final entry in entries)
          if (entry case CloudFolder(:final id)) id,
      },
    );
    if (destination == null || !mounted) return;
    final target = destination.id;
    final pending = entries.where((entry) {
      final parent = switch (entry) {
        CloudFile(:final folderId) => folderId,
        CloudFolder(:final parentId) => parentId,
      };
      return parent != target;
    }).toList();
    if (pending.isEmpty) return;
    await _guard(() => _controller.move(pending, target));
    if (mounted) _controller.clearSelection();
  }

  Future<void> _copyLink(CloudFile file) async {
    final link = file.pageUrl;
    if (link == null) {
      _snack(_l10n.noLinks);
      return;
    }
    await Clipboard.setData(ClipboardData(text: link.toString()));
    if (mounted) _snack(_l10n.linkCopied);
  }

  Future<void> _uploadFiles() => _guard(() async {
    final pick = widget.onPickFiles;
    if (pick == null) return;
    final sources = await pick();
    if (sources.isEmpty || !mounted) return;
    final tasks = _controller.upload(sources);
    _snack(_l10n.uploadsQueued(tasks.length));
  });

  Future<void> _uploadFromUrl() async {
    final result = await showDialog<(Uri, String?)>(
      context: context,
      builder: (context) => const _RemoteUploadDialog(),
    );
    if (result == null || !mounted) return;
    await _guard(() async {
      await _controller.uploadFromUrl(result.$1, name: result.$2);
      if (mounted) _snack(_l10n.remoteUploadStarted);
    });
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final CloudEntryAction action;

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive
        ? Theme.of(context).colorScheme.error
        : null;
    return Row(
      children: [
        Icon(action.icon, color: color),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            action.label,
            style: color == null ? null : TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error, required this.retry});

  final UpCloudException error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.errorMessage(error),
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            TextButton(onPressed: retry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _RemoteUploadDialog extends StatefulWidget {
  const _RemoteUploadDialog();

  @override
  State<_RemoteUploadDialog> createState() => _RemoteUploadDialogState();
}

class _RemoteUploadDialogState extends State<_RemoteUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _url = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _name.text.trim();
    Navigator.of(context)
        .pop((parseHttpUrl(_url.text)!, name.isEmpty ? null : name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.uploadFromUrl),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _url,
                autofocus: true,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.url,
                  hintText: 'https://',
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
                validator: (value) =>
                    parseHttpUrl(value ?? '') == null ? l10n.invalidUrl : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.fileNameOptional),
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.upload)),
      ],
    );
  }
}
