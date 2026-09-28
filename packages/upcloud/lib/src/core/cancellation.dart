import 'dart:async';

/// Signals that an operation should stop.
///
/// Pass the same token to one or more operations and call [cancel] to abort
/// them. Cancelled operations throw a `CancelledException`.
final class CancellationToken {
  final _completer = Completer<void>();

  /// Whether [cancel] was called.
  bool get isCancelled => _completer.isCompleted;

  /// Completes when [cancel] is called.
  Future<void> get whenCancelled => _completer.future;

  /// Requests cancellation. Calling it more than once has no effect.
  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
