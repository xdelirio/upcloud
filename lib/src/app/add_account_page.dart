import 'package:flutter/material.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/ui.dart';

/// Connects a new account: choose the provider and enter its credentials
/// on the same screen.
///
/// Pops with the new [CloudAccount].
class AddAccountPage extends StatelessWidget {
  const AddAccountPage({required this.controller, super.key});

  final AccountsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return FormPageScaffold(
      title: l10n.addAccount,
      header: FormHeader(
        title: l10n.connectTitle,
        message: l10n.connectMessage,
      ),
      child: AccountForm(
        controller: controller,
        onAdded: (account) => Navigator.of(context).pop(account),
      ),
    );
  }
}
