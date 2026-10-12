import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

import '../support/testing.dart';
import '../support/wait.dart';

void main() {
  final memoryRequest = UploadRequest(url: Uri.parse('memory://test/upload'));
  final remoteRequest = UploadRequest(url: Uri.parse('https://up.test/'));
  final source = UploadSource.bytes(List.filled(10, 0), name: 'a.mp4');

  test('answers memory requests and reports progress in steps', () async {
    final executor = FakeUploadExecutor(progressSteps: 2);
    final progress = <TransferProgress>[];

    final response = await executor.execute(
      memoryRequest,
      source,
      onProgress: progress.add,
    );

    expect(response.statusCode, 200);
    expect(progress.map((p) => p.transferred), [0, 5, 10]);
    expect(executor.requests, [memoryRequest]);
  });

  test('needs a responder for other requests', () async {
    await expectLater(
      FakeUploadExecutor().execute(remoteRequest, source),
      throwsA(isA<StateError>()),
    );

    final executor = FakeUploadExecutor(
      respond: (request, _) => request.url.host == 'up.test'
          ? const UploadResponse(statusCode: 201, body: 'ok')
          : null,
    );
    final response = await executor.execute(remoteRequest, source);
    expect(response.body, 'ok');
  });

  test('fails the next attempts', () async {
    final executor = FakeUploadExecutor()
      ..failNext(1, const RateLimitedException('Slow down'));

    await expectLater(
      executor.execute(memoryRequest, source),
      throwsA(isA<RateLimitedException>()),
    );
    await executor.execute(memoryRequest, source);
    expect(executor.requests, hasLength(2));
  });

  test('holds executions while paused and honors cancellation', () async {
    final executor = FakeUploadExecutor()..pause();
    final token = CancellationToken();

    final held = executor.execute(memoryRequest, source);
    final cancelled = executor.execute(
      memoryRequest,
      source,
      cancelToken: token,
    );
    await until(() => executor.running == 2);
    expect(executor.isPaused, isTrue);
    token.cancel();

    await expectLater(cancelled, throwsA(isA<CancelledException>()));
    executor.resume();
    expect((await held).statusCode, 200);
    expect(executor.running, 0);
    expect(executor.maxRunning, 2);
  });
}
