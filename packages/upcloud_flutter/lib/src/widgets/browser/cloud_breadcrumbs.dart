import 'package:flutter/material.dart';
import 'package:upcloud_flutter/src/controllers/cloud_browser_state.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';

/// A horizontal, scrollable path of folders: `My files › Series › Season 1`.
///
/// Tapping a folder other than the last calls [onSelected].
class CloudBreadcrumbs extends StatelessWidget {
  /// Creates breadcrumbs for [path] (root first).
  const CloudBreadcrumbs({
    required this.path,
    this.onSelected,
    this.rootLabel,
    this.textStyle,
    super.key,
  });

  /// Folders from the root to the current folder.
  final List<CloudBreadcrumb> path;

  /// Called with the tapped breadcrumb.
  final ValueChanged<CloudBreadcrumb>? onSelected;

  /// Label of the root folder. Defaults to the localized "My files".
  final String? rootLabel;

  /// Style of the labels.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = textStyle ?? theme.textTheme.titleSmall;
    final children = <Widget>[];
    for (var i = 0; i < path.length; i++) {
      final crumb = path[i];
      final isLast = i == path.length - 1;
      final label = crumb.isRoot ? rootLabel ?? l10n.rootFolder : crumb.name;
      if (i > 0) {
        children.add(
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
        );
      }
      final onSelected = this.onSelected;
      children.add(
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLast || onSelected == null ? null : () => onSelected(crumb),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (crumb.isRoot) ...[
                  Icon(
                    Icons.home_outlined,
                    size: 18,
                    color: isLast ? scheme.onSurface : scheme.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style?.copyWith(
                      color: isLast ? scheme.onSurface : scheme.primary,
                      fontWeight: isLast ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
