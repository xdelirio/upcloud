import 'package:flutter/material.dart';
import 'package:upcloud_example/src/page_scaffold.dart';
import 'package:upcloud_example/src/strings.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

/// Connects a new account: choose the provider and enter its credentials
/// on the same screen.
///
/// Pops with the new [CloudAccount].
class AddAccountPage extends StatelessWidget {
  const AddAccountPage({required this.controller, super.key});

  final AccountsController controller;

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    return FormPageScaffold(
      title: strings.addAccount,
      header: FormHeader(
        title: strings.connectTitle,
        message: strings.connectMessage,
      ),
      child: AccountForm(
        controller: controller,
        onAdded: (account) => Navigator.of(context).pop(account),
      ),
    );
  }
}
