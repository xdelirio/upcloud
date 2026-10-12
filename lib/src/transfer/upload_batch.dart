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
  int? get totalBytes => totalUploadBytes(_snapshots);

  /// Bytes sent by running uploads plus the size of completed ones.
  int get transferredBytes => transferredUploadBytes(_snapshots);

  /// Overall progress between 0 and 1.
  ///
  /// Finished tasks count as done whatever their outcome, so it reaches 1
  /// when [isFinished]. Weighted by size when every size is known.
  double get progress => uploadsProgress(_snapshots);

  Iterable<UploadSnapshot> get _snapshots =>
      tasks.map((task) => (state: task.state, totalBytes: task.totalBytes));

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

/// State and size of one upload of a group (a batch).
typedef UploadSnapshot = ({TransferState state, int? totalBytes});

/// Size of [uploads] in bytes, or `null` while a size is unknown.
int? totalUploadBytes(Iterable<UploadSnapshot> uploads) {
  var total = 0;
  for (final upload in uploads) {
    final bytes = upload.totalBytes;
    if (bytes == null) return null;
    total += bytes;
  }
  return total;
}

/// Bytes sent by the running [uploads] plus the size of completed ones.
int transferredUploadBytes(Iterable<UploadSnapshot> uploads) {
  var sent = 0;
  for (final upload in uploads) {
    sent += switch (upload.state) {
      TransferCompleted() => upload.totalBytes ?? 0,
      TransferRunning(:final progress) => progress.transferred,
      _ => 0,
    };
  }
  return sent;
}

/// Overall progress of [uploads] between 0 and 1 (1 when there are none).
///
/// Finished uploads count as done whatever their outcome. Weighted by size
/// when every size is known.
double uploadsProgress(Iterable<UploadSnapshot> uploads) {
  final bySize = (totalUploadBytes(uploads) ?? 0) > 0;
  var done = 0.0;
  var total = 0.0;
  for (final upload in uploads) {
    final weight = bySize ? (upload.totalBytes ?? 0).toDouble() : 1.0;
    total += weight;
    done += switch (upload.state) {
      TransferRunning(:final progress) => weight * (progress.fraction ?? 0),
      final state when state.isFinished => weight,
      _ => 0,
    };
  }
  return total == 0 ? 1 : (done / total).clamp(0, 1).toDouble();
}
