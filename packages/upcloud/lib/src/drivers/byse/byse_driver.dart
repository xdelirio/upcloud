import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/drivers/byse/byse_provider.dart';
import 'package:upcloud/src/registry/cloud_driver.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// Default API base URL of Byse.
final Uri byseApiBaseUrl = Uri.https('api.byse.sx');

/// Default upload limits of Byse.
///
/// The upload page of byse.sx only accepts these extensions and shows a
/// "2 GB" per file limit by default (the real limit is sent by the server
/// and may be higher for premium accounts; override it in the registry or
/// with `ProviderOptions.limits`).
const ProviderLimits byseLimits = ProviderLimits(
  maxFileSize: DataSize.mb(2048),
  allowedExtensions: {
    '3gp', 'avi', 'flv', 'mkv', 'mov', 'mp4', 'mpeg', 'mpg', 'ts', 'vob', //
    'webm', 'wmv',
  },
);

/// Operations supported by the Byse API.
const byseCapabilities = <Capability>{
  Capability.browseFolders,
  Capability.createFolder,
  Capability.fileInfo,
  Capability.moveFile,
  Capability.search,
  Capability.upload,
  Capability.remoteUpload,
  Capability.accountInfo,
};

/// Driver for Byse (https://byse.sx), a video host whose API derives from
/// Filemoon but diverged enough to be implemented on its own.
final class ByseDriver extends CloudDriver {
  /// Creates the driver. Prefer the [byseDriver] instance.
  const ByseDriver();

  /// Id of this driver in registry entries.
  static const driverId = 'byse';

  @override
  String get id => driverId;

  @override
  String get name => 'Byse';

  @override
  String get description => 'Byse video hosting.';

  @override
  Set<Capability> get capabilities => byseCapabilities;

  @override
  ProviderLimits get defaultLimits => byseLimits;

  /// Falls back to [byseApiBaseUrl].
  @override
  bool get requiresApiBase => false;

  /// The API key shown in the account settings of the website.
  @override
  CredentialSchema defaultCredentials(ProviderConfig config) =>
      CredentialSchema.apiKey(
        helpUrl: (config.website ?? Uri.https('byse.sx')).resolve('/settings'),
      );

  @override
  CloudProvider create(
    ProviderDefinition definition,
    Credentials credentials,
    ProviderOptions options,
  ) => ByseProvider(
    credentials: credentials,
    options: options,
    definition: definition,
  );
}

/// The Byse driver.
const byseDriver = ByseDriver();

/// Definition used when a [ByseProvider] is created without one (the
/// registry entry `byse` normally provides it).
final ProviderDefinition byseFallbackDefinition = byseDriver.definitionFor(
  ProviderConfig(
    id: 'byse',
    name: 'Byse',
    driver: ByseDriver.driverId,
    website: Uri.https('byse.sx'),
    apiBase: byseApiBaseUrl,
  ),
);
