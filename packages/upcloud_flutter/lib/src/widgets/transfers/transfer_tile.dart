import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/theme/upcloud_theme.dart';
import 'package:upcloud_flutter/src/utils/file_kind.dart';

/// Displays one upload: name, progress bar, status or error,
/// optional speed and cancel/retry/remove buttons.
///
/// While an automatic retry runs the status reads "Retrying (1/2)".
///
/// Buttons are shown only when their callback is set and they make sense
/// for the current state (cancel while active, retry after a failure or
/// cancellation, remove when finished).
class TransferTile extends StatelessWidget {
  /// Creates a tile for [task].
  const TransferTile({
    required this.task,
    this.state,
    this.attempt,
    this.maxRetries,
    this.bytesPerSecond,
    this.showSpeed = true,
    this.subtitle,
    this.onCancel,
    this.onRetry,
    this.onRemove,
    super.key,
  });

  /// The upload to show.
  final UploadTask task;

  /// State to show. Defaults to `task.state`.
  final TransferState? state;

  /// Attempt to show (see [UploadTask.attempt]). Defaults to
  /// `task.attempt`.
  final int? attempt;

  /// Automatic retries allowed (`UploadSettings.retries`), shown next to
  /// the current retry; `null` when unknown.
  final int? maxRetries;

  /// Current speed, shown while running when [showSpeed] is true.
  final double? bytesPerSecond;

  /// Whether to show [bytesPerSecond].
  final bool showSpeed;

  /// Secondary text, e.g. the account name.
  final String? subtitle;

  /// Cancels the transfer.
  final VoidCallback? onCancel;

  /// Queues the transfer again.
  final VoidCallback? onRetry;

  /// Removes the transfer from the list.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = UpCloudTheme.of(context);
    final material = Theme.of(context);
    final scheme = material.colorScheme;
    final state = this.state ?? task.state;
    final subtitle = this.subtitle;
    final attempt = this.attempt ?? task.attempt;
    final retrying = attempt > 1 && !state.isFinished
        ? l10n.transferRetrying(attempt - 1, maxRetries)
        : null;

    final (String status, Color statusColor) = switch (state) {
      TransferQueued() => (
        [
          retrying ?? l10n.transferQueued,
          if (task.totalBytes case final total? when total > 0)
            l10n.formatBytes(total),
        ].join(' · '),
        scheme.onSurfaceVariant,
      ),
      TransferRunning(:final progress) => (
        _runningText(l10n, progress, retrying),
        retrying == null ? scheme.onSurfaceVariant : theme.warningColor,
      ),
      TransferCompleted() => (l10n.transferCompleted, theme.successColor),
      TransferFailed(:final error) => (l10n.errorMessage(error), scheme.error),
      TransferCancelled() => (l10n.transferCancelled, scheme.onSurfaceVariant),
    };
    final double? progressValue;
    final bool showProgress;
    switch (state) {
      case TransferQueued():
        progressValue = null;
        showProgress = true;
      case TransferRunning(:final progress):
        progressValue = progress.fraction;
        showProgress = true;
      case TransferCompleted() || TransferFailed() || TransferCancelled():
        progressValue = null;
        showProgress = false;
    }

    final buttons = <Widget>[
      if (!state.isFinished && onCancel != null)
        IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.cancel,
          onPressed: onCancel,
        ),
      if ((state is TransferFailed || state is TransferCancelled) &&
          onRetry != null)
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: l10n.retry,
          onPressed: onRetry,
        ),
      if (state.isFinished && onRemove != null)
        IconButton(
          icon: const Icon(Icons.clear_all_rounded),
          tooltip: l10n.remove,
          onPressed: onRemove,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TransferIcon(task: task, state: state),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: material.textTheme.bodyLarge,
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: material.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                if (showProgress)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: theme.progressHeight,
                      borderRadius: BorderRadius.circular(theme.progressHeight),
                    ),
                  ),
                Text(
                  status,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: material.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (buttons.isNotEmpty) ...[const SizedBox(width: 8), ...buttons],
        ],
      ),
    );
  }

  String _runningText(
    UpCloudLocalizations l10n,
    TransferProgress progress,
    String? retrying,
  ) {
    final total = progress.total;
    final fraction = progress.fraction;
    final speed = bytesPerSecond;
    return [
      retrying ?? l10n.transferUploading,
      if (total != null && total > 0)
        l10n.transferProgress(
          l10n.formatBytes(progress.transferred),
          l10n.formatBytes(total),
        )
      else
        l10n.formatBytes(progress.transferred),
      if (fraction != null) '${(fraction * 100).floor()} %',
      if (showSpeed && speed != null && speed > 0) l10n.formatSpeed(speed),
    ].join(' · ');
  }
}

class _TransferIcon extends StatelessWidget {
  const _TransferIcon({required this.task, required this.state});

  final UploadTask task;
  final TransferState state;

  @override
  Widget build(BuildContext context) {
    final theme = UpCloudTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final kind = CloudFileKind.fromName(task.name);
    final color = theme.colorFor(kind);
    final size = theme.thumbnailSize;
    final (IconData badge, Color badgeColor) = switch (state) {
      TransferCompleted() => (Icons.check_circle_rounded, theme.successColor),
      TransferFailed() => (Icons.error_rounded, scheme.error),
      TransferCancelled() => (Icons.cancel_rounded, scheme.outline),
      TransferQueued() ||
      TransferRunning() => (Icons.arrow_circle_up_rounded, scheme.primary),
    };
    return SizedBox.square(
      dimension: size + 6,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(size / 4),
            ),
            child: Icon(kind.icon, color: color, size: size * 0.6),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(badge, size: 18, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}
