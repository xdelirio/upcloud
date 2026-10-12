import 'package:flutter/material.dart';

/// A titled group of rows on a filled card, as used by `UploadSettingsForm`
/// and `UploadComposer`.
///
/// The card follows the ambient [CardThemeData] (color and shape), so the
/// sections of an app can match them.
class UpCloudSection extends StatelessWidget {
  /// Creates a section.
  const UpCloudSection({
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    super.key,
  });

  /// Text above the card.
  final String title;

  /// Secondary text below [title], e.g. a count.
  final String? subtitle;

  /// Widget at the end of the title row, e.g. a text button.
  final Widget? trailing;

  /// Rows of the card, separated with dividers.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Card.filled(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
