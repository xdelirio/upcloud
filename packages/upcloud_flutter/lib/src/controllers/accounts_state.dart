import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/upcloud.dart';

part 'accounts_state.freezed.dart';

/// Result of checking the connection of an account.
@freezed
sealed class AccountStatus with _$AccountStatus {
  /// The connection is being checked.
  const factory AccountStatus.checking() = AccountStatusChecking;

  /// The provider accepted the credentials.
  const factory AccountStatus.connected({
    /// Account details, when the provider reports them.
    AccountInfo? info,
  }) = AccountStatusConnected;

  /// The check failed with [error].
  const factory AccountStatus.failed(UpCloudException error) =
      AccountStatusFailed;
}

/// Immutable state of an `AccountsController`.
@freezed
abstract class AccountsState with _$AccountsState {
  /// Creates an accounts state.
  const factory AccountsState({
    /// Saved accounts, in insertion order.
    @Default(<CloudAccount>[]) List<CloudAccount> accounts,

    /// Whether saved accounts are being loaded.
    @Default(false) bool isLoading,

    /// Whether an account is being added, updated or removed.
    @Default(false) bool isBusy,

    /// Error of the last failed operation.
    UpCloudException? error,

    /// Result of the last connection check of each account, by id.
    @Default(<String, AccountStatus>{}) Map<String, AccountStatus> statuses,
  }) = _AccountsState;

  const AccountsState._();

  /// Account with [id], or `null`.
  CloudAccount? account(String id) {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  /// Last connection check of account [id], or `null` if never checked.
  AccountStatus? statusOf(String id) => statuses[id];
}
