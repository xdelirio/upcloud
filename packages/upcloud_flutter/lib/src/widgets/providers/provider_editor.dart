import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/controllers/providers_controller.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/widgets/common/dialogs.dart';

final _idPattern = RegExp(r'^[a-z0-9][a-z0-9_-]*$');

/// Edits a [ProviderConfig] of the provider registry, or creates a custom
/// provider when [initial] is `null`.
///
/// Offers the name, description, website, API base URL, mirrors, file
/// link template (`ProviderConfig.fileUrlTemplate`), upload limits, the
/// driver specific settings (`CloudDriver.settings`) and the enabled flag.
/// New providers also choose an id and a driver. Modified entries can be
/// reset to the registry defaults.
///
/// The form is not scrollable; place it inside a scroll view, or use
/// [showProviderEditor].
class ProviderEditor extends StatefulWidget {
  /// Creates an editor.
  const ProviderEditor({
    required this.controller,
    this.initial,
    this.onSaved,
    this.onReset,
    this.submitLabel,
    super.key,
  });

  /// Controller used to validate and save the config.
  final ProvidersController controller;

  /// Config to edit, `null` to add a custom provider.
  final ProviderConfig? initial;

  /// Called with the saved config.
  final ValueChanged<ProviderConfig>? onSaved;

  /// Called after "reset to default". The provider no longer exists when it
  /// was a custom one.
  final VoidCallback? onReset;

  /// Label of the save button. Defaults to "Save".
  final String? submitLabel;

  @override
  State<ProviderEditor> createState() => _ProviderEditorState();
}

class _ProviderEditorState extends State<ProviderEditor> {
  final _formKey = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _website = TextEditingController();
  final _apiBase = TextEditingController();
  final _fileUrlTemplate = TextEditingController();
  final _maxSize = TextEditingController();
  final _extensions = TextEditingController();
  final _mirrors = <TextEditingController>[];
  final _settingTexts = <String, TextEditingController>{};
  final _settingFlags = <String, bool>{};
  ProviderConfig? _base;
  String? _driverId;
  var _enabled = true;
  var _saving = false;
  List<ConfigProblem> _problems = const [];
  Object? _error;

  bool get _isNew => _base == null;

  CloudDriver? get _driver =>
      _driverId == null ? null : widget.controller.driver(_driverId!);

  @override
  void initState() {
    super.initState();
    _fill(widget.initial);
  }

  @override
  void didUpdateWidget(ProviderEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial?.id != widget.initial?.id) _fill(widget.initial);
  }

  /// Loads [config] (or defaults for a new provider) into the fields.
  void _fill(ProviderConfig? config) {
    _base = config;
    _driverId = config?.driver ?? widget.controller.drivers.firstOrNull?.id;
    _id.text = config?.id ?? '';
    _name.text = config?.name ?? '';
    _description.text = config?.description ?? '';
    _website.text = config?.website?.toString() ?? '';
    _apiBase.text = config?.apiBase?.toString() ?? '';
    _fileUrlTemplate.text = config?.fileUrlTemplate ?? '';
    final maxSize = config?.limits?.maxFileSizeMb;
    _maxSize.text = maxSize == null ? '' : _formatNumber(maxSize);
    _extensions.text = config?.limits?.allowedExtensions?.join(', ') ?? '';
    _setMirrors([for (final url in config?.mirrors ?? <Uri>[]) '$url']);
    _enabled = config?.enabled ?? true;
    _fillSettings(config);
    _problems = const [];
    _error = null;
  }

  void _setMirrors(List<String> values) {
    for (final controller in _mirrors) {
      controller.dispose();
    }
    _mirrors
      ..clear()
      ..addAll([for (final v in values) TextEditingController(text: v)]);
  }

  void _fillSettings(ProviderConfig? config) {
    for (final controller in _settingTexts.values) {
      controller.dispose();
    }
    _settingTexts.clear();
    _settingFlags.clear();
    for (final setting in _driver?.settings ?? const <DriverSetting>[]) {
      final value = config?.settings[setting.key];
      if (setting.kind == DriverSettingKind.flag) {
        _settingFlags[setting.key] = value == true || value == 'true';
      } else {
        _settingTexts[setting.key] = TextEditingController(
          text: switch (value) {
            null => '',
            final num n => _formatNumber(n),
            _ => '$value',
          },
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _id,
      _name,
      _description,
      _website,
      _apiBase,
      _fileUrlTemplate,
      _maxSize,
      _extensions,
      ..._mirrors,
      ..._settingTexts.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  static String _formatNumber(num value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';

  static num? _parseNumber(String text) =>
      num.tryParse(text.trim().replaceAll(',', '.'));

  ProviderConfig _buildConfig() {
    final driver = _driverId!;
    final base =
        _base ?? ProviderConfig(id: _id.text.trim(), name: '', driver: driver);
    final maxText = _maxSize.text.trim();
    final extensionsText = _extensions.text.trim();
    final limits = (base.limits ?? const LimitsConfig()).copyWith(
      maxFileSizeMb: maxText.isEmpty ? null : _parseNumber(maxText)?.toDouble(),
      allowedExtensions: extensionsText.isEmpty
          ? null
          : [
              for (final part in extensionsText.split(RegExp(r'[,;\s]+')))
                if (part.trim().isNotEmpty)
                  part.trim().toLowerCase().replaceFirst('.', ''),
            ],
    );
    final settings = <String, Object?>{...base.settings};
    for (final setting in _driver?.settings ?? const <DriverSetting>[]) {
      switch (setting.kind) {
        case DriverSettingKind.flag:
          settings[setting.key] = _settingFlags[setting.key] ?? false;
        case DriverSettingKind.number:
          final value = _parseNumber(_settingTexts[setting.key]?.text ?? '');
          if (value == null) {
            settings.remove(setting.key);
          } else {
            settings[setting.key] = value;
          }
        case DriverSettingKind.text || DriverSettingKind.url:
          final text = _settingTexts[setting.key]?.text.trim() ?? '';
          if (text.isEmpty) {
            settings.remove(setting.key);
          } else {
            settings[setting.key] = text;
          }
      }
    }
    final description = _description.text.trim();
    final fileUrlTemplate = _fileUrlTemplate.text.trim();
    return base.copyWith(
      name: _name.text.trim(),
      description: description.isEmpty ? null : description,
      website: parseHttpUrl(_website.text),
      apiBase: parseHttpUrl(_apiBase.text),
      mirrors: [for (final mirror in _mirrors) ?parseHttpUrl(mirror.text)],
      fileUrlTemplate: fileUrlTemplate.isEmpty ? null : fileUrlTemplate,
      limits: limits == const LimitsConfig() ? null : limits,
      settings: settings,
      enabled: _enabled,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _problems = const [];
      _error = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final config = _buildConfig();
    final problems = widget.controller.validate(config);
    if (problems.isNotEmpty) {
      setState(() => _problems = problems);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.controller.save(config);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _base = widget.controller.state.config(config.id) ?? config;
      });
      widget.onSaved?.call(config);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e;
        });
      }
    }
  }

  Future<void> _reset() async {
    final base = _base;
    if (base == null) return;
    final l10n = UpCloudLocalizations.of(context);
    final isCustom = widget.controller.state.isCustom(base.id);
    final confirmed = await showConfirmDialog(
      context,
      title: isCustom ? l10n.delete : l10n.resetToDefault,
      message: isCustom
          ? l10n.deleteProviderMessage(base.name)
          : l10n.resetProviderMessage(base.name),
      confirmLabel: isCustom ? l10n.delete : l10n.resetToDefault,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await widget.controller.reset(base.id);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
      return;
    }
    if (!mounted) return;
    final restored = widget.controller.state.config(base.id);
    if (restored != null) setState(() => _fill(restored));
    widget.onReset?.call();
  }

  void _onDriverChanged(String? id) {
    if (id == null || id == _driverId) return;
    setState(() {
      _driverId = id;
      _fillSettings(_base);
      _problems = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final driver = _driver;
    final base = _base;
    final isModified =
        base != null && widget.controller.state.isModified(base.id);
    final isCustom = base != null && widget.controller.state.isCustom(base.id);
    final enabled = !_saving;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isNew) ...[
            DropdownButtonFormField<String>(
              key: const ValueKey('upcloud-provider-driver'),
              initialValue: _driverId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.driver,
                helperText: driver?.description,
                helperMaxLines: 3,
                prefixIcon: const Icon(Icons.extension_outlined),
              ),
              items: [
                for (final d in widget.controller.drivers)
                  DropdownMenuItem(value: d.id, child: Text(d.name)),
              ],
              onChanged: enabled ? _onDriverChanged : null,
              validator: (value) =>
                  value == null ? l10n.fieldRequired(l10n.driver) : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('upcloud-provider-id'),
              controller: _id,
              enabled: enabled,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.providerId,
                helperText: l10n.providerIdHelper,
                helperMaxLines: 2,
                prefixIcon: const Icon(Icons.tag_rounded),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return l10n.fieldRequired(l10n.providerId);
                if (!_idPattern.hasMatch(text)) return l10n.invalidProviderId;
                if (widget.controller.state.config(text) != null) {
                  return l10n.duplicateProviderId;
                }
                return null;
              },
            ),
          ] else
            _Summary(
              config: base!,
              driverName: driver?.name ?? l10n.unknownDriver(base.driver),
              isCustom: isCustom,
              isModified: isModified,
            ),
          section(l10n.general),
          TextFormField(
            key: const ValueKey('upcloud-provider-name'),
            controller: _name,
            enabled: enabled,
            decoration: InputDecoration(labelText: l10n.name),
            validator: (value) => (value?.trim() ?? '').isEmpty
                ? l10n.fieldRequired(l10n.name)
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('upcloud-provider-description'),
            controller: _description,
            enabled: enabled,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: '${l10n.description} (${l10n.optional})',
            ),
          ),
          const SizedBox(height: 16),
          _UrlField(
            fieldKey: const ValueKey('upcloud-provider-website'),
            controller: _website,
            enabled: enabled,
            label: '${l10n.website} (${l10n.optional})',
            icon: Icons.public_rounded,
          ),
          section(l10n.connection),
          _UrlField(
            fieldKey: const ValueKey('upcloud-provider-api-base'),
            controller: _apiBase,
            enabled: enabled,
            label: (driver?.requiresApiBase ?? true)
                ? l10n.baseUrl
                : '${l10n.baseUrl} (${l10n.optional})',
            icon: Icons.dns_outlined,
            required: driver?.requiresApiBase ?? true,
          ),
          const SizedBox(height: 16),
          Text(l10n.mirrors, style: theme.textTheme.bodyLarge),
          Text(
            l10n.mirrorsHelper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final (index, mirror) in _mirrors.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _UrlField(
                      fieldKey: ValueKey('upcloud-provider-mirror-$index'),
                      controller: mirror,
                      enabled: enabled,
                      label: '${l10n.url} ${index + 1}',
                      icon: Icons.alt_route_rounded,
                      required: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    tooltip: l10n.remove,
                    onPressed: enabled
                        ? () => setState(() {
                            _mirrors.removeAt(index).dispose();
                          })
                        : null,
                  ),
                ],
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: enabled
                  ? () => setState(() => _mirrors.add(TextEditingController()))
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addMirror),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey('upcloud-provider-file-url-template'),
            controller: _fileUrlTemplate,
            enabled: enabled,
            autocorrect: false,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: '${l10n.fileUrlTemplate} (${l10n.optional})',
              helperText: l10n.fileUrlTemplateHelper,
              helperMaxLines: 2,
              hintText:
                  _defaultFileUrlTemplate(driver) ??
                  'https://…/${ProviderConfig.fileIdPlaceholder}',
              prefixIcon: const Icon(Icons.link_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              return CloudDriver.fileUrlTemplateProblem(text) == null
                  ? null
                  : l10n.invalidFileUrlTemplate;
            },
          ),
          section(l10n.limits),
          TextFormField(
            key: const ValueKey('upcloud-provider-max-size'),
            controller: _maxSize,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.maxFileSizeMb,
              helperText: l10n.maxFileSizeHelper,
              hintText: _defaultMaxSize(driver),
              prefixIcon: const Icon(Icons.straighten_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              final number = _parseNumber(text);
              return number == null || number < 0 ? l10n.invalidNumber : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('upcloud-provider-extensions'),
            controller: _extensions,
            enabled: enabled,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.allowedExtensions,
              helperText: l10n.allowedExtensionsHelper,
              helperMaxLines: 2,
              prefixIcon: const Icon(Icons.rule_rounded),
            ),
          ),
          if (driver != null && driver.settings.isNotEmpty) ...[
            section(l10n.driverSettings),
            for (final setting in driver.settings)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSetting(context, setting, enabled: enabled),
              ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            key: const ValueKey('upcloud-provider-enabled'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.enabled),
            subtitle: Text(l10n.providerEnabledHelper),
            value: _enabled,
            onChanged: enabled ? (v) => setState(() => _enabled = v) : null,
          ),
          if (_problems.isNotEmpty || _error != null) ...[
            const SizedBox(height: 8),
            _Problems(
              problems: [
                for (final problem in _problems) l10n.configProblem(problem),
                if (_error case final error?) _describeError(l10n, error),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isModified)
                TextButton.icon(
                  onPressed: enabled ? () => unawaited(_reset()) : null,
                  icon: Icon(
                    isCustom
                        ? Icons.delete_outline_rounded
                        : Icons.settings_backup_restore_rounded,
                  ),
                  label: Text(isCustom ? l10n.delete : l10n.resetToDefault),
                ),
              FilledButton.icon(
                onPressed: enabled ? () => unawaited(_save()) : null,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(widget.submitLabel ?? l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Template the driver uses when the field is empty, shown as a hint.
  String? _defaultFileUrlTemplate(CloudDriver? driver) {
    if (driver == null) return null;
    final base = _base;
    return driver.defaultFileUrlTemplate(
      base != null && base.driver == driver.id
          ? base
          : ProviderConfig(id: '', name: '', driver: driver.id),
    );
  }

  String? _defaultMaxSize(CloudDriver? driver) {
    final size = driver?.defaultLimits.maxFileSize;
    if (size == null) return null;
    return _formatNumber(size.inMegabytes);
  }

  Widget _buildSetting(
    BuildContext context,
    DriverSetting setting, {
    required bool enabled,
  }) {
    final l10n = UpCloudLocalizations.of(context);
    final key = ValueKey('upcloud-provider-setting-${setting.key}');
    switch (setting.kind) {
      case DriverSettingKind.flag:
        return SwitchListTile(
          key: key,
          contentPadding: EdgeInsets.zero,
          title: Text(setting.label),
          subtitle: setting.description == null
              ? null
              : Text(setting.description!),
          value: _settingFlags[setting.key] ?? false,
          onChanged: enabled
              ? (v) => setState(() => _settingFlags[setting.key] = v)
              : null,
        );
      case DriverSettingKind.number:
        return TextFormField(
          key: key,
          controller: _settingTexts[setting.key],
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: setting.label,
            helperText: setting.description,
            helperMaxLines: 3,
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            return text.isEmpty || _parseNumber(text) != null
                ? null
                : l10n.invalidNumber;
          },
        );
      case DriverSettingKind.text || DriverSettingKind.url:
        return TextFormField(
          key: key,
          controller: _settingTexts[setting.key],
          enabled: enabled,
          autocorrect: false,
          keyboardType: setting.kind == DriverSettingKind.url
              ? TextInputType.url
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: setting.label,
            helperText: setting.description,
            helperMaxLines: 3,
          ),
        );
    }
  }
}

String _describeError(UpCloudLocalizations l10n, Object error) =>
    switch (error) {
      InvalidProviderConfigException(:final problems) =>
        problems.map(l10n.configProblem).join('\n'),
      UpCloudException() => l10n.errorMessage(error),
      _ => '$error',
    };

class _UrlField extends StatelessWidget {
  const _UrlField({
    required this.fieldKey,
    required this.controller,
    required this.enabled,
    required this.label,
    required this.icon,
    this.required = false,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final IconData icon;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return TextFormField(
      key: fieldKey,
      controller: controller,
      enabled: enabled,
      autocorrect: false,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'https://',
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return required ? l10n.fieldRequired(label) : null;
        return parseHttpUrl(text) == null ? l10n.invalidUrl : null;
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.config,
    required this.driverName,
    required this.isCustom,
    required this.isModified,
  });

  final ProviderConfig config;
  final String driverName;
  final bool isCustom;
  final bool isModified;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${l10n.providerId}: ${config.id} · ${l10n.driver}: $driverName',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isCustom)
          ProviderBadge(label: l10n.customBadge, kind: ProviderBadgeKind.custom)
        else if (isModified)
          ProviderBadge(
            label: l10n.modifiedBadge,
            kind: ProviderBadgeKind.modified,
          ),
      ],
    );
  }
}

class _Problems extends StatelessWidget {
  const _Problems({required this.problems});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onErrorContainer,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.invalidProviderConfig,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final problem in problems) Text('• $problem', style: style),
        ],
      ),
    );
  }
}

/// Kind of a [ProviderBadge].
enum ProviderBadgeKind {
  /// Added by the user.
  custom,

  /// Edited by the user.
  modified,

  /// Disabled.
  disabled,

  /// Has registry issues.
  issue,
}

/// A small label shown next to providers: custom, modified, disabled...
class ProviderBadge extends StatelessWidget {
  /// Creates a badge.
  const ProviderBadge({required this.label, required this.kind, super.key});

  /// Text of the badge.
  final String label;

  /// Selects the colors.
  final ProviderBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (kind) {
      ProviderBadgeKind.custom => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      ProviderBadgeKind.modified => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      ProviderBadgeKind.disabled => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      ProviderBadgeKind.issue => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}

/// Opens a page with a [ProviderEditor] for [config], or for a new custom
/// provider when [config] is `null`.
///
/// Returns the saved config, or `null` when the page is closed without
/// saving (or the provider was reset).
Future<ProviderConfig?> showProviderEditor(
  BuildContext context, {
  required ProvidersController controller,
  ProviderConfig? config,
}) => Navigator.of(context).push(
  MaterialPageRoute<ProviderConfig>(
    builder: (context) {
      final l10n = UpCloudLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(
          title: Text(config == null ? l10n.addProvider : l10n.editProvider),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ProviderEditor(
                controller: controller,
                initial: config,
                onSaved: (saved) => Navigator.of(context).pop(saved),
                onReset: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      );
    },
  ),
);
