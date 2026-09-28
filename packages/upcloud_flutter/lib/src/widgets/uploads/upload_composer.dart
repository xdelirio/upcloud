import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/controllers/upload_composer_controller.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/scope/upcloud_scope.dart';
import 'package:upcloud_flutter/src/theme/upcloud_theme.dart';
import 'package:upcloud_flutter/src/utils/file_kind.dart';
import 'package:upcloud_flutter/src/widgets/accounts/provider_picker.dart';
import 'package:upcloud_flutter/src/widgets/browser/cloud_browser.dart'
    show PickUploadSources;
import 'package:upcloud_flutter/src/widgets/common/folder_path_field.dart';
import 'package:upcloud_flutter/src/widgets/common/message_view.dart';
import 'package:upcloud_flutter/src/widgets/common/section.dart';
import 'package:upcloud_flutter/src/widgets/settings/upload_settings_form.dart'
    show VisibilitySelector;

/// Prepares a batch upload: several files to several accounts, into the
/// same folder path, and starts it with `UpCloud.uploadBatch`.
///
/// Sections:
///
/// * **Files**: the files to upload, added with [onPickFiles] (the package
///   does not depend on a file picker).
/// * **Accounts**: the accounts that can receive uploads, grouped by
///   provider.
/// * **Destination**: the folder path (e.g. `Movies/2026`, prefilled with
///   `UploadSettings.defaultFolderPath`, with the recent paths as
///   suggestions), found by name in every account and created when
///   missing, and the visibility.
///
/// Files that break the limits of a provider (too large, file type not
/// allowed) are listed before submitting and skipped for that provider.
/// [onSubmitted] receives the started batch; the files are cleared, the
/// accounts and the folder are kept.
///
/// ```dart
/// UploadComposer(
///   onPickFiles: () async => [UploadSource.file(path)],
///   onSubmitted: (batch) => showTransfers(),
/// );
/// ```
///
/// The composer is a scroll view. Pass a [controller] to drive it from
/// outside, e.g. with your own submit button and [showSubmitButton] set to
/// false.
class UploadComposer extends StatefulWidget {
  /// Creates a composer.
  const UploadComposer({
    required this.onPickFiles,
    this.onSubmitted,
    this.controller,
    this.showSubmitButton = true,
    this.padding = const EdgeInsets.all(16),
    this.maxContentWidth = 720,
    this.maxSkippedShown = 4,
    super.key,
  });

  /// Returns the files to add, e.g. with a file picker. An empty list adds
  /// nothing.
  final PickUploadSources onPickFiles;

  /// Called with the batch started by the submit button (or
  /// [submitComposer]).
  final ValueChanged<UploadBatch>? onSubmitted;

  /// State of the composer. When `null`, one is created for the
  /// [UpCloudScope].
  final UploadComposerController? controller;

  /// Whether to show the submit button at the end of the content.
  final bool showSubmitButton;

  /// Padding of the scroll view.
  final EdgeInsets padding;

  /// Maximum width of the content, centered on wide layouts.
  final double maxContentWidth;

  /// Skipped uploads listed before "and N more".
  final int maxSkippedShown;

  @override
  State<UploadComposer> createState() => _UploadComposerState();
}

/// Starts the uploads of [controller] and notifies [onSubmitted], as the
/// submit button of [UploadComposer] does. Returns `null` when there is
/// nothing to upload.
UploadBatch? submitComposer(
  UploadComposerController controller, {
  ValueChanged<UploadBatch>? onSubmitted,
}) {
  if (!controller.canSubmit) return null;
  final batch = controller.submit();
  onSubmitted?.call(batch);
  return batch;
}

class _UploadComposerState extends State<UploadComposer> {
  UploadComposerController? _internal;
  final _folder = TextEditingController();
  final _folderFocus = FocusNode();
  var _picking = false;

  UploadComposerController get _controller => widget.controller ?? _internal!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureController();
  }

  @override
  void didUpdateWidget(UploadComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_syncFolder);
      _ensureController();
    }
  }

  void _ensureController() {
    final previous = _internal;
    if (widget.controller == null) {
      final upcloud = UpCloudScope.of(context);
      if (previous == null || !identical(previous.upcloud, upcloud)) {
        previous?.removeListener(_syncFolder);
        previous?.dispose();
        _internal = UploadComposerController(upcloud);
      }
    } else if (previous != null) {
      previous
        ..removeListener(_syncFolder)
        ..dispose();
      _internal = null;
    }
    _controller
      ..removeListener(_syncFolder)
      ..addListener(_syncFolder);
    _folder.text = _controller.folderPath;
  }

  /// Follows folder changes made outside the field (e.g. the default
  /// folder of the settings).
  void _syncFolder() {
    if (_folderFocus.hasFocus) return;
    final path = _controller.folderPath;
    if (_folder.text != path) _folder.text = path;
  }

  @override
  void dispose() {
    _controller.removeListener(_syncFolder);
    _internal?.dispose();
    _folder.dispose();
    _folderFocus.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final files = await widget.onPickFiles();
      if (mounted) _controller.addFiles(files);
    } on Object catch (e) {
      if (mounted) {
        showUpCloudSnackBar(
          context,
          UpCloudLocalizations.of(context).errorMessage(e),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _submit() {
    _folderFocus.unfocus();
    submitComposer(_controller, onSubmitted: widget.onSubmitted);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = widget.padding;
        final extra = math.max(
          0,
          (constraints.maxWidth - padding.horizontal - widget.maxContentWidth) /
              2,
        );
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) => ListView(
            padding: padding.copyWith(
              left: padding.left + extra,
              right: padding.right + extra,
            ),
            children: [
              _FilesSection(
                controller: controller,
                picking: _picking,
                onAdd: () => unawaited(_pickFiles()),
              ),
              const SizedBox(height: 24),
              _AccountsSection(controller: controller),
              if (controller.skipped.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SkippedCard(
                  skipped: controller.skipped,
                  maxShown: widget.maxSkippedShown,
                ),
              ],
              const SizedBox(height: 24),
              _DestinationSection(
                controller: controller,
                folder: _folder,
                folderFocus: _folderFocus,
              ),
              if (widget.showSubmitButton) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const ValueKey('upcloud-composer-submit'),
                  onPressed: controller.canSubmit ? _submit : null,
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    controller.canSubmit
                        ? UpCloudLocalizations.of(context)
                              .startUploads(controller.uploadCount)
                        : UpCloudLocalizations.of(context).upload,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilesSection extends StatelessWidget {
  const _FilesSection({
    required this.controller,
    required this.picking,
    required this.onAdd,
  });

  final UploadComposerController controller;
  final bool picking;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final files = controller.files;
    final addButton = TextButton.icon(
      key: const ValueKey('upcloud-composer-add-files'),
      onPressed: picking ? null : onAdd,
      icon: const Icon(Icons.add_rounded),
      label: Text(l10n.addFiles),
    );
    return UpCloudSection(
      title: l10n.filesSection,
      subtitle: files.isEmpty
          ? null
          : l10n.filesSummary(
              files.length,
              l10n.formatBytes(controller.totalBytes),
            ),
      trailing: files.isEmpty ? null : addButton,
      children: [
        if (files.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  size: 40,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(l10n.noFilesSelected, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.noFilesSelectedHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  key: const ValueKey('upcloud-composer-add-files'),
                  onPressed: picking ? null : onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addFiles),
                ),
              ],
            ),
          )
        else
          for (final (index, file) in files.indexed)
            _FileTile(
              key: ValueKey('upcloud-composer-file-$index'),
              file: file,
              size: controller.sizeOf(file),
              skippedFor: [
                for (final s in controller.skipped)
                  if (identical(s.file, file)) s.account.label,
              ],
              removeKey: ValueKey('upcloud-composer-remove-$index'),
              onRemove: () => controller.removeFile(file),
            ),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.size,
    required this.skippedFor,
    required this.removeKey,
    required this.onRemove,
    super.key,
  });

  final UploadSource file;
  final int? size;

  /// Accounts the file is skipped for.
  final List<String> skippedFor;
  final Key removeKey;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = UpCloudTheme.of(context);
    final kind = CloudFileKind.fromName(file.name);
    final color = theme.colorFor(kind);
    final extent = theme.thumbnailSize;
    final size = this.size;
    final details = [
      if (size != null) l10n.formatBytes(size),
      if (file.extension.isNotEmpty) file.extension.toUpperCase(),
    ].join(' · ');
    return ListTile(
      leading: Container(
        width: extent,
        height: extent,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(extent / 4),
        ),
        child: Icon(kind.icon, color: color, size: extent * 0.6),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: skippedFor.isEmpty
          ? Text(details)
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$details\n'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 4),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: theme.warningColor,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: l10n.skippedFor(skippedFor.join(', ')),
                    style: TextStyle(color: theme.warningColor),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: IconButton(
        key: removeKey,
        icon: const Icon(Icons.close_rounded),
        tooltip: l10n.remove,
        onPressed: onRemove,
      ),
    );
  }
}

class _AccountsSection extends StatelessWidget {
  const _AccountsSection({required this.controller});

  final UploadComposerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final upcloud = controller.upcloud;
    final accounts = controller.accounts;
    final selected = controller.selectedAccountIds;
    final allSelected =
        accounts.isNotEmpty && selected.length == accounts.length;

    // Accounts grouped by provider, in the order of their first account.
    final groups = <String, List<CloudAccount>>{};
    for (final account in accounts) {
      (groups[account.providerId] ??= []).add(account);
    }

    return UpCloudSection(
      title: l10n.accounts,
      subtitle: accounts.isEmpty
          ? null
          : l10n.accountsSelected(selected.length, accounts.length),
      trailing: accounts.isEmpty
          ? null
          : TextButton(
              key: const ValueKey('upcloud-composer-select-all'),
              onPressed: allSelected
                  ? controller.selectNone
                  : controller.selectAll,
              child: Text(allSelected ? l10n.selectNone : l10n.selectAll),
            ),
      children: [
        if (accounts.isEmpty)
          MessageView(
            icon: Icons.cloud_off_rounded,
            title: l10n.noUploadAccounts,
            message: l10n.noUploadAccountsHint,
          )
        else
          for (final MapEntry(key: providerId, value: members)
              in groups.entries)
            _ProviderGroup(
              info:
                  upcloud.provider(providerId)?.info ??
                  ProviderInfo(id: providerId, name: providerId),
              limits: upcloud.provider(providerId)?.defaultLimits,
              accounts: members,
              selected: selected,
              onToggle: controller.toggleAccount,
            ),
      ],
    );
  }
}

class _ProviderGroup extends StatelessWidget {
  const _ProviderGroup({
    required this.info,
    required this.limits,
    required this.accounts,
    required this.selected,
    required this.onToggle,
  });

  final ProviderInfo info;
  final ProviderLimits? limits;
  final List<CloudAccount> accounts;
  final Set<String> selected;
  final void Function(String id, {bool? selected}) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxSize = limits?.maxFileSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              ProviderAvatar(info: info, radius: 14),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  info.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (maxSize != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.upToSize(l10n.formatSize(maxSize)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        for (final account in accounts)
          CheckboxListTile(
            key: ValueKey('upcloud-composer-account-${account.id}'),
            value: selected.contains(account.id),
            onChanged: (value) =>
                onToggle(account.id, selected: value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsetsDirectional.only(
              start: 20,
              end: 16,
            ),
            title: Text(
              account.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _DestinationSection extends StatelessWidget {
  const _DestinationSection({
    required this.controller,
    required this.folder,
    required this.folderFocus,
  });

  final UploadComposerController controller;
  final TextEditingController folder;
  final FocusNode folderFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    return UpCloudSection(
      title: l10n.destinationSection,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: FolderPathField(
            fieldKey: const ValueKey('upcloud-composer-folder'),
            controller: folder,
            focusNode: folderFocus,
            label: l10n.destinationFolder,
            helperText: l10n.destinationFolderHelper,
            suggestions: controller.upcloud.recentFolderPaths,
            onChanged: (value) => controller.folderPath = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.visibilityLabel, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 12),
              VisibilitySelector(
                key: const ValueKey('upcloud-composer-visibility'),
                value: controller.visibility,
                onChanged: (value) => controller.visibility = value,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkippedCard extends StatelessWidget {
  const _SkippedCard({required this.skipped, required this.maxShown});

  final List<SkippedUpload> skipped;
  final int maxShown;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = Theme.of(context);
    final warning = UpCloudTheme.of(context).warningColor;
    final shown = skipped.take(maxShown).toList();
    final hidden = skipped.length - shown.length;
    final small = theme.textTheme.bodySmall;
    return DecoratedBox(
      key: const ValueKey('upcloud-composer-skipped'),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warning.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: warning),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.uploadsSkipped(skipped.length),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.uploadsSkippedHint,
                    style: small?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final item in shown)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        l10n.skippedUpload(
                          item.file.name,
                          item.account.label,
                          l10n.rejection(item.reason),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: small,
                      ),
                    ),
                  if (hidden > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(l10n.andMore(hidden), style: small),
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
