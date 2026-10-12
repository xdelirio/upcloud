import 'package:flutter/material.dart';

/// A filled button that is disabled and shows a spinner while [busy].
class BusyButton extends StatelessWidget {
  /// Creates a button with [label].
  const BusyButton({
    required this.busy,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busyLabel,
    this.tonal = false,
    this.destructive = false,
    super.key,
  });

  /// Whether the action is running.
  final bool busy;

  /// Text of the button.
  final String label;

  /// Text shown while [busy]. Defaults to [label].
  final String? busyLabel;

  /// Icon shown while not [busy], replaced by the spinner otherwise.
  final IconData? icon;

  /// Called when the button is pressed; `null` disables it.
  final VoidCallback? onPressed;

  /// Whether to use the tonal style.
  final bool tonal;

  /// Whether to use the error colors.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = destructive
        ? FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          )
        : null;
    final icon = this.icon;
    if (!busy && icon == null) {
      return FilledButton(
        style: style,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    final leading = busy
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon);
    final text = Text(busy ? busyLabel ?? label : label);
    final action = busy ? null : onPressed;
    return tonal
        ? FilledButton.tonalIcon(
            style: style,
            onPressed: action,
            icon: leading,
            label: text,
          )
        : FilledButton.icon(
            style: style,
            onPressed: action,
            icon: leading,
            label: text,
          );
  }
}
