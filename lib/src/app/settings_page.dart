import 'package:flutter/material.dart';
import 'package:upcloud/src/app/file_io.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/src/app/settings.dart';
import 'package:upcloud/src/app/strings.dart';
import 'package:upcloud/ui.dart';

/// Upload settings, the app theme and language, and
/// encrypted backups of the whole configuration.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    return FormPageScaffold(
      title: strings.settings,
      maxWidth: 640,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageSection(
            icon: Icons.cloud_upload_outlined,
            title: strings.uploadsSection,
            message: strings.uploadsSectionHint,
          ),
          const SizedBox(height: 16),
          // Saves every change with UpCloud.updateSettings.
          const UploadSettingsForm(),
          const SizedBox(height: 40),
          _PageSection(
            icon: Icons.palette_outlined,
            title: strings.appSection,
            message: strings.appSectionHint,
          ),
          const SizedBox(height: 16),
          const _AppSettings(),
          const SizedBox(height: 40),
          _PageSection(
            icon: Icons.settings_backup_restore_rounded,
            title: strings.backupSection,
            message: strings.backupSectionHint,
          ),
          const SizedBox(height: 16),
          const _Backup(),
        ],
      ),
    );
  }
}

class _PageSection extends StatelessWidget {
  const _PageSection({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: scheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
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
      title: ExampleStrings.of(context).backupFile,
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
    final strings = ExampleStrings.of(context);
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
          strings.theme,
          SegmentedButton<ThemeMode>(
            key: const ValueKey('settings-theme'),
            showSelectedIcon: false,
            segments: [
              for (final (mode, label) in [
                (ThemeMode.system, strings.system),
                (ThemeMode.light, strings.light),
                (ThemeMode.dark, strings.dark),
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
          strings.language,
          SegmentedButton<String>(
            key: const ValueKey('settings-language'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: '', label: Text(strings.system)),
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
      ],
    );
  }
}
