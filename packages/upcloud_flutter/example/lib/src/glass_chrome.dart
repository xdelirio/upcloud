import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Window size classes used by the example.
abstract final class Breakpoints {
  /// From this width the tab bar becomes a side rail.
  static const double medium = 720;

  /// From this width the rail shows its labels next to the icons.
  static const double expanded = 1024;

  /// Space the floating glass tab bar takes at the bottom of phones: the
  /// pill (64) and its bottom margin (20), plus a small gap.
  static const double tabBarClearance = 92;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < medium;
}

/// A top-level section of the app.
@immutable
class AppDestination {
  const AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Number shown in a badge on the icon; hidden when 0.
  final ValueListenable<int>? badgeCount;

  /// The icon, with its badge when there is one.
  Widget buildIcon({required bool selected, double? size}) {
    final icon = Icon(selected ? selectedIcon : this.icon, size: size);
    final count = badgeCount;
    if (count == null) return icon;
    return ValueListenableBuilder<int>(
      valueListenable: count,
      builder: (context, value, child) =>
          Badge(isLabelVisible: value > 0, label: Text('$value'), child: child),
      child: icon,
    );
  }
}

/// Glass settings tuned to stay legible over the app backdrop.
LiquidGlassSettings chromeGlassSettings(ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  return LiquidGlassSettings(
    glassColor: dark
        ? scheme.surfaceContainerHigh.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.45),
    thickness: 22,
    blur: 14,
    lightIntensity: dark ? 0.4 : 0.6,
    saturation: 1.3,
  );
}

/// The primary action of a screen: a floating, primary-tinted glass pill
/// (or circle when [extended] is false).
///
/// Sits in the `floatingActionButton` slot of a Material [Scaffold], above
/// the glass tab bar on phones. Dimmed while [onPressed] is `null`.
class GlassActionButton extends StatelessWidget {
  const GlassActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.extended = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPressed = this.onPressed;
    final enabled = onPressed != null;
    // Disabled: Material's disabled colors on a neutral tint. (The glass
    // button's own disabled opacity hides the content of an own layer.)
    final foreground = enabled
        ? scheme.onPrimary
        : scheme.onSurface.withValues(alpha: 0.38);
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: extended ? 20 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 22),
          if (extended) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
    Widget button = GlassButton.custom(
      onTap: onPressed ?? () {},
      label: label,
      height: 56,
      width: extended ? null : 56,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      quality: GlassQuality.premium,
      useOwnLayer: true,
      glowColor: scheme.primaryContainer.withValues(alpha: 0.35),
      // A clear body composites the tint as is, so the button keeps the
      // exact primary color while the rim and highlights stay glassy.
      settings: LiquidGlassSettings(
        glassColor: enabled
            ? scheme.primary.withValues(alpha: 0.94)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.9),
        bodyMode: GlassBodyMode.clear,
        thickness: 26,
        blur: 10,
        lightIntensity: 0.7,
      ),
      child: content,
    );
    if (!enabled) {
      button = Semantics(
        button: true,
        enabled: false,
        label: label,
        child: ExcludeSemantics(child: IgnorePointer(child: button)),
      );
    }
    // The extended button shows its label; the round one needs a tooltip.
    return extended ? button : Tooltip(message: label, child: button);
  }
}

/// Side navigation for tablets and desktops: a floating glass rail, with
/// the labels next to the icons when [extended].
class GlassSidebar extends StatelessWidget {
  const GlassSidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    required this.title,
    super.key,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassContainer(
      width: extended ? 248 : 92,
      useOwnLayer: true,
      quality: GlassQuality.premium,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      settings: chromeGlassSettings(scheme),
      // Ink of the destinations is painted inside the glass.
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 12 : 8,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: extended
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: [
              _Brand(title: title, extended: extended),
              const SizedBox(height: 28),
              for (final (index, destination) in destinations.indexed) ...[
                if (extended)
                  _SidebarItem(
                    destination: destination,
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  )
                else
                  _RailItem(
                    destination: destination,
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
                SizedBox(height: extended ? 4 : 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.title, required this.extended});

  final String title;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logo = AppLogo(size: extended ? 40 : 44);
    if (!extended) return Tooltip(message: title, child: logo);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          logo,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The app mark: a cloud on a primary gradient tile.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Brand colors, the same in light and dark mode.
          colors: [Color(0xFF4A86F7), Color(0xFF6E4BF2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A86F7).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.cloud_upload_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 76,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.secondaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    child: Center(
                      child: destination.buildIcon(selected: selected),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  IconTheme.merge(
                    data: IconThemeData(color: foreground),
                    child: destination.buildIcon(selected: selected),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurface,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
