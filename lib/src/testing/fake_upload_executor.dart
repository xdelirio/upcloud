import 'dart:async';
import 'dart:math' as math;

import 'package:upcloud/src/core/cancellation.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/models/upload_request.dart';
import 'package:upcloud/src/testing/in_memory_provider.dart';
import 'package:upcloud/src/transfer/upload_executor.dart';

/// Answers an upload request, or returns `null` to use the default answer.
typedef FakeUploadResponder = UploadResponse? Function(
  UploadRequest request,
  UploadSource source,
);

/// An [UploadExecutor] for tests and demos that sends nothing.
///
/// It reports progress in [progressSteps] steps, waiting [stepDelay] before
/// each, then answers with [respond]. Requests of [InMemoryProvider]
/// (`memory://`) succeed by default; any other request needs [respond].
///
/// ```dart
/// final executor = FakeUploadExecutor()..failNext(2);
/// final upcloud = UpCloud(uploadExecutor: executor, ...);
/// ```
final class FakeUploadExecutor implements UploadExecutor {
  /// Creates an executor.
  FakeUploadExecutor({
    this.progressSteps = 4,
    this.stepDelay = Duration.zero,
    this.respond,
  });

  /// Progress notifications sent after the initial one, the last one with
  /// every byte.
  final int progressSteps;

  /// Delay before each progress step.
  final Duration stepDelay;

  /// Canned responses; `null` (or a `null` answer) uses the default one.
  final FakeUploadResponder? respond;

  final _requests = <UploadRequest>[];
  final _failures = <UpCloudException>[];
  Completer<void>? _pause;
  var _running = 0;
  var _maxRunning = 0;

  /// Requests executed so far (including failed ones), in order.
  List<UploadRequest> get requests => List.unmodifiable(_requests);

  /// Executions in progress.
  int get running => _running;

  /// Highest number of executions in progress at the same time.
  int get maxRunning => _maxRunning;

  /// Whether executions are held by [pause].
  bool get isPaused => _pause != null;

  /// Makes the next [attempts] executions fail with [error] before sending
  /// anything.
  void failNext(
    int attempts, [
    UpCloudException error = const NetworkException('Simulated failure'),
  ]) {
    for (var i = 0; i < attempts; i++) {
      _failures.add(error);
    }
  }

  /// Holds running and new executions before their next progress step,
  /// until [resume] is called.
  void pause() => _pause ??= Completer<void>();

  /// Releases the executions held by [pause].
  void resume() {
    _pause?.complete();
    _pause = null;
  }

  @override
  Future<UploadResponse> execute(
    UploadRequest request,
    UploadSource source, {
    void Function(TransferProgress progress)? onProgress,
    CancellationToken? cancelToken,
  }) async {
    _requests.add(request);
    _running++;
    _maxRunning = math.max(_maxRunning, _running);
    try {
      _checkCancelled(cancelToken);
      if (_failures.isNotEmpty) throw _failures.removeAt(0);
      final length = await source.resolveLength();
      onProgress?.call(TransferProgress(transferred: 0, total: length));
      for (var step = 1; step <= progressSteps; step++) {
        for (var held = _pause; held != null; held = _pause) {
          await _untilCancelled(held.future, cancelToken);
        }
        if (stepDelay > Duration.zero) {
          await _untilCancelled(Future<void>.delayed(stepDelay), cancelToken);
        }
        _checkCancelled(cancelToken);
        onProgress?.call(
          TransferProgress(
            transferred: length == null
                ? step
                : (length * step / progressSteps).round(),
            total: length,
          ),
        );
      }
      return respond?.call(request, source) ?? _defaultResponse(request);
    } finally {
      _running--;
    }
  }

  static UploadResponse _defaultResponse(UploadRequest request) {
    if (request.url.scheme == InMemoryProvider.uploadScheme) {
      return const UploadResponse(statusCode: 200, body: '{}');
    }
    throw StateError(
      'FakeUploadExecutor has no response for ${request.url}: pass '
      '`respond`',
    );
  }

  static Future<void> _untilCancelled(
    Future<void> future,
    CancellationToken? cancelToken,
  ) async {
    await Future.any([future, ?cancelToken?.whenCancelled]);
    _checkCancelled(cancelToken);
  }

  static void _checkCancelled(CancellationToken? cancelToken) {
    if (cancelToken?.isCancelled ?? false) throw const CancelledException();
  }
}
