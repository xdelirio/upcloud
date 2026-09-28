import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/src/core/http/http_logger.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  group('redactUri', () {
    test('hides secrets and keeps other parameters', () {
      final uri = Uri.parse('https://a.com/api?key=secret&fld_id=3');
      expect(redactUri(uri), 'https://a.com/api?key=***&fld_id=3');
    });

    test('leaves URIs without query untouched', () {
      expect(redactUri(Uri.parse('https://a.com/x')), 'https://a.com/x');
    });
  });

  group('mapDioException', () {
    DioException response(int status, {Map<String, List<String>>? headers}) {
      final request = RequestOptions(path: '/x');
      return DioException.badResponse(
        statusCode: status,
        requestOptions: request,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: status,
          headers: Headers.fromMap(headers ?? {}),
          data: {'msg': 'boom'},
        ),
      );
    }

    test('maps HTTP status codes', () {
      expect(mapDioException(response(401)), isA<AuthenticationException>());
      expect(mapDioException(response(403)), isA<AuthenticationException>());
      expect(mapDioException(response(404)), isA<NotFoundException>());
      expect(
        mapDioException(response(500)),
        isA<ProviderException>()
            .having((e) => e.statusCode, 'status', 500)
            .having((e) => e.response, 'response', {'msg': 'boom'}),
      );
    });

    test('reads Retry-After on 429', () {
      final error = mapDioException(
        response(
          429,
          headers: {
            'retry-after': ['7'],
          },
        ),
      );
      expect(
        error,
        isA<RateLimitedException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 7),
        ),
      );
    });

    test('maps timeouts and cancellations', () {
      final request = RequestOptions(path: '/x');
      expect(
        mapDioException(
          DioException.connectionTimeout(
            timeout: Duration.zero,
            requestOptions: request,
          ),
        ),
        isA<NetworkException>(),
      );
      expect(
        mapDioException(
          DioException.requestCancelled(requestOptions: request, reason: null),
        ),
        isA<CancelledException>(),
      );
    });

    test('unwraps UpCloudExceptions thrown inside interceptors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/x'),
        error: const QuotaExceededException('full'),
      );
      expect(mapDioException(error), isA<QuotaExceededException>());
    });
  });

  group('createDio', () {
    test('sets base URL, user agent and logs redacted requests', () async {
      final logs = <String>[];
      final dio = Dio();
      DioAdapter(dio: dio).onGet(
        'account/info',
        (server) => server.reply(200, {'ok': true}),
        queryParameters: {'key': 'secret'},
      );
      createDio(
        baseUrl: Uri.parse('https://api.example.com/api'),
        options: ProviderOptions(
          dio: dio,
          logger: logs.add,
          userAgent: 'test-agent',
          maxRetries: 0,
        ),
      );

      final response = await dio.get<dynamic>(
        'account/info',
        queryParameters: {'key': 'secret'},
      );

      expect(response.data, {'ok': true});
      expect(dio.options.baseUrl, 'https://api.example.com/api/');
      expect(dio.options.headers['user-agent'], 'test-agent');
      expect(logs, hasLength(2));
      expect(logs.join(), isNot(contains('secret')));
    });

    test('retries requests flagged as retryable on 5xx', () async {
      final dio = Dio();
      var calls = 0;
      dio.httpClientAdapter = _CountingAdapter(() {
        calls++;
        return calls < 3 ? 503 : 200;
      });
      createDio(
        baseUrl: Uri.parse('https://api.example.com'),
        options: ProviderOptions(dio: dio),
      );
      dio.interceptors.whereType<RetryInterceptor>().single;

      final response = await dio.get<dynamic>(
        'x',
        options: Options(extra: {retryableExtraKey: true}),
      );

      expect(response.statusCode, 200);
      expect(calls, 3);
    });

    test('does not retry unflagged GET requests', () async {
      // Hosting APIs use GET for writes (folder/create, file/delete...).
      final dio = Dio();
      var calls = 0;
      dio.httpClientAdapter = _CountingAdapter(() {
        calls++;
        return 503;
      });
      createDio(
        baseUrl: Uri.parse('https://api.example.com'),
        options: ProviderOptions(dio: dio),
      );

      await expectLater(
        guardRequest(() => dio.get<dynamic>('folder/create')),
        throwsA(isA<ProviderException>()),
      );
      expect(calls, 1);
    });

    test('fails fast when Retry-After is too long', () async {
      final dio = Dio();
      var calls = 0;
      dio.httpClientAdapter = _CountingAdapter(
        () {
          calls++;
          return 429;
        },
        headers: {
          'retry-after': ['3600'],
        },
      );
      createDio(
        baseUrl: Uri.parse('https://api.example.com'),
        options: ProviderOptions(dio: dio),
      );

      final stopwatch = Stopwatch()..start();
      await expectLater(
        guardRequest(
          () => dio.get<dynamic>(
            'x',
            options: Options(extra: {retryableExtraKey: true}),
          ),
        ),
        throwsA(
          isA<RateLimitedException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(hours: 1),
          ),
        ),
      );
      expect(calls, 1);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('cancelling interrupts the wait before a retry', () async {
      final dio = Dio()
        ..httpClientAdapter = _CountingAdapter(
          () => 429,
          headers: {
            'retry-after': ['20'],
          },
        );
      createDio(
        baseUrl: Uri.parse('https://api.example.com'),
        options: ProviderOptions(dio: dio),
      );
      final token = CancelToken();
      final stopwatch = Stopwatch()..start();
      final request = guardRequest(
        () => dio.get<dynamic>(
          'x',
          cancelToken: token,
          options: Options(extra: {retryableExtraKey: true}),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      token.cancel();

      await expectLater(request, throwsA(isA<UpCloudException>()));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('does not retry POST requests by default', () async {
      final dio = Dio();
      var calls = 0;
      dio.httpClientAdapter = _CountingAdapter(() {
        calls++;
        return 503;
      });
      createDio(
        baseUrl: Uri.parse('https://api.example.com'),
        options: ProviderOptions(dio: dio),
      );

      await expectLater(
        guardRequest(() => dio.post<dynamic>('x')),
        throwsA(isA<ProviderException>()),
      );
      expect(calls, 1);
    });
  });
}

/// Replies with the status code returned by [status] on every request.
final class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.status, {this.headers = const {}});

  final int Function() status;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{}',
    status(),
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...headers,
    },
  );

  @override
  void close({bool force = false}) {}
}
