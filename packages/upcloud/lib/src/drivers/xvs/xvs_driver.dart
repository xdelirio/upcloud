import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/drivers/xvs/xvs_config.dart';
import 'package:upcloud/src/drivers/xvs/xvs_provider.dart';
import 'package:upcloud/src/registry/cloud_driver.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// Capabilities implemented by [XvsProvider].
const xvsCapabilities = <Capability>{
  Capability.browseFolders,
  ...Capability.folderManagement,
  ...Capability.fileManagement,
  Capability.search,
  Capability.upload,
  Capability.remoteUpload,
  Capability.accountInfo,
};

/// Limits used when a provider does not declare its own: video files of
/// any size.
const xvsDefaultLimits = ProviderLimits(
  allowedExtensions: ProviderLimits.videoExtensions,
);

/// Driver for hosts running the XVideoSharing (XVS) script.
///
/// Most XVS hosts keep the API unchanged and only differ in domain, so a
/// new one is just a registry entry:
///
/// ```json
/// {
///   "id": "myhost",
///   "name": "MyHost",
///   "driver": "xvs",
///   "website": "https://myhost.com",
///   "apiBase": "https://myhost.com/api",
///   "fileUrlTemplate": "https://myhost.com/{id}.html"
/// }
/// ```
///
/// Files get the link returned by the API; when there is none, it is built
/// from `fileUrlTemplate` (`{id}` is the file code). The driver has no
/// default template.
final class XvsDriver extends CloudDriver {
  /// Creates the driver. Prefer the [xvsDriver] instance.
  const XvsDriver();

  /// Id of this driver in registry entries.
  static const driverId = 'xvs';

  @override
  String get id => driverId;

  @override
  String get name => 'XVideoSharing';

  @override
  String get description =>
      'Video hosts running the XVideoSharing script (StreamHG, EarnVids, '
      'VidHide...).';

  @override
  Set<Capability> get capabilities => xvsCapabilities;

  @override
  ProviderLimits get defaultLimits => xvsDefaultLimits;

  /// A single API key, with a link to the account page of the website.
  @override
  CredentialSchema defaultCredentials(ProviderConfig config) =>
      CredentialSchema.apiKey(
        helpUrl: config.website?.resolve('/?op=my_account'),
      );

  @override
  CloudProvider create(
    ProviderDefinition definition,
    Credentials credentials,
    ProviderOptions options,
  ) {
    final config = definition.config;
    return XvsProvider(
      definition: definition,
      credentials: credentials,
      options: options,
      config: XvsConfig(
        disabledCapabilities: config?.disabledCapabilitySet ?? const {},
      ),
    );
  }
}

/// The XVideoSharing driver.
const xvsDriver = XvsDriver();
