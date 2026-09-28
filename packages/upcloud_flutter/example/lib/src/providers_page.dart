import 'dart:async';

import 'package:flutter/material.dart';
import 'package:upcloud_example/src/glass_chrome.dart';
import 'package:upcloud_example/src/page_scaffold.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

/// Manages the provider registry: enable, edit, reset, add custom
/// providers and check for registry updates.
class ProvidersPage extends StatelessWidget {
  const ProvidersPage({required this.controller, super.key});

  final ProvidersController controller;

  /// Edits [config], or adds a custom provider when it is `null`, on a
  /// page styled like the rest of the app.
  Future<void> _edit(BuildContext context, [ProviderConfig? config]) async {
    final saved = await Navigator.of(context).push(
      MaterialPageRoute<ProviderConfig>(
        builder: (context) {
          final l10n = UpCloudLocalizations.of(context);
          return FormPageScaffold(
            title: config == null ? l10n.addProvider : l10n.editProvider,
            maxWidth: 640,
            child: ProviderEditor(
              controller: controller,
              initial: config,
              onSaved: (saved) => Navigator.of(context).pop(saved),
              onReset: () => Navigator.of(context).pop(),
            ),
          );
        },
      ),
    );
    if (saved != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(UpCloudLocalizations.of(context).providerSaved),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return PageScaffold(
      title: Text(l10n.providers),
      primaryAction: GlassActionButton(
        icon: Icons.add_rounded,
        label: l10n.addProvider,
        onPressed: () => unawaited(_edit(context)),
      ),
      body: ProviderList(
        controller: controller,
        onEdit: (config) => unawaited(_edit(context, config)),
        onAdd: () => unawaited(_edit(context)),
        // The floating button replaces the one at the end of the list.
        showAddButton: false,
        padding: panelListPadding(context, extra: 88),
      ),
    );
  }
}
