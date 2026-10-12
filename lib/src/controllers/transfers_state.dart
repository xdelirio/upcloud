import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/upcloud.dart';

part 'transfers_state.freezed.dart';

/// A snapshot of one upload inside [TransfersState].
@freezed
abstract class TransferEntry with _$TransferEntry {
  /// Creates a snapshot of [task].
  const factory TransferEntry({
    required UploadTask task,

    /// State of [task] when the snapshot was taken.
    required TransferState state,

    /// Recent average speed in bytes per second, while running.
    double? bytesPerSecond,

    /// [UploadTask.attempt] when the snapshot was taken: `1` for the first
    /// attempt, `2` for the first automatic retry...
    @Default(0) int attempt,
  }) = _TransferEntry;

  const TransferEntry._();

  /// Shortcut for `task.id`.
  String get id => task.id;

  /// Shortcut for `task.batchId`.
  String? get batchId => task.batchId;

  /// Automatic retries done so far (`attempt - 1`, at least 0).
  int get retry => attempt > 1 ? attempt - 1 : 0;

  /// Progress between 0 and 1, `null` when unknown or not running.
  double? get fraction => switch (state) {
    TransferRunning(:final progress) => progress.fraction,
    TransferCompleted() => 1,
    TransferQueued() || TransferFailed() || TransferCancelled() => null,
  };
}

/// A snapshot of the uploads of one `UploadBatch` (several files to several
/// accounts started together), grouped by [UploadTask.batchId].
@freezed
abstract class TransferBatchEntry with _$TransferBatchEntry {
  /// Creates a snapshot of the batch [id].
  const factory TransferBatchEntry({
    required String id,

    /// Uploads of the batch, oldest first.
    required List<TransferEntry> entries,
  }) = _TransferBatchEntry;

  const TransferBatchEntry._();

  /// Destination folder path of the batch (empty for the root), or `null`
  /// when the uploads target a folder id.
  String? get folderPath => entries.firstOrNull?.task.folderPath;

  /// Number of different files of the batch.
  int get fileCount =>
      (Set<UploadSource>.identity()..addAll(entries.map((e) => e.task.source)))
          .length;

  /// Number of different accounts of the batch.
  int get accountCount => {for (final e in entries) e.task.accountId}.length;

  /// Uploads that completed.
  int get completedCount => _count((s) => s is TransferCompleted);

  /// Uploads that failed.
  int get failedCount => _count((s) => s is TransferFailed);

  /// Uploads cancelled by the user.
  int get cancelledCount => _count((s) => s is TransferCancelled);

  /// Uploads queued or running.
  int get activeCount => _count((s) => !s.isFinished);

  /// Uploads that reached a final state.
  int get finishedCount => entries.length - activeCount;

  /// Whether every upload reached a final state.
  bool get isFinished => activeCount == 0;

  /// Size of every upload in bytes, or `null` while a size is unknown.
  int? get totalBytes {
    var total = 0;
    for (final entry in entries) {
      final bytes = entry.task.totalBytes;
      if (bytes == null) return null;
      total += bytes;
    }
    return total;
  }

  /// Bytes sent by running uploads plus the size of completed ones.
  int get transferredBytes {
    var sent = 0;
    for (final entry in entries) {
      sent += switch (entry.state) {
        TransferCompleted() => entry.task.totalBytes ?? 0,
        TransferRunning(:final progress) => progress.transferred,
        _ => 0,
      };
    }
    return sent;
  }

  /// Overall progress between 0 and 1, like `UploadBatch.progress`.
  ///
  /// Finished uploads count as done whatever their outcome. Weighted by
  /// size when every size is known.
  double get progress {
    if (entries.isEmpty) return 1;
    final bySize = (totalBytes ?? 0) > 0;
    var done = 0.0;
    var total = 0.0;
    for (final entry in entries) {
      final weight = bySize ? (entry.task.totalBytes ?? 0).toDouble() : 1.0;
      total += weight;
      done += switch (entry.state) {
        TransferRunning(:final progress) => weight * (progress.fraction ?? 0),
        final state when state.isFinished => weight,
        _ => 0,
      };
    }
    return total == 0 ? 1 : (done / total).clamp(0, 1).toDouble();
  }

  int _count(bool Function(TransferState state) test) =>
      entries.where((e) => test(e.state)).length;
}

/// Immutable state of a `TransfersController`.
@freezed
abstract class TransfersState with _$TransfersState {
  /// Creates a transfers state.
  const factory TransfersState({
    /// Every transfer, oldest first.
    @Default(<TransferEntry>[]) List<TransferEntry> entries,
  }) = _TransfersState;

  const TransfersState._();

  /// Transfers that are queued or running.
  int get activeCount => entries.where((e) => !e.state.isFinished).length;

  /// Transfers that completed, failed or were cancelled.
  int get finishedCount => entries.length - activeCount;

  /// Whether any transfer is queued or running.
  bool get isBusy => activeCount > 0;

  /// Whether any transfer completed, failed or was cancelled.
  bool get hasFinished => finishedCount > 0;

  /// Snapshot of task [id], or `null`.
  TransferEntry? entry(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Uploads grouped by batch, in the order of their oldest task. Uploads
  /// without batch are left out.
  List<TransferBatchEntry> get batches {
    final groups = <String, List<TransferEntry>>{};
    for (final e in entries) {
      final id = e.batchId;
      if (id != null) (groups[id] ??= []).add(e);
    }
    return [
      for (final MapEntry(:key, :value) in groups.entries)
        TransferBatchEntry(id: key, entries: List.unmodifiable(value)),
    ];
  }

  /// Snapshot of the batch [id], or `null` when none of its uploads is
  /// left.
  TransferBatchEntry? batch(String id) {
    final list = [
      for (final e in entries)
        if (e.batchId == id) e,
    ];
    return list.isEmpty ? null : TransferBatchEntry(id: id, entries: list);
  }
}
