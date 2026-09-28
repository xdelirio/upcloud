import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/controllers/accounts_controller.dart';
import 'package:upcloud_flutter/src/controllers/accounts_state.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/scope/upcloud_scope.dart';
import 'package:upcloud_flutter/src/theme/upcloud_theme.dart';
import 'package:upcloud_flutter/src/widgets/accounts/provider_picker.dart';
import 'package:upcloud_flutter/src/widgets/common/dialogs.dart';
import 'package:upcloud_flutter/src/widgets/common/message_view.dart';

/// Builds a custom row of an [AccountList].
typedef AccountItemBuilder = Widget Function(
  BuildContext context,
  CloudAccount account,
  AccountsController controller,
);

/// The saved accounts, with their provider, connection status and storage.
///
/// Each row offers "check connection" and "remove" actions when
/// [showActions] is true. Uses [controller], or creates one for the
/// [UpCloudScope] above.
class AccountList extends StatefulWidget {
  /// Creates an account list.
  const AccountList({
    this.controller,
    this.onTap,
    this.onAddAccount,
    this.selectedAccountId,
    this.showActions = true,
    this.verifyOnLoad = false,
    this.itemBuilder,
    this.emptyBuilder,
    this.padding,
    super.key,
  });

  /// Controller to use. When `null`, one is created from [UpCloudScope].
  final AccountsController? controller;

  /// Called when an account is tapped.
  final ValueChanged<CloudAccount>? onTap;

  /// Shows an "Add account" button in the empty state.
  final VoidCallback? onAddAccount;

  /// Account shown as selected.
  final String? selectedAccountId;

  /// Whether to show the actions menu of each account.
  final bool showActions;

  /// Whether to check every account connection when the list is created.
  final bool verifyOnLoad;

  /// Replaces the default row.
  final AccountItemBuilder? itemBuilder;

  /// Replaces the empty view.
  final WidgetBuilder? emptyBuilder;

  /// Padding of the list.
  final EdgeInsetsGeometry? padding;

  @override
  State<AccountList> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  AccountsController? _internal;
  UpCloud? _internalUpcloud;
  var _verified = false;

  AccountsController get _controller => widget.controller ?? _internal!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureController();
    if (widget.verifyOnLoad && !_verified) {
      _verified = true;
      unawaited(_verifyWhenLoaded());
    }
  }

  Future<void> _verifyWhenLoaded() async {
    final controller = _controller;
    await controller.init();
    if (mounted && controller == _controller) await controller.verifyAll();
  }

  @override
  void didUpdateWidget(AccountList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureController();
  }

  void _ensureController() {
    if (widget.controller != null) {
      _disposeInternal();
      return;
    }
    final upcloud = UpCloudScope.of(context);
    if (_internal != null && _internalUpcloud == upcloud) return;
    _disposeInternal();
    _internalUpcloud = upcloud;
    _internal = AccountsController(upcloud);
  }

  void _disposeInternal() {
    _internal?.dispose();
    _internal = null;
    _internalUpcloud = null;
  }

  @override
  void dispose() {
    _disposeInternal();
    super.dispose();
  }

  Future<void> _remove(CloudAccount account) async {
    final l10n = UpCloudLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.removeAccount,
      message: l10n.removeAccountMessage(account.label),
      confirmLabel: l10n.remove,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _controller.remove(account.id);
    } on UpCloudException catch (e) {
      if (mounted) {
        showUpCloudSnackBar(context, l10n.errorMessage(e), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        if (state.accounts.isEmpty) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final l10n = UpCloudLocalizations.of(context);
          final onAdd = widget.onAddAccount;
          return widget.emptyBuilder?.call(context) ??
              MessageView(
                icon: Icons.cloud_outlined,
                title: l10n.noAccounts,
                message: l10n.noAccountsHint,
                action: onAdd == null
                    ? null
                    : FilledButton.icon(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.addAccount),
                      ),
              );
        }
        return ListView.builder(
          padding: widget.padding,
          itemCount: state.accounts.length,
          itemBuilder: (context, index) {
            final account = state.accounts[index];
            final custom = widget.itemBuilder;
            if (custom != null) return custom(context, account, _controller);
            return _AccountTile(
              key: ValueKey(account.id),
              account: account,
              provider: _controller.providerOf(account),
              status: state.statusOf(account.id),
              selected: account.id == widget.selectedAccountId,
              onTap: widget.onTap == null ? null : () => widget.onTap!(account),
              onVerify: widget.showActions
                  ? () => unawaited(_controller.verify(account.id))
                  : null,
              onRemove: widget.showActions
                  ? () => unawaited(_remove(account))
                  : null,
            );
          },
        );
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.provider,
    required this.status,
    required this.selected,
    required this.onTap,
    required this.onVerify,
    required this.onRemove,
    super.key,
  });

  final CloudAccount account;
  final ProviderDefinition? provider;
  final AccountStatus? status;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onVerify;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = UpCloudTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final info =
        provider?.info ??
        ProviderInfo(id: account.providerId, name: account.providerId);
    final status = this.status;
    final details = <String>[
      info.name,
      ...switch (status) {
        null => const <String>[],
        AccountStatusChecking() => [l10n.accountChecking],
        AccountStatusConnected(info: final accountInfo) => [
          if (accountInfo?.storageUsed case final used?)
            l10n.storageUsed(l10n.formatSize(used)),
          if (accountInfo?.storageLeft case final left?)
            l10n.storageFree(l10n.formatSize(left)),
          if (accountInfo == null ||
              (accountInfo.storageUsed == null &&
                  accountInfo.storageLeft == null))
            l10n.accountConnected,
        ],
        AccountStatusFailed() => [l10n.accountConnectionFailed],
      },
    ];
    final statusIcon = switch (status) {
      null => null,
      AccountStatusChecking() => const SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      AccountStatusConnected() => Tooltip(
        message: l10n.accountConnected,
        child: Icon(Icons.check_circle_rounded, color: theme.successColor),
      ),
      AccountStatusFailed(:final error) => Tooltip(
        message: l10n.errorMessage(error),
        child: Icon(Icons.error_rounded, color: scheme.error),
      ),
    };
    final storage = switch (status) {
      AccountStatusConnected(info: final accountInfo?) => _usedFraction(
        accountInfo,
      ),
      _ => null,
    };
    final hasMenu = onVerify != null || onRemove != null;
    final subtitle = Text(
      details.join(' · '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    return ListTile(
      leading: ProviderAvatar(info: info, radius: 20),
      title: Text(account.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: storage == null
          ? subtitle
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                subtitle,
                const SizedBox(height: 8),
                _StorageBar(fraction: storage),
              ],
            ),
      selected: selected,
      selectedTileColor: scheme.secondaryContainer,
      selectedColor: scheme.onSecondaryContainer,
      onTap: onTap,
      trailing: statusIcon == null && !hasMenu
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?statusIcon,
                if (hasMenu)
                  PopupMenuButton<VoidCallback>(
                    icon: const Icon(Icons.more_vert_rounded),
                    tooltip: l10n.moreActions,
                    onSelected: (action) => action(),
                    itemBuilder: (context) => [
                      if (onVerify case final verify?)
                        PopupMenuItem(
                          value: verify,
                          child: Row(
                            children: [
                              const Icon(Icons.wifi_protected_setup_rounded),
                              const SizedBox(width: 12),
                              Flexible(child: Text(l10n.checkConnection)),
                            ],
                          ),
                        ),
                      if (onRemove case final remove?)
                        PopupMenuItem(
                          value: remove,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: scheme.error,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  l10n.removeAccount,
                                  style: TextStyle(color: scheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
    );
  }
}

/// Share of the storage in use, when the provider reports both the used
/// and the free space.
double? _usedFraction(AccountInfo info) {
  final used = info.storageUsed?.bytes;
  final left = info.storageLeft?.bytes;
  if (used == null || left == null || used + left <= 0) return null;
  return (used / (used + left)).clamp(0.0, 1.0);
}

/// A thin storage usage meter that turns to the error color when the
/// account is almost full.
class _StorageBar extends StatelessWidget {
  const _StorageBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final theme = UpCloudTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: theme.progressHeight,
        borderRadius: BorderRadius.circular(theme.progressHeight),
        color: fraction >= 0.9 ? scheme.error : scheme.primary,
        backgroundColor: scheme.surfaceContainerHighest,
        semanticsValue: '${(fraction * 100).round()} %',
      ),
    );
  }
}
