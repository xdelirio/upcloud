/// Receives log lines from the HTTP layer.
///
/// API keys are redacted before reaching the logger.
typedef HttpLogger = void Function(String message);

/// Query/form keys whose values are replaced by `***` in logs.
const redactedKeys = {
  'key',
  'api_key',
  'apikey',
  'password',
  'session_token',
  'token',
  'signature',
};

/// Returns [uri] with secret query parameters replaced by `***`.
String redactUri(Uri uri) {
  if (uri.queryParameters.isEmpty) return uri.toString();
  String encode(String key, String value) {
    final secret = redactedKeys.contains(key.toLowerCase());
    final shown = secret ? '***' : Uri.encodeQueryComponent(value);
    return '${Uri.encodeQueryComponent(key)}=$shown';
  }

  final query = [
    for (final MapEntry(:key, :value) in uri.queryParameters.entries)
      encode(key, value),
  ].join('&');
  return uri.replace(query: query).toString();
}
