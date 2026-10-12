import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:upcloud/src/controllers/providers_state.dart';
import 'package:upcloud/upcloud.dart';

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

  /// Operations in progress: they may overlap.
  var _saving = 0;

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
    RegistryRefreshResult result;
    try {
      result = await registry.refresh(force: force);
    } on Object catch (e) {
      result = RegistryRefreshResult(RegistryRefreshStatus.failed, error: e);
    }
    _sync(_state.copyWith(isRefreshing: false, lastRefresh: result));
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

  Future<T> _run<T>(Future<T> Function() action) async {
    _saving++;
    _emit(_state.copyWith(isSaving: true, error: null));
    try {
      final result = await action();
      _saving--;
      _sync(_state.copyWith(isSaving: _saving > 0));
      return result;
    } on Object catch (e) {
      _saving--;
      _emit(_state.copyWith(isSaving: _saving > 0, error: e));
      rethrow;
    }
  }

  /// Publishes [base] (the current state by default) with the data of the
  /// registry.
  void _sync([ProvidersState? base]) {
    final configs = registry.configs;
    _emit(
      (base ?? _state).copyWith(
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
