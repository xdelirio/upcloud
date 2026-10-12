import 'package:flutter/material.dart';
import 'package:upcloud/src/controllers/transfers_controller.dart';
import 'package:upcloud/src/controllers/transfers_state.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/theme/upcloud_theme.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/src/widgets/transfers/transfer_tile.dart';
import 'package:upcloud/upcloud.dart';

/// Builds a custom row of a [TransferList].
typedef TransferEntryWidgetBuilder = Widget Function(
  BuildContext context,
  TransferEntry entry,
  TransfersController controller,
);

/// A scrollable list of uploads with live progress.
///
/// Uploads of the same batch (`UpCloud.uploadBatch`) are grouped under a
/// [TransferBatchHeader] with the overall progress and batch actions
/// (cancel, retry failed, clear); set [groupBatches] to false to list them
/// one by one. Other uploads are listed as [TransferTile]s.
///
/// Uses [controller], or creates one for the transfers of the
/// [UpCloudScope] above.
class TransferList extends StatefulWidget {
  /// Creates a transfer list.
  const TransferList({
    this.controller,
    this.newestFirst = true,
    this.showSpeed = true,
    this.groupBatches = true,
    this.subtitleBuilder,
    this.itemBuilder,
    this.emptyBuilder,
    this.padding,
    super.key,
  });

  /// Controller to use. When `null`, one is created from [UpCloudScope].
  final TransfersController? controller;

  /// Whether to show the latest transfers (and batches) at the top.
  final bool newestFirst;

  /// Whether tiles show the transfer speed.
  final bool showSpeed;

  /// Whether uploads of the same batch are grouped under a header.
  final bool groupBatches;

  /// Secondary text of each tile. Defaults to the account label when an
  /// [UpCloudScope] is available.
  final String? Function(UploadTask task)? subtitleBuilder;

  /// Replaces the default [TransferTile].
  final TransferEntryWidgetBuilder? itemBuilder;

  /// Replaces the empty view.
  final WidgetBuilder? emptyBuilder;

  /// Padding of the list.
  final EdgeInsetsGeometry? padding;

  @override
  State<TransferList> createState() => _TransferListState();
}

/// A row of a [TransferList]: one upload or one batch.
sealed class _Row {
  const _Row();
}

final class _TaskRow extends _Row {
  const _TaskRow(this.entry);

  final TransferEntry entry;
}

final class _BatchRow extends _Row {
  const _BatchRow(this.batch);

  final TransferBatchEntry batch;
}

class _TransferListState extends State<TransferList> {
  TransfersController? _internal;
  UpCloud? _internalUpcloud;
  final _collapsed = <String>{};

  TransfersController get _controller => widget.controller ?? _internal!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureController();
  }

  @override
  void didUpdateWidget(TransferList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureController();
  }

  void _ensureController() {
    if (widget.controller != null) {
      _disposeInternal();
      return;
    }
    final upcloud = UpCloudScope.of(context);
    if (_internal != null && _internalUpcloud == upcloud) return;
    _disposeInternal();
    _internalUpcloud = upcloud;
    _internal = TransfersController(upcloud.transfers);
  }

  void _disposeInternal() {
    _internal?.dispose();
    _internal = null;
    _internalUpcloud = null;
  }

  @override
  void dispose() {
    _disposeInternal();
    super.dispose();
  }

  List<_Row> _rows(TransfersState state) {
    final entries = state.entries;
    if (!widget.groupBatches) {
      final rows = [for (final e in entries) _TaskRow(e)];
      return widget.newestFirst ? rows.reversed.toList() : rows;
    }
    final batches = {for (final b in state.batches) b.id: b};
    final seen = <String>{};
    final rows = <_Row>[];
    // A batch takes the place of its oldest upload.
    for (final entry in entries) {
      final batchId = entry.batchId;
      if (batchId == null) {
        rows.add(_TaskRow(entry));
      } else if (seen.add(batchId)) {
        rows.add(_BatchRow(batches[batchId]!));
      }
    }
    return widget.newestFirst ? rows.reversed.toList() : rows;
  }

  Widget _tile(
    BuildContext context,
    TransferEntry entry,
    String? Function(UploadTask task) subtitleBuilder,
  ) {
    final custom = widget.itemBuilder;
    if (custom != null) return custom(context, entry, _controller);
    return TransferTile(
      key: ValueKey(entry.id),
      task: entry.task,
      state: entry.state,
      attempt: entry.attempt,
      maxRetries: _controller.maxRetries,
      bytesPerSecond: entry.bytesPerSecond,
      showSpeed: widget.showSpeed,
      subtitle: subtitleBuilder(entry.task),
      onCancel: () => _controller.cancel(entry.task),
      onRetry: () => _controller.retry(entry.task),
      onRemove: () => _controller.remove(entry.task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcloud = UpCloudScope.maybeOf(context);
    final subtitleBuilder =
        widget.subtitleBuilder ??
        (UploadTask task) => upcloud?.account(task.accountId)?.label;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        if (state.entries.isEmpty) {
          return widget.emptyBuilder?.call(context) ??
              MessageView(
                icon: Icons.swap_vert_rounded,
                title: UpCloudLocalizations.of(context).noTransfers,
              );
        }
        final rows = _rows(state);
        return ListView.separated(
          padding: widget.padding,
          itemCount: rows.length,
          separatorBuilder: (context, index) =>
              rows[index] is _TaskRow && rows[index + 1] is _TaskRow
              ? const Divider(height: 1)
              : const SizedBox.shrink(),
          itemBuilder: (context, index) => switch (rows[index]) {
            _TaskRow(:final entry) => _tile(context, entry, subtitleBuilder),
            _BatchRow(:final batch) => _BatchGroup(
              key: ValueKey('batch-${batch.id}'),
              batch: batch,
              controller: _controller,
              expanded: !_collapsed.contains(batch.id),
              onExpandedChanged: (expanded) => setState(() {
                if (expanded) {
                  _collapsed.remove(batch.id);
                } else {
                  _collapsed.add(batch.id);
                }
              }),
              tileBuilder: (context, entry) =>
                  _tile(context, entry, subtitleBuilder),
            ),
          },
        );
      },
    );
  }
}

class _BatchGroup extends StatelessWidget {
  const _BatchGroup({
    required this.batch,
    required this.controller,
    required this.expanded,
    required this.onExpandedChanged,
    required this.tileBuilder,
    super.key,
  });

  final TransferBatchEntry batch;
  final TransfersController controller;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final Widget Function(BuildContext context, TransferEntry entry) tileBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = UpCloudTheme.of(context).borderRadius;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Material(
        // Like the cards of the app, e.g. `UpCloudSection`.
        color: theme.cardTheme.color ?? scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TransferBatchHeader(
              batch: batch,
              expanded: expanded,
              onExpandedChanged: onExpandedChanged,
              onCancel: () => controller.cancelBatch(batch.id),
              onRetryFailed: () => controller.retryFailed(batch.id),
              onClear: () => controller.clearBatch(batch.id),
            ),
            if (expanded)
              for (final entry in batch.entries) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                tileBuilder(context, entry),
              ],
          ],
        ),
      ),
    );
  }
}

/// Header of a batch of uploads in a [TransferList]: files and accounts,
/// destination folder, overall progress, counts and batch actions.
///
/// Actions are shown only when their callback is set and they make sense:
/// cancel while uploads are active, retry when some failed, clear when some
/// finished.
class TransferBatchHeader extends StatelessWidget {
  /// Creates a header for [batch].
  const TransferBatchHeader({
    required this.batch,
    this.expanded,
    this.onExpandedChanged,
    this.onCancel,
    this.onRetryFailed,
    this.onClear,
    super.key,
  });

  /// The batch to describe.
  final TransferBatchEntry batch;

  /// Whether the uploads of the batch are shown below; `null` hides the
  /// expand button.
  final bool? expanded;

  /// Called by the expand button.
  final ValueChanged<bool>? onExpandedChanged;

  /// Cancels the active uploads of the batch.
  final VoidCallback? onCancel;

  /// Queues the failed uploads of the batch again.
  final VoidCallback? onRetryFailed;

  /// Removes the finished uploads of the batch.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final upTheme = UpCloudTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final folderPath = batch.folderPath;
    final progress = batch.progress;
    final failed = batch.failedCount;
    final cancelled = batch.cancelledCount;
    final (IconData icon, Color color) = !batch.isFinished
        ? (Icons.cloud_upload_rounded, scheme.primary)
        : failed > 0
        ? (Icons.error_rounded, scheme.error)
        : batch.completedCount == 0
        ? (Icons.cancel_rounded, scheme.outline)
        : (Icons.check_circle_rounded, upTheme.successColor);
    final status = [
      l10n.batchDone(batch.finishedCount, batch.entries.length),
      if (failed > 0) l10n.batchFailedCount(failed),
      if (cancelled > 0) l10n.batchCancelledCount(cancelled),
      if (!batch.isFinished) '${(progress * 100).floor()} %',
    ].join(' · ');
    final expanded = this.expanded;
    final onExpandedChanged = this.onExpandedChanged;

    const dense = VisualDensity.compact;
    final actions = <Widget>[
      if (!batch.isFinished && onCancel != null)
        IconButton(
          key: ValueKey('upcloud-batch-cancel-${batch.id}'),
          visualDensity: dense,
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.cancelAll,
          onPressed: onCancel,
        ),
      if (failed > 0 && onRetryFailed != null)
        IconButton(
          key: ValueKey('upcloud-batch-retry-${batch.id}'),
          visualDensity: dense,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: l10n.retryFailed,
          onPressed: onRetryFailed,
        ),
      if (batch.finishedCount > 0 && onClear != null)
        IconButton(
          key: ValueKey('upcloud-batch-clear-${batch.id}'),
          visualDensity: dense,
          icon: const Icon(Icons.clear_all_rounded),
          tooltip: l10n.clear,
          onPressed: onClear,
        ),
    ];
    final extent = upTheme.thumbnailSize;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: extent,
                height: extent,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(extent / 4),
                ),
                child: Icon(icon, color: color, size: extent * 0.6),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.batchTitle(batch.fileCount, batch.accountCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (folderPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 16,
                              color: upTheme.folderColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                folderPath.isEmpty
                                    ? l10n.rootFolder
                                    : folderPath,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (expanded != null && onExpandedChanged != null)
                IconButton(
                  key: ValueKey('upcloud-batch-expand-${batch.id}'),
                  icon: Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  tooltip: expanded
                      ? MaterialLocalizations.of(context).collapsedIconTapHint
                      : MaterialLocalizations.of(context).expandedIconTapHint,
                  onPressed: () => onExpandedChanged(!expanded),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: extent + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!batch.isFinished)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8, end: 8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: upTheme.progressHeight,
                      borderRadius: BorderRadius.circular(
                        upTheme.progressHeight,
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          status,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: failed > 0
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
