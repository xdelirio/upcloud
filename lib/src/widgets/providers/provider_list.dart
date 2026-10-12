import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/src/controllers/providers_controller.dart';
import 'package:upcloud/src/controllers/providers_state.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/scope/upcloud_scope.dart';
import 'package:upcloud/src/widgets/accounts/provider_avatar.dart';
import 'package:upcloud/src/widgets/common/busy_button.dart';
import 'package:upcloud/src/widgets/common/menu_row.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/src/widgets/providers/provider_editor.dart';
import 'package:upcloud/src/widgets/providers/provider_helpers.dart';
import 'package:upcloud/upcloud.dart';

/// Manages the providers of the registry: enable or disable them, edit
/// them, reset user changes, add custom providers and check for registry
/// updates. Entries that could not be loaded are listed as issues.
///
/// Uses [controller], or creates one for the registry of the
/// [UpCloudScope] above. Editing opens [showProviderEditor] unless
/// [onEdit] / [onAdd] are given.
class ProviderList extends StatefulWidget {
  /// Creates a provider management list.
  const ProviderList({
    this.controller,
    this.onEdit,
    this.onAdd,
    this.showAddButton = true,
    this.padding,
    super.key,
  });

  /// Controller to use. When `null`, one is created from [UpCloudScope].
  final ProvidersController? controller;

  /// Called to edit a provider. Defaults to [showProviderEditor].
  final ValueChanged<ProviderConfig>? onEdit;

  /// Called to add a custom provider. Defaults to [showProviderEditor].
  final VoidCallback? onAdd;

  /// Whether to show an "Add provider" button at the end of the list.
  final bool showAddButton;

  /// Padding of the list.
  final EdgeInsetsGeometry? padding;

  @override
  State<ProviderList> createState() => _ProviderListState();
}

class _ProviderListState extends State<ProviderList> {
  ProvidersController? _internal;
  ProviderRegistry? _internalRegistry;

  ProvidersController get _controller => widget.controller ?? _internal!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureController();
  }

  @override
  void didUpdateWidget(ProviderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureController();
  }

  void _ensureController() {
    if (widget.controller != null) {
      _disposeInternal();
      return;
    }
    final registry = UpCloudScope.of(context).registry;
    if (_internal != null && _internalRegistry == registry) return;
    _disposeInternal();
    _internalRegistry = registry;
    _internal = ProvidersController(registry);
  }

  void _disposeInternal() {
    _internal?.dispose();
    _internal = null;
    _internalRegistry = null;
  }

  @override
  void dispose() {
    _disposeInternal();
    super.dispose();
  }

  void _snack(String message, {bool isError = false}) =>
      showUpCloudSnackBar(context, message, isError: isError);

  String _describe(Object? error) =>
      describeProviderError(UpCloudLocalizations.of(context), error);

  Future<void> _checkForUpdates() async {
    final l10n = UpCloudLocalizations.of(context);
    final result = await _controller.refresh();
    if (!mounted) return;
    final failed = result.status == RegistryRefreshStatus.failed;
    _snack(switch (result.status) {
      RegistryRefreshStatus.updated => l10n.registryUpdated,
      RegistryRefreshStatus.notModified ||
      RegistryRefreshStatus.skipped => l10n.registryUpToDate,
      RegistryRefreshStatus.disabled => l10n.registryDisabled,
      RegistryRefreshStatus.failed => l10n.registryUpdateFailed(
        _describe(result.error),
      ),
    }, isError: failed);
  }

  Future<void> _edit(ProviderConfig config) async {
    final onEdit = widget.onEdit;
    if (onEdit != null) {
      onEdit(config);
      return;
    }
    final saved = await showProviderEditor(
      context,
      controller: _controller,
      config: config,
    );
    if (saved != null && mounted) {
      _snack(UpCloudLocalizations.of(context).providerSaved);
    }
  }

  Future<void> _add() async {
    final onAdd = widget.onAdd;
    if (onAdd != null) {
      onAdd();
      return;
    }
    final saved = await showProviderEditor(context, controller: _controller);
    if (saved != null && mounted) {
      _snack(UpCloudLocalizations.of(context).providerSaved);
    }
  }

  Future<void> _setEnabled(ProviderConfig config, bool enabled) async {
    try {
      await _controller.setEnabled(config.id, enabled: enabled);
    } on Object catch (e) {
      if (mounted) _snack(_describe(e), isError: true);
    }
  }

  Future<void> _reset(ProviderConfig config) async {
    final confirmed = await confirmProviderReset(
      context,
      config: config,
      isCustom: _controller.state.isCustom(config.id),
    );
    if (!confirmed || !mounted) return;
    try {
      await _controller.reset(config.id);
    } on Object catch (e) {
      if (mounted) _snack(_describe(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final orphanIssues = [
          for (final issue in state.issues)
            if (state.config(issue.providerId) == null) issue,
        ];
        return ListView(
          padding: widget.padding,
          children: [
            _UpdateCard(
              state: state,
              onCheck: () => unawaited(_checkForUpdates()),
            ),
            if (orphanIssues.isNotEmpty) _IssuesCard(issues: orphanIssues),
            if (state.configs.isEmpty)
              MessageView(
                icon: Icons.cloud_off_rounded,
                title: l10n.noProviders,
              ),
            for (final config in state.configs)
              _ProviderConfigTile(
                key: ValueKey(config.id),
                config: config,
                state: state,
                driver: _controller.driver(config.driver),
                busy: state.isSaving,
                onTap: () => unawaited(_edit(config)),
                onEnabledChanged: (enabled) =>
                    unawaited(_setEnabled(config, enabled)),
                onReset: () => unawaited(_reset(config)),
              ),
            if (widget.showAddButton)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: () => unawaited(_add()),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addProvider),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.state, required this.onCheck});

  final ProvidersState state;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final material = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final fetchedAt = state.lastFetchedAt?.toLocal();
    final date = fetchedAt == null || material == null
        ? null
        : '${material.formatMediumDate(fetchedAt)} '
              '${material.formatTimeOfDay(TimeOfDay.fromDateTime(fetchedAt))}';
    return Card.filled(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_sync_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.providers, style: theme.textTheme.titleMedium),
                      if (date != null)
                        Text(
                          l10n.lastChecked(date),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            BusyButton(
              busy: state.isRefreshing,
              tonal: true,
              icon: Icons.sync_rounded,
              label: l10n.checkForUpdates,
              onPressed: onCheck,
            ),
          ],
        ),
      ),
    );
  }
}

class _IssuesCard extends StatelessWidget {
  const _IssuesCard({required this.issues});

  final List<RegistryIssue> issues;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.errorContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.registryIssues,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final issue in issues)
              Text(
                '• ${issue.providerId}: ${l10n.registryIssue(issue)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProviderConfigTile extends StatelessWidget {
  const _ProviderConfigTile({
    required this.config,
    required this.state,
    required this.driver,
    required this.busy,
    required this.onTap,
    required this.onEnabledChanged,
    required this.onReset,
    super.key,
  });

  final ProviderConfig config;
  final ProvidersState state;
  final CloudDriver? driver;
  final bool busy;
  final VoidCallback onTap;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isCustom = state.isCustom(config.id);
    final isModified = state.isModified(config.id);
    final issues = state.issuesFor(config.id);
    final details = [
      driver?.name ?? l10n.unknownDriver(config.driver),
      ?config.apiBase?.host,
    ].join(' · ');
    final badges = [
      if (isCustom)
        ProviderBadge(label: l10n.customBadge, kind: ProviderBadgeKind.custom)
      else if (isModified)
        ProviderBadge(
          label: l10n.modifiedBadge,
          kind: ProviderBadgeKind.modified,
        ),
      if (!config.enabled)
        ProviderBadge(
          label: l10n.disabledBadge,
          kind: ProviderBadgeKind.disabled,
        ),
    ];
    return ListTile(
      leading: ProviderAvatar(
        info: ProviderInfo(
          id: config.id,
          name: config.name,
          iconUrl: config.iconUrl,
        ),
        radius: 20,
      ),
      title: Text(config.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
          for (final issue in issues)
            Text(
              l10n.registryIssue(issue),
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          if (badges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(spacing: 4, runSpacing: 4, children: badges),
            ),
        ],
      ),
      onTap: busy ? null : onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: config.enabled,
            onChanged: busy ? null : onEnabledChanged,
          ),
          PopupMenuButton<VoidCallback>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: l10n.moreActions,
            enabled: !busy,
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: onTap,
                child: MenuRow(icon: Icons.edit_outlined, label: l10n.edit),
              ),
              if (isModified)
                PopupMenuItem(
                  value: onReset,
                  child: MenuRow(
                    icon: isCustom
                        ? Icons.delete_outline_rounded
                        : Icons.settings_backup_restore_rounded,
                    label: isCustom ? l10n.delete : l10n.resetToDefault,
                    color: scheme.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
