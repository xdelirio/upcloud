import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/src/app/file_io.dart';
import 'package:upcloud/src/app/glass_chrome.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/ui.dart';

/// Browses the selected account with [CloudBrowser].
///
/// The page owns the [CloudBrowserController]: the floating upload button
/// sends files to the open folder.
class BrowserPage extends StatefulWidget {
  const BrowserPage({
    required this.accounts,
    required this.accountId,
    required this.onAccountChanged,
    required this.onAddAccount,
    this.isActive = true,
    super.key,
  });

  final List<CloudAccount> accounts;
  final String? accountId;
  final ValueChanged<String> onAccountChanged;
  final VoidCallback onAddAccount;

  /// Whether the page is the visible tab. Hidden pages stay mounted in an
  /// `IndexedStack`, so they must not handle the back button.
  final bool isActive;

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  CloudBrowserController? _controller;
  String? _controllerAccountId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(BrowserPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  /// Creates a controller for the selected account, if it changed.
  void _syncController() {
    final accountId = widget.accountId;
    if (accountId == _controllerAccountId) return;
    _controller?.dispose();
    _controller = null;
    _controllerAccountId = accountId;
    if (accountId != null) {
      _controller = CloudBrowserController.forAccount(
        UpCloudScope.of(context),
        accountId,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _upload(CloudBrowserController controller) async {
    final sources = await pickUploadSources();
    if (sources.isEmpty || !mounted) return;
    controller.upload(sources);
    showUpCloudSnackBar(
      context,
      UpCloudLocalizations.of(context).uploadsQueued(sources.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final controller = _controller;
    return PageScaffold(
      title: widget.accounts.isEmpty
          ? Text(l10n.files)
          : _AccountSelector(
              accounts: widget.accounts,
              selectedId: widget.accountId,
              onChanged: widget.onAccountChanged,
            ),
      body: controller == null
          ? MessageView(
              icon: Icons.cloud_off_rounded,
              title: l10n.noAccountTitle,
              message: l10n.noAccountMessage,
              action: FilledButton.tonal(
                onPressed: widget.onAddAccount,
                child: Text(l10n.goToAccounts),
              ),
            )
          : CloudBrowser(
              key: ValueKey(controller),
              controller: controller,
              handleBackButton: widget.isActive,
              onPickFiles: pickUploadSources,
              // Leaves room for the floating upload button.
              padding: panelListPadding(
                context,
                extra: controller.canUpload ? 88 : 8,
              ).copyWith(top: 4),
            ),
      primaryAction: controller == null || !controller.canUpload
          ? null
          : GlassActionButton(
              icon: Icons.upload_rounded,
              label: l10n.upload,
              onPressed: () => unawaited(_upload(controller)),
            ),
    );
  }
}

class _AccountSelector extends StatelessWidget {
  const _AccountSelector({
    required this.accounts,
    required this.selectedId,
    required this.onChanged,
  });

  final List<CloudAccount> accounts;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final upcloud = UpCloudScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    ProviderInfo infoOf(CloudAccount account) =>
        upcloud.providerInfo(account.providerId);
    final selected =
        accounts.where((a) => a.id == selectedId).firstOrNull ?? accounts.first;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: PopupMenuButton<String>(
        tooltip: UpCloudLocalizations.of(context).account,
        position: PopupMenuPosition.under,
        onSelected: onChanged,
        itemBuilder: (context) => [
          for (final account in accounts)
            PopupMenuItem(
              value: account.id,
              child: Row(
                children: [
                  ProviderAvatar(info: infoOf(account), radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(account.label, overflow: TextOverflow.ellipsis),
                  ),
                  if (account.id == selected.id) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.check_rounded, size: 20, color: scheme.primary),
                  ],
                ],
              ),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProviderAvatar(info: infoOf(selected), radius: 16),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  selected.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
