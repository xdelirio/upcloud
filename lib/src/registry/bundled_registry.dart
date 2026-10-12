import 'package:upcloud/src/registry/bundled_registry_data.dart';
import 'package:upcloud/src/registry/registry_document.dart';

/// The registry bundled with this version of the package, used offline and
/// before the first remote download.
RegistryDocument bundledRegistry() =>
    RegistryDocument.parse(bundledRegistryJson);
