import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/errors.dart';

part 'credentials.freezed.dart';
part 'credentials.g.dart';

/// Secrets used to authenticate against a provider.
///
/// Stored as a flat map so any provider (API key, email/password, OAuth
/// tokens...) can use it and apps can persist it as JSON. The keys a
/// provider expects are declared by its [CredentialSchema].
@freezed
abstract class Credentials with _$Credentials {
  /// Creates credentials from raw [values].
  const factory Credentials(Map<String, String> values) = _Credentials;

  const Credentials._();

  /// Credentials with a single API key, the most common case.
  factory Credentials.apiKey(String apiKey) =>
      Credentials({CredentialField.apiKeyId: apiKey});

  /// Restores credentials saved with [toJson].
  factory Credentials.fromJson(Map<String, dynamic> json) =>
      _$CredentialsFromJson(json);

  /// Value for [key], or `null`.
  String? operator [](String key) => values[key];

  /// Value for [key]; throws [AuthenticationException] if missing or blank.
  ///
  /// Surrounding whitespace is removed unless [trim] is false (use it for
  /// passwords, where spaces may be meaningful).
  String require(String key, {bool trim = true}) {
    final value = values[key];
    if (value == null || value.trim().isEmpty) {
      throw AuthenticationException('Missing credential "$key"');
    }
    return trim ? value.trim() : value;
  }

  /// The API key stored under [CredentialField.apiKeyId].
  String get apiKey => require(CredentialField.apiKeyId);
}

/// Kind of input used to fill a [CredentialField].
enum CredentialInputKind {
  /// Plain text.
  text,

  /// Secret text, hidden while typing.
  secret,

  /// An email address.
  email,

  /// A URL.
  url,
}

/// Describes one value a provider needs to authenticate.
///
/// UI packages use it to build login forms automatically.
@freezed
abstract class CredentialField with _$CredentialField {
  /// Creates a field description.
  const factory CredentialField({
    /// Key inside [Credentials.values].
    required String id,

    /// Label shown to the user.
    required String label,
    @Default(CredentialInputKind.text) CredentialInputKind kind,
    @Default(true) bool isRequired,

    /// Short help text.
    String? hint,

    /// Where the user can obtain the value (e.g. the API settings page).
    Uri? helpUrl,

    /// Value used when the user leaves the field empty.
    String? defaultValue,
  }) = _CredentialField;

  /// Reads a field from the provider registry JSON.
  factory CredentialField.fromJson(Map<String, dynamic> json) =>
      _$CredentialFieldFromJson(json);

  /// Id used by API key based providers.
  static const apiKeyId = 'api_key';
}

/// The set of values a provider needs to authenticate.
@freezed
abstract class CredentialSchema with _$CredentialSchema {
  /// Creates a schema with [fields].
  const factory CredentialSchema(List<CredentialField> fields) =
      _CredentialSchema;

  const CredentialSchema._();

  /// Schema for providers authenticated with a single API key.
  factory CredentialSchema.apiKey({Uri? helpUrl}) => CredentialSchema([
    CredentialField(
      id: CredentialField.apiKeyId,
      label: 'API key',
      kind: CredentialInputKind.secret,
      helpUrl: helpUrl,
    ),
  ]);

  /// Returns the ids of required fields missing in [credentials].
  ///
  /// Fields with a [CredentialField.defaultValue] are never missing.
  List<String> missingFields(Credentials credentials) => [
    for (final field in fields)
      if (field.isRequired &&
          field.defaultValue == null &&
          (credentials[field.id]?.trim() ?? '').isEmpty)
        field.id,
  ];

  /// Returns [credentials] with empty fields set to their default value.
  Credentials applyDefaults(Credentials credentials) {
    final values = {...credentials.values};
    for (final field in fields) {
      final fallback = field.defaultValue;
      if (fallback != null && (values[field.id]?.trim() ?? '').isEmpty) {
        values[field.id] = fallback;
      }
    }
    return Credentials(values);
  }
}
