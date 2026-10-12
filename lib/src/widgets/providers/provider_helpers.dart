import 'package:flutter/widgets.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';
import 'package:upcloud/src/widgets/common/dialogs.dart';
import 'package:upcloud/upcloud.dart';

/// Asks to confirm resetting [config] to the registry defaults, or deleting
/// it when it [isCustom]. Returns `true` when confirmed.
Future<bool> confirmProviderReset(
  BuildContext context, {
  required ProviderConfig config,
  required bool isCustom,
}) {
  final l10n = UpCloudLocalizations.of(context);
  return showConfirmDialog(
    context,
    title: isCustom ? l10n.delete : l10n.resetToDefault,
    message: isCustom
        ? l10n.deleteProviderMessage(config.name)
        : l10n.resetProviderMessage(config.name),
    confirmLabel: isCustom ? l10n.delete : l10n.resetToDefault,
    destructive: true,
  );
}

/// A message for an [error] of the provider registry.
String describeProviderError(UpCloudLocalizations l10n, Object? error) =>
    switch (error) {
      InvalidProviderConfigException(:final problems) =>
        problems.map(l10n.configProblem).join('\n'),
      UpCloudException() => l10n.errorMessage(error),
      FormatException(:final message) => message,
      _ => '$error',
    };
