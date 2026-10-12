import 'package:flutter/material.dart';
import 'package:upcloud/src/app/page_scaffold.dart';
import 'package:upcloud/src/app/strings.dart';
import 'package:upcloud/ui.dart';

/// Uploads with live progress.
class TransfersPage extends StatelessWidget {
  const TransfersPage({required this.controller, super.key});

  final TransfersController controller;

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    final l10n = UpCloudLocalizations.of(context);
    return PageScaffold(
      title: Text(strings.transfers),
      actions: [
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final state = controller.state;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: l10n.cancelAll,
                  onPressed: state.isBusy ? controller.cancelAll : null,
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all_rounded),
                  tooltip: l10n.clearFinished,
                  onPressed: state.hasFinished
                      ? controller.clearFinished
                      : null,
                ),
              ],
            );
          },
        ),
      ],
      body: TransferList(
        controller: controller,
        padding: panelListPadding(context).copyWith(top: 8),
      ),
    );
  }
}
