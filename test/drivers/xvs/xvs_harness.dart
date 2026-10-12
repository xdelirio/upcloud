import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/drivers/xvs/xvs.dart';

import '../../support/bundled_providers.dart';

/// API key used by every test.
const testApiKey = 'test-key-123';

/// Reads `test/fixtures/xvs/[name].json`.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/xvs/$name.json').readAsStringSync())
        as Map<String, dynamic>;

/// A generic clone with a file link template.
final ProviderDefinition testDefinition = testXvsDefinition(
  info: ProviderInfo(
    id: 'xvs-test',
    name: 'XVS Test',
    website: Uri.parse('https://xvs.test'),
  ),
  apiBase: Uri.parse('https://xvs.test/api'),
  fileUrlTemplate: 'https://xvs.test/{id}.html',
);

/// A provider wired to a mocked HTTP client.
final class XvsHarness {
  /// Creates a provider for [definition] (defaults to [testDefinition]).
  XvsHarness({
    ProviderDefinition? definition,
    ProviderLimits? limits,
    String apiKey = testApiKey,
  }) : dio = Dio() {
    adapter = DioAdapter(dio: dio);
    provider = (definition ?? testDefinition).create(
      Credentials.apiKey(apiKey),
      options: ProviderOptions(dio: dio, maxRetries: 0, limits: limits),
    ) as XvsProvider;
  }

  /// HTTP client used by [provider].
  final Dio dio;

  /// Mocks of [dio].
  late final DioAdapter adapter;

  /// Provider under test.
  late final XvsProvider provider;

  /// Requests received by the mocks, in order.
  final List<RequestOptions> requests = [];

  /// Answers `GET [path]` with [body] when the request contains [query]
  /// (the API key is always expected).
  void onGet(
    String path,
    Object? body, {
    Map<String, Object?> query = const {},
    int status = 200,
    Map<String, List<String>>? headers,
  }) {
    adapter.onGet(
      path,
      (server) => server.replyCallback(
        status,
        (options) {
          requests.add(options);
          return body;
        },
        headers:
            headers ??
            const {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
      ),
      queryParameters: {'key': testApiKey, ...query},
    );
  }

  /// Last request sent to [path].
  RequestOptions lastRequest(String path) =>
      requests.lastWhere((r) => r.path == path);
}
