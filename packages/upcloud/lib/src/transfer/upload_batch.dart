import 'dart:async';

import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/transfer/transfer_task.dart';

/// An upload of a batch that failed, with the error that stopped it.
typedef UploadFailure = ({UploadTask task, UpCloudException error});

/// Uploads of several files to several accounts, started together.
///
/// Holds one [UploadTask] per file and account (all with [id] as
/// [UploadTask.batchId]) and aggregates their state:
///
/// ```dart
/// final batch = upcloud.uploadBatch(
///   files: [UploadSource.file(path)],
///   accountIds: [streamHg.id, byse.id],
///   folderPath: 'Movies/2026',
/// );
/// batch.changes.listen((b) => print('${(b.progress * 100).round()} %'));
/// final files = await batch.results;
/// print('${files.length} uploaded, ${batch.failures.length} failed');
/// ```
final class UploadBatch {
  /// Creates a batch of [tasks].
  UploadBatch({
    required this.id,
    required List<UploadTask> tasks,
    this.folderPath,
  }) : tasks = List.unmodifiable(tasks);

  /// Unique id of the batch.
  final String id;

  /// Tasks of the batch, grouped by file in the order they were given.
  final List<UploadTask> tasks;

  /// Destination folder path in every account (empty for the root), or
  /// `null` when the destination is `UploadOptions.folderId`.
  final String? folderPath;

  List<StreamSubscription<TransferState>> _subscriptions = [];

  late final StreamController<UploadBatch> _changes =
      StreamController.broadcast(
        onListen: () => _subscriptions = [
          for (final task in tasks)
            task.changes.listen((_) => _changes.add(this)),
        ],
        onCancel: () {
          for (final subscription in _subscriptions) {
            unawaited(subscription.cancel());
          }
          _subscriptions = [];
        },
      );

  /// Emits this batch whenever one of its tasks changes (state or
  /// progress).
  Stream<UploadBatch> get changes => _changes.stream;

  /// Tasks that uploaded their file.
  int get completedCount => _count((s) => s is TransferCompleted);

  /// Tasks that failed.
  int get failedCount => _count((s) => s is TransferFailed);

  /// Tasks cancelled by the user.
  int get cancelledCount => _count((s) => s is TransferCancelled);

  /// Tasks that reached a final state, whatever the outcome.
  int get finishedCount => _count((s) => s.isFinished);

  /// Whether every task reached a final state.
  bool get isFinished => finishedCount == tasks.length;

  /// Failed tasks with their errors.
  List<UploadFailure> get failures => [
    for (final task in tasks)
      if (task.state case TransferFailed(:final error))
        (task: task, error: error),
  ];

  /// Size of every upload in bytes, or `null` while a size is unknown.
  int? get totalBytes {
    var total = 0;
    for (final task in tasks) {
      final bytes = task.totalBytes;
      if (bytes == null) return null;
      total += bytes;
    }
    return total;
  }

  /// Bytes sent by running uploads plus the size of completed ones.
  int get transferredBytes {
    var sent = 0;
    for (final task in tasks) {
      sent += switch (task.state) {
        TransferCompleted() => task.totalBytes ?? 0,
        TransferRunning(:final progress) => progress.transferred,
        _ => 0,
      };
    }
    return sent;
  }

  /// Overall progress between 0 and 1.
  ///
  /// Finished tasks count as done whatever their outcome, so it reaches 1
  /// when [isFinished]. Weighted by size when every size is known.
  double get progress {
    if (tasks.isEmpty) return 1;
    final bySize = (totalBytes ?? 0) > 0;
    var done = 0.0;
    var total = 0.0;
    for (final task in tasks) {
      final weight = bySize ? (task.totalBytes ?? 0).toDouble() : 1.0;
      total += weight;
      done += switch (task.state) {
        TransferRunning(:final progress) => weight * (progress.fraction ?? 0),
        final state when state.isFinished => weight,
        _ => 0,
      };
    }
    return total == 0 ? 1 : (done / total).clamp(0, 1).toDouble();
  }

  /// The uploaded files, in task order, once every task finished.
  ///
  /// Never completes with an error: failed and cancelled uploads are left
  /// out (see [failures]).
  Future<List<CloudFile>> get results async {
    final files = await Future.wait([
      for (final task in tasks)
        task.result.then<CloudFile?>(
          (file) => file,
          onError: (Object _) => null,
        ),
    ]);
    return [for (final file in files) ?file];
  }

  int _count(bool Function(TransferState state) test) =>
      tasks.where((task) => test(task.state)).length;
}
