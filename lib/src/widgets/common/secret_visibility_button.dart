import 'package:flutter/material.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';

/// The show/hide button at the end of a secret text field.
class SecretVisibilityButton extends StatelessWidget {
  /// Creates the button of a field that is currently [obscured].
  const SecretVisibilityButton({
    required this.obscured,
    required this.onPressed,
    super.key,
  });

  /// Whether the text of the field is hidden.
  final bool obscured;

  /// Called to show or hide the text.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      tooltip: obscured ? l10n.showSecret : l10n.hideSecret,
      onPressed: onPressed,
    );
  }
}
