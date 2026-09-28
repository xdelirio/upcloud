import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud_example/src/add_account_page.dart';
import 'package:upcloud_example/src/glass_chrome.dart';
import 'package:upcloud_example/src/page_scaffold.dart';
import 'package:upcloud_example/src/strings.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

/// Saved accounts, with their status and storage.
class AccountsPage extends StatelessWidget {
  const AccountsPage({
    required this.controller,
    required this.onOpen,
    this.selectedAccountId,
    super.key,
  });

  final AccountsController controller;
  final ValueChanged<CloudAccount> onOpen;
  final String? selectedAccountId;

  Future<void> _add(BuildContext context) async {
    final account = await Navigator.of(context).push(
      MaterialPageRoute<CloudAccount>(
        builder: (context) => AddAccountPage(controller: controller),
      ),
    );
    if (account != null) {
      onOpen(account);
      unawaited(controller.verify(account.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    return PageScaffold(
      title: Text(strings.accounts),
      primaryAction: GlassActionButton(
        icon: Icons.add_rounded,
        label: strings.addAccount,
        onPressed: () => unawaited(_add(context)),
      ),
      body: AccountList(
        controller: controller,
        selectedAccountId: selectedAccountId,
        verifyOnLoad: true,
        onTap: onOpen,
        onAddAccount: () => unawaited(_add(context)),
        // Leaves room for the floating action button.
        padding: panelListPadding(context, extra: 88).copyWith(top: 8),
      ),
    );
  }
}
