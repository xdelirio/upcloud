import 'package:meta/meta.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';

/// Differences between XVideoSharing clones that cannot be discovered
/// through the API.
///
/// Built by `XvsDriver` from a registry entry. File links come from the
/// API or from `ProviderDefinition.fileUrlTemplate`.
@immutable
final class XvsConfig {
  /// Creates a configuration.
  const XvsConfig({this.disabledCapabilities = const {}});

  /// Capabilities the clone does not offer. Their methods throw an
  /// `UnsupportedOperationException`.
  final Set<Capability> disabledCapabilities;
}
