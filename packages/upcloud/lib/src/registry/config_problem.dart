import 'package:meta/meta.dart';

/// Kind of problem found in a `ProviderConfig`.
///
/// UIs can map codes to translated messages.
enum ConfigProblemCode {
  /// The config uses another driver than the one validating it.
  wrongDriver,

  /// No driver with the config's `driver` id is registered.
  unknownDriver,

  /// The id is empty or has characters other than `a-z`, `0-9`, `_`, `-`.
  invalidId,

  /// The name is empty.
  missingName,

  /// The driver needs `apiBase` and it is missing.
  missingApiBase,

  /// A URL is not absolute.
  invalidUrl,

  /// A URL does not use HTTPS (credentials would travel in clear text).
  insecureUrl,

  /// A driver specific problem, described by the message.
  other,
}

/// A problem found in a `ProviderConfig`.
@immutable
final class ConfigProblem {
  /// Creates a problem.
  const ConfigProblem(this.code, this.message, {this.field});

  /// Kind of problem.
  final ConfigProblemCode code;

  /// English description.
  final String message;

  /// Name of the offending field (e.g. `apiBase`, `mirrors`), if any.
  final String? field;

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      other is ConfigProblem &&
      other.code == code &&
      other.field == field &&
      other.message == message;

  @override
  int get hashCode => Object.hash(code, field, message);
}
