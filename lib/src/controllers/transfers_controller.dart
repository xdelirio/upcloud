import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upcloud/src/controllers/transfers_state.dart';
import 'package:upcloud/upcloud.dart';

/// Exposes the tasks of a [TransferManager] as a listenable [state] with
/// per-task progress and speed.
///
/// ```dart
/// final transfers = TransfersController(upcloud.transfers);
/// ListenableBuilder(
///   listenable: transfers,
///   builder: (context, _) => Text('${transfers.state.activeCount} active'),
/// );
/// ```
class TransfersController extends ChangeNotifier {
  /// Creates a controller for [manager].
  ///
  /// [clock] is used to measure speeds; override it in tests.
  TransfersController(this.manager, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _managerSubscription = manager.changes.listen(_sync);
    _sync(manager.tasks);
  }

  /// Creates a controller for `upcloud.transfers`.
  factory TransfersController.of(UpCloud upcloud) =>
      TransfersController(upcloud.transfers);

  /// The wrapped manager.
  final TransferManager manager;

  final DateTime Function() _clock;
  late final StreamSubscription<List<UploadTask>> _managerSubscription;
  final _taskSubscriptions = <UploadTask, StreamSubscription<void>>{};
  final _speeds = <UploadTask, _SpeedMeter>{};
  var _state = const TransfersState();
  var _disposed = false;

  /// Current state.
  TransfersState get state => _state;

  /// Automatic retries of the uploads, from the manager settings.
  int get maxRetries => manager.settings.retries;

  /// Cancels [task].
  void cancel(UploadTask task) => manager.cancel(task);

  /// Queues a failed or cancelled [task] again.
  void retry(UploadTask task) => manager.retry(task);

  /// Removes [task] from the list, cancelling it if needed.
  void remove(UploadTask task) => manager.remove(task);

  /// Removes every completed, failed or cancelled task.
  void clearFinished() => manager.clearFinished();

  /// Cancels every queued or running task.
  void cancelAll() => manager.cancelAll();

  /// Cancels the queued and running uploads of the batch [batchId].
  void cancelBatch(String batchId) => _batchTasks(batchId).forEach(cancel);

  /// Queues the failed uploads of the batch [batchId] again.
  void retryFailed(String batchId) {
    for (final task in _batchTasks(batchId)) {
      if (task.state is TransferFailed) retry(task);
    }
  }

  /// Removes the finished uploads of the batch [batchId] (all of them when
  /// the batch is finished).
  void clearBatch(String batchId) {
    for (final task in _batchTasks(batchId)) {
      if (task.state.isFinished) remove(task);
    }
  }

  List<UploadTask> _batchTasks(String batchId) => [
    for (final task in manager.tasks)
      if (task.batchId == batchId) task,
  ];

  void _sync(List<UploadTask> tasks) {
    if (_disposed) return;
    final current = tasks.toSet();
    for (final task in [..._taskSubscriptions.keys]) {
      if (!current.contains(task)) {
        unawaited(_taskSubscriptions.remove(task)?.cancel());
        _speeds.remove(task);
      }
    }
    for (final task in tasks) {
      _taskSubscriptions[task] ??= task.changes.listen(
        (state) => _onTaskState(task, state),
      );
    }
    _publish(tasks);
  }

  void _onTaskState(UploadTask task, TransferState state) {
    if (_disposed) return;
    if (state case TransferRunning(:final progress)) {
      (_speeds[task] ??= _SpeedMeter()).add(progress.transferred, _clock());
    } else {
      _speeds.remove(task);
    }
    _publish(manager.tasks);
  }

  void _publish(List<UploadTask> tasks) {
    _state = TransfersState(
      entries: List.unmodifiable([
        for (final task in tasks)
          TransferEntry(
            task: task,
            state: task.state,
            bytesPerSecond: task.state is TransferRunning
                ? _speeds[task]?.bytesPerSecond
                : null,
            attempt: task.attempt,
          ),
      ]),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_managerSubscription.cancel());
    for (final subscription in _taskSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _taskSubscriptions.clear();
    super.dispose();
  }
}

/// Smoothed transfer speed computed from progress samples.
class _SpeedMeter {
  static const _minInterval = Duration(milliseconds: 250);

  DateTime? _lastTime;
  int _lastBytes = 0;
  double? bytesPerSecond;

  void add(int bytes, DateTime now) {
    final lastTime = _lastTime;
    if (lastTime == null || bytes < _lastBytes) {
      _lastTime = now;
      _lastBytes = bytes;
      return;
    }
    final elapsed = now.difference(lastTime);
    if (elapsed < _minInterval) return;
    final instant = (bytes - _lastBytes) * 1000000 / elapsed.inMicroseconds;
    final previous = bytesPerSecond;
    bytesPerSecond = previous == null
        ? instant
        : previous * 0.7 + instant * 0.3;
    _lastTime = now;
    _lastBytes = bytes;
  }
}
