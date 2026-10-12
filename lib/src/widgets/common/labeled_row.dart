import 'package:flutter/material.dart';

/// A title, optional helper text and a control below them, as a row of an
/// `UpCloudSection`.
class LabeledRow extends StatelessWidget {
  /// Creates a row with [title] above [child].
  const LabeledRow({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  /// Name of the setting.
  final String title;

  /// Helper text below [title].
  final String? subtitle;

  /// Control of the setting.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          if (subtitle != null)
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
