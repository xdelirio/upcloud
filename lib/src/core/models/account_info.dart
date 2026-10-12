import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/models/data_size.dart';

part 'account_info.freezed.dart';

/// Information about the authenticated account.
@freezed
abstract class AccountInfo with _$AccountInfo {
  /// Creates account information.
  const factory AccountInfo({
    String? login,
    String? email,
    DataSize? storageUsed,

    /// Remaining storage. `null` when unknown or unlimited.
    DataSize? storageLeft,
    int? filesTotal,
    @Default(false) bool isPremium,
    DateTime? premiumUntil,

    /// Account balance as reported by the provider (currency varies).
    String? balance,

    /// Provider specific data not covered by the common fields.
    @Default(<String, Object?>{}) Map<String, Object?> extra,
  }) = _AccountInfo;
}
