import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/controllers/providers_state.dart';

/// Exposes a [ProviderRegistry] as a listenable [state]: provider configs,
/// user edits, registry updates and issues.
///
/// ```dart
/// final providers = ProvidersController(upcloud.registry);
/// await providers.setEnabled('streamhg', enabled: false);
/// final result = await providers.refresh();
/// ```
class ProvidersController extends ChangeNotifier {
  /// Creates a controller for [registry].
  ///
  /// Saved registry data is loaded with `ProviderRegistry.load` only when
  /// [load] is true; `UpCloud.init` already loads it.
  ProvidersController(this.registry, {bool load = false})
    : _state = const ProvidersState() {
    _subscription = registry.changes.listen((_) => _sync());
    _sync();
    if (load) unawaited(this.load());
  }

  /// The wrapped registry.
  final ProviderRegistry registry;

  late final StreamSubscription<void> _subscription;
  ProvidersState _state;
  var _disposed = false;

  /// Current state.
  ProvidersState get state => _state;

  /// Registered drivers.
  List<CloudDriver> get drivers => registry.drivers;

  /// Driver with [id], or `null`.
  CloudDriver? driver(String id) => registry.driver(id);

  /// Definition of provider [id], or `null` if disabled or invalid.
  ProviderDefinition? definition(String id) => registry.definition(id);

  /// Problems that prevent saving [config], empty when it is valid.
  List<ConfigProblem> validate(ProviderConfig config) =>
      registry.validate(config);

  /// Loads the cached registry and the user's edits.
  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, error: null));
    try {
      await registry.load();
      _emit(_state.copyWith(isLoading: false));
    } on Object catch (e) {
      _emit(_state.copyWith(isLoading: false, error: e));
    }
  }

  /// Checks the remote registry for updates. Never throws.
  ///
  /// [force] ignores `ProviderRegistry.minRefreshInterval`.
  Future<RegistryRefreshResult> refresh({bool force = true}) async {
    _emit(_state.copyWith(isRefreshing: true, error: null));
    final result = await registry.refresh(force: force);
    _sync();
    _emit(
      _state.copyWith(
        isRefreshing: false,
        lastRefresh: result,
        lastFetchedAt: registry.lastFetchedAt,
      ),
    );
    return result;
  }

  /// Adds provider [config] or saves the user's edits to it.
  ///
  /// Throws [InvalidProviderConfigException] when the driver is unknown or
  /// the config is invalid (see [validate]).
  Future<void> save(ProviderConfig config) => _run(() => registry.save(config));

  /// Enables or disables provider [id].
  Future<void> setEnabled(String id, {required bool enabled}) =>
      _run(() => registry.setEnabled(id, enabled: enabled));

  /// Discards the user's edits to [id]; custom providers are removed.
  Future<void> reset(String id) => _run(() => registry.reset(id));

  /// The user's edits and custom providers, e.g. for a backup.
  RegistryDocument exportUserChanges() => registry.exportUserChanges();

  /// Imports the providers of [document] as user changes.
  ///
  /// Returns the imported ids.
  Future<List<String>> importProviders(RegistryDocument document) =>
      _run(() => registry.importProviders(document));

  /// Clears [ProvidersState.error].
  void clearError() {
    if (_state.error != null) _emit(_state.copyWith(error: null));
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    _emit(_state.copyWith(isSaving: true, error: null));
    try {
      final result = await action();
      _sync();
      _emit(_state.copyWith(isSaving: false));
      return result;
    } on Object catch (e) {
      _emit(_state.copyWith(isSaving: false, error: e));
      rethrow;
    }
  }

  void _sync() {
    final configs = registry.configs;
    _emit(
      _state.copyWith(
        configs: configs,
        issues: registry.issues,
        customIds: {
          for (final config in configs)
            if (registry.isCustom(config.id)) config.id,
        },
        modifiedIds: {
          for (final config in configs)
            if (registry.isModified(config.id)) config.id,
        },
        lastFetchedAt: registry.lastFetchedAt,
      ),
    );
  }

  void _emit(ProvidersState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
