import 'package:flutter/material.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/utils/password_strength.dart';
import 'package:upcloud/src/widgets/common/busy_button.dart';
import 'package:upcloud/src/widgets/common/dialogs.dart';
import 'package:upcloud/src/widgets/common/secret_visibility_button.dart';
import 'package:upcloud/upcloud.dart';

/// Asks for the password of a new backup and runs [export] with it.
/// Returns the backup file, or `null` when cancelled.
Future<String?> showBackupExportDialog(
  BuildContext context, {
  required Future<String> Function(String password) export,
}) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (context) => _ExportDialog(export: export),
);

/// Asks for the password of the backup described by [info] and how to
/// import it, then runs [import]. Returns its result, or `null` when
/// cancelled.
Future<BackupImportResult?> showBackupImportDialog(
  BuildContext context, {
  required BackupInfo info,
  required Future<BackupImportResult> Function(
    String password,
    BackupImportMode mode,
  )
  import,
}) => showDialog<BackupImportResult>(
  context: context,
  barrierDismissible: false,
  builder: (context) => _ImportDialog(info: info, import: import),
);

/// Shows what a restored backup changed.
Future<void> showBackupImportSummary(
  BuildContext context,
  BackupImportResult result,
) => showDialog<void>(
  context: context,
  builder: (context) => _ImportSummaryDialog(result: result),
);

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
          BusyButton(
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
          BusyButton(
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
            : SecretVisibilityButton(obscured: obscured, onPressed: onToggle),
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
