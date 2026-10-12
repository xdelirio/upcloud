import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/provider_limits.dart';

part 'provider_config.freezed.dart';
part 'provider_config.g.dart';

/// A provider described as data: which driver talks to it, its domains,
/// limits and credentials.
///
/// Configs come from the provider registry (`registry/providers.json` in the
/// repository, bundled in the app and refreshed remotely) and can be
/// edited or added by the user.
///
/// ```json
/// {
///   "id": "streamhg",
///   "name": "StreamHG",
///   "driver": "xvs",
///   "website": "https://streamhg.com",
///   "apiBase": "https://streamhgapi.com/api",
///   "mirrors": ["https://streamhgapi.net/api"],
///   "fileUrlTemplate": "https://hgcloud.to/{id}",
///   "limits": {"maxFileSizeMb": 2048}
/// }
/// ```
@freezed
abstract class ProviderConfig with _$ProviderConfig {
  /// Creates a provider config.
  const factory ProviderConfig({
    /// Stable unique id (e.g. `streamhg`). Accounts reference it.
    required String id,

    /// Display name.
    required String name,

    /// Id of the `CloudDriver` that implements the API (e.g. `xvs`).
    required String driver,
    String? description,

    /// Home page of the service.
    Uri? website,

    /// Logo or favicon.
    Uri? iconUrl,

    /// Base URL the API paths are appended to.
    Uri? apiBase,

    /// Alternative API base URLs tried in order when [apiBase] cannot be
    /// reached (connection errors only).
    @Default(<Uri>[]) List<Uri> mirrors,

    /// Public link of a file, with [fileIdPlaceholder] where the file id
    /// of the provider goes (e.g. `https://hgcloud.to/{id}`).
    ///
    /// Drivers use the link returned by the API when there is one, then
    /// this template, then the default of the driver, if any (see
    /// `CloudDriver.defaultFileUrlTemplate`). See [fileUrl].
    String? fileUrlTemplate,

    /// Overrides the driver's default limits.
    LimitsConfig? limits,

    /// Overrides the driver's default credential fields.
    List<CredentialField>? credentials,

    /// Driver specific settings (see `CloudDriver.settings`).
    @Default(<String, Object?>{}) Map<String, Object?> settings,

    /// Names of [Capability] values the provider does not offer.
    @Default(<String>[]) List<String> disabledCapabilities,

    /// Disabled providers are hidden from the app.
    @Default(true) bool enabled,
  }) = _ProviderConfig;

  const ProviderConfig._();

  /// Reads a config from registry JSON.
  factory ProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$ProviderConfigFromJson(json);

  /// Placeholder of [fileUrlTemplate] replaced by the file id: the file
  /// code for `xvs` and `byse`, the quickkey for `mediafire`.
  static const fileIdPlaceholder = '{id}';

  /// Link of the file [id] built from [fileUrlTemplate], or `null` when
  /// there is no template (see [expandFileUrl]).
  ///
  /// ```dart
  /// config.fileUrl('a b'); // https://hgcloud.to/a%20b
  /// ```
  Uri? fileUrl(String id) => expandFileUrl(fileUrlTemplate, id);

  /// Replaces [fileIdPlaceholder] in [template] with the URL-encoded [id].
  ///
  /// Returns `null` when [template] or [id] is empty, when [template] has
  /// no placeholder or when the result is not an absolute URL.
  static Uri? expandFileUrl(String? template, String id) {
    final value = template?.trim();
    if (value == null || id.isEmpty || !value.contains(fileIdPlaceholder)) {
      return null;
    }
    final url = Uri.tryParse(
      value.replaceAll(fileIdPlaceholder, Uri.encodeComponent(id)),
    );
    return url != null && url.hasScheme && url.host.isNotEmpty ? url : null;
  }

  /// [disabledCapabilities] as enum values; unknown names are ignored.
  Set<Capability> get disabledCapabilitySet => {
    for (final name in disabledCapabilities)
      ?Capability.values.asNameMap()[name],
  };
}

/// Limits declared in a [ProviderConfig], in a human friendly format.
///
/// `null` fields keep the driver's default.
@freezed
abstract class LimitsConfig with _$LimitsConfig {
  /// Creates a limits config.
  const factory LimitsConfig({
    /// Maximum upload size in megabytes (MiB). `0` removes the limit.
    double? maxFileSizeMb,

    /// Accepted extensions. `["*"]` or an empty list accepts any file.
    List<String>? allowedExtensions,
    int? maxConcurrentUploads,

    /// Minimum milliseconds between API requests.
    int? minRequestIntervalMs,
  }) = _LimitsConfig;

  const LimitsConfig._();

  /// Reads limits from registry JSON.
  factory LimitsConfig.fromJson(Map<String, dynamic> json) =>
      _$LimitsConfigFromJson(json);

  /// Returns [base] with the fields declared here replaced.
  ProviderLimits applyTo(ProviderLimits base) {
    var limits = base;
    final maxMb = maxFileSizeMb;
    if (maxMb != null) {
      limits = limits.copyWith(
        maxFileSize: maxMb <= 0
            ? null
            : DataSize((maxMb * 1024 * 1024).round()),
      );
    }
    final extensions = allowedExtensions;
    if (extensions != null) {
      final normalized = {
        for (final e in extensions)
          e.trim().toLowerCase().replaceFirst('.', ''),
      }..remove('');
      limits = limits.copyWith(
        allowedExtensions: normalized.isEmpty || normalized.contains('*')
            ? null
            : normalized,
      );
    }
    if (maxConcurrentUploads case final uploads? when uploads > 0) {
      limits = limits.copyWith(maxConcurrentUploads: uploads);
    }
    if (minRequestIntervalMs case final ms?) {
      limits = limits.copyWith(
        minRequestInterval: ms <= 0 ? null : Duration(milliseconds: ms),
      );
    }
    return limits;
  }
}
