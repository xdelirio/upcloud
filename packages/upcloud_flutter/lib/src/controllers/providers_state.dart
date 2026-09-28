import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/upcloud.dart';

part 'providers_state.freezed.dart';

/// Immutable state of a `ProvidersController`.
@freezed
abstract class ProvidersState with _$ProvidersState {
  /// Creates a providers state.
  const factory ProvidersState({
    /// Every provider config, including disabled and invalid ones.
    @Default(<ProviderConfig>[]) List<ProviderConfig> configs,

    /// Entries that could not be used and why.
    @Default(<RegistryIssue>[]) List<RegistryIssue> issues,

    /// Ids of providers added by the user.
    @Default(<String>{}) Set<String> customIds,

    /// Ids of providers edited (or added) by the user.
    @Default(<String>{}) Set<String> modifiedIds,

    /// Whether saved registry data is being loaded.
    @Default(false) bool isLoading,

    /// Whether the remote registry is being checked.
    @Default(false) bool isRefreshing,

    /// Whether a change is being saved.
    @Default(false) bool isSaving,

    /// Result of the last check for updates.
    RegistryRefreshResult? lastRefresh,

    /// When the remote registry was last checked.
    DateTime? lastFetchedAt,

    /// Error of the last failed operation, usually an [UpCloudException]
    /// (an [InvalidProviderConfigException] for invalid configs).
    Object? error,
  }) = _ProvidersState;

  const ProvidersState._();

  /// Config of provider [id], or `null`.
  ProviderConfig? config(String id) {
    for (final config in configs) {
      if (config.id == id) return config;
    }
    return null;
  }

  /// Whether provider [id] was added by the user.
  bool isCustom(String id) => customIds.contains(id);

  /// Whether provider [id] was edited or added by the user.
  bool isModified(String id) => modifiedIds.contains(id);

  /// Issues reported for provider [id].
  List<RegistryIssue> issuesFor(String id) => [
    for (final issue in issues)
      if (issue.providerId == id) issue,
  ];
}
