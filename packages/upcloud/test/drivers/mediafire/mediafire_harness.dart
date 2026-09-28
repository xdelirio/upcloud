import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:upcloud/upcloud.dart';

/// Session token returned by `session_token.json`.
const loginToken =
    'd590e7ddf92917a14f2ebe1c6767a160d3cdf5f725d3d274215378c75ba52852e080097'
    '6f7f88f53446dbad342ebefe85c75d647c5f3ee3e82724ecf1dbf23695e7a26f2a8f600e0';

/// Session token returned by `renew_session_token.json`.
const renewedToken =
    '7d31c37ae57f08951f7e50e69eaf81d2a1a8c047aabc945272e838f82e3384f4ebfe894'
    '53f888b9c3a7a777667ada551c21604493d9863e61db0593ad06a45cf2d46f016771732a4';

/// Reads `test/fixtures/mediafire/<name>.json`.
Map<String, Object?> fixture(String name) =>
    jsonDecode(File('test/fixtures/mediafire/$name.json').readAsStringSync())
        as Map<String, Object?>;

/// A successful MediaFire payload.
Map<String, Object?> success([Map<String, Object?> body = const {}]) => {
  'response': {'result': 'Success', 'current_api_version': '1.5', ...body},
};

/// A MediaFire error payload.
Map<String, Object?> apiError(int code, String message) => {
  'response': {
    'message': message,
    'error': code,
    'result': 'Error',
    'current_api_version': '1.5',
  },
};

/// A login response returning [token].
Map<String, Object?> sessionToken(String token) =>
    success({'action': 'user/get_session_token', 'session_token': token});

/// Mocked MediaFire server plus a log of the requests sent to it.
final class MediaFireHarness {
  /// Creates the mocks.
  MediaFireHarness() {
    adapter = DioAdapter(dio: dio);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.next(options);
        },
      ),
    );
  }

  /// Client given to the provider through `ProviderOptions.dio`.
  final Dio dio = Dio();

  /// Mock adapter; later registrations win over earlier ones.
  late final DioAdapter adapter;

  /// Every request sent, in order.
  final List<RequestOptions> requests = [];

  /// Current time seen by the provider.
  DateTime now = DateTime.utc(2026, 9, 27, 12);

  /// Default credentials.
  static final Credentials credentials = MediaFireCredentials.create(
    email: 'me@example.com',
    password: 'secret',
    applicationId: '42',
  );

  /// Creates a provider talking to the mocks.
  MediaFireProvider provider({
    ProviderLimits? limits,
    Duration pollTimeout = const Duration(minutes: 1),
  }) => MediaFireProvider(
    credentials: credentials,
    options: ProviderOptions(dio: dio, maxRetries: 0),
    limits: limits,
    pollInterval: Duration.zero,
    pollTimeout: pollTimeout,
    clock: () => now,
  );

  /// Answers `<action>.php` with [body].
  ///
  /// [data] restricts the mock to requests whose form fields contain it.
  void on(
    String action,
    Object? body, {
    int status = 200,
    Map<String, Object?>? data,
    bool asText = false,
  }) => adapter.onPost(
    '$action.php',
    (server) => server.reply(
      status,
      asText ? jsonEncode(body) : body,
      headers: {
        Headers.contentTypeHeader: [
          if (asText) 'text/xml' else Headers.jsonContentType,
        ],
      },
    ),
    data: data ?? Matchers.any,
  );

  /// Answers `<action>.php` with the result of [body].
  void onCallback(
    String action,
    Object? Function(RequestOptions options) body, {
    int status = 200,
  }) => adapter.onPost(
    '$action.php',
    (server) => server.replyCallback(status, body),
    data: Matchers.any,
  );

  /// Makes `<action>.php` fail with [error].
  void onThrow(String action, DioException error) => adapter.onPost(
    '$action.php',
    (server) => server.throws(0, error),
    data: Matchers.any,
  );

  /// Mocks a successful login.
  void login() => on('user/get_session_token', fixture('session_token'));

  /// Requests sent to [action].
  List<RequestOptions> calls(String action) =>
      requests.where((r) => r.path == '$action.php').toList();

  /// Actions called, in order (`folder/get_content`, ...).
  List<String> get actions => [
    for (final r in requests) r.path.replaceAll('.php', ''),
  ];
}

/// Form fields of a form encoded request.
Map<String, Object?> fields(RequestOptions options) =>
    (options.data as Map).cast<String, Object?>();
