import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/theme/upcloud_theme.dart';
import 'package:upcloud_flutter/src/utils/file_kind.dart';

/// How a [CloudEntryTile] is laid out.
enum CloudEntryLayout {
  /// A row with icon, name and details.
  list,

  /// A card with a large icon or thumbnail.
  grid,
}

/// Displays a [CloudEntry]: icon by type (or thumbnail), name, size and
/// date.
class CloudEntryTile extends StatelessWidget {
  /// Creates a tile for [entry].
  const CloudEntryTile({
    required this.entry,
    this.layout = CloudEntryLayout.list,
    this.selected = false,
    this.selectionMode = false,
    this.onTap,
    this.onLongPress,
    this.trailing,
    super.key,
  });

  /// The file or folder to show.
  final CloudEntry entry;

  /// List row or grid card.
  final CloudEntryLayout layout;

  /// Whether the entry is selected.
  final bool selected;

  /// Whether the parent is in selection mode (shows selection marks).
  final bool selectionMode;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Widget shown at the end of list rows or at the top-right corner of
  /// grid cards, usually an actions menu.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => switch (layout) {
    CloudEntryLayout.list => _buildListTile(context),
    CloudEntryLayout.grid => _buildGridTile(context),
  };

  Widget _buildListTile(BuildContext context) {
    final theme = UpCloudTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final details = describeEntry(context, entry);
    return ListTile(
      leading: selected
          ? SizedBox.square(
              dimension: theme.thumbnailSize,
              child: CircleAvatar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: const Icon(Icons.check_rounded),
              ),
            )
          : CloudEntryIcon(entry: entry, size: theme.thumbnailSize),
      title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: details.isEmpty
          ? null
          : Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing,
      selected: selected,
      selectedTileColor: scheme.secondaryContainer,
      selectedColor: scheme.onSecondaryContainer,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildGridTile(BuildContext context) {
    final theme = UpCloudTheme.of(context);
    final material = Theme.of(context);
    final scheme = material.colorScheme;
    final details = describeEntry(context, entry, short: true);
    final trailing = this.trailing;
    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: theme.borderRadius,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _GridPreview(entry: entry),
                  if (selectionMode)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  if (trailing != null)
                    Positioned(top: 0, right: 0, child: trailing),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: material.textTheme.bodyMedium,
                  ),
                  Text(
                    details.isEmpty ? ' ' : details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: material.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview({required this.entry});

  final CloudEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = UpCloudTheme.of(context);
    final kind = entry.kind;
    final icon = Center(
      child: Icon(kind.icon, size: 56, color: theme.colorFor(kind)),
    );
    final thumbnail = switch (entry) {
      CloudFile(:final thumbnailUrl) => thumbnailUrl,
      CloudFolder() => null,
    };
    if (thumbnail == null) return icon;
    return Image.network(
      thumbnail.toString(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => icon,
    );
  }
}

/// Icon of a [CloudEntry] by type, or its thumbnail when available.
class CloudEntryIcon extends StatelessWidget {
  /// Creates an icon for [entry].
  const CloudEntryIcon({required this.entry, this.size = 40, super.key});

  /// The file or folder.
  final CloudEntry entry;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = UpCloudTheme.of(context);
    final kind = entry.kind;
    final color = theme.colorFor(kind);
    final icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(kind.icon, color: color, size: size * 0.6),
    );
    final thumbnail = switch (entry) {
      CloudFile(:final thumbnailUrl) => thumbnailUrl,
      CloudFolder() => null,
    };
    if (thumbnail == null) return icon;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: Image.network(
        thumbnail.toString(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => icon,
      ),
    );
  }
}

/// Details of [entry] such as `740.0 MB · 1:32 · Sep 27, 2026`.
///
/// With [short] only the most relevant detail is included.
String describeEntry(
  BuildContext context,
  CloudEntry entry, {
  bool short = false,
}) {
  final l10n = UpCloudLocalizations.of(context);
  final material = Localizations.of<MaterialLocalizations>(
    context,
    MaterialLocalizations,
  );
  String? date(DateTime? value) =>
      value == null ? null : material?.formatMediumDate(value.toLocal());
  final parts = switch (entry) {
    CloudFile(:final size, :final duration, :final createdAt) => [
      if (size != null) l10n.formatSize(size),
      if (duration != null && duration > Duration.zero)
        formatDuration(duration),
      date(createdAt),
    ],
    CloudFolder(:final fileCount, :final createdAt) => [
      if (fileCount != null) l10n.fileCount(fileCount),
      date(createdAt),
    ],
  }.nonNulls.toList();
  if (short && parts.length > 1) return parts.first;
  return parts.join(' · ');
}

/// Formats [duration] as `m:ss` or `h:mm:ss`.
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds'
      : '$minutes:$seconds';
}
