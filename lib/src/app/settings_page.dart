import 'package:flutter/material.dart';
import 'package:upcloud/src/app/file_io.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/src/app/settings.dart';
import 'package:upcloud/ui.dart';

/// Upload settings, the app theme and language, and
/// encrypted backups of the whole configuration.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return FormHeader(
      title: title,
      message: message,
      titleStyle: theme.textTheme.titleLarge,
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return FormPageScaffold(
      title: l10n.settings,
      maxWidth: 640,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(
            context,
            icon: Icons.cloud_upload_outlined,
            title: l10n.uploadsSection,
            message: l10n.uploadsSectionHint,
          ),
          const SizedBox(height: 16),
          // Saves every change with UpCloud.updateSettings.
          const UploadSettingsForm(),
          const SizedBox(height: 40),
          _sectionHeader(
            context,
            icon: Icons.palette_outlined,
            title: l10n.appSection,
            message: l10n.appSectionHint,
          ),
          const SizedBox(height: 16),
          const _AppSettings(),
          const SizedBox(height: 40),
          _sectionHeader(
            context,
            icon: Icons.settings_backup_restore_rounded,
            title: l10n.backupSection,
            message: l10n.backupSectionHint,
          ),
          const SizedBox(height: 16),
          const _Backup(),
        ],
      ),
    );
  }
}

/// Export and import of an encrypted backup of the accounts, providers and
/// settings. The theme and language travel in the backup as `extra` data.
class _Backup extends StatelessWidget {
  const _Backup();

  @override
  Widget build(BuildContext context) {
    final notifier = AppSettingsScope.of(context);
    return BackupSection(
      title: UpCloudLocalizations.of(context).backupFile,
      onSave: saveBackupFile,
      onOpen: openBackupFile,
      exportExtra: () => notifier.value.toJson(),
      onImportedExtra: (extra) => notifier.value = notifier.value.merge(extra),
    );
  }
}

/// Theme and language, applied right away.
class _AppSettings extends StatelessWidget {
  const _AppSettings();

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final notifier = AppSettingsScope.of(context);
    final settings = notifier.value;

    Widget section(String title, Widget control) => UpCloudSection(
      title: title,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: double.infinity, child: control),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section(
          l10n.theme,
          SegmentedButton<ThemeMode>(
            key: const ValueKey('settings-theme'),
            showSelectedIcon: false,
            segments: [
              for (final (mode, label) in [
                (ThemeMode.system, l10n.system),
                (ThemeMode.light, l10n.light),
                (ThemeMode.dark, l10n.dark),
              ])
                ButtonSegment(value: mode, label: Text(label)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) =>
                notifier.value = settings.copyWith(themeMode: selection.single),
          ),
        ),
        const SizedBox(height: 24),
        section(
          l10n.language,
          SegmentedButton<String>(
            key: const ValueKey('settings-language'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: '', label: Text(l10n.system)),
              const ButtonSegment(value: 'en', label: Text('English')),
              const ButtonSegment(value: 'es', label: Text('Español')),
            ],
            selected: {settings.locale?.languageCode ?? ''},
            onSelectionChanged: (selection) {
              final code = selection.single;
              notifier.value = settings.copyWith(
                locale: () => code.isEmpty ? null : Locale(code),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        UpCloudSection(
          title: l10n.animatedBackground,
          children: [
            SwitchListTile(
              key: const ValueKey('settings-animated-background'),
              title: Text(l10n.animatedBackgroundHint),
              value: settings.animatedBackground,
              onChanged: (value) =>
                  notifier.value = settings.copyWith(animatedBackground: value),
            ),
          ],
        ),
      ],
    );
  }
}
