import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/cancellation.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/upload.dart';

part 'transfer_task.freezed.dart';

/// State of a [TransferTask].
@freezed
sealed class TransferState with _$TransferState {
  /// Waiting for a free slot.
  const factory TransferState.queued() = TransferQueued;

  /// Transferring data.
  const factory TransferState.running(TransferProgress progress) =
      TransferRunning;

  /// Finished successfully.
  const factory TransferState.completed() = TransferCompleted;

  /// Finished with [error].
  const factory TransferState.failed(UpCloudException error) = TransferFailed;

  /// Cancelled by the user.
  const factory TransferState.cancelled() = TransferCancelled;

  const TransferState._();

  /// Whether the task reached a final state.
  bool get isFinished => switch (this) {
    TransferCompleted() || TransferFailed() || TransferCancelled() => true,
    TransferQueued() || TransferRunning() => false,
  };
}

/// An upload managed by a `TransferManager`.
///
/// Listen to [changes] (or read [state]) to follow its progress.
sealed class TransferTask {
  TransferTask({required this.id, required this.accountId, required this.name})
    : createdAt = DateTime.now();

  /// Unique id inside the manager.
  final String id;

  /// Account the transfer belongs to.
  final String accountId;

  /// File name shown to the user.
  final String name;

  /// When the task was created.
  final DateTime createdAt;

  TransferState _state = const TransferState.queued();
  int? _totalBytes;

  /// Size of the transfer in bytes, once known (before it starts for most
  /// uploads).
  int? get totalBytes => _totalBytes;

  /// Sets [totalBytes] and notifies listeners with the current state.
  @internal
  void setTotalBytes(int? bytes) {
    if (bytes == null || bytes == _totalBytes) return;
    _totalBytes = bytes;
    if (!_changes.isClosed) _changes.add(_state);
  }

  final _changes = StreamController<TransferState>.broadcast(sync: true);
  CancellationToken _cancelToken = CancellationToken();

  /// Current state.
  TransferState get state => _state;

  /// Emits every state change.
  Stream<TransferState> get changes => _changes.stream;

  /// Token passed to the upload steps; cancelled by
  /// `TransferManager.cancel`.
  @internal
  CancellationToken get cancelToken => _cancelToken;

  /// Sets a new state and notifies listeners.
  @internal
  void setState(TransferState state) {
    _state = state;
    if (!_changes.isClosed) _changes.add(state);
  }

  /// Prepares the task to run again after a failure or cancellation.
  @internal
  void reset() {
    _cancelToken = CancellationToken();
    resetResult();
    setState(const TransferState.queued());
  }

  /// Clears the stored result before a retry.
  @protected
  void resetResult();

  /// Stops notifying listeners.
  @internal
  Future<void> dispose() => _changes.close();
}

/// Uploads [source] to an account.
final class UploadTask extends TransferTask {
  /// Creates an upload task.
  UploadTask({
    required super.id,
    required super.accountId,
    required this.source,
    this.options = const UploadOptions(),
    this.batchId,
    this.folderPath,
  }) : super(name: source.name);

  /// Content to upload.
  final UploadSource source;

  /// Metadata for the uploaded file.
  final UploadOptions options;

  /// Id of the `UploadBatch` this task belongs to, if any.
  final String? batchId;

  /// Destination folder path (e.g. `Movies/2026`, empty for the root),
  /// resolved by name before the upload starts. When `null` the
  /// destination is [UploadOptions.folderId].
  final String? folderPath;

  int _attempt = 0;
  Completer<CloudFile> _result = Completer<CloudFile>();

  /// Number of the current (or last) attempt: `0` before the task starts,
  /// then `1`, `2`... as automatic retries run. A manual retry starts again
  /// from `0`.
  int get attempt => _attempt;

  /// Completes with the uploaded file, or with the error that stopped it.
  ///
  /// After a retry this returns the future of the new attempt.
  Future<CloudFile> get result => _result.future;

  /// Starts a new attempt; listeners are notified by the next state change.
  @internal
  void startAttempt() => _attempt++;

  @override
  void resetResult() {
    _attempt = 0;
    if (_result.isCompleted) _result = Completer<CloudFile>();
  }

  /// Completes [result] successfully.
  @internal
  void complete(CloudFile file) {
    if (!_result.isCompleted) _result.complete(file);
    setState(const TransferState.completed());
  }

  /// Completes [result] with [error].
  @internal
  void fail(UpCloudException error) {
    if (!_result.isCompleted) {
      // Avoid "unhandled error" when nobody listens to [result].
      _result.future.ignore();
      _result.completeError(error);
    }
    setState(
      error is CancelledException
          ? const TransferState.cancelled()
          : TransferState.failed(error),
    );
  }
}
