import 'dart:async';
import 'dart:convert';

import 'package:upcloud/src/accounts/account_store.dart';
import 'package:upcloud/src/accounts/cloud_account.dart';
import 'package:upcloud/src/backup/argon2id_params.dart';
import 'package:upcloud/src/backup/backup_envelope.dart';
import 'package:upcloud/src/backup/backup_payload.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/key_value_store.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/registry/provider_registry.dart';
import 'package:upcloud/src/settings/upload_settings.dart';
import 'package:upcloud/src/transfer/transfer_manager.dart';
import 'package:upcloud/src/transfer/transfer_task.dart';
import 'package:upcloud/src/transfer/upload_batch.dart';
import 'package:upcloud/src/transfer/upload_executor.dart';

/// Builds the [ProviderOptions] used to connect [account].
typedef ProviderOptionsBuilder = ProviderOptions Function(
  CloudAccount account,
  ProviderDefinition provider,
);

/// Entry point of the package: available providers, connected accounts,
/// uploads and their settings.
///
/// Providers come from the [ProviderRegistry] (the registry bundled with
/// the package, remote updates and the user's edits) plus any definition
/// passed in `providers`.
///
/// ```dart
/// final upcloud = UpCloud(uploadExecutor: executor);
/// await upcloud.init();
/// final account = await upcloud.addAccount(
///   providerId: 'streamhg',
///   credentials: Credentials.apiKey('...'),
/// );
/// final browser = upcloud.connect(account.id).capability<FolderBrowsing>();
/// ```
final class UpCloud {
  /// Creates an instance.
  ///
  /// * `uploadExecutor` sends the bytes of uploads. The app uses
  ///   `BackgroundUploadExecutor` (background uploads); tests can use
  ///   `FakeUploadExecutor` from `package:upcloud/testing.dart`.
  /// * [registry] provides the providers described as data. By default it
  ///   uses the built-in drivers, the bundled registry and remote updates,
  ///   keeping downloads and user edits in memory; pass a
  ///   `ProviderRegistry(store: ...)` to persist them. [dispose] disposes a
  ///   registry created here, and a given one only when `disposeRegistry`
  ///   is true.
  /// * [providers] adds definitions written in code. They win over registry
  ///   entries with the same id.
  /// * Accounts are persisted with [store] (in memory by default).
  /// * Upload [settings] and [recentFolderPaths] are persisted with
  ///   `settingsStore` (in memory by default); it can be the same store as
  ///   the registry's.
  /// * `optionsBuilder` customizes each connection (logging, proxies...);
  ///   never share one `Dio` instance between accounts.
  /// * [backupKdf] is the cost of the key derivation of [exportBackup].
  ///   Keep the default outside tests.
  UpCloud({
    required UploadExecutor uploadExecutor,
    ProviderRegistry? registry,
    bool disposeRegistry = false,
    Iterable<ProviderDefinition> providers = const [],
    AccountStore? store,
    KeyValueStore? settingsStore,
    this._optionsBuilder,
    this.backupKdf = Argon2idParams.recommended,
  }) : registry = registry ?? ProviderRegistry(),
       _ownsRegistry = registry == null || disposeRegistry,
       _store = store ?? InMemoryAccountStore(),
       _settingsStore = settingsStore ?? InMemoryKeyValueStore() {
    if (!backupKdf.isValid) {
      throw ArgumentError.value(backupKdf, 'backupKdf', 'out of range');
    }
    providers.forEach(register);
    _registrySubscription = this.registry.changes.listen(
      (_) => _onProvidersChanged(),
    );
    transfers = TransferManager(
      resolveProvider: connect,
      executor: uploadExecutor,
    );
  }

  /// Key of the upload settings in the settings store.
  static const settingsKey = 'upcloud.settings.upload';

  /// Key of the recent folder paths in the settings store.
  static const recentFolderPathsKey = 'upcloud.settings.recentFolderPaths';

  /// Number of folder paths kept in [recentFolderPaths].
  static const maxRecentFolderPaths = 10;

  /// Minimum number of characters of a backup password.
  static const minBackupPasswordLength = 8;

  /// Providers described as data (bundled, remote and user edited).
  final ProviderRegistry registry;

  /// Cost of the key derivation of new backups (see [exportBackup]).
  final Argon2idParams backupKdf;

  final bool _ownsRegistry;
  final AccountStore _store;
  final KeyValueStore _settingsStore;
  final ProviderOptionsBuilder? _optionsBuilder;
  final _definitions = <String, ProviderDefinition>{};
  final _accounts = <String, CloudAccount>{};
  final _connections = <String, CloudProvider>{};
  final _connectedWith = <String, ProviderDefinition>{};
  final _accountChanges = StreamController<List<CloudAccount>>.broadcast();
  final _providerChanges =
      StreamController<List<ProviderDefinition>>.broadcast();
  final _settingsChanges = StreamController<UploadSettings>.broadcast();
  late final StreamSubscription<void> _registrySubscription;
  var _recentFolderPaths = const <String>[];
  var _initialized = false;

  /// Queue of uploads.
  late final TransferManager transfers;

  // ---------------------------------------------------------------------------
  // Providers
  // ---------------------------------------------------------------------------

  /// Makes a provider written in code available. It wins over a registry
  /// entry with the same id.
  void register(ProviderDefinition definition) {
    _definitions[definition.id] = definition;
    _onProvidersChanged();
  }

  /// Available providers: code definitions first, then enabled registry
  /// entries.
  List<ProviderDefinition> get providers => List.unmodifiable([
    ..._definitions.values,
    for (final definition in registry.definitions)
      if (!_definitions.containsKey(definition.id)) definition,
  ]);

  /// Emits [providers] when they change (registry download, user edit...).
  Stream<List<ProviderDefinition>> get providerChanges =>
      _providerChanges.stream;

  /// Provider with [id], or `null` if unknown or disabled.
  ProviderDefinition? provider(String id) =>
      _definitions[id] ?? registry.definition(id);

  // ---------------------------------------------------------------------------
  // Accounts
  // ---------------------------------------------------------------------------

  /// Loads the registry, the saved accounts and the upload settings. Call
  /// once at startup.
  ///
  /// When [refreshRegistry] is true the remote registry is checked in the
  /// background; [providerChanges] emits if it brings updates.
  Future<void> init({bool refreshRegistry = true}) async {
    if (_initialized) return;
    await registry.load();
    if (refreshRegistry) unawaited(registry.refresh());
    await _loadSettings();
    final saved = await _store.load();
    _accounts
      ..clear()
      ..addEntries(saved.map((a) => MapEntry(a.id, a)));
    _initialized = true;
    _emitAccounts();
  }

  /// Connected accounts, in insertion order.
  List<CloudAccount> get accounts => List.unmodifiable(_accounts.values);

  /// Emits [accounts] whenever an account is added, updated or removed.
  Stream<List<CloudAccount>> get accountChanges => _accountChanges.stream;

  /// Account with [id], or `null`.
  CloudAccount? account(String id) => _accounts[id];

  /// Connects a new account to provider [providerId].
  ///
  /// When [verify] is true the credentials are checked with a cheap API call
  /// (account info or listing the root folder) and an
  /// [AuthenticationException] is thrown if they are rejected.
  Future<CloudAccount> addAccount({
    required String providerId,
    required Credentials credentials,
    String? label,
    Uri? baseUrl,
    bool verify = true,
  }) async {
    final definition = _definitionOrThrow(providerId);
    final missing = definition.credentialSchema.missingFields(credentials);
    if (missing.isNotEmpty) {
      throw AuthenticationException(
        'Missing credentials: ${missing.join(', ')}',
      );
    }
    var account = CloudAccount(
      id: _newAccountId(providerId),
      providerId: providerId,
      label: label ?? definition.info.name,
      credentials: definition.credentialSchema.applyDefaults(credentials),
      baseUrl: baseUrl,
      createdAt: DateTime.now(),
    );
    if (verify) {
      final provider = _create(account, definition);
      try {
        final info = await verifyConnection(provider);
        if (label == null && info != null) {
          account = account.copyWith(label: '${definition.info.name} · $info');
        }
      } finally {
        provider.close();
      }
    }
    _accounts[account.id] = account;
    await _persist();
    return account;
  }

  /// Replaces the saved data of an account (label, credentials, base URL...).
  Future<void> updateAccount(CloudAccount account) async {
    if (!_accounts.containsKey(account.id)) {
      throw NotFoundException('Unknown account ${account.id}');
    }
    _accounts[account.id] = account;
    // New credentials may point to another user: forget its folders.
    transfers.folders.invalidate(account.id);
    _dropConnections(where: (a) => a.id == account.id);
    await _persist();
  }

  /// Removes the account [id] and cancels its transfers.
  Future<void> removeAccount(String id) async {
    if (_forgetAccount(id)) await _persist();
  }

  /// Provider connected to account [accountId]. Instances are cached.
  ///
  /// Throws [NotFoundException] if the account or its provider is unknown.
  CloudProvider connect(String accountId) {
    final cached = _connections[accountId];
    if (cached != null) return cached;
    final account = _accounts[accountId];
    if (account == null) throw NotFoundException('Unknown account $accountId');
    final definition = _definitionOrThrow(account.providerId);
    _connectedWith[accountId] = definition;
    return _connections[accountId] = _create(account, definition);
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  /// Current upload settings (defaults until [init] loads the saved ones).
  UploadSettings get settings => transfers.settings;

  /// Emits the settings when they change.
  Stream<UploadSettings> get settingsChanges => _settingsChanges.stream;

  /// Applies [settings] (normalized) to the uploads right away and saves
  /// them in the settings store.
  Future<void> updateSettings(UploadSettings settings) async {
    transfers.updateSettings(settings);
    final applied = transfers.settings;
    if (!_settingsChanges.isClosed) _settingsChanges.add(applied);
    await _settingsStore.write(settingsKey, jsonEncode(applied.toJson()));
  }

  /// Folder paths recently used by uploads, most recent first; handy as
  /// suggestions. Paths differing only in case are kept once.
  List<String> get recentFolderPaths => List.unmodifiable(_recentFolderPaths);

  // ---------------------------------------------------------------------------
  // Backups
  // ---------------------------------------------------------------------------

  /// Exports the configuration as an encrypted backup file (JSON text).
  ///
  /// The backup contains the [accounts] with their credentials, the
  /// user's provider edits and custom providers
  /// (`registry.exportUserChanges()`), the upload [settings], the
  /// [recentFolderPaths] and [extra], data of the app (its own
  /// preferences) returned by [importBackup]. [extra] must contain JSON
  /// values only.
  ///
  /// The file is a JSON envelope saying what it is (format, version,
  /// date, key derivation and cipher) with the content encrypted in
  /// `data`: the key is derived from [password] with Argon2id
  /// ([backupKdf]) and the content encrypted with AES-256-GCM. A lost
  /// password cannot be recovered.
  ///
  /// Throws [WeakBackupPasswordException] when [password] has fewer than
  /// [minBackupPasswordLength] characters.
  Future<String> exportBackup({
    required String password,
    Map<String, Object?> extra = const {},
  }) async {
    _checkInitialized();
    if (password.runes.length < minBackupPasswordLength) {
      throw const WeakBackupPasswordException(minBackupPasswordLength);
    }
    if (!_isJson(extra)) {
      throw ArgumentError.value(
        '${extra.keys}',
        'extra',
        'must contain JSON values only',
      );
    }
    final payload = BackupPayload(
      accounts: accounts,
      providers: registry.exportUserChanges(),
      settings: settings,
      recentFolderPaths: recentFolderPaths,
      extra: extra,
    );
    return await sealBackup(
      payload.toJson(),
      password: password,
      kdf: backupKdf,
    );
  }

  /// Restores a backup made by [exportBackup] and returns what changed,
  /// with the `extra` data of the app.
  ///
  /// With [BackupImportMode.merge] (the default) accounts are added or
  /// updated by id, provider changes are imported, the upload settings are
  /// applied and recent folder paths are merged. With
  /// [BackupImportMode.replace] the configuration becomes the one of the
  /// backup: accounts not in it are removed (cancelling their uploads, as
  /// [removeAccount] does), provider changes are reset before importing
  /// those of the backup, and settings and recent paths are replaced.
  ///
  /// Nothing changes when the backup cannot be read: throws
  /// [WrongBackupPasswordException] when [password] is wrong (or the file
  /// was modified) and [InvalidBackupException] when [json] is not a
  /// backup, is damaged or was made by a newer version.
  Future<BackupImportResult> importBackup(
    String json, {
    required String password,
    BackupImportMode mode = BackupImportMode.merge,
  }) async {
    _checkInitialized();
    final (info, content) = await openBackup(json, password: password);
    final backup = BackupPayload.fromJson(content);
    final replace = mode == BackupImportMode.replace;

    // Providers first: accounts may use a custom provider of the backup.
    if (replace) await registry.resetAll();
    final imported = await registry.importProviders(backup.providers);

    final incoming = {for (final a in backup.accounts) a.id: a};
    var added = 0;
    var updated = 0;
    var removed = 0;
    if (replace) {
      for (final id in [..._accounts.keys]) {
        if (!incoming.containsKey(id) && _forgetAccount(id)) removed++;
      }
    }
    for (final account in incoming.values) {
      final current = _accounts[account.id];
      if (current == null) {
        added++;
      } else if (current != account) {
        updated++;
        transfers.folders.invalidate(account.id);
        _dropConnections(where: (a) => a.id == account.id);
      }
      _accounts[account.id] = account;
    }
    if (replace) {
      // Same order as in the backup.
      final ordered = {for (final id in incoming.keys) id: _accounts[id]!};
      _accounts
        ..clear()
        ..addAll(ordered);
    }
    await _persist();

    final settings = backup.settings;
    if (settings != null) await updateSettings(settings);

    _recentFolderPaths = _uniquePaths([
      if (!replace) ..._recentFolderPaths,
      ...backup.recentFolderPaths,
    ]);
    await _settingsStore.write(
      recentFolderPathsKey,
      jsonEncode(_recentFolderPaths),
    );

    return BackupImportResult(
      mode: mode,
      createdAt: info.createdAt,
      accountsAdded: added,
      accountsUpdated: updated,
      accountsRemoved: removed,
      providersImported: imported.length,
      providersSkipped: backup.providers.providers.length - imported.length,
      settingsApplied: settings != null,
      extra: backup.extra,
    );
  }

  /// Reads what a backup file says about itself (format version, date,
  /// key derivation cost) without the password, e.g. to show it before
  /// asking for it.
  ///
  /// Throws [InvalidBackupException] when [json] is not a backup, is
  /// damaged or was made by a newer version.
  static BackupInfo inspectBackup(String json) => inspectBackupEnvelope(json);

  // ---------------------------------------------------------------------------
  // Transfers
  // ---------------------------------------------------------------------------

  /// Queues the upload of [source] to [accountId].
  ///
  /// The destination is [UploadOptions.folderId] or, when given, the folder
  /// at [folderPath] (by name, e.g. `Movies/2026`, created if missing; empty
  /// for the root). [UploadSettings.defaultFolderPath] does not apply.
  ///
  /// The visibility is [UploadOptions.isPublic] when set, else
  /// [visibility] when given, else [UploadSettings.defaultVisibility];
  /// [UploadVisibility.providerDefault] keeps the provider default.
  UploadTask upload(
    String accountId,
    UploadSource source, {
    UploadOptions options = const UploadOptions(),
    String? folderPath,
    UploadVisibility? visibility,
  }) {
    final task = transfers.upload(
      accountId,
      source,
      options: options,
      folderPath: folderPath,
      visibility: visibility,
    );
    _rememberFolderPath(task.folderPath);
    return task;
  }

  /// Uploads every file of [files] to every account of [accountIds], into
  /// the folder at [folderPath] of each account.
  ///
  /// The path is made of folder names (e.g. `Movies/2026`): in each account
  /// every segment is looked up by name (ignoring case) from the root and
  /// created when missing, once per account however many files there are.
  /// When neither [folderPath] nor [UploadOptions.folderId] is given,
  /// [UploadSettings.defaultFolderPath] is used; pass an empty path for the
  /// root folder.
  ///
  /// Pairs for which [skip] returns true are not queued (e.g. files a
  /// provider would reject, see `ProviderLimits.check`). [visibility]
  /// applies as in [upload].
  UploadBatch uploadBatch({
    required List<UploadSource> files,
    required List<String> accountIds,
    String? folderPath,
    UploadOptions options = const UploadOptions(),
    UploadVisibility? visibility,
    UploadPairFilter? skip,
  }) {
    final batch = transfers.uploadBatch(
      files: files,
      accountIds: accountIds,
      folderPath: folderPath,
      options: options,
      visibility: visibility,
      skip: skip,
    );
    if (batch.tasks.isNotEmpty) _rememberFolderPath(batch.folderPath);
    return batch;
  }

  /// Uploads the same [source] to several accounts ("mirror upload").
  ///
  /// A batch of one file: see [uploadBatch].
  List<UploadTask> uploadToMany(
    Iterable<String> accountIds,
    UploadSource source, {
    UploadOptions options = const UploadOptions(),
    String? folderPath,
    UploadVisibility? visibility,
  }) => uploadBatch(
    files: [source],
    accountIds: [...accountIds],
    folderPath: folderPath,
    options: options,
    visibility: visibility,
  ).tasks;

  /// Id of the folder at [path] (folder names, e.g. `Movies/2026`) in
  /// account [accountId]; `null` for the root (an empty path).
  ///
  /// Each segment is looked up by name, ignoring case, and created when
  /// missing if [create] is true (otherwise a [NotFoundException] is
  /// thrown). Results are cached for the session and shared with uploads.
  /// Throws [UnsupportedOperationException] when the provider cannot browse
  /// folders, or cannot create a missing one.
  Future<FolderId?> resolveFolderPath(
    String accountId,
    String path, {
    bool create = true,
  }) => transfers.folders.resolve(accountId, path, create: create);

  /// Cancels transfers and closes every connection.
  Future<void> dispose() async {
    await transfers.dispose();
    _dropConnections(where: (_) => true);
    await _registrySubscription.cancel();
    if (_ownsRegistry) await registry.dispose();
    await _accountChanges.close();
    await _providerChanges.close();
    await _settingsChanges.close();
  }

  // ---------------------------------------------------------------------------

  /// Checks that [provider] accepts its credentials with a cheap call.
  ///
  /// Returns the account login when the provider reports it.
  static Future<String?> verifyConnection(CloudProvider provider) async {
    if (provider is AccountInfoProviding) {
      final info = await provider.accountInfo();
      return info.login ?? info.email;
    }
    if (provider is FolderBrowsing) {
      await provider.listFolder(null);
    }
    return null;
  }

  CloudProvider _create(CloudAccount account, ProviderDefinition definition) {
    var options =
        _optionsBuilder?.call(account, definition) ?? const ProviderOptions();
    if (account.baseUrl != null) {
      options = options.copyWith(baseUrl: account.baseUrl);
    }
    final maxBytes = account.maxFileSizeBytes;
    if (maxBytes != null) {
      final limits = definition.limitsFor(options);
      options = options.copyWith(
        limits: limits.copyWith(maxFileSize: DataSize(maxBytes)),
      );
    }
    return definition.create(account.credentials, options: options);
  }

  ProviderDefinition _definitionOrThrow(String providerId) {
    final definition = provider(providerId);
    if (definition == null) {
      throw NotFoundException(
        'Provider "$providerId" is not available (unknown or disabled)',
      );
    }
    return definition;
  }

  /// Reconnects accounts whose provider definition changed (new domain,
  /// limits...) and notifies listeners.
  void _onProvidersChanged() {
    _dropConnections(
      where: (account) =>
          !identical(_connectedWith[account.id], provider(account.providerId)),
    );
    if (!_providerChanges.isClosed) _providerChanges.add(providers);
  }

  String _newAccountId(String providerId) {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    var id = '$providerId-$stamp';
    for (var i = 1; _accounts.containsKey(id); i++) {
      id = '$providerId-$stamp-$i';
    }
    return id;
  }

  void _checkInitialized() {
    if (!_initialized) throw StateError('Call UpCloud.init() first');
  }

  /// Removes account [id] from memory, cancelling its transfers. Returns
  /// whether it existed; the caller persists the accounts.
  bool _forgetAccount(String id) {
    for (final task in transfers.tasks) {
      if (task.accountId == id) transfers.remove(task);
    }
    transfers.folders.invalidate(id);
    _dropConnections(where: (a) => a.id == id);
    return _accounts.remove(id) != null;
  }

  /// Whether [value] is made of JSON values only (maps with string keys,
  /// lists, strings, finite numbers, booleans and `null`).
  static bool _isJson(Object? value) => switch (value) {
    null || bool() || String() => true,
    num() => value.isFinite,
    List() => value.every(_isJson),
    Map() => value.entries.every((e) => e.key is String && _isJson(e.value)),
    _ => false,
  };

  /// [paths] without repetitions (ignoring case), at most
  /// [maxRecentFolderPaths].
  static List<String> _uniquePaths(Iterable<String> paths) {
    final seen = <String>{};
    return [
      for (final path in paths)
        if (path.isNotEmpty && seen.add(path.toLowerCase())) path,
    ].take(maxRecentFolderPaths).toList();
  }

  void _dropConnections({required bool Function(CloudAccount) where}) {
    _connections.removeWhere((id, provider) {
      final account = _accounts[id];
      if (account == null || !where(account)) return false;
      provider.close();
      _connectedWith.remove(id);
      return true;
    });
  }

  Future<void> _persist() async {
    await _store.save(accounts);
    _emitAccounts();
  }

  void _emitAccounts() {
    if (!_accountChanges.isClosed) _accountChanges.add(accounts);
  }

  Future<void> _loadSettings() async {
    final settings = _decode(
      await _settingsStore.read(settingsKey),
      (json) => UploadSettings.fromJson(json! as Map<String, dynamic>),
    );
    if (settings != null) {
      transfers.updateSettings(settings);
      if (!_settingsChanges.isClosed) _settingsChanges.add(transfers.settings);
    }
    _recentFolderPaths =
        _decode(
          await _settingsStore.read(recentFolderPathsKey),
          (json) => [for (final path in json! as List) path as String],
        ) ??
        const [];
  }

  /// Decodes a saved JSON [value]; `null` when missing or invalid (e.g.
  /// saved by an incompatible version).
  static T? _decode<T>(String? value, T Function(Object? json) read) {
    if (value == null) return null;
    try {
      return read(jsonDecode(value));
    } on Object {
      return null;
    }
  }

  void _rememberFolderPath(String? path) {
    if (path == null || path.isEmpty) return;
    _recentFolderPaths = _uniquePaths([path, ..._recentFolderPaths]);
    // Suggestions only: a failed write must not break the upload.
    unawaited(
      _settingsStore
          .write(recentFolderPathsKey, jsonEncode(_recentFolderPaths))
          .catchError((Object _) {}),
    );
  }
}
