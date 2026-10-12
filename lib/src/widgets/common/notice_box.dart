import 'package:flutter/material.dart';

/// A rounded box in the error container color with a bold [title], an
/// optional [icon] and smaller details below the title.
class NoticeBox extends StatelessWidget {
  /// Creates a box with [title].
  const NoticeBox({
    required this.title,
    this.icon,
    this.children = const [],
    super.key,
  });

  /// Icon before the texts.
  final IconData? icon;

  /// Main text.
  final String title;

  /// Widgets below [title]; their texts default to a small style in the
  /// color of the box.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = this.icon;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (children.isNotEmpty)
          DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onErrorContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: icon == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: scheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(child: content),
              ],
            ),
    );
  }
}
