import 'package:meta/meta.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';

/// Differences between XVideoSharing clones that cannot be discovered
/// through the API.
///
/// Built by `XvsDriver` from the settings of a registry entry.
@immutable
final class XvsConfig {
  /// Creates a configuration.
  const XvsConfig({this.pageUrlTemplate, this.disabledCapabilities = const {}});

  /// Placeholder replaced by the file code in URL templates.
  static const codePlaceholder = '{code}';

  /// URL of the public page of a file, with [codePlaceholder] where the
  /// file code goes (e.g. `https://xvideosharing.com/{code}.html`).
  ///
  /// Only used when the API does not return the page link itself.
  final String? pageUrlTemplate;

  /// Capabilities the clone does not offer. Their methods throw an
  /// `UnsupportedOperationException`.
  final Set<Capability> disabledCapabilities;

  /// Page URL for the file [code], or `null` if unknown.
  Uri? pageUrl(String code) {
    final template = pageUrlTemplate;
    if (template == null) return null;
    return Uri.tryParse(
      template.replaceAll(codePlaceholder, Uri.encodeComponent(code)),
    );
  }
}
