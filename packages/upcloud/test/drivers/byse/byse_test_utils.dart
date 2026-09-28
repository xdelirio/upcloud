import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:upcloud/upcloud.dart';

/// API key used by the tests.
const testApiKey = 'test-key';

/// Loads `test/fixtures/byse/[name]`.
Map<String, Object?> byseFixture(String name) =>
    jsonDecode(File('test/fixtures/byse/$name').readAsStringSync())
        as Map<String, Object?>;

/// A [ByseProvider] wired to a mocked [DioAdapter].
final class ByseHarness {
  /// Creates the harness. [limits] replaces the default Byse limits.
  ByseHarness({ProviderLimits? limits}) {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.next(options);
        },
      ),
    );
    provider = ByseProvider(
      credentials: Credentials.apiKey(testApiKey),
      options: ProviderOptions(dio: dio, maxRetries: 0, limits: limits),
    );
  }

  /// Client used by [provider].
  late final Dio dio;

  /// Mock adapter installed in [dio].
  late final DioAdapter adapter;

  /// Provider under test.
  late final ByseProvider provider;

  /// Every request sent by [provider], in order.
  final List<RequestOptions> requests = [];

  /// Paths of [requests].
  List<String> get paths => [for (final r in requests) r.path];

  /// Mocks `GET [path]` (with the API key and [query]) replying [body].
  void onGet(
    String path,
    Object? body, {
    Map<String, Object?> query = const {},
    int statusCode = 200,
  }) {
    adapter.onGet(
      path,
      (server) => server.reply(statusCode, body),
      queryParameters: {'key': testApiKey, ...query},
    );
  }
}
