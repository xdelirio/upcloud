import 'package:flutter/widgets.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/uploads/background_upload_executor.dart';

/// Keeps the notification texts of [executor] in the language of the app.
///
/// Put it below the `Localizations` of the app, e.g. in
/// `MaterialApp.builder`. Whenever `UpCloudLocalizations.of(context)`
/// changes, the texts of `executor.notifications` are replaced by the
/// localized ones (`UploadNotifications.localizedWith`); the other settings
/// are kept. Uploads started from then on use the new texts.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => LocalizedUploadNotifications(
///     executor: executor,
///     child: child!,
///   ),
/// );
/// ```
class LocalizedUploadNotifications extends StatefulWidget {
  /// Localizes the notifications of [executor].
  const LocalizedUploadNotifications({
    required this.executor,
    required this.child,
    super.key,
  });

  /// Executor whose notification texts are localized.
  final BackgroundUploadExecutor executor;

  /// The rest of the app.
  final Widget child;

  @override
  State<LocalizedUploadNotifications> createState() =>
      _LocalizedUploadNotificationsState();
}

class _LocalizedUploadNotificationsState
    extends State<LocalizedUploadNotifications> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localize();
  }

  @override
  void didUpdateWidget(LocalizedUploadNotifications oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.executor != widget.executor) _localize();
  }

  void _localize() {
    final executor = widget.executor;
    executor.notifications = executor.notifications.localizedWith(
      UpCloudLocalizations.of(context),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
