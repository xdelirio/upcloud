import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/registry/provider_registry.dart';

/// Providers of the registry bundled with the package.
///
/// Prefer `UpCloud`, whose `ProviderRegistry` also downloads registry
/// updates and applies the user's edits. This list is a static snapshot for
/// code that only needs the default providers:
///
/// ```dart
/// final upcloud = UpCloud(providers: builtInProviders);
/// ```
final List<ProviderDefinition> builtInProviders = List.unmodifiable(
  ProviderRegistry(useRemote: false).definitions,
);
