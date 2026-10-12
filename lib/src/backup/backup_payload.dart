import 'package:upcloud/src/accounts/cloud_account.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/registry/registry_document.dart';
import 'package:upcloud/src/settings/upload_settings.dart';

/// What to do with the current configuration when importing a backup.
enum BackupImportMode {
  /// Adds what is new and updates what exists; nothing is removed.
  ///
  /// Accounts are matched by id, provider changes are imported, the upload
  /// settings are applied and recent folder paths are merged.
  merge,

  /// Makes the configuration equal to the backup.
  ///
  /// Accounts not in the backup are removed (their uploads are cancelled),
  /// every provider change is discarded before importing those of the
  /// backup, and the upload settings and recent folder paths are replaced.
  replace,
}

/// Outcome of `UpCloud.importBackup`.
final class BackupImportResult {
  /// Creates a result.
  const BackupImportResult({
    required this.mode,
    this.createdAt,
    this.accountsAdded = 0,
    this.accountsUpdated = 0,
    this.accountsRemoved = 0,
    this.providersImported = 0,
    this.providersSkipped = 0,
    this.settingsApplied = false,
    this.extra = const {},
  });

  /// How the backup was imported.
  final BackupImportMode mode;

  /// When the backup was made, if known.
  final DateTime? createdAt;

  /// Accounts of the backup that did not exist.
  final int accountsAdded;

  /// Existing accounts whose data (label, credentials...) changed.
  final int accountsUpdated;

  /// Accounts removed because they are not in the backup
  /// ([BackupImportMode.replace] only).
  final int accountsRemoved;

  /// Provider edits and custom providers imported.
  final int providersImported;

  /// Provider entries that could not be imported (e.g. their driver needs
  /// a newer version of the app).
  final int providersSkipped;

  /// Whether the upload settings of the backup were applied.
  final bool settingsApplied;

  /// The app data passed to `UpCloud.exportBackup` as `extra`.
  final Map<String, Object?> extra;

  @override
  String toString() =>
      'BackupImportResult(${mode.name}, accounts: +$accountsAdded '
      '~$accountsUpdated -$accountsRemoved, providers: $providersImported '
      '(skipped $providersSkipped), settings: $settingsApplied)';
}

/// The encrypted content of a backup.
final class BackupPayload {
  /// Creates a payload.
  BackupPayload({
    required this.accounts,
    required this.providers,
    required this.settings,
    required this.recentFolderPaths,
    required this.extra,
  });

  /// Reads a payload written by [toJson].
  ///
  /// Throws [InvalidBackupException] if it is malformed or newer than
  /// [version].
  factory BackupPayload.fromJson(Map<String, Object?> json) {
    final payloadVersion = json['version'];
    if (payloadVersion is! int) throw _corrupted();
    if (payloadVersion > version) {
      throw InvalidBackupException(
        'Backup content version $payloadVersion is newer than $version: '
        'update the app to restore it',
        reason: InvalidBackupReason.unsupported,
      );
    }
    // Errors are not attached as causes: they may quote secrets.
    try {
      final settings = json['settings'];
      final providers = json['providers'];
      return BackupPayload(
        accounts: [
          for (final account in json['accounts'] as List? ?? const [])
            CloudAccount.fromJson(account as Map<String, Object?>),
        ],
        providers: providers == null
            ? RegistryDocument(providers: const [])
            : RegistryDocument.fromJson(providers as Map<String, Object?>),
        settings: settings == null
            ? null
            : UploadSettings.fromJson(settings as Map<String, Object?>),
        recentFolderPaths: [
          for (final path in json['recentFolderPaths'] as List? ?? const [])
            path as String,
        ],
        extra: Map.unmodifiable(json['extra'] as Map? ?? const {}),
      );
    } on Object {
      throw _corrupted();
    }
  }

  /// Version of the payload format written by [toJson].
  static const version = 1;

  /// Accounts, with their credentials.
  final List<CloudAccount> accounts;

  /// The user's provider edits and custom providers.
  final RegistryDocument providers;

  /// Upload settings; `null` leaves the current ones.
  final UploadSettings? settings;

  /// Recently used folder paths, most recent first.
  final List<String> recentFolderPaths;

  /// Data of the app.
  final Map<String, Object?> extra;

  /// JSON representation.
  Map<String, Object?> toJson() => {
    'version': version,
    'accounts': [for (final account in accounts) account.toJson()],
    'providers': providers.toJson(),
    if (settings case final settings?) 'settings': settings.toJson(),
    'recentFolderPaths': recentFolderPaths,
    'extra': extra,
  };

  static InvalidBackupException _corrupted() => const InvalidBackupException(
    'The backup content is malformed',
    reason: InvalidBackupReason.corrupted,
  );
}
