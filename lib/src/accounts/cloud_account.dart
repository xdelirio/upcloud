import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/credentials.dart';

part 'cloud_account.freezed.dart';
part 'cloud_account.g.dart';

/// A user account connected to a provider.
///
/// Serializable to JSON so apps can persist it with an `AccountStore`.
/// Note that [credentials] contain secrets: store them securely.
@freezed
abstract class CloudAccount with _$CloudAccount {
  /// Creates an account.
  const factory CloudAccount({
    /// Unique id of the account inside the app.
    required String id,

    /// Id of the `ProviderDefinition` used to connect.
    required String providerId,

    /// Name shown to the user.
    required String label,
    required Credentials credentials,

    /// Overrides the provider's API base URL (e.g. after a domain change).
    Uri? baseUrl,

    /// Overrides the provider's maximum upload size, in bytes.
    int? maxFileSizeBytes,
    DateTime? createdAt,
  }) = _CloudAccount;

  /// Restores an account saved with [toJson].
  factory CloudAccount.fromJson(Map<String, dynamic> json) =>
      _$CloudAccountFromJson(json);
}
