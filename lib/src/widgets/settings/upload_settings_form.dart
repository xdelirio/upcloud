import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/widgets/common/folder_path_field.dart';
import 'package:upcloud/src/widgets/common/labeled_row.dart';
import 'package:upcloud/src/widgets/common/section.dart';
import 'package:upcloud/upcloud.dart';

/// Edits the [UploadSettings] of an [UpCloud] instance: simultaneous
/// uploads, automatic retries, free storage check, auto-clear of completed
/// uploads, default folder and default visibility.
///
/// Reads `upcloud.settings`, saves every change with
/// `UpCloud.updateSettings` (typing in the folder field is debounced) and
/// follows `UpCloud.settingsChanges`.
///
/// It is a column of sections that sizes itself to its content: put it in
/// a scroll view.
///
/// ```dart
/// SingleChildScrollView(
///   padding: const EdgeInsets.all(16),
///   child: UploadSettingsForm(),
/// );
/// ```
class UploadSettingsForm extends StatefulWidget {
  /// Creates the form for [upcloud], or the instance of the [UpCloudScope].
  const UploadSettingsForm({this.upcloud, super.key});

  /// Instance to edit. Defaults to `UpCloudScope.of(context)`.
  final UpCloud? upcloud;

  @override
  State<UploadSettingsForm> createState() => _UploadSettingsFormState();
}

class _UploadSettingsFormState extends State<UploadSettingsForm> {
  /// Choices of [UploadSettings.autoClearAfterSeconds]: `null` (never), `0`
  /// (immediately), 30 s, 5 min and 30 min. The current value is always
  /// offered too.
  static const _autoClearChoices = <int?>[null, 0, 30, 300, 1800];

  /// Delay after the last keystroke before the default folder is saved.
  static const _textDebounce = Duration(milliseconds: 600);

  /// Space between sections.
  static const _spacing = 24.0;

  final _folder = TextEditingController();
  final _folderFocus = FocusNode();
  UpCloud? _upcloud;
  StreamSubscription<UploadSettings>? _subscription;
  late UploadSettings _settings;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _folderFocus.addListener(_onFolderFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(UploadSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
  }

  void _attach() {
    final upcloud = widget.upcloud ?? UpCloudScope.of(context);
    if (identical(upcloud, _upcloud)) return;
    _flushFolder(rebuild: false);
    unawaited(_subscription?.cancel());
    _upcloud = upcloud;
    _settings = upcloud.settings;
    _folder.text = _settings.defaultFolderPath ?? '';
    _subscription = upcloud.settingsChanges.listen(_onSettings);
  }

  void _onSettings(UploadSettings settings) {
    if (!mounted) return;
    setState(() => _settings = settings);
    // Do not rewrite the text (and move the cursor) while the user types.
    if (!_folderFocus.hasFocus && _debounce == null) {
      final path = settings.defaultFolderPath ?? '';
      if (_folder.text != path) _folder.text = path;
    }
  }

  void _onFolderFocus() {
    if (_folderFocus.hasFocus) return;
    _flushFolder();
    final path = _settings.defaultFolderPath ?? '';
    if (_folder.text.trim() != path) _folder.text = path;
  }

  void _update(UploadSettings settings, {bool rebuild = true}) {
    if (rebuild) {
      setState(() => _settings = settings);
    } else {
      _settings = settings;
    }
    final upcloud = _upcloud;
    if (upcloud == null) return;
    // Settings apply before being saved: a failed write only loses
    // persistence.
    unawaited(upcloud.updateSettings(settings).catchError((Object _) {}));
  }

  void _onFolderChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(_textDebounce, _flushFolder);
  }

  void _flushFolder({bool rebuild = true}) {
    final pending = _debounce;
    if (pending == null) return;
    pending.cancel();
    _debounce = null;
    final text = _folder.text.trim();
    final path = text.isEmpty ? null : normalizeFolderPath(text);
    if (path != _settings.defaultFolderPath) {
      _update(_settings.copyWith(defaultFolderPath: path), rebuild: rebuild);
    }
  }

  @override
  void dispose() {
    _flushFolder(rebuild: false);
    unawaited(_subscription?.cancel());
    _folderFocus
      ..removeListener(_onFolderFocus)
      ..dispose();
    _folder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final settings = _settings;
    final autoClear = [
      ..._autoClearChoices,
      if (!_autoClearChoices.contains(settings.autoClearAfterSeconds))
        settings.autoClearAfterSeconds,
    ];
    String autoClearLabel(int? seconds) => switch (seconds) {
      null => l10n.autoClearNever,
      0 => l10n.autoClearImmediately,
      _ => l10n.autoClearAfter(Duration(seconds: seconds)),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        UpCloudSection(
          title: l10n.uploadQueueSection,
          children: [
            _CountTile(
              keyPrefix: 'upcloud-settings-concurrency',
              title: l10n.maxConcurrentUploads,
              subtitle: l10n.maxConcurrentUploadsHelper,
              value: settings.maxConcurrentUploads,
              min: UploadSettings.minConcurrentUploads,
              max: UploadSettings.maxConcurrentUploadsLimit,
              onChanged: (value) =>
                  _update(_settings.copyWith(maxConcurrentUploads: value)),
            ),
            _CountTile(
              keyPrefix: 'upcloud-settings-retries',
              title: l10n.automaticRetries,
              subtitle: l10n.automaticRetriesHelper,
              value: settings.retries,
              min: 0,
              max: UploadSettings.maxRetries,
              format: (value) => value == 0 ? l10n.off : '$value',
              onChanged: (value) => _update(_settings.copyWith(retries: value)),
            ),
            SwitchListTile(
              key: const ValueKey('upcloud-settings-check-storage'),
              title: Text(l10n.checkStorage),
              subtitle: Text(l10n.checkStorageHelper),
              value: settings.checkStorage,
              onChanged: (value) =>
                  _update(_settings.copyWith(checkStorage: value)),
            ),
          ],
        ),
        const SizedBox(height: _spacing),
        UpCloudSection(
          title: l10n.finishedUploadsSection,
          children: [
            LabeledRow(
              title: l10n.autoClear,
              subtitle: l10n.autoClearHelper,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final seconds in autoClear)
                    ChoiceChip(
                      key: ValueKey('upcloud-settings-auto-clear-$seconds'),
                      label: Text(autoClearLabel(seconds)),
                      selected: settings.autoClearAfterSeconds == seconds,
                      onSelected: (_) => _update(
                        _settings.copyWith(autoClearAfterSeconds: seconds),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacing),
        UpCloudSection(
          title: l10n.uploadDefaultsSection,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: FolderPathField(
                fieldKey: const ValueKey('upcloud-settings-default-folder'),
                controller: _folder,
                focusNode: _folderFocus,
                label: l10n.defaultFolder,
                helperText: l10n.defaultFolderHelper,
                suggestions: _upcloud?.recentFolderPaths ?? const [],
                onChanged: _onFolderChanged,
                onSubmitted: (_) => _flushFolder(),
              ),
            ),
            LabeledRow(
              title: l10n.visibilityLabel,
              child: VisibilitySelector(
                key: const ValueKey('upcloud-settings-visibility'),
                value: settings.defaultVisibility,
                onChanged: (value) =>
                    _update(_settings.copyWith(defaultVisibility: value)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A choice of [UploadVisibility], as chips.
class VisibilitySelector extends StatelessWidget {
  /// Creates a selector showing [value].
  const VisibilitySelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Selected visibility.
  final UploadVisibility value;

  /// Called with the new visibility.
  final ValueChanged<UploadVisibility>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final onChanged = this.onChanged;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final visibility in UploadVisibility.values)
          ChoiceChip(
            key: ValueKey('upcloud-visibility-${visibility.name}'),
            showCheckmark: false,
            avatar: Icon(switch (visibility) {
              UploadVisibility.providerDefault => Icons.tune_rounded,
              UploadVisibility.public => Icons.public_rounded,
              UploadVisibility.private => Icons.lock_outline_rounded,
            }, size: 18),
            label: Text(l10n.visibility(visibility)),
            selected: visibility == value,
            onSelected: onChanged == null ? null : (_) => onChanged(visibility),
          ),
      ],
    );
  }
}

/// A title with the current value, a helper text and a slider.
class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.keyPrefix,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.format,
  });

  final String keyPrefix;
  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String Function(int value)? format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = format?.call(value) ?? '$value';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
              const SizedBox(width: 12),
              Text(
                text,
                key: ValueKey('$keyPrefix-value'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Slider(
            key: ValueKey('$keyPrefix-slider'),
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: text,
            semanticFormatterCallback: (value) =>
                format?.call(value.round()) ?? '${value.round()}',
            onChanged: (value) {
              final rounded = value.round();
              if (rounded != this.value) onChanged(rounded);
            },
          ),
        ],
      ),
    );
  }
}
