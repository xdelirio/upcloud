import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/scope/upcloud_scope.dart';
import 'package:upcloud_flutter/src/utils/password_strength.dart';
import 'package:upcloud_flutter/src/widgets/common/dialogs.dart';
import 'package:upcloud_flutter/src/widgets/common/section.dart';

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
    this.fileNamePrefix = 'upcloud-backup',
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

  /// Start of the suggested file name, followed by the date:
  /// `upcloud-backup-2026-09-28.json`.
  final String fileNamePrefix;

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
    final json = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ExportDialog(
        export: (password) => upcloud.exportBackup(
          password: password,
          extra: widget.exportExtra?.call() ?? const {},
        ),
      ),
    );
    if (json == null || !mounted) return;
    final l10n = UpCloudLocalizations.of(context);
    setState(() => _busy = _Busy.saving);
    try {
      final name = BackupSection.fileName(
        DateTime.now(),
        prefix: widget.fileNamePrefix,
      );
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
    final result = await showDialog<BackupImportResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportDialog(
        info: info,
        import: (password, mode) =>
            upcloud.importBackup(content, password: password, mode: mode),
      ),
    );
    if (result == null || !mounted) return;
    widget.onImportedExtra?.call(result.extra);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _ImportSummaryDialog(result: result),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

/// Asks for the password of a new backup and exports it; pops with the
/// backup file.
class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.export});

  final Future<String> Function(String password) export;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _obscured = true;
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() => setState(() {});

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final json = await widget.export(_password.text);
      if (mounted) Navigator.of(context).pop(json);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = UpCloudLocalizations.of(context).errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const minLength = UpCloud.minBackupPasswordLength;
    final error = _error;

    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        key: const ValueKey('upcloud-backup-export-dialog'),
        icon: const Icon(Icons.lock_outline_rounded),
        title: Text(l10n.exportBackupTitle),
        scrollable: true,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.exportBackupMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _PasswordField(
                  fieldKey: const ValueKey('upcloud-backup-password'),
                  controller: _password,
                  label: l10n.password,
                  obscured: _obscured,
                  enabled: !_busy,
                  autofocus: true,
                  newPassword: true,
                  textInputAction: TextInputAction.next,
                  onToggle: () => setState(() => _obscured = !_obscured),
                  validator: (value) => (value ?? '').runes.length < minLength
                      ? l10n.passwordTooShort(minLength)
                      : null,
                ),
                const SizedBox(height: 10),
                _StrengthMeter(strength: PasswordStrength.of(_password.text)),
                const SizedBox(height: 16),
                _PasswordField(
                  fieldKey: const ValueKey('upcloud-backup-confirm'),
                  controller: _confirm,
                  label: l10n.confirmPassword,
                  obscured: _obscured,
                  enabled: !_busy,
                  newPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) =>
                      value != _password.text ? l10n.passwordsDoNotMatch : null,
                ),
                const SizedBox(height: 16),
                _Notice(
                  icon: Icons.warning_amber_rounded,
                  text: l10n.backupPasswordWarning,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    key: const ValueKey('upcloud-backup-error'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          _BusyButton(
            key: const ValueKey('upcloud-backup-submit'),
            busy: _busy,
            label: l10n.exportAction,
            busyLabel: l10n.encryptingBackup,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// Asks for the password of a backup and how to import it, then imports
/// it; pops with the result.
class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.info, required this.import});

  final BackupInfo info;
  final Future<BackupImportResult> Function(
    String password,
    BackupImportMode mode,
  )
  import;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  BackupImportMode _mode = BackupImportMode.merge;
  var _obscured = true;
  var _busy = false;
  String? _passwordError;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_formKey.currentState?.validate() ?? false)) return;
    final l10n = UpCloudLocalizations.of(context);
    if (_mode == BackupImportMode.replace) {
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.replaceConfirmTitle,
        message: l10n.replaceConfirmMessage,
        confirmLabel: l10n.replaceAction,
        destructive: true,
      );
      if (!confirmed || !mounted) return;
    }
    setState(() {
      _busy = true;
      _passwordError = null;
      _error = null;
    });
    try {
      final result = await widget.import(_password.text, _mode);
      if (mounted) Navigator.of(context).pop(result);
    } on WrongBackupPasswordException {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _passwordError = l10n.wrongBackupPassword;
      });
      _password.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _password.text.length,
      );
      _passwordFocus.requestFocus();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final createdAt = widget.info.createdAt?.toLocal();
    String? date;
    if (createdAt != null) {
      final time = material.formatTimeOfDay(
        TimeOfDay.fromDateTime(createdAt),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );
      date = '${material.formatShortDate(createdAt)} · $time';
    }
    final replace = _mode == BackupImportMode.replace;
    final error = _error;

    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        key: const ValueKey('upcloud-backup-import-dialog'),
        icon: const Icon(Icons.settings_backup_restore_rounded),
        title: Text(l10n.importBackupTitle),
        scrollable: true,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (date != null) ...[
                  _Notice(
                    icon: Icons.event_outlined,
                    tone: _NoticeTone.neutral,
                    text: l10n.backupCreatedAt(date),
                  ),
                  const SizedBox(height: 20),
                ],
                _PasswordField(
                  fieldKey: const ValueKey('upcloud-backup-import-password'),
                  controller: _password,
                  focusNode: _passwordFocus,
                  label: l10n.password,
                  helperText: l10n.backupPasswordHelper,
                  errorText: _passwordError,
                  obscured: _obscured,
                  enabled: !_busy,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onToggle: () => setState(() => _obscured = !_obscured),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  onSubmitted: (_) => _submit(),
                  validator: (value) => (value ?? '').isEmpty
                      ? l10n.fieldRequired(l10n.password)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(l10n.importModeLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                RadioGroup<BackupImportMode>(
                  groupValue: _mode,
                  onChanged: (mode) {
                    if (mode != null && !_busy) setState(() => _mode = mode);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (mode, title, subtitle) in [
                        (
                          BackupImportMode.merge,
                          l10n.importMerge,
                          l10n.importMergeHelper,
                        ),
                        (
                          BackupImportMode.replace,
                          l10n.importReplace,
                          l10n.importReplaceHelper,
                        ),
                      ])
                        RadioListTile<BackupImportMode>(
                          key: ValueKey('upcloud-backup-mode-${mode.name}'),
                          value: mode,
                          enabled: !_busy,
                          contentPadding: EdgeInsets.zero,
                          title: Text(title),
                          subtitle: Text(subtitle),
                        ),
                    ],
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    key: const ValueKey('upcloud-backup-error'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          _BusyButton(
            key: const ValueKey('upcloud-backup-submit'),
            busy: _busy,
            destructive: replace,
            label: replace ? l10n.replaceAction : l10n.importAction,
            busyLabel: l10n.decryptingBackup,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

/// What a restored backup changed.
class _ImportSummaryDialog extends StatelessWidget {
  const _ImportSummaryDialog({required this.result});

  final BackupImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lines = <(IconData, String)>[
      if (result.accountsAdded > 0)
        (
          Icons.person_add_alt_rounded,
          l10n.accountsAdded(result.accountsAdded),
        ),
      if (result.accountsUpdated > 0)
        (
          Icons.manage_accounts_outlined,
          l10n.accountsUpdated(result.accountsUpdated),
        ),
      if (result.accountsRemoved > 0)
        (
          Icons.person_remove_outlined,
          l10n.accountsRemoved(result.accountsRemoved),
        ),
      if (result.providersImported > 0)
        (Icons.dns_outlined, l10n.providersImported(result.providersImported)),
      if (result.providersSkipped > 0)
        (
          Icons.info_outline_rounded,
          l10n.providersSkipped(result.providersSkipped),
        ),
      if (result.settingsApplied)
        (Icons.tune_rounded, l10n.uploadSettingsRestored),
    ];
    return AlertDialog(
      key: const ValueKey('upcloud-backup-summary'),
      icon: Icon(Icons.check_circle_outline_rounded, color: scheme.primary),
      title: Text(l10n.backupRestored),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lines.isEmpty) Text(l10n.backupUpToDate),
          for (final (icon, text) in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

/// A password field with a show/hide button.
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.obscured,
    required this.enabled,
    required this.textInputAction,
    this.focusNode,
    this.helperText,
    this.errorText,
    this.autofocus = false,
    this.newPassword = false,
    this.onToggle,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? helperText;
  final String? errorText;
  final bool obscured;
  final bool enabled;
  final bool autofocus;
  final bool newPassword;
  final TextInputAction textInputAction;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final onToggle = this.onToggle;
    return TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscured,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: [
        if (newPassword) AutofillHints.newPassword else AutofillHints.password,
      ],
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        errorText: errorText,
        errorMaxLines: 3,
        prefixIcon: const Icon(Icons.key_rounded),
        suffixIcon: onToggle == null
            ? null
            : IconButton(
                icon: Icon(
                  obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: obscured ? l10n.showSecret : l10n.hideSecret,
                onPressed: onToggle,
              ),
      ),
    );
  }
}

/// A bar and a word telling the [strength] of a password.
class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final color = switch (strength) {
      PasswordStrength.tooShort => scheme.outline,
      PasswordStrength.weak => scheme.error,
      PasswordStrength.fair =>
        dark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
      PasswordStrength.good =>
        dark ? const Color(0xFF9CCC65) : const Color(0xFF558B2F),
      PasswordStrength.strong =>
        dark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
    };
    final levels = PasswordStrength.values.length - 1;
    return Semantics(
      container: true,
      label: l10n.passwordStrength(strength),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var level = 1; level <= levels; level++) ...[
              if (level > 1) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  decoration: BoxDecoration(
                    color: strength.index >= level
                        ? color
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: Text(
                l10n.passwordStrength(strength),
                key: const ValueKey('upcloud-backup-strength'),
                textAlign: TextAlign.end,
                style: theme.textTheme.labelMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NoticeTone { warning, neutral }

/// An icon and a short text on a tinted background.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    this.tone = _NoticeTone.warning,
  });

  final IconData icon;
  final String text;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (tone) {
      _NoticeTone.warning => (scheme.errorContainer, scheme.onErrorContainer),
      _NoticeTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A filled button that shows a spinner and [busyLabel] while [busy].
class _BusyButton extends StatelessWidget {
  const _BusyButton({
    required this.busy,
    required this.label,
    required this.busyLabel,
    required this.onPressed,
    this.destructive = false,
    super.key,
  });

  final bool busy;
  final String label;
  final String busyLabel;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = destructive
        ? FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          )
        : null;
    if (!busy) {
      return FilledButton(
        style: style,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return FilledButton.icon(
      style: style,
      onPressed: null,
      icon: const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      label: Text(busyLabel),
    );
  }
}
