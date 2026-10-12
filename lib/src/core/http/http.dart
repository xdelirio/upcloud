import 'dart:async';

import 'package:dio/dio.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http_logger.dart';
import 'package:upcloud/src/core/models/upload_request.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';

/// Default user agent sent by providers.
const defaultUserAgent = 'upcloud-dart';

/// Marks a request as safe to retry (set in `Options.extra`).
///
/// Retries are opt-in: many hosting APIs use GET for operations that
/// change data (create folder, delete file...), so only requests flagged
/// with `true` are retried.
const retryableExtraKey = 'upcloud.retryable';

/// Creates the [Dio] client used by a provider.
///
/// Reuses [ProviderOptions.dio] when given and installs rate limiting,
/// retries and logging interceptors.
Dio createDio({
  required Uri baseUrl,
  required ProviderOptions options,
  ProviderLimits limits = ProviderLimits.none,
}) {
  final dio = options.dio ?? Dio();
  dio.options
    ..baseUrl = _withSlash(baseUrl)
    ..connectTimeout = options.connectTimeout
    ..receiveTimeout = options.receiveTimeout
    ..responseType = ResponseType.json
    ..headers['user-agent'] = options.userAgent ?? defaultUserAgent;

  // Reusing a Dio instance must not stack our interceptors twice.
  dio.interceptors.removeWhere(
    (i) =>
        i is MirrorFallbackInterceptor ||
        i is RateLimitInterceptor ||
        i is RetryInterceptor ||
        i is LoggingInterceptor,
  );
  final mirrors = options.mirrors.where((m) => m != baseUrl).toList();
  if (mirrors.isNotEmpty) {
    dio.interceptors.add(MirrorFallbackInterceptor(dio, [baseUrl, ...mirrors]));
  }
  final interval = limits.minRequestInterval;
  if (interval != null && interval > Duration.zero) {
    dio.interceptors.add(RateLimitInterceptor(interval));
  }
  if (options.maxRetries > 0) {
    dio.interceptors.add(RetryInterceptor(dio, maxRetries: options.maxRetries));
  }
  final logger = options.logger;
  if (logger != null) dio.interceptors.add(LoggingInterceptor(logger));
  return dio;
}

String _withSlash(Uri uri) {
  final text = uri.toString();
  return text.endsWith('/') ? text : '$text/';
}

/// Runs [request] and converts Dio errors into [UpCloudException]s.
Future<T> guardRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on UpCloudException {
    rethrow;
  } on DioException catch (e, st) {
    throw mapDioException(e, st);
  }
}

/// Converts a [DioException] into the matching [UpCloudException].
UpCloudException mapDioException(DioException e, [StackTrace? stackTrace]) {
  final st = stackTrace ?? e.stackTrace;
  final inner = e.error;
  if (inner is UpCloudException) return inner;
  switch (e.type) {
    case DioExceptionType.cancel:
      return const CancelledException();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkException(
        e.message ?? e.type.name,
        cause: e,
        stackTrace: st,
      );
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      final response = e.response;
      final status = response?.statusCode;
      return httpStatusException(
        status,
        e.message ?? 'HTTP $status',
        retryAfter: parseRetryAfter(response?.headers.value('retry-after')),
        response: response?.data,
        cause: e,
        stackTrace: st,
      );
  }
}

/// Converts an HTTP error [status] into the matching [UpCloudException].
///
/// `401`/`403` are [AuthenticationException], `404` [NotFoundException],
/// `429` [RateLimitedException] (with [retryAfter]), a missing status
/// [NetworkException] and anything else [ProviderException].
UpCloudException httpStatusException(
  int? status,
  String message, {
  Duration? retryAfter,
  Object? response,
  Object? cause,
  StackTrace? stackTrace,
}) => switch (status) {
  401 ||
  403 => AuthenticationException(message, cause: cause, stackTrace: stackTrace),
  404 => NotFoundException(message, cause: cause, stackTrace: stackTrace),
  429 => RateLimitedException(
    message,
    retryAfter: retryAfter,
    cause: cause,
    stackTrace: stackTrace,
  ),
  null => NetworkException(message, cause: cause, stackTrace: stackTrace),
  _ => ProviderException(
    message,
    statusCode: status,
    response: response,
    cause: cause,
    stackTrace: stackTrace,
  ),
};

/// The error of an upload [response] with an HTTP error status whose body
/// does not explain it. See [httpStatusException].
UpCloudException uploadResponseException(UploadResponse response) =>
    httpStatusException(
      response.statusCode,
      'The upload failed with HTTP ${response.statusCode}',
      retryAfter: parseRetryAfter(response.header('retry-after')),
      response: response.body,
    );

/// Reads a `Retry-After` header expressed in seconds.
Duration? parseRetryAfter(String? value) {
  final seconds = value == null ? null : int.tryParse(value.trim());
  return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
}

/// Switches to the next base URL when the current one cannot be reached.
///
/// Only connection errors (DNS failures, refused connections, connect
/// timeouts) trigger the fallback, so the request never reached the server
/// and repeating it is safe. The working base URL is kept for later
/// requests. Absolute request URLs (e.g. upload servers) are not affected.
final class MirrorFallbackInterceptor extends Interceptor {
  /// Creates the interceptor for [dio] with [baseUrls] in priority order.
  MirrorFallbackInterceptor(this.dio, List<Uri> baseUrls)
    : baseUrls = [for (final url in baseUrls) _withSlash(url)];

  /// Client whose base URL is switched.
  final Dio dio;

  /// Base URLs in priority order, with a trailing slash.
  final List<String> baseUrls;

  static const _mirrorKey = 'upcloud.mirror';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isConnectionError =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;
    final isRelative = !request.path.startsWith(RegExp('https?://'));
    if (!isConnectionError ||
        !isRelative ||
        request.extra[_mirrorKey] == true ||
        !baseUrls.contains(request.baseUrl)) {
      handler.next(err);
      return;
    }
    final failed = request.baseUrl;
    var lastError = err;
    for (final base in baseUrls) {
      if (base == failed) continue;
      if (request.cancelToken?.isCancelled ?? false) break;
      final attempt = request.copyWith(baseUrl: base)..extra[_mirrorKey] = true;
      try {
        final response = await dio.fetch<dynamic>(attempt);
        dio.options.baseUrl = base;
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        lastError = e;
        final stillUnreachable =
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout;
        if (!stillUnreachable) {
          handler.next(e);
          return;
        }
      }
    }
    handler.next(lastError);
  }
}

/// Waits so that requests are at least [interval] apart.
final class RateLimitInterceptor extends Interceptor {
  /// Creates the interceptor.
  RateLimitInterceptor(this.interval);

  /// Minimum time between requests.
  final Duration interval;

  DateTime _nextSlot = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final now = DateTime.now();
    final slot = _nextSlot.isAfter(now) ? _nextSlot : now;
    _nextSlot = slot.add(interval);
    final wait = slot.difference(now);
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    handler.next(options);
  }
}

/// Retries idempotent requests on network errors, `429` and `5xx`.
final class RetryInterceptor extends Interceptor {
  /// Creates the interceptor for [dio].
  RetryInterceptor(
    this.dio, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxRetryAfter = const Duration(seconds: 30),
  });

  /// Client used to repeat the request.
  final Dio dio;

  /// Maximum number of retries per request.
  final int maxRetries;

  /// Delay before the first retry; doubles on every attempt.
  final Duration baseDelay;

  /// Longest `Retry-After` the interceptor waits for. Longer waits fail
  /// immediately with a `RateLimitedException` so callers can decide.
  final Duration maxRetryAfter;

  static const _attemptKey = 'upcloud.attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final attempt = (request.extra[_attemptKey] as int?) ?? 0;
    if (attempt >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }
    final retryAfter = parseRetryAfter(
      err.response?.headers.value('retry-after'),
    );
    if (retryAfter != null && retryAfter > maxRetryAfter) {
      handler.next(err);
      return;
    }
    final delay = retryAfter ?? baseDelay * (1 << attempt);
    await Future.any([
      Future<void>.delayed(delay),
      ?request.cancelToken?.whenCancel,
    ]);
    if (request.cancelToken?.isCancelled ?? false) {
      handler.next(err);
      return;
    }
    request.extra[_attemptKey] = attempt + 1;
    try {
      handler.resolve(await dio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    final request = err.requestOptions;
    final retryable = (request.extra[retryableExtraKey] as bool?) ?? false;
    if (!retryable) return false;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => switch (err.response?.statusCode) {
        final int code => code == 429 || code >= 500,
        null => false,
      },
      _ => false,
    };
  }
}

/// Logs requests and responses with secrets redacted.
final class LoggingInterceptor extends Interceptor {
  /// Creates the interceptor.
  LoggingInterceptor(this.log);

  /// Destination of the log lines.
  final HttpLogger log;

  static const _startKey = 'upcloud.start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    log('--> ${options.method} ${redactUri(options.uri)}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    log(
      '<-- ${response.statusCode} ${request.method} '
      '${redactUri(request.uri)} (${_elapsed(request)})',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    log(
      '<-- ERROR ${err.response?.statusCode ?? err.type.name} '
      '${request.method} ${redactUri(request.uri)} (${_elapsed(request)})',
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions request) {
    final start = request.extra[_startKey];
    if (start is! DateTime) return '?';
    return '${DateTime.now().difference(start).inMilliseconds}ms';
  }
}
