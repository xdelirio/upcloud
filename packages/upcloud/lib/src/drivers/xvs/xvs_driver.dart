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
///   "settings": {
///     "pageUrlTemplate": "https://myhost.com/{code}.html"
///   }
/// }
/// ```
///
/// Settings (see [XvsConfig]):
/// * `pageUrlTemplate`: public page URL of a file, `{code}` is the file
///   code. Only needed when the API does not return the link itself.
final class XvsDriver extends CloudDriver {
  /// Creates the driver. Prefer the [xvsDriver] instance.
  const XvsDriver();

  /// Id of this driver in registry entries.
  static const driverId = 'xvs';

  /// Setting key of [XvsConfig.pageUrlTemplate].
  static const pageUrlTemplateKey = 'pageUrlTemplate';

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

  @override
  List<DriverSetting> get settings => const [
    DriverSetting(
      key: pageUrlTemplateKey,
      label: 'Page URL template',
      kind: DriverSettingKind.url,
      description: 'Public page URL, {code} is replaced by the file code.',
    ),
  ];

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
        pageUrlTemplate: config?.stringSetting(pageUrlTemplateKey),
        disabledCapabilities: config?.disabledCapabilitySet ?? const {},
      ),
    );
  }
}

/// The XVideoSharing driver.
const xvsDriver = XvsDriver();
