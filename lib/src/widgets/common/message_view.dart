import 'package:flutter/material.dart';

/// A centered icon, title, optional message and optional action.
///
/// Used for empty and error states.
class MessageView extends StatelessWidget {
  /// Creates a message view.
  const MessageView({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.isError = false,
    super.key,
  });

  /// Large icon above the title.
  final IconData icon;

  /// Main text.
  final String title;

  /// Secondary text.
  final String? message;

  /// Button shown below the texts.
  final Widget? action;

  /// Whether to use error colors.
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = this.message;
    final action = this.action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isError
                      ? scheme.errorContainer
                      : scheme.secondaryContainer.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    icon,
                    size: 40,
                    color: isError
                        ? scheme.onErrorContainer
                        : scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null && message.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[const SizedBox(height: 24), action],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows [message] in the closest [ScaffoldMessenger], if any.
void showUpCloudSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final scheme = Theme.of(context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: isError ? TextStyle(color: scheme.onErrorContainer) : null,
        ),
        backgroundColor: isError ? scheme.errorContainer : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
