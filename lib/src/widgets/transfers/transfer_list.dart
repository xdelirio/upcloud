import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:upcloud/src/controllers/transfers_controller.dart';
import 'package:upcloud/src/controllers/transfers_state.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/theme/upcloud_theme.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/src/widgets/common/tinted_icon_box.dart';
import 'package:upcloud/src/widgets/transfers/transfer_tile.dart';
import 'package:upcloud/upcloud.dart';

/// A scrollable list of uploads with live progress, newest first.
///
/// Uploads of the same batch (`UpCloud.uploadBatch`) are grouped under a
/// [TransferBatchHeader] with the overall progress and batch actions
/// (cancel, retry failed, clear); set [groupBatches] to false to list them
/// one by one. Other uploads are listed as [TransferTile]s, with the
/// account label as secondary text.
///
/// Uses [controller], or creates one for the transfers of the
/// [UpCloudScope] above.
class TransferList extends StatefulWidget {
  /// Creates a transfer list.
  const TransferList({
    this.controller,
    this.groupBatches = true,
    this.padding,
    super.key,
  });

  /// Controller to use. When `null`, one is created from [UpCloudScope].
  final TransfersController? controller;

  /// Whether uploads of the same batch are grouped under a header.
  final bool groupBatches;

  /// Padding of the list.
  final EdgeInsetsGeometry? padding;

  @override
  State<TransferList> createState() => _TransferListState();
}

/// A row of a [TransferList]: one upload, the header of a batch or one
/// upload of an expanded batch.
sealed class _Row {
  const _Row();
}

final class _TaskRow extends _Row {
  const _TaskRow(this.entry);

  final TransferEntry entry;
}

final class _BatchRow extends _Row {
  const _BatchRow(this.batch, {required this.expanded});

  final TransferBatchEntry batch;
  final bool expanded;

  /// Whether the card of the batch ends with this row.
  bool get isLast => !expanded || batch.entries.isEmpty;
}

final class _BatchTaskRow extends _Row {
  const _BatchTaskRow(this.entry, {required this.isLast});

  final TransferEntry entry;

  /// Whether the card of the batch ends with this row.
  final bool isLast;
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

  /// Rows of the list, newest first.
  List<_Row> _rows(TransfersState state) {
    final entries = state.entries;
    if (!widget.groupBatches) {
      return [for (final e in entries.reversed) _TaskRow(e)];
    }
    final batches = {for (final b in state.batches) b.id: b};
    final seen = <String>{};
    // Uploads and batches, oldest first: a batch takes the place of its
    // oldest upload.
    final items = <Object>[];
    for (final entry in entries) {
      final batchId = entry.batchId;
      if (batchId == null) {
        items.add(entry);
      } else if (seen.add(batchId)) {
        items.add(batches[batchId]!);
      }
    }
    final rows = <_Row>[];
    for (final item in items.reversed) {
      switch (item) {
        case TransferEntry():
          rows.add(_TaskRow(item));
        case TransferBatchEntry():
          // The uploads of a batch are rows of the list (oldest first), so
          // that they are built lazily like the others.
          final expanded = !_collapsed.contains(item.id);
          rows.add(_BatchRow(item, expanded: expanded));
          if (!expanded) continue;
          final last = item.entries.length - 1;
          for (final (index, entry) in item.entries.indexed) {
            rows.add(_BatchTaskRow(entry, isLast: index == last));
          }
      }
    }
    return rows;
  }

  Widget _tile(TransferEntry entry, UpCloud? upcloud) => TransferTile(
    key: ValueKey(entry.id),
    task: entry.task,
    state: entry.state,
    attempt: entry.attempt,
    maxRetries: _controller.maxRetries,
    bytesPerSecond: entry.bytesPerSecond,
    subtitle: upcloud?.account(entry.task.accountId)?.label,
    onCancel: () => _controller.cancel(entry.task),
    onRetry: () => _controller.retry(entry.task),
    onRemove: () => _controller.remove(entry.task),
  );

  void _setExpanded(String batchId, {required bool expanded}) => setState(() {
    if (expanded) {
      _collapsed.remove(batchId);
    } else {
      _collapsed.add(batchId);
    }
  });

  @override
  Widget build(BuildContext context) {
    final upcloud = UpCloudScope.maybeOf(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        if (state.entries.isEmpty) {
          return MessageView(
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
            _TaskRow(:final entry) => _tile(entry, upcloud),
            _BatchRow(:final batch, :final expanded, :final isLast) =>
              _BatchCardSlice(
                key: ValueKey('batch-${batch.id}'),
                isFirst: true,
                isLast: isLast,
                child: TransferBatchHeader(
                  batch: batch,
                  expanded: expanded,
                  onExpandedChanged: (expanded) =>
                      _setExpanded(batch.id, expanded: expanded),
                  onCancel: () => _controller.cancelBatch(batch.id),
                  onRetryFailed: () => _controller.retryFailed(batch.id),
                  onClear: () => _controller.clearBatch(batch.id),
                ),
              ),
            _BatchTaskRow(:final entry, :final isLast) => _BatchCardSlice(
              key: ValueKey('batch-task-${entry.id}'),
              isFirst: false,
              isLast: isLast,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _tile(entry, upcloud),
                ],
              ),
            ),
          },
        );
      },
    );
  }
}

/// One row of the card of a batch: the header ([isFirst]) or one of its
/// uploads. Consecutive slices draw a single card, like the cards of the
/// app (e.g. `UpCloudSection`), while the list builds them one by one.
class _BatchCardSlice extends StatelessWidget {
  const _BatchCardSlice({
    required this.isFirst,
    required this.isLast,
    required this.child,
    super.key,
  });

  final bool isFirst;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, isFirst ? 6 : 0, 8, isLast ? 6 : 0),
      child: CustomPaint(
        painter: _BatchCardPainter(
          color: theme.cardTheme.color ?? scheme.surfaceContainerLow,
          borderColor: scheme.outlineVariant.withValues(alpha: 0.5),
          radius: UpCloudTheme.of(context).borderRadius,
          isFirst: isFirst,
          isLast: isLast,
        ),
        // Ink of the buttons of the row.
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}

/// Paints the part of a bordered card that a row covers: the top edge
/// only on the first row and the bottom edge only on the last one.
class _BatchCardPainter extends CustomPainter {
  const _BatchCardPainter({
    required this.color,
    required this.borderColor,
    required this.radius,
    required this.isFirst,
    required this.isLast,
  });

  final Color color;
  final Color borderColor;
  final BorderRadius radius;
  final bool isFirst;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: borderColor),
    );
    // The card continues past the edges shared with other rows, far enough
    // to keep its corners and border out of this row.
    final overflow =
        [
          radius.topLeft.y,
          radius.topRight.y,
          radius.bottomLeft.y,
          radius.bottomRight.y,
        ].reduce(math.max) +
        shape.side.width;
    final card = Rect.fromLTRB(
      0,
      isFirst ? 0 : -overflow,
      size.width,
      isLast ? size.height : size.height + overflow,
    );
    final outline = shape.getOuterPath(card);
    canvas
      ..save()
      // Not anti-aliased, so that rows meet without a seam.
      ..clipRect(Offset.zero & size, doAntiAlias: false)
      ..drawPath(outline, Paint()..color = color)
      // Like a `Material`, which clips its border to its shape.
      ..clipPath(outline);
    shape.paint(canvas, card);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BatchCardPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.radius != radius ||
      oldDelegate.isFirst != isFirst ||
      oldDelegate.isLast != isLast;
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
    // Every count walks the uploads of the batch: read each one once.
    final total = batch.entries.length;
    final finished = batch.finishedCount;
    final failed = batch.failedCount;
    final cancelled = batch.cancelledCount;
    final isFinished = finished == total;
    final completed = finished - failed - cancelled;
    final progress = isFinished ? 1.0 : batch.progress;
    final (IconData icon, Color color) = !isFinished
        ? (Icons.cloud_upload_rounded, scheme.primary)
        : failed > 0
        ? (Icons.error_rounded, scheme.error)
        : completed == 0
        ? (Icons.cancel_rounded, scheme.outline)
        : (Icons.check_circle_rounded, upTheme.successColor);
    final status = [
      l10n.batchDone(finished, total),
      if (failed > 0) l10n.batchFailedCount(failed),
      if (cancelled > 0) l10n.batchCancelledCount(cancelled),
      if (!isFinished) l10n.formatPercent(progress),
    ].join(' · ');
    final expanded = this.expanded;
    final onExpandedChanged = this.onExpandedChanged;

    const dense = VisualDensity.compact;
    final actions = <Widget>[
      if (!isFinished && onCancel != null)
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
      if (finished > 0 && onClear != null)
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
              TintedIconBox(icon: icon, color: color, size: extent),
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
                if (!isFinished)
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
