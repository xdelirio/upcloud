import 'package:flutter/material.dart';
import 'package:upcloud_example/src/ambient_background.dart';
import 'package:upcloud_example/src/glass_chrome.dart';
import 'package:upcloud_example/src/settings.dart';

/// Layout shared by the tabs: a transparent Material [Scaffold] over the
/// app backdrop, with the content on a rounded [ContentPanel] and the
/// primary action as a floating glass button.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.title,
    required this.body,
    this.actions = const [],
    this.primaryAction,
    super.key,
  });

  final Widget title;
  final Widget body;

  /// Shown before the settings button.
  final List<Widget> actions;

  /// Floating glass action, e.g. a [GlassActionButton].
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: title,
        actions: [...actions, const SettingsButton(), const SizedBox(width: 8)],
      ),
      body: ContentPanel(child: body),
      // On wide layouts the button floats inside the panel's corner.
      floatingActionButton: primaryAction == null || compact
          ? primaryAction
          : Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: primaryAction,
            ),
    );
  }
}

/// The surface content sits on: a rounded sheet slightly lifted from the
/// backdrop.
///
/// On phones it runs to the bottom edge, under the floating tab bar, so
/// lists scroll behind the glass; children add the bottom inset from
/// [MediaQuery.paddingOf] to their own padding.
class ContentPanel extends StatelessWidget {
  const ContentPanel({required this.child, super.key});

  final Widget child;

  /// Color of the panel for [scheme].
  static Color colorOf(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
      ? scheme.surfaceContainerLow
      : scheme.surfaceContainerLowest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = Breakpoints.isCompact(context);
    const radius = Radius.circular(28);
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(8, 4, 8, 0)
          : const EdgeInsets.fromLTRB(4, 4, 16, 16),
      child: Material(
        color: colorOf(scheme),
        clipBehavior: Clip.antiAlias,
        shape: RoundedSuperellipseBorder(
          borderRadius: compact
              ? const BorderRadius.vertical(top: radius)
              : const BorderRadius.all(radius),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Bottom padding for scroll views inside a [ContentPanel]: clears the
/// floating tab bar (or the safe area) plus [extra].
EdgeInsets panelListPadding(BuildContext context, {double extra = 8}) =>
    EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + extra);

/// A pushed page holding a form: the app backdrop with the form centered
/// on a panel, under an optional [header].
class FormPageScaffold extends StatelessWidget {
  const FormPageScaffold({
    required this.title,
    required this.child,
    this.header,
    this.maxWidth = 560,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? header;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.paddingOf(context);
    final header = this.header;
    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 4, 12, 24 + padding.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Material(
                color: ContentPanel.colorOf(scheme),
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (header != null) ...[
                        header,
                        const SizedBox(height: 24),
                      ],
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon, title and description at the top of a [FormPageScaffold].
class FormHeader extends StatelessWidget {
  const FormHeader({
    required this.title,
    required this.message,
    this.leading = const AppLogo(size: 48),
    super.key,
  });

  final String title;
  final String message;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        leading,
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
