import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/scope/upcloud_scope.dart';
import 'package:upcloud_flutter/src/theme/upcloud_theme.dart';
import 'package:upcloud_flutter/src/widgets/accounts/capability_chips.dart';
import 'package:upcloud_flutter/src/widgets/common/message_view.dart';

/// How a [ProviderPicker] lays out its providers.
enum ProviderPickerLayout {
  /// Grid on wide screens, list otherwise.
  auto,

  /// One provider per row.
  list,

  /// Several cards per row.
  grid,
}

/// Builds a custom item of a [ProviderPicker].
typedef ProviderItemBuilder = Widget Function(
  BuildContext context,
  ProviderDefinition provider,
  VoidCallback onTap,
);

/// Lets the user choose one of the registered providers.
///
/// Each item shows the provider icon and name. Set [showDetails] to also
/// show its description, upload limit and capabilities.
///
/// To pick a provider and enter its credentials in one screen, use
/// `AccountForm` without a fixed provider instead.
class ProviderPicker extends StatelessWidget {
  /// Creates a picker.
  const ProviderPicker({
    required this.onSelected,
    this.providers,
    this.layout = ProviderPickerLayout.list,
    this.showDetails = false,
    this.selectedId,
    this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.physics,
    super.key,
  });

  /// Called with the chosen provider.
  final ValueChanged<ProviderDefinition> onSelected;

  /// Providers to show. Defaults to the providers of the [UpCloudScope].
  final List<ProviderDefinition>? providers;

  /// List, grid, or automatic depending on the width.
  final ProviderPickerLayout layout;

  /// Whether to show the description, upload limit and capabilities.
  final bool showDetails;

  /// Id of the provider shown as selected.
  final String? selectedId;

  /// Replaces the default card.
  final ProviderItemBuilder? itemBuilder;

  /// Padding around the items.
  final EdgeInsetsGeometry padding;

  /// Scroll physics.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final explicit = providers;
    if (explicit != null) return _buildProviders(context, explicit);
    final upcloud = UpCloudScope.maybeOf(context);
    if (upcloud == null) return _buildProviders(context, const []);
    // Follow registry updates and user edits.
    return StreamBuilder<List<ProviderDefinition>>(
      stream: upcloud.providerChanges,
      initialData: upcloud.providers,
      builder: (context, snapshot) =>
          _buildProviders(context, snapshot.data ?? upcloud.providers),
    );
  }

  Widget _buildProviders(
    BuildContext context,
    List<ProviderDefinition> providers,
  ) {
    if (providers.isEmpty) {
      return MessageView(
        icon: Icons.cloud_off_rounded,
        title: UpCloudLocalizations.of(context).noProviders,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final grid = switch (layout) {
          ProviderPickerLayout.grid => true,
          ProviderPickerLayout.list => false,
          ProviderPickerLayout.auto => width >= 640,
        };
        const spacing = 12.0;
        final horizontal = padding.horizontal;
        final available = (width.isFinite ? width : 600) - horizontal;
        final columns = grid ? (available / 320).floor().clamp(1, 4) : 1;
        final itemWidth = (available - spacing * (columns - 1)) / columns;
        return SingleChildScrollView(
          padding: padding,
          physics: physics,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final provider in providers)
                SizedBox(
                  width: itemWidth,
                  child: _buildItem(context, provider),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, ProviderDefinition provider) {
    void onTap() => onSelected(provider);
    final custom = itemBuilder;
    if (custom != null) return custom(context, provider, onTap);
    return ProviderCard(
      provider: provider,
      selected: provider.id == selectedId,
      showDetails: showDetails,
      onTap: onTap,
    );
  }
}

/// A card with the icon and name of a [ProviderDefinition].
class ProviderCard extends StatelessWidget {
  /// Creates a card for [provider].
  const ProviderCard({
    required this.provider,
    this.onTap,
    this.selected = false,
    this.showDetails = false,
    super.key,
  });

  /// The provider to describe.
  final ProviderDefinition provider;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to highlight the card.
  final bool selected;

  /// Whether to show the description, upload limit and [CapabilityChips].
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final theme = UpCloudTheme.of(context);
    final material = Theme.of(context);
    final scheme = material.colorScheme;
    final info = provider.info;
    final description = info.description;
    final maxSize = provider.defaultLimits.maxFileSize;
    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: theme.borderRadius,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: showDetails
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              ProviderAvatar(info: info),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name, style: material.textTheme.titleMedium),
                    if (showDetails &&
                        description != null &&
                        description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: material.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (showDetails && maxSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.maxFileSize(l10n.formatSize(maxSize)),
                        style: material.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (showDetails && provider.capabilities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      CapabilityChips(capabilities: provider.capabilities),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round avatar with the provider icon, or its initial.
class ProviderAvatar extends StatelessWidget {
  /// Creates an avatar for [info].
  const ProviderAvatar({required this.info, this.radius = 22, super.key});

  /// The provider to represent.
  final ProviderInfo info;

  /// Radius of the avatar.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = info.name.trim().isEmpty
        ? '?'
        : info.name.trim().characters.first.toUpperCase();
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(initial, style: TextStyle(fontSize: radius * 0.8)),
    );
    final iconUrl = info.iconUrl;
    if (iconUrl == null) return fallback;
    return ClipOval(
      child: Image.network(
        iconUrl.toString(),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
