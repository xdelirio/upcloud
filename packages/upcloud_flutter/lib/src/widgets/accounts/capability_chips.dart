import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';

/// Icons for [Capability] values.
extension CapabilityIcon on Capability {
  /// Icon representing this capability.
  IconData get icon => switch (this) {
    Capability.browseFolders => Icons.folder_open_outlined,
    Capability.createFolder => Icons.create_new_folder_outlined,
    Capability.renameFolder ||
    Capability.renameFile => Icons.drive_file_rename_outline_rounded,
    Capability.moveFolder ||
    Capability.moveFile => Icons.drive_file_move_outline,
    Capability.deleteFolder || Capability.deleteFile => Icons.delete_outline,
    Capability.fileInfo => Icons.info_outline_rounded,
    Capability.search => Icons.search_rounded,
    Capability.upload => Icons.upload_rounded,
    Capability.remoteUpload => Icons.add_link_rounded,
    Capability.accountInfo => Icons.person_outline_rounded,
  };
}

/// A wrap of small chips naming [capabilities], in a stable order.
class CapabilityChips extends StatelessWidget {
  /// Creates chips for [capabilities].
  const CapabilityChips({
    required this.capabilities,
    this.maxVisible,
    this.spacing = 6,
    this.groupManagement = true,
    super.key,
  });

  /// Capabilities to show.
  final Set<Capability> capabilities;

  /// Shows at most this many chips followed by a `+N` chip.
  final int? maxVisible;

  /// Gap between chips.
  final double spacing;

  /// Shows folder and file management operations (create, rename, move,
  /// delete...) as one chip each instead of one chip per operation.
  final bool groupManagement;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ordered = <(String, IconData)>[];
    var hasFolders = false;
    var hasFiles = false;
    for (final capability in Capability.values) {
      if (!capabilities.contains(capability)) continue;
      if (groupManagement && Capability.folderManagement.contains(capability)) {
        if (!hasFolders) {
          hasFolders = true;
          ordered.add((
            l10n.manageFoldersCapability,
            Icons.create_new_folder_outlined,
          ));
        }
      } else if (groupManagement &&
          Capability.fileManagement.contains(capability)) {
        if (!hasFiles) {
          hasFiles = true;
          ordered.add((
            l10n.manageFilesCapability,
            Icons.drive_file_rename_outline_rounded,
          ));
        }
      } else {
        ordered.add((l10n.capability(capability), capability.icon));
      }
    }
    final limit = maxVisible;
    final visible = limit == null || ordered.length <= limit
        ? ordered
        : ordered.take(limit).toList();
    final hidden = ordered.length - visible.length;
    Widget chip(Widget label, [IconData? icon]) => Chip(
      avatar: icon == null ? null : Icon(icon, size: 16),
      label: label,
      labelStyle: Theme.of(context).textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      side: BorderSide(color: scheme.outlineVariant),
    );
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final (label, icon) in visible) chip(Text(label), icon),
        if (hidden > 0) chip(Text('+$hidden')),
      ],
    );
  }
}
