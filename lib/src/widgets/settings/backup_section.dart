import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/src/widgets/common/section.dart';
import 'package:upcloud/src/widgets/settings/backup_dialogs.dart';
import 'package:upcloud/upcloud.dart';

/// Saves the backup file [json] (e.g. with a save dialog), proposing
/// [suggestedFileName]. Returns whether it was saved: `false` when the
/// user cancelled.
typedef BackupFileSaver = Future<bool> Function(
  String json,
  String suggestedFileName,
);

/// Lets the user choose a backup file and returns its content, or `null`
/// when the user cancelled.
typedef BackupFileOpener = Future<String?> Function();

/// Exports and imports the configuration of an [UpCloud] instance as an
/// encrypted backup file: accounts with their credentials, provider
/// changes, upload settings and recent folders, plus preferences of the
/// app (see [exportExtra]).
///
/// * **Export** asks for a password (twice, at least
///   `UpCloud.minBackupPasswordLength` characters, with a strength hint),
///   encrypts the backup with `UpCloud.exportBackup` and hands the file to
///   [onSave].
/// * **Import** gets the content of a file from [onOpen], shows when the
///   backup was made, asks for its password and whether to merge it with
///   the current configuration or replace it (after a confirmation), runs
///   `UpCloud.importBackup` and shows a summary.
///
/// The package reads and writes no files: [onSave] and [onOpen] use the
/// file plugin of the app.
///
/// ```dart
/// BackupSection(
///   onSave: (json, fileName) async =>
///       await FilePicker.saveFile(
///         fileName: fileName,
///         bytes: utf8.encode(json),
///       ) !=
///       null,
///   onOpen: () async {
///     final files = await FilePicker.pickFiles(
///       type: FileType.custom,
///       allowedExtensions: ['json'],
///     );
///     if (files.isEmpty) return null;
///     return utf8.decode(await files.first.readAsBytes());
///   },
/// )
/// ```
class BackupSection extends StatefulWidget {
  /// Creates the section for [upcloud], or the instance of the
  /// [UpCloudScope].
  const BackupSection({
    required this.onSave,
    required this.onOpen,
    this.upcloud,
    this.exportExtra,
    this.onImportedExtra,
    this.title,
    super.key,
  });

  /// Saves a new backup file.
  final BackupFileSaver onSave;

  /// Opens a backup file.
  final BackupFileOpener onOpen;

  /// Instance to back up. Defaults to `UpCloudScope.of(context)`.
  final UpCloud? upcloud;

  /// Preferences of the app to include in the backup (JSON values only),
  /// read when a backup is exported.
  final Map<String, Object?> Function()? exportExtra;

  /// Receives the preferences saved with [exportExtra] after a backup is
  /// restored, before the summary is shown.
  final void Function(Map<String, Object?> extra)? onImportedExtra;

  /// Title of the section. Defaults to the localized "Backup".
  final String? title;

  /// Suggested name of a backup made at [time]: [prefix], the local date
  /// and `.json`.
  static String fileName(DateTime time, {String prefix = 'upcloud-backup'}) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '$prefix-${local.year}-${two(local.month)}-${two(local.day)}.json';
  }

  @override
  State<BackupSection> createState() => _BackupSectionState();
}

enum _Busy { saving, opening }

class _BackupSectionState extends State<BackupSection> {
  _Busy? _busy;

  UpCloud get _upcloud => widget.upcloud ?? UpCloudScope.of(context);

  Future<void> _export() async {
    final upcloud = _upcloud;
    final json = await showBackupExportDialog(
      context,
      export: (password) => upcloud.exportBackup(
        password: password,
        extra: widget.exportExtra?.call() ?? const {},
      ),
    );
    if (json == null || !mounted) return;
    final l10n = UpCloudLocalizations.of(context);
    setState(() => _busy = _Busy.saving);
    try {
      final name = BackupSection.fileName(DateTime.now());
      if (await widget.onSave(json, name)) _showMessage(l10n.backupSaved);
    } on Object {
      _showMessage(l10n.saveBackupFailed);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _import() async {
    final upcloud = _upcloud;
    final l10n = UpCloudLocalizations.of(context);
    setState(() => _busy = _Busy.opening);
    String? json;
    try {
      json = await widget.onOpen();
    } on Object {
      _showMessage(l10n.openBackupFailed);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
    if (json == null || !mounted) return;

    final BackupInfo info;
    try {
      info = UpCloud.inspectBackup(json);
    } on InvalidBackupException catch (e) {
      await _showInvalidFile(e.reason);
      return;
    }
    if (!mounted) return;
    final content = json;
    final result = await showBackupImportDialog(
      context,
      info: info,
      import: (password, mode) =>
          upcloud.importBackup(content, password: password, mode: mode),
    );
    if (result == null || !mounted) return;
    widget.onImportedExtra?.call(result.extra);
    if (!mounted) return;
    await showBackupImportSummary(context, result);
  }

  void _showMessage(String message) {
    if (mounted) showUpCloudSnackBar(context, message);
  }

  Future<void> _showInvalidFile(InvalidBackupReason reason) => showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = UpCloudLocalizations.of(context);
      return AlertDialog(
        key: const ValueKey('upcloud-backup-invalid'),
        icon: const Icon(Icons.error_outline_rounded),
        title: Text(l10n.invalidBackupTitle),
        content: Text(l10n.invalidBackup(reason)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final busy = _busy;
    Widget tile({
      required String key,
      required IconData icon,
      required String title,
      required String subtitle,
      required bool running,
      required VoidCallback onTap,
    }) => ListTile(
      key: ValueKey(key),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: running
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right_rounded),
      enabled: busy == null,
      onTap: onTap,
    );
    return UpCloudSection(
      title: widget.title ?? l10n.backupSection,
      children: [
        tile(
          key: 'upcloud-backup-export',
          icon: Icons.upload_file_rounded,
          title: l10n.exportBackup,
          subtitle: l10n.exportBackupHelper,
          running: busy == _Busy.saving,
          onTap: _export,
        ),
        tile(
          key: 'upcloud-backup-import',
          icon: Icons.settings_backup_restore_rounded,
          title: l10n.importBackup,
          subtitle: l10n.importBackupHelper,
          running: busy == _Busy.opening,
          onTap: _import,
        ),
      ],
    );
  }
}
