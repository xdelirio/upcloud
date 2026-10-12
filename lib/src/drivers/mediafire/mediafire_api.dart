import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/upload_request.dart';

/// Signature sent to `user/get_session_token`:
/// `SHA1(email + password + application_id + api_key)`.
///
/// [apiKey] is only needed when the MediaFire application has "Require
/// Secret Key" enabled; otherwise it is left out of the hash.
String mediaFireSessionSignature({
  required String email,
  required String password,
  required String applicationId,
  String? apiKey,
}) {
  final input = '$email$password$applicationId${apiKey ?? ''}';
  return sha1.convert(utf8.encode(input)).toString();
}

/// Converts a MediaFire error code (`"error"` field) into the matching
/// [UpCloudException].
///
/// See https://www.mediafire.com/developers/core_api/1.5/getting_started/#error_codes
UpCloudException mediaFireException(
  int? code,
  String message, {
  Object? response,
}) {
  return switch (code) {
    // Missing/invalid API key, token, credentials, user, app id, signature;
    // disabled/suspended app; locked account; unauthenticated app.
    102 ||
    103 ||
    104 ||
    105 ||
    107 ||
    108 ||
    109 ||
    127 ||
    145 ||
    146 || //
    215 ||
    243 ||
    248 => AuthenticationException(message, cause: response),
    // Invalid quickkey/folderkey, removed by DMCA, already deleted, unknown
    // folder/file path.
    110 ||
    112 ||
    165 ||
    209 ||
    210 ||
    259 ||
    260 => NotFoundException(message, cause: response),
    // Non premium limit, storage limit, copy limit.
    130 || 162 || 207 => QuotaExceededException(message, cause: response),
    // API access limit, rate limit.
    163 || 261 => RateLimitedException(message, cause: response),
    _ => ProviderException(message, statusCode: code, response: response),
  };
}

/// Error payload (`"result": "Error"`) returned by the API.
final class _ApiError implements Exception {
  const _ApiError(this.code, this.message, this.response);

  final int? code;
  final String message;
  final Object? response;

  /// The session token is missing, expired or invalid.
  bool get isTokenError => code == 104 || code == 105;

  UpCloudException toException() =>
      mediaFireException(code, message, response: response);
}

/// Low level client for the MediaFire Core API 1.5.
///
/// Handles the session token (version 1) transparently:
///
/// * the first authenticated call logs in with `user/get_session_token`;
/// * tokens older than [renewAfter] are extended with
///   `user/renew_session_token` (falling back to a new login);
/// * upload URLs get a token younger than [uploadTokenMaxAge];
/// * a call rejected because the token expired (errors 104/105) logs in
///   again and is retried once.
///
/// Every call is a form encoded `POST` with `response_format=json`.
/// Uploads are sent by an `UploadExecutor` to an [authenticatedUrl].
final class MediaFireApi {
  /// Creates a client that authenticates with the given credentials.
  MediaFireApi(
    this._dio, {
    required this.email,
    required this.password,
    required this.applicationId,
    this.apiKey,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Age after which the session token is renewed before being used.
  ///
  /// Version 1 tokens live ten minutes; MediaFire only renews tokens older
  /// than five minutes.
  static const renewAfter = Duration(minutes: 6);

  /// Oldest session token put in an [authenticatedUrl].
  ///
  /// The upload is sent later by an executor, maybe after waiting in a
  /// queue, so it needs at least half of the ten minutes of the token.
  /// Not lower: younger tokens cannot be extended, and every upload
  /// would sign in again.
  static const uploadTokenMaxAge = Duration(minutes: 5);

  final Dio _dio;

  /// Account email.
  final String email;

  /// Account password.
  final String password;

  /// Id of the MediaFire application used to log in.
  final String applicationId;

  /// Secret key of the application, when it requires one.
  final String? apiKey;

  final DateTime Function() _clock;

  String? _token;
  DateTime _tokenIssuedAt = DateTime.fromMillisecondsSinceEpoch(0);
  Future<String>? _pendingToken;
  bool _closed = false;

  /// Calls [action] (e.g. `folder/get_content`) with [params] and the
  /// session token, and returns the content of the `response` object.
  ///
  /// Set [retryable] for read-only (or idempotent) calls so network
  /// errors, `429` and `5xx` responses are retried.
  Future<Map<String, Object?>> request(
    String action, {
    Map<String, Object?> params = const {},
    bool retryable = false,
  }) {
    return _guard(
      () => _authenticated(
        (token) => _post(action, {
          ...params,
          'session_token': token,
        }, retryable: retryable),
      ),
    );
  }

  /// Absolute URL of [action] (e.g. `upload/simple`) with [query], a
  /// session token younger than [uploadTokenMaxAge] and
  /// `response_format=json`, for a request sent outside this client (an
  /// upload). Read its answer with [parseUploadResponse].
  Future<Uri> authenticatedUrl(
    String action, [
    Map<String, Object?> query = const {},
  ]) async {
    final token = await _guard(() => _sessionToken(maxAge: uploadTokenMaxAge));
    return Uri.parse(_dio.options.baseUrl)
        .resolve('$action.php')
        .replace(
          queryParameters: {
            ...compactParams(query),
            'session_token': token,
            'response_format': 'json',
          },
        );
  }

  /// Unwraps the [response] to an upload [request] built with
  /// [authenticatedUrl], throwing the matching [UpCloudException] for
  /// errors.
  ///
  /// A session token rejected because it expired before the upload was
  /// sent is forgotten and reported as a [ProviderException] without
  /// status, so the upload is retried with a new token.
  Map<String, Object?> parseUploadResponse(
    UploadRequest request,
    UploadResponse response,
  ) {
    final body = _unwrap(response.body);
    try {
      // `429` keeps the HTTP error, which carries `Retry-After`.
      if (body != null && response.statusCode != 429) _throwIfError(body);
    } on _ApiError catch (e) {
      if (!e.isTokenError) throw e.toException();
      final token = request.url.queryParameters['session_token'];
      if (token != null && token == _token) _token = null;
      throw ProviderException(
        'The MediaFire session expired before the upload was sent',
        cause: e.response,
      );
    }
    if (!response.isSuccessful) throw uploadResponseException(response);
    if (body == null) {
      throw ProviderException(
        'Unexpected upload response from MediaFire',
        statusCode: response.statusCode,
        response: response.body,
      );
    }
    return body;
  }

  /// Logs in if needed and returns a valid session token.
  ///
  /// Useful to check the credentials when an account is added.
  Future<String> sessionToken() => _guard(_sessionToken);

  /// Stops accepting calls.
  void close() => _closed = true;

  Future<T> _guard<T>(Future<T> Function() body) async {
    if (_closed) throw StateError('The MediaFire provider was closed');
    try {
      return await body();
    } on _ApiError catch (e) {
      throw e.toException();
    }
  }

  Future<Map<String, Object?>> _authenticated(
    Future<Map<String, Object?>> Function(String token) send,
  ) async {
    final token = await _sessionToken();
    try {
      return await send(token);
    } on _ApiError catch (e) {
      if (!e.isTokenError) rethrow;
      // Expired or revoked: log in again (unless another call already did)
      // and retry once. A second token error is reported to the caller.
      if (_token == token) _token = null;
      return await send(await _sessionToken());
    }
  }

  /// The session token, renewed or created again when it is older than
  /// [maxAge].
  ///
  /// A token being requested by another call is new, so it is shared
  /// whatever [maxAge] is.
  Future<String> _sessionToken({Duration maxAge = renewAfter}) {
    final pending = _pendingToken;
    if (pending != null) return pending;
    final token = _token;
    final age = _clock().difference(_tokenIssuedAt);
    if (token != null && age < maxAge) return Future.value(token);
    // MediaFire does not extend tokens younger than [renewAfter]: those
    // are replaced with a new login.
    final future =
        (token == null || age < renewAfter ? _login() : _renew(token))
            .whenComplete(() => _pendingToken = null);
    return _pendingToken = future;
  }

  Future<String> _login() async {
    _token = null;
    final body = await _post('user/get_session_token', {
      'email': email,
      'password': password,
      'application_id': applicationId,
      'signature': mediaFireSessionSignature(
        email: email,
        password: password,
        applicationId: applicationId,
        apiKey: apiKey,
      ),
      'token_version': 1,
    }, retryable: true);
    return _store(body) ??
        (throw const AuthenticationException(
          'MediaFire did not return a session token',
        ));
  }

  /// Extends [token] with `user/renew_session_token`; logs in again when
  /// MediaFire refuses.
  Future<String> _renew(String token) async {
    final Map<String, Object?> body;
    try {
      body = await _post('user/renew_session_token', {
        'session_token': token,
      }, retryable: true);
    } on _ApiError {
      return await _login();
    }
    return _store(body) ?? await _login();
  }

  /// Saves the `session_token` of [body] and returns it.
  String? _store(Map<String, Object?> body) {
    final token = readString(body['session_token'])?.trim();
    if (token == null || token.isEmpty) return null;
    _token = token;
    _tokenIssuedAt = _clock();
    return token;
  }

  Future<Map<String, Object?>> _post(
    String action,
    Map<String, Object?> params, {
    bool retryable = false,
  }) {
    return _send(
      () => _dio.post<Object?>(
        '$action.php',
        data: {...compactParams(params), 'response_format': 'json'},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {retryableExtraKey: retryable},
        ),
      ),
    );
  }

  /// Sends a request and unwraps `{"response": {...}}`, throwing [_ApiError]
  /// for error payloads (MediaFire answers errors with 4xx statuses and a
  /// JSON body).
  Future<Map<String, Object?>> _send(
    Future<Response<Object?>> Function() send,
  ) async {
    final response = await guardRequest(
      send,
      onBadResponse: (e, _) {
        // `429` keeps the HTTP error, which carries `Retry-After`.
        if (e.response?.statusCode == 429) return null;
        final body = _unwrap(e.response?.data);
        if (body != null) _throwIfError(body);
        return null;
      },
    );
    final body = _unwrap(response.data);
    if (body == null) {
      throw ProviderException(
        'Unexpected response from MediaFire',
        statusCode: response.statusCode,
        response: response.data,
      );
    }
    _throwIfError(body);
    return body;
  }

  /// The content of the `response` object of [data]. Upload endpoints
  /// answer JSON with a `text/xml` content type.
  static Map<String, Object?>? _unwrap(Object? data) {
    final map = readJsonObject(data);
    if (map == null) return null;
    return readMap(map['response']) ?? map;
  }

  static void _throwIfError(Map<String, Object?> body) {
    if (readString(body['result'])?.toLowerCase() != 'error') return;
    // Codes may be prefixed with "+" or "-".
    final code = readInt(body['error'])?.abs();
    final message = readString(body['message']) ?? 'MediaFire error $code';
    throw _ApiError(code, message, body);
  }
}
