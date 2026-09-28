import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/registry/config_problem.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// Kind of value of a [DriverSetting].
enum DriverSettingKind {
  /// Free text.
  text,

  /// A URL or URL template.
  url,

  /// A number.
  number,

  /// A boolean flag.
  flag,
}

/// A driver specific setting accepted in `ProviderConfig.settings`.
///
/// Lets UIs build editors for provider configs.
final class DriverSetting {
  /// Creates a setting description.
  const DriverSetting({
    required this.key,
    required this.label,
    this.kind = DriverSettingKind.text,
    this.description,
  });

  /// Key inside `ProviderConfig.settings`.
  final String key;

  /// Label shown to the user.
  final String label;

  /// Kind of value.
  final DriverSettingKind kind;

  /// Help text.
  final String? description;
}

/// Implements the API shared by a group of providers.
///
/// Drivers are code; providers are data ([ProviderConfig]). For example the
/// `xvs` driver speaks the XVideoSharing API, and StreamHG or EarnVids are
/// registry entries using it with different domains.
///
/// Implement this class to support a new API, then register the driver in
/// `UpCloud(drivers: [...])`.
abstract base class CloudDriver {
  /// Const constructor for subclasses.
  const CloudDriver();

  /// Stable id referenced by `ProviderConfig.driver` (e.g. `xvs`).
  String get id;

  /// Display name (e.g. `XVideoSharing`).
  String get name;

  /// Short description of the API family.
  String? get description => null;

  /// Capabilities every provider of this driver supports, before
  /// `ProviderConfig.disabledCapabilities` is applied.
  Set<Capability> get capabilities;

  /// Limits used when the config does not declare its own.
  ProviderLimits get defaultLimits => ProviderLimits.none;

  /// Whether `ProviderConfig.apiBase` must be set.
  bool get requiresApiBase => true;

  /// Settings understood in `ProviderConfig.settings`.
  List<DriverSetting> get settings => const [];

  /// Credential fields used when the config does not declare its own.
  CredentialSchema defaultCredentials(ProviderConfig config) =>
      CredentialSchema.apiKey();

  /// File link template used when [config] has no
  /// [ProviderConfig.fileUrlTemplate], or `null` when the driver has no
  /// default (files then only get the links returned by the API).
  String? defaultFileUrlTemplate(ProviderConfig config) => null;

  /// Creates a provider for [definition] (built from a [ProviderConfig],
  /// available as [ProviderDefinition.config]).
  CloudProvider create(
    ProviderDefinition definition,
    Credentials credentials,
    ProviderOptions options,
  );

  /// Builds the definition of the provider described by [config].
  ///
  /// Throws [InvalidProviderConfigException] when [config] is not valid for
  /// this driver.
  ProviderDefinition definitionFor(ProviderConfig config) {
    final problems = validate(config);
    if (problems.isNotEmpty) {
      throw InvalidProviderConfigException(config.id, problems);
    }
    return ProviderDefinition(
      info: ProviderInfo(
        id: config.id,
        name: config.name,
        website: config.website,
        iconUrl: config.iconUrl,
        driver: id,
        description: config.description,
      ),
      credentialSchema: switch (config.credentials) {
        final fields? when fields.isNotEmpty => CredentialSchema(fields),
        _ => defaultCredentials(config),
      },
      capabilities: capabilities.difference(config.disabledCapabilitySet),
      defaultLimits: config.limits?.applyTo(defaultLimits) ?? defaultLimits,
      defaultBaseUrl: config.apiBase,
      fileUrlTemplate: switch (config.fileUrlTemplate?.trim()) {
        final template? when template.isNotEmpty => template,
        _ => defaultFileUrlTemplate(config),
      },
      config: config,
      factory: (definition, credentials, options) => create(
        definition,
        credentials,
        options.mirrors.isEmpty && config.mirrors.isNotEmpty
            ? options.copyWith(mirrors: config.mirrors)
            : options,
      ),
    );
  }

  /// Returns the problems of [config], empty when it is valid.
  ///
  /// Subclasses can add driver specific checks:
  ///
  /// ```dart
  /// @override
  /// List<ConfigProblem> validate(ProviderConfig config) => [
  ///   ...super.validate(config),
  ///   if (config.settings['region'] == null)
  ///     const ConfigProblem(ConfigProblemCode.other, 'region is required'),
  /// ];
  /// ```
  List<ConfigProblem> validate(ProviderConfig config) => [
    if (config.driver != id)
      ConfigProblem(
        ConfigProblemCode.wrongDriver,
        'driver is "${config.driver}", expected "$id"',
        field: 'driver',
      ),
    if (!_idPattern.hasMatch(config.id))
      const ConfigProblem(
        ConfigProblemCode.invalidId,
        'id must use lowercase letters, digits, "_" or "-"',
        field: 'id',
      ),
    if (config.name.trim().isEmpty)
      const ConfigProblem(
        ConfigProblemCode.missingName,
        'name is required',
        field: 'name',
      ),
    if (requiresApiBase && config.apiBase == null)
      const ConfigProblem(
        ConfigProblemCode.missingApiBase,
        'apiBase is required',
        field: 'apiBase',
      ),
    ..._urlProblems('apiBase', [?config.apiBase]),
    ..._urlProblems('mirrors', config.mirrors),
    ?fileUrlTemplateProblem(config.fileUrlTemplate),
  ];

  /// Problem of a file link [template] (see
  /// [ProviderConfig.fileUrlTemplate]), or `null` when it is valid.
  ///
  /// The template must be an absolute `https` URL that contains
  /// [ProviderConfig.fileIdPlaceholder]. A `null` or blank template is
  /// valid: the driver default is used.
  static ConfigProblem? fileUrlTemplateProblem(String? template) {
    if (template == null || template.trim().isEmpty) return null;
    const field = 'fileUrlTemplate';
    const placeholder = ProviderConfig.fileIdPlaceholder;
    if (!template.contains(placeholder)) {
      return const ConfigProblem(
        ConfigProblemCode.missingIdPlaceholder,
        '$field must contain $placeholder',
        field: field,
      );
    }
    final url = ProviderConfig.expandFileUrl(template, 'id');
    if (url == null) {
      return ConfigProblem(
        ConfigProblemCode.invalidUrl,
        '$field must be an absolute URL: $template',
        field: field,
      );
    }
    if (url.scheme != 'https') {
      return ConfigProblem(
        ConfigProblemCode.insecureUrl,
        '$field must use https: $template',
        field: field,
      );
    }
    return null;
  }

  static final _idPattern = RegExp(r'^[a-z0-9][a-z0-9_-]*$');

  static Iterable<ConfigProblem> _urlProblems(
    String field,
    List<Uri> urls,
  ) sync* {
    for (final url in urls) {
      if (!url.hasScheme || url.host.isEmpty) {
        yield ConfigProblem(
          ConfigProblemCode.invalidUrl,
          '$field must be an absolute URL: $url',
          field: field,
        );
      } else if (url.scheme != 'https') {
        yield ConfigProblem(
          ConfigProblemCode.insecureUrl,
          '$field must use https: $url',
          field: field,
        );
      }
    }
  }

  @override
  String toString() => 'CloudDriver($id)';
}
