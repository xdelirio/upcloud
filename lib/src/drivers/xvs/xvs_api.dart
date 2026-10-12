import 'package:dio/dio.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/upload_request.dart';

/// Low level client for the XVideoSharing HTTP API.
///
/// Every endpoint is a `GET` authenticated with the `key` query parameter
/// and answers with an envelope:
///
/// ```json
/// {"msg": "OK", "status": 200, "server_time": "...", "result": ...}
/// ```
///
/// Envelopes with a status other than `200` are converted into
/// [UpCloudException]s by [xvsError].
final class XvsApi {
  /// Creates a client that sends requests with a Dio client whose base URL
  /// is the API base (e.g. `https://xvideosharing.com/api/`).
  ///
  /// The API key getter is called for every request, so a missing key
  /// surfaces as an [AuthenticationException] from the first request.
  XvsApi(this._dio, this._apiKey);

  final Dio _dio;
  final String Function() _apiKey;

  /// Endpoints that only read data. Only these are retried on transient
  /// errors: the XVS API uses GET for writes too (folder/create,
  /// file/delete...) and repeating them would duplicate the action.
  static const readOnlyPaths = {
    'account/info',
    'file/info',
    'file/list',
    'file/url_uploads',
    'folder/list',
    'upload/server',
  };

  /// Calls `GET [path]` and returns the `result` of the envelope.
  ///
  /// `null` values in [query] are skipped.
  Future<Object?> get(
    String path, [
    Map<String, Object?> query = const {},
  ]) async => (await getEnvelope(path, query))['result'];

  /// Calls `GET [path]` and returns the whole envelope.
  Future<Map<String, Object?>> getEnvelope(
    String path, [
    Map<String, Object?> query = const {},
  ]) => guardRequest(() async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: {'key': _apiKey(), ...compactParams(query)},
      options: Options(
        extra: {retryableExtraKey: readOnlyPaths.contains(path)},
      ),
    );
    return checkEnvelope(response.data);
  }, onBadResponse: _apiError);

  /// The multipart fields of an upload: the API key (`key`) followed by
  /// [fields] without `null` values.
  Map<String, String> uploadFields(Map<String, Object?> fields) => {
    'key': _apiKey(),
    ...compactParams(fields),
  };

  /// Closes the underlying HTTP client.
  void close({bool force = false}) => _dio.close(force: force);

  /// The API error of an error response, preferred over the generic HTTP
  /// error. `429` keeps the HTTP error, which carries `Retry-After`.
  static UpCloudException? _apiError(DioException e, StackTrace st) {
    final response = e.response;
    if (response == null || response.statusCode == 429) return null;
    final envelope = readJsonObject(response.data);
    final message = readString(envelope?['msg']);
    if (envelope == null || message == null) return null;
    return xvsError(
      status: readInt(envelope['status']) ?? response.statusCode,
      message: message,
      response: envelope,
      cause: e,
      stackTrace: st,
    );
  }
}

/// Validates an XVS envelope and returns it as a map.
///
/// Accepts JSON already decoded or as text (many clones answer JSON with a
/// `text/html` content type). Throws the exception built by [xvsError] when
/// the status is not `200`.
Map<String, Object?> checkEnvelope(Object? data) {
  final envelope = readJsonObject(data);
  if (envelope == null) {
    throw ProviderException('Unexpected response from the API', response: data);
  }
  _throwIfError(envelope);
  return envelope;
}

/// Throws the exception built by [xvsError] when [envelope] is not a
/// success. [fallbackStatus] is used when the envelope has no status.
void _throwIfError(Map<String, Object?> envelope, {int? fallbackStatus}) {
  final status = readInt(envelope['status']);
  final message = readString(envelope['msg']);
  final ok =
      status == 200 ||
      (status == null && (message == null || message.toUpperCase() == 'OK'));
  if (!ok) {
    throw xvsError(
      status: status ?? fallbackStatus,
      message: message ?? 'Unknown error',
      response: envelope,
    );
  }
}

/// Answer of clones that turned an endpoint off (StreamHG and EarnVids for
/// `file/delete` and `folder/delete`).
final _unsupportedPattern = RegExp(
  r'^\s*invalid (operation|op|action)\W*$',
  caseSensitive: false,
);
final _authPattern = RegExp(
  r'(\bkey\b|api[ _-]?key|unauthori[sz]ed|not authori[sz]ed|authenticat)',
  caseSensitive: false,
);
final _notFoundPattern = RegExp(
  "(not found|no such|does ?n[o']t exist|not exist|"
  '(invalid|wrong|unknown) (file[ _]?(code|id)|fld[ _]?id|folder))',
  caseSensitive: false,
);
final _rateLimitPattern = RegExp(
  '(too many|rate limit|slow down|try again later)',
  caseSensitive: false,
);
final _quotaPattern = RegExp(
  '(quota|limit|exceed|storage|disk space|no space|not enough space|'
  'bandwidth|traffic|max(imum)? (file)?size|too (big|large))',
  caseSensitive: false,
);

/// Validates the response of an upload server and returns its envelope.
///
/// Errors of a `2xx` response carry its HTTP status when the envelope has
/// none: the server accepted the file, so uploading it again would not
/// help.
Map<String, Object?> checkUploadResponse(UploadResponse response) {
  final envelope = readJsonObject(response.body);
  final message = readString(envelope?['msg']);
  if (!response.isSuccessful) {
    // `429` keeps the HTTP error, which carries `Retry-After`.
    if (envelope == null || message == null || response.statusCode == 429) {
      throw uploadResponseException(response);
    }
    throw xvsError(
      status: readInt(envelope['status']) ?? response.statusCode,
      message: message,
      response: envelope,
    );
  }
  if (envelope == null) {
    throw ProviderException(
      'Unexpected response from the upload server',
      statusCode: response.statusCode,
      response: response.body,
    );
  }
  _throwIfError(envelope, fallbackStatus: response.statusCode);
  return envelope;
}

/// Converts an XVS error ([status] and [message] of the envelope) into the
/// matching [UpCloudException].
///
/// * "Invalid operation" (the clone has no such endpoint):
///   [UnsupportedOperationException].
/// * Messages about the API key, `401` and `403`: [AuthenticationException].
/// * `404` and "not found" messages: [NotFoundException].
/// * `429` and "too many requests" messages: [RateLimitedException].
/// * Messages about limits, storage or traffic: [QuotaExceededException].
/// * Anything else: [ProviderException].
UpCloudException xvsError({
  required int? status,
  required String message,
  Object? response,
  Object? cause,
  StackTrace? stackTrace,
}) {
  if (_unsupportedPattern.hasMatch(message)) {
    return UnsupportedOperationException(message);
  }
  if (_authPattern.hasMatch(message)) {
    return AuthenticationException(
      message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
  if (status == 404 || _notFoundPattern.hasMatch(message)) {
    return NotFoundException(message, cause: cause, stackTrace: stackTrace);
  }
  if (status == 429 || _rateLimitPattern.hasMatch(message)) {
    return RateLimitedException(message, cause: cause, stackTrace: stackTrace);
  }
  if (_quotaPattern.hasMatch(message)) {
    return QuotaExceededException(
      message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
  if (status == 401 || status == 403) {
    return AuthenticationException(
      message,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
  return ProviderException(
    message,
    statusCode: status,
    response: response,
    cause: cause,
    stackTrace: stackTrace,
  );
}
