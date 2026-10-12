import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud/src/app/file_io.dart';
import 'package:upcloud/src/app/glass_chrome.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/src/app/strings.dart';
import 'package:upcloud/ui.dart';

/// Browses the selected account with [CloudBrowser].
///
/// The page owns the [CloudBrowserController] to show how apps can drive
/// the browser: the floating upload button sends files to the open folder.
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

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _upload(CloudBrowserController controller) async {
    final sources = await pickUploadSources();
    if (sources.isEmpty || !mounted) return;
    controller.upload(sources);
    _snack(UpCloudLocalizations.of(context).uploadsQueued(sources.length));
  }

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    final controller = _controller;
    return PageScaffold(
      title: widget.accounts.isEmpty
          ? Text(strings.files)
          : _AccountSelector(
              accounts: widget.accounts,
              selectedId: widget.accountId,
              onChanged: widget.onAccountChanged,
            ),
      body: controller == null
          ? _NoAccount(onAddAccount: widget.onAddAccount)
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
              label: strings.upload,
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
        upcloud.provider(account.providerId)?.info ??
        ProviderInfo(id: account.providerId, name: account.providerId);
    final selected =
        accounts.where((a) => a.id == selectedId).firstOrNull ?? accounts.first;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: PopupMenuButton<String>(
        tooltip: ExampleStrings.of(context).account,
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

class _NoAccount extends StatelessWidget {
  const _NoAccount({required this.onAddAccount});

  final VoidCallback onAddAccount;

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Same look as the empty states of the package widgets.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 40,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                strings.noAccountTitle,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                strings.noAccountMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onAddAccount,
                child: Text(strings.goToAccounts),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
