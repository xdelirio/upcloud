import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_provider.dart';
import 'package:upcloud/src/registry/cloud_driver.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// Default API base URL of MediaFire.
final Uri mediaFireDefaultBaseUrl = Uri.parse(
  'https://www.mediafire.com/api/1.5/',
);

/// Default file link template of MediaFire (`{id}` is the quickkey).
const mediaFireFileUrlTemplate = 'https://www.mediafire.com/file/{id}';

/// Default limits: free accounts accept files up to 5 GB (paid plans up to
/// 50 GB; raise it in the registry or with `ProviderOptions.limits`).
const mediaFireLimits = ProviderLimits(maxFileSize: DataSize.gb(5));

/// Operations supported by the MediaFire API.
const mediaFireCapabilities = <Capability>{
  Capability.browseFolders,
  ...Capability.folderManagement,
  ...Capability.fileManagement,
  Capability.search,
  Capability.upload,
  Capability.remoteUpload,
  Capability.accountInfo,
};

/// Driver for the MediaFire Core API 1.5.
///
/// Signs in with email, password and the id of a MediaFire developer
/// application (see [MediaFireCredentials]).
final class MediaFireDriver extends CloudDriver {
  /// Creates the driver. Prefer the [mediaFireDriver] instance.
  const MediaFireDriver();

  /// Id of this driver in registry entries.
  static const driverId = 'mediafire';

  @override
  String get id => driverId;

  @override
  String get name => 'MediaFire';

  @override
  String get description => 'MediaFire cloud storage (Core API 1.5).';

  @override
  Set<Capability> get capabilities => mediaFireCapabilities;

  @override
  ProviderLimits get defaultLimits => mediaFireLimits;

  /// Falls back to [mediaFireDefaultBaseUrl].
  @override
  bool get requiresApiBase => false;

  @override
  CredentialSchema defaultCredentials(ProviderConfig config) =>
      MediaFireCredentials.schema;

  /// [mediaFireFileUrlTemplate].
  @override
  String defaultFileUrlTemplate(ProviderConfig config) =>
      mediaFireFileUrlTemplate;

  @override
  CloudProvider create(
    ProviderDefinition definition,
    Credentials credentials,
    ProviderOptions options,
  ) => MediaFireProvider(
    credentials: credentials,
    options: options,
    info: definition.info,
    limits: definition.limitsFor(options),
    capabilities: definition.capabilities,
    baseUrl: definition.baseUrlFor(options),
    fileUrlTemplate: definition.fileUrlTemplate,
  );
}

/// The MediaFire driver.
const mediaFireDriver = MediaFireDriver();

/// Definition used when a [MediaFireProvider] is created without one (the
/// registry entry `mediafire` normally provides it).
final ProviderDefinition mediaFireFallbackDefinition = mediaFireDriver
    .definitionFor(
      ProviderConfig(
        id: 'mediafire',
        name: 'MediaFire',
        driver: MediaFireDriver.driverId,
        website: Uri.https('www.mediafire.com'),
        apiBase: mediaFireDefaultBaseUrl,
      ),
    );
