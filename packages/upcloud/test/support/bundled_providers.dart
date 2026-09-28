import 'package:upcloud/upcloud.dart';

/// The registry bundled with the package, without remote updates.
final ProviderRegistry bundledProviders = ProviderRegistry(useRemote: false);

/// Definition of [id] in the bundled registry.
ProviderDefinition bundledDefinition(String id) =>
    bundledProviders.definition(id) ??
    (throw StateError('Provider $id is not in the bundled registry'));

/// StreamHG as described by the bundled registry.
final ProviderDefinition streamHg = bundledDefinition('streamhg');

/// EarnVids (VidHide) as described by the bundled registry.
final ProviderDefinition earnVids = bundledDefinition('earnvids');

/// Byse as described by the bundled registry.
final ProviderDefinition byse = bundledDefinition('byse');

/// MediaFire as described by the bundled registry.
final ProviderDefinition mediaFire = bundledDefinition('mediafire');

/// The XVideoSharing reference host (not in the registry: its API is not
/// public), used to test the documented XVS responses.
final ProviderDefinition xVideoSharing = testXvsDefinition(
  info: ProviderInfo(
    id: 'xvideosharing',
    name: 'XVideoSharing',
    website: Uri.parse('https://xvideosharing.com'),
  ),
  apiBase: Uri.parse('https://xvideosharing.com/api'),
  limits: const LimitsConfig(maxFileSizeMb: 1000),
  pageUrlTemplate: 'https://xvideosharing.com/{code}.html',
);

/// Builds an `xvs` definition from arguments, as a registry entry would.
ProviderDefinition testXvsDefinition({
  required ProviderInfo info,
  required Uri apiBase,
  LimitsConfig? limits,
  CredentialSchema? credentials,
  String? pageUrlTemplate,
  Set<Capability> disabledCapabilities = const {},
}) => xvsDriver.definitionFor(
  ProviderConfig(
    id: info.id,
    name: info.name,
    driver: XvsDriver.driverId,
    website: info.website,
    apiBase: apiBase,
    limits: limits,
    credentials: credentials?.fields,
    settings: {XvsDriver.pageUrlTemplateKey: ?pageUrlTemplate},
    disabledCapabilities: [for (final c in disabledCapabilities) c.name],
  ),
);
