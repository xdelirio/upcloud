import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/src/controllers/cloud_browser_controller.dart';
import 'package:upcloud/src/controllers/cloud_browser_state.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/widgets/browser/cloud_breadcrumbs.dart';
import 'package:upcloud/src/widgets/browser/cloud_entry_tile.dart';
import 'package:upcloud/upcloud.dart';

/// Lets the user browse the folders of [provider] and pick one.
///
/// Returns the breadcrumb of the chosen folder (its `id` is `null` for the
/// root), or `null` when cancelled. Folders in [excluded] are hidden, e.g.
/// the folders being moved.
Future<CloudBreadcrumb?> showCloudFolderPicker(
  BuildContext context, {
  required CloudProvider provider,
  List<CloudBreadcrumb>? initialPath,
  Set<FolderId> excluded = const {},
}) => showDialog<CloudBreadcrumb>(
  context: context,
  builder: (context) => _FolderPickerDialog(
    provider: provider,
    initialPath: initialPath,
    excluded: excluded,
  ),
);

class _FolderPickerDialog extends StatefulWidget {
  const _FolderPickerDialog({
    required this.provider,
    required this.initialPath,
    required this.excluded,
  });

  final CloudProvider provider;
  final List<CloudBreadcrumb>? initialPath;
  final Set<FolderId> excluded;

  @override
  State<_FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends State<_FolderPickerDialog> {
  late final _controller = CloudBrowserController(
    provider: widget.provider,
    initialPath: widget.initialPath,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final folders = [
          for (final entry in state.entries)
            if (entry case final CloudFolder folder
                when !widget.excluded.contains(folder.id))
              folder,
        ];
        return AlertDialog(
          title: Text(l10n.moveTo),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          content: SizedBox(
            width: 420,
            height: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CloudBreadcrumbs(
                      path: state.path,
                      onSelected: _controller.goTo,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _buildBody(context, state, folders)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: state.error == null
                  ? () => Navigator.of(context).pop(state.current)
                  : null,
              child: Text(l10n.moveHere),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CloudBrowserState state,
    List<CloudFolder> folders,
  ) {
    final l10n = UpCloudLocalizations.of(context);
    if (state.error case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorMessage(error), textAlign: TextAlign.center),
              TextButton(
                onPressed: _controller.refresh,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (state.isLoading && state.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: folders.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= folders.length) {
          if (state.loadMoreError != null) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text(l10n.loadMoreFailed)),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => unawaited(_controller.loadMore()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          if (!state.isLoadingMore) {
            scheduleMicrotask(() => unawaited(_controller.loadMore()));
          }
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final folder = folders[index];
        return CloudEntryTile(
          entry: folder,
          onTap: () => unawaited(_controller.openFolder(folder)),
        );
      },
    );
  }
}
