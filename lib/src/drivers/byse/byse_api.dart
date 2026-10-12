import 'package:dio/dio.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/upload_request.dart';

/// Low level client for the Byse REST API (`https://api.byse.sx`).
///
/// Adds the API key to every request, checks the
/// `{"status": ..., "msg": ..., "result": ...}` envelope and converts every
/// failure into an [UpCloudException].
final class ByseApi {
  /// Creates a client that sends [apiKey] with every request made by [dio].
  ByseApi(this.dio, this.apiKey);

  /// HTTP client, already configured with the API base URL.
  final Dio dio;

  /// Key sent as the `key` parameter.
  final String apiKey;

  /// Endpoints that only read data. Only these are retried on transient
  /// errors: Byse uses GET for writes too (folder/create, remote/add...)
  /// and repeating them would duplicate the action.
  static const readOnlyPaths = {
    'account/info',
    'file/info',
    'file/list',
    'folder/list',
    'remote/status',
    'upload/server',
  };

  /// Calls `GET [path]` and returns the whole response envelope.
  ///
  /// `null` values in [query] are not sent.
  Future<Map<String, Object?>> get(
    String path, {
    Map<String, Object?> query = const {},
  }) async {
    final response = await guardRequest(
      () => dio.get<Object?>(
        path,
        queryParameters: {'key': apiKey, ...compactParams(query)},
        options: Options(
          extra: {retryableExtraKey: readOnlyPaths.contains(path)},
        ),
      ),
      onBadResponse: _apiError,
    );
    return parseByseEnvelope(response.data);
  }

  /// The API error of an error page that still carries the envelope,
  /// preferred over the generic HTTP error. `429` keeps the HTTP error,
  /// which carries `Retry-After`.
  static UpCloudException? _apiError(DioException e, StackTrace st) {
    final response = e.response;
    if (response == null || response.statusCode == 429) return null;
    final body = readJsonObject(response.data);
    final message = body == null ? null : _message(body);
    if (body == null || message == null) return null;
    return byseApiException(
      readInt(body['status']) ?? response.statusCode,
      message,
      response: body,
      cause: e,
      stackTrace: st,
    );
  }
}

/// Checks the envelope of a Byse response and returns it as a map.
///
/// Throws the matching [UpCloudException] when `status` is not `2xx` and a
/// [ProviderException] when the body is not a JSON object.
Map<String, Object?> parseByseEnvelope(Object? data) {
  final body = readJsonObject(data);
  if (body == null) {
    throw ProviderException('Unexpected response from Byse', response: data);
  }
  _checkStatus(body);
  return body;
}

/// Checks the response of an upload server and returns its body.
///
/// Errors of a `2xx` response without an API status carry the HTTP status:
/// the server accepted the file, so uploading it again would not help.
Map<String, Object?> parseByseUploadResponse(UploadResponse response) {
  final body = readJsonObject(response.body);
  final message = body == null ? null : _message(body);
  if (!response.isSuccessful) {
    if (body == null || message == null || response.statusCode == 429) {
      throw uploadResponseException(response);
    }
    throw byseApiException(
      readInt(body['status']) ?? response.statusCode,
      message,
      response: body,
    );
  }
  if (body == null) {
    throw ProviderException(
      'Unexpected response from the Byse upload server',
      statusCode: response.statusCode,
      response: response.body,
    );
  }
  _checkStatus(body);
  return body;
}

void _checkStatus(Map<String, Object?> body) {
  final status = readInt(body['status']);
  if (status != null && (status < 200 || status >= 300)) {
    throw byseApiException(status, _message(body), response: body);
  }
}

/// Converts an API level error ([status] and [message] from the envelope)
/// into the matching [UpCloudException].
///
/// Byse answers most errors with HTTP 200 and the real code in the body,
/// e.g. `{"status": 400, "msg": "Invalid key"}`.
UpCloudException byseApiException(
  int? status,
  String? message, {
  Object? response,
  Object? cause,
  StackTrace? stackTrace,
}) {
  final text = message ?? 'Byse API error${status == null ? '' : ' $status'}';
  final lower = text.toLowerCase();
  if (status == 401 || _authPattern.hasMatch(lower)) {
    return AuthenticationException(text, cause: cause, stackTrace: stackTrace);
  }
  if (status == 429 || _rateLimitPattern.hasMatch(lower)) {
    return RateLimitedException(text, cause: cause, stackTrace: stackTrace);
  }
  if (status == 404 || _notFoundPattern.hasMatch(lower)) {
    return NotFoundException(text, cause: cause, stackTrace: stackTrace);
  }
  if (_quotaPattern.hasMatch(lower)) {
    return QuotaExceededException(text, cause: cause, stackTrace: stackTrace);
  }
  return ProviderException(
    text,
    statusCode: status,
    response: response,
    cause: cause,
    stackTrace: stackTrace,
  );
}

final _authPattern = RegExp(
  r'\b(invalid|wrong|bad|missing|no|expired|incorrect)\s+(api\s+)?key\b|'
  r'\bkey\s+(is\s+)?(invalid|wrong|missing|expired|required)\b|'
  r'unauthori[sz]ed|not\s+authori[sz]ed|authentication',
);

final _rateLimitPattern = RegExp(r'too\s+many\s+requests|rate\s*limit');

final _notFoundPattern = RegExp(
  r'not\s+found|\bno\s+(such\s+)?(file|folder|video)s?\b|n.?t\s+exist',
);

final _quotaPattern = RegExp(
  r'quota|not\s+enough\s+(disk\s+)?(space|storage|bandwidth)|disk\s+space|'
  r'storage\s+(is\s+)?full|limit\s+(reached|exceeded)',
);

String? _message(Map<String, Object?> body) =>
    readString(body['msg']) ??
    readString(body['message']) ??
    readString(body['error']);
