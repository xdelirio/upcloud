import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/drivers/built_in_drivers.dart';
import 'package:upcloud/src/registry/bundled_registry.dart';
import 'package:upcloud/src/registry/cloud_driver.dart';
import 'package:upcloud/src/registry/config_problem.dart';
import 'package:upcloud/src/registry/provider_config.dart';
import 'package:upcloud/src/registry/registry_document.dart';
import 'package:upcloud/src/registry/registry_store.dart';

/// Registry maintained in the upcloud repository. Apps download it to get
/// new providers, domains and limits without updating the package.
final Uri defaultRegistryUrl = Uri.parse(
  'https://raw.githubusercontent.com/xdelirio/upcloud/main/registry/providers.json',
);

/// Outcome of [ProviderRegistry.refresh].
enum RegistryRefreshStatus {
  /// A newer registry was downloaded and applied.
  updated,

  /// The remote registry did not change since the last download.
  notModified,

  /// Skipped: the last download is more recent than the refresh interval.
  skipped,

  /// No remote URL is configured.
  disabled,

  /// The download failed; the previous registry is still in use.
  failed,
}

/// Result of [ProviderRegistry.refresh].
final class RegistryRefreshResult {
  /// Creates a result.
  const RegistryRefreshResult(this.status, {this.error});

  /// What happened.
  final RegistryRefreshStatus status;

  /// Why the refresh failed, when [status] is
  /// [RegistryRefreshStatus.failed].
  final Object? error;

  @override
  String toString() =>
      'RegistryRefreshResult(${status.name}'
      '${error == null ? '' : ', $error'})';
}

/// A registry entry that could not be used.
final class RegistryIssue {
  /// Creates an issue.
  const RegistryIssue(this.providerId, this.message);

  /// Id of the entry, or `?` when it has none.
  final String providerId;

  /// What is wrong.
  final String message;

  @override
  String toString() => '$providerId: $message';
}

/// The providers available to the app, described as data.
///
/// Combines three layers, later ones winning:
///
/// 1. The registry bundled with the package (works offline).
/// 2. The latest registry downloaded from [remoteUrl], cached in [store].
///    The newest of 1 and 2 (by `updatedAt`) is used as the base.
/// 3. The user's edits and custom providers, saved in [store].
///
/// Only entries whose driver is registered become [definitions]; entries
/// for drivers of newer package versions are reported in [issues].
final class ProviderRegistry {
  /// Creates a registry.
  ///
  /// [drivers] defaults to every built-in driver. Pass `remoteUrl: null`
  /// to disable remote updates. The remote URL must use HTTPS: the registry
  /// decides where credentials are sent.
  ProviderRegistry({
    Iterable<CloudDriver>? drivers,
    RegistryStore? store,
    Uri? remoteUrl,
    bool useRemote = true,
    RegistryDocument? bundled,
    Dio? httpClient,
    this.minRefreshInterval = const Duration(hours: 6),
  }) : store = store ?? InMemoryRegistryStore(),
       remoteUrl = useRemote ? (remoteUrl ?? defaultRegistryUrl) : null,
       _bundled = bundled ?? bundledRegistry(),
       _http = httpClient ?? Dio() {
    for (final driver in drivers ?? builtInDrivers) {
      _drivers[driver.id] = driver;
    }
    final url = this.remoteUrl;
    if (url != null && url.scheme != 'https') {
      throw ArgumentError.value(url, 'remoteUrl', 'must use https');
    }
    _rebuild();
  }

  /// Keys used in [store].
  static const remoteKey = 'upcloud.registry.remote';

  /// Key of the ETag of the cached remote registry.
  static const etagKey = 'upcloud.registry.remote.etag';

  /// Key of the time of the last remote download.
  static const fetchedAtKey = 'upcloud.registry.remote.fetchedAt';

  /// Key of the user's edits.
  static const overridesKey = 'upcloud.registry.overrides';

  /// Where downloaded registries and user edits are saved.
  final RegistryStore store;

  /// Where updates are downloaded from, or `null` when disabled.
  final Uri? remoteUrl;

  /// Minimum time between two automatic downloads.
  final Duration minRefreshInterval;

  final RegistryDocument _bundled;
  final Dio _http;
  final _drivers = <String, CloudDriver>{};
  final _overrides = <String, Map<String, Object?>>{};
  final _changes = StreamController<void>.broadcast();
  RegistryDocument? _remote;
  String? _etag;
  DateTime? _fetchedAt;
  Future<RegistryRefreshResult>? _refreshing;

  List<ProviderConfig> _configs = const [];
  Map<String, ProviderDefinition> _definitions = const {};
  List<RegistryIssue> _issues = const [];

  /// Emits after the providers change (download, edit, reset...).
  Stream<void> get changes => _changes.stream;

  /// Registered drivers.
  List<CloudDriver> get drivers => List.unmodifiable(_drivers.values);

  /// Driver with [id], or `null`.
  CloudDriver? driver(String id) => _drivers[id];

  /// Every provider config, including disabled ones, in registry order
  /// followed by custom providers.
  List<ProviderConfig> get configs => _configs;

  /// Config of provider [id], or `null`.
  ProviderConfig? config(String id) =>
      _configs.where((c) => c.id == id).firstOrNull;

  /// Definitions of the enabled, valid providers.
  List<ProviderDefinition> get definitions =>
      List.unmodifiable(_definitions.values);

  /// Definition of provider [id], or `null` if missing, disabled or
  /// invalid.
  ProviderDefinition? definition(String id) => _definitions[id];

  /// Entries that were skipped and why.
  List<RegistryIssue> get issues => _issues;

  /// The base document in use (bundled or downloaded).
  RegistryDocument get document => _base;

  /// When the remote registry was last checked, if ever.
  DateTime? get lastFetchedAt => _fetchedAt;

  /// Whether [id] was added by the user (it is not in the base registry).
  bool isCustom(String id) => _base.entry(id) == null;

  /// Whether the user edited or added provider [id].
  bool isModified(String id) => _overrides.containsKey(id);

  /// Loads the cached remote registry and the user's edits from [store].
  Future<void> load() async {
    final cached = await store.read(remoteKey);
    if (cached != null) {
      try {
        final document = RegistryDocument.parse(cached);
        if (document.isSupported) _remote = document;
      } on FormatException {
        await store.write(remoteKey, null);
      }
    }
    _etag = await store.read(etagKey);
    _fetchedAt = readDateTime(await store.read(fetchedAtKey));

    _overrides.clear();
    final saved = await store.read(overridesKey);
    if (saved != null) {
      try {
        for (final entry in readList(jsonDecode(saved))) {
          final map = readMap(entry);
          final id = readString(map?['id']);
          if (map != null && id != null) _overrides[id] = map;
        }
      } on FormatException {
        await store.write(overridesKey, null);
      }
    }
    _rebuildAndNotify();
  }

  /// Downloads the remote registry if it changed.
  ///
  /// Does nothing when the last download is newer than
  /// [minRefreshInterval], unless [force] is true. Never throws: failures
  /// are returned as [RegistryRefreshStatus.failed] and the current
  /// registry keeps working.
  Future<RegistryRefreshResult> refresh({bool force = false}) {
    final url = remoteUrl;
    if (url == null) {
      return Future.value(
        const RegistryRefreshResult(RegistryRefreshStatus.disabled),
      );
    }
    final last = _fetchedAt;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < minRefreshInterval) {
      return Future.value(
        const RegistryRefreshResult(RegistryRefreshStatus.skipped),
      );
    }
    return _refreshing ??= _download(url)
        .whenComplete(() => _refreshing = null);
  }

  /// Adds provider [config] or saves the user's edits to it.
  ///
  /// Only the differences with the base registry are stored, so future
  /// registry updates still apply to the fields the user did not touch.
  /// Throws [InvalidProviderConfigException] if the driver is unknown or
  /// the config is invalid (see [validate]).
  Future<void> save(ProviderConfig config) async {
    final problems = validate(config);
    if (problems.isNotEmpty) {
      throw InvalidProviderConfigException(config.id, problems);
    }
    final target = compactJson(config.toJson());
    final baseEntry = _base.entry(config.id);
    if (baseEntry == null) {
      _overrides[config.id] = target;
    } else {
      final normalized = compactJson(
        ProviderConfig.fromJson(baseEntry).toJson(),
      );
      final patch = diffJson(normalized, target);
      if (patch.isEmpty) {
        _overrides.remove(config.id);
      } else {
        _overrides[config.id] = {'id': config.id, ...patch};
      }
    }
    await _saveOverrides();
  }

  /// Problems that prevent saving [config], empty when it is valid.
  List<ConfigProblem> validate(ProviderConfig config) {
    final driver = _drivers[config.driver];
    if (driver == null) {
      return [
        ConfigProblem(
          ConfigProblemCode.unknownDriver,
          'Unknown driver "${config.driver}"',
          field: 'driver',
        ),
      ];
    }
    return driver.validate(config);
  }

  /// Enables or disables provider [id].
  Future<void> setEnabled(String id, {required bool enabled}) async {
    final current = config(id);
    if (current == null) throw NotFoundException('Unknown provider $id');
    await save(current.copyWith(enabled: enabled));
  }

  /// Discards the user's edits to [id]. Custom providers are removed.
  Future<void> reset(String id) async {
    if (_overrides.remove(id) != null) await _saveOverrides();
  }

  /// Discards every user edit and custom provider.
  Future<void> resetAll() async {
    if (_overrides.isEmpty) return;
    _overrides.clear();
    await _saveOverrides();
  }

  /// The user's edits and custom providers as a registry document, e.g. to
  /// back them up or share them.
  RegistryDocument exportUserChanges() => RegistryDocument(
    providers: [..._overrides.values],
    updatedAt: DateTime.now().toUtc(),
  );

  /// Adds every provider of [document] as a user change.
  ///
  /// Returns the ids that were imported; invalid entries are skipped.
  Future<List<String>> importProviders(RegistryDocument document) async {
    final imported = <String>[];
    for (final entry in document.providers) {
      try {
        final config = ProviderConfig.fromJson(
          mergeJson(_base.entry(readString(entry['id']) ?? '') ?? {}, entry),
        );
        await save(config);
        imported.add(config.id);
      } on Object {
        // Invalid entries are skipped.
      }
    }
    return imported;
  }

  /// Releases resources.
  Future<void> dispose() async {
    _http.close();
    await _changes.close();
  }

  RegistryDocument get _base {
    final remote = _remote;
    if (remote == null) return _bundled;
    final remoteDate = remote.updatedAt;
    final bundledDate = _bundled.updatedAt;
    if (remoteDate != null &&
        bundledDate != null &&
        bundledDate.isAfter(remoteDate)) {
      return _bundled;
    }
    return remote;
  }

  Future<RegistryRefreshResult> _download(Uri url) async {
    try {
      final response = await _http.getUri<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {'if-none-match': ?_etag},
          validateStatus: (status) => status == 200 || status == 304,
        ),
      );
      _fetchedAt = DateTime.now();
      await store.write(fetchedAtKey, _fetchedAt!.toIso8601String());
      if (response.statusCode == 304) {
        return const RegistryRefreshResult(RegistryRefreshStatus.notModified);
      }
      final body = response.data ?? '';
      final document = RegistryDocument.parse(body);
      if (!document.isSupported) {
        throw FormatException(
          'Registry schema ${document.schemaVersion} is newer than '
          '$supportedRegistrySchema; update the upcloud package',
        );
      }
      _remote = document;
      _etag = response.headers.value('etag');
      await store.write(remoteKey, body);
      await store.write(etagKey, _etag);
      _rebuildAndNotify();
      return const RegistryRefreshResult(RegistryRefreshStatus.updated);
    } on DioException catch (e, st) {
      return RegistryRefreshResult(
        RegistryRefreshStatus.failed,
        error: mapDioException(e, st),
      );
    } on FormatException catch (e) {
      return RegistryRefreshResult(RegistryRefreshStatus.failed, error: e);
    }
  }

  Future<void> _saveOverrides() async {
    await store.write(
      overridesKey,
      _overrides.isEmpty ? null : jsonEncode([..._overrides.values]),
    );
    _rebuildAndNotify();
  }

  void _rebuildAndNotify() {
    _rebuild();
    if (!_changes.isClosed) _changes.add(null);
  }

  void _rebuild() {
    final base = _base;
    final entries = <Map<String, Object?>>[
      for (final entry in base.providers)
        switch (_overrides[entry['id']]) {
          final patch? => mergeJson(entry, patch),
          null => entry,
        },
      for (final MapEntry(:key, :value) in _overrides.entries)
        if (base.entry(key) == null) value,
    ];

    final configs = <ProviderConfig>[];
    final definitions = <String, ProviderDefinition>{};
    final issues = <RegistryIssue>[];
    for (final entry in entries) {
      final id = readString(entry['id']) ?? '?';
      final ProviderConfig config;
      try {
        config = ProviderConfig.fromJson(entry);
      } on Object catch (e) {
        issues.add(RegistryIssue(id, 'Invalid entry: $e'));
        continue;
      }
      if (configs.any((c) => c.id == config.id)) {
        issues.add(RegistryIssue(id, 'Duplicated id'));
        continue;
      }
      configs.add(config);
      final driver = _drivers[config.driver];
      if (driver == null) {
        issues.add(RegistryIssue(id, 'Unknown driver "${config.driver}"'));
        continue;
      }
      final problems = driver.validate(config);
      if (problems.isNotEmpty) {
        issues.add(RegistryIssue(id, problems.join('; ')));
        continue;
      }
      if (config.enabled) definitions[id] = driver.definitionFor(config);
    }
    _configs = List.unmodifiable(configs);
    _definitions = Map.unmodifiable(definitions);
    _issues = List.unmodifiable(issues);
  }
}
