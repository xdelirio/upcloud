import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/http/http_logger.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/registry/provider_config.dart';

part 'provider_definition.freezed.dart';

/// Static description of a provider.
@freezed
abstract class ProviderInfo with _$ProviderInfo {
  /// Creates a provider description.
  const factory ProviderInfo({
    /// Stable unique id (e.g. `streamhg`). Used to persist accounts.
    required String id,

    /// Display name (e.g. `StreamHG`).
    required String name,

    /// Home page of the service.
    Uri? website,

    /// Logo or favicon.
    Uri? iconUrl,

    /// Id of the driver that implements the provider's API (e.g. `xvs`).
    String? driver,
    String? description,
  }) = _ProviderInfo;
}

/// Per-account overrides applied when a provider is created.
@freezed
abstract class ProviderOptions with _$ProviderOptions {
  /// Creates provider options.
  const factory ProviderOptions({
    /// Replaces the provider's API base URL. Useful when a service moves to
    /// a new domain before the package is updated.
    Uri? baseUrl,

    /// Alternative API base URLs tried in order when the base URL cannot be
    /// reached (connection errors only).
    @Default(<Uri>[]) List<Uri> mirrors,

    /// Replaces the provider's default limits.
    ProviderLimits? limits,

    /// Custom Dio instance (proxies, extra interceptors, testing adapters).
    /// Its `baseUrl` is overwritten by the provider.
    Dio? dio,

    /// Receives request/response logs.
    HttpLogger? logger,

    /// User agent sent with every request.
    String? userAgent,

    /// Retries for idempotent requests that fail with network errors,
    /// `429` or `5xx`.
    @Default(2) int maxRetries,
    @Default(Duration(seconds: 20)) Duration connectTimeout,
    @Default(Duration(seconds: 60)) Duration receiveTimeout,
  }) = _ProviderOptions;
}

/// Creates a [CloudProvider] for some credentials.
typedef ProviderFactory = CloudProvider Function(
  ProviderDefinition definition,
  Credentials credentials,
  ProviderOptions options,
);

/// Everything needed to list a provider in the UI and connect to it.
///
/// Register definitions in `UpCloud` to make them available to the app.
final class ProviderDefinition {
  /// Creates a definition.
  const ProviderDefinition({
    required this.info,
    required this.credentialSchema,
    required this.capabilities,
    required this._factory,
    this.defaultLimits = ProviderLimits.none,
    this.defaultBaseUrl,
    this.config,
  });

  /// Static description.
  final ProviderInfo info;

  /// Values required to authenticate.
  final CredentialSchema credentialSchema;

  /// Capabilities every instance supports. Lets the UI show features before
  /// an account is connected.
  final Set<Capability> capabilities;

  /// Limits used unless overridden by [ProviderOptions.limits].
  final ProviderLimits defaultLimits;

  /// API base URL used unless overridden by [ProviderOptions.baseUrl].
  final Uri? defaultBaseUrl;

  /// Registry entry this definition was built from, if any.
  final ProviderConfig? config;

  final ProviderFactory _factory;

  /// Shortcut for `info.id`.
  String get id => info.id;

  /// Creates a provider authenticated with [credentials].
  CloudProvider create(
    Credentials credentials, {
    ProviderOptions options = const ProviderOptions(),
  }) => _factory(this, credentials, options);

  /// Base URL to use with [options].
  Uri? baseUrlFor(ProviderOptions options) => options.baseUrl ?? defaultBaseUrl;

  /// Limits to use with [options].
  ProviderLimits limitsFor(ProviderOptions options) =>
      options.limits ?? defaultLimits;

  @override
  String toString() => 'ProviderDefinition(${info.id})';
}
