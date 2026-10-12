import 'package:flutter/foundation.dart';
import 'package:upcloud/src/l10n/upcloud_localizations.dart';

/// The title and body of an upload notification.
///
/// Both may contain the tokens of background_downloader, replaced when the
/// notification is shown:
///
/// * `{displayName}`: the file name (`UploadSource.name`);
/// * `{progress}`: the percentage sent, e.g. `42%` (Android only, empty on
///   iOS);
/// * `{networkSpeed}` and `{timeRemaining}` (Android only);
/// * `{numFinished}`, `{numFailed}` and `{numTotal}`: counts of a grouped
///   notification (see [UploadNotifications.grouped]).
@immutable
final class UploadNotificationText {
  /// Creates a notification text.
  const UploadNotificationText(this.title, [this.body = '']);

  /// First line of the notification.
  final String title;

  /// Second line of the notification; empty for none.
  final String body;

  @override
  bool operator ==(Object other) =>
      other is UploadNotificationText &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(title, body);

  @override
  String toString() => 'UploadNotificationText($title, $body)';
}

/// The system notifications shown by `BackgroundUploadExecutor` while
/// uploads run in the background (Android and iOS; desktop platforms show
/// none).
///
/// By default every upload shows a notification with the file name and a
/// progress bar while it runs, and one when it completes or fails. Tapping
/// a notification opens the app. On Android the running notification has a
/// Cancel button: it cancels that upload, which then shows as cancelled in
/// the transfer queue.
///
/// On Android, notifications also let long uploads survive in the
/// background: with [allowLongUploads], uploads run as user-initiated data
/// transfers (Android 14+) or in a foreground service (older versions),
/// which Android does not stop after about 10 minutes. Both need the
/// notification permission (Android 13+) and the manifest entries listed
/// in the README.
///
/// Use [UploadNotifications.localized] (or [localizedWith]) for texts in
/// the language of the app.
@immutable
final class UploadNotifications {
  /// Creates the notification settings. The texts default to English.
  const UploadNotifications({
    this.enabled = true,
    this.running = const UploadNotificationText(
      'Uploading {displayName}',
      '{progress}',
    ),
    this.complete = const UploadNotificationText(
      'Upload complete',
      '{displayName}',
    ),
    this.error = const UploadNotificationText('Upload failed', '{displayName}'),
    this.grouped = false,
    this.groupRunning = const UploadNotificationText(
      'Uploading files',
      '{numFinished} of {numTotal} done',
    ),
    this.groupComplete = const UploadNotificationText(
      'Uploads complete',
      '{numTotal} files uploaded',
    ),
    this.groupError = const UploadNotificationText(
      'Some uploads failed',
      '{numFailed} of {numTotal} failed',
    ),
    this.cancelLabel = 'Cancel',
    this.allowLongUploads = true,
    this.requestPermission = true,
  });

  /// Settings with the texts of [l10n] (English or Spanish).
  factory UploadNotifications.localized(
    UpCloudLocalizations l10n, {
    bool enabled = true,
    bool grouped = false,
    bool allowLongUploads = true,
    bool requestPermission = true,
  }) => UploadNotifications(
    enabled: enabled,
    grouped: grouped,
    allowLongUploads: allowLongUploads,
    requestPermission: requestPermission,
  ).localizedWith(l10n);

  /// No notifications. On Android, uploads then run as regular background
  /// work, which Android stops after about 10 minutes.
  static const disabled = UploadNotifications(enabled: false);

  /// Whether to show notifications.
  final bool enabled;

  /// Notification of an upload in progress.
  final UploadNotificationText running;

  /// Notification of an upload whose bytes were sent. The provider may
  /// still reject the file when completing the upload: the transfer queue
  /// has the final state.
  final UploadNotificationText complete;

  /// Notification of an upload that failed. The transfer queue may retry
  /// it automatically.
  final UploadNotificationText error;

  /// Whether to show one notification for all the uploads running at the
  /// same time instead of one per upload.
  ///
  /// It uses [groupRunning], [groupComplete] and [groupError], whose
  /// counts only include the uploads already handed to the system (the
  /// transfer queue starts the others as slots free up), and shows no
  /// progress of the bytes sent. Its Cancel button (Android) cancels the
  /// uploads that are running, not the queued ones.
  final bool grouped;

  /// Grouped notification while uploads run.
  final UploadNotificationText groupRunning;

  /// Grouped notification when every upload completed.
  final UploadNotificationText groupComplete;

  /// Grouped notification when some upload failed.
  final UploadNotificationText groupError;

  /// Label of the Cancel button on iOS. On Android, override the
  /// `bg_downloader_cancel` string resource instead (see the README).
  final String cancelLabel;

  /// Whether, on Android, uploads run as user-initiated data transfers
  /// (Android 14+) or in a foreground service, so they are not stopped
  /// after about 10 minutes in the background. Only when notifications are
  /// [enabled] and allowed by the user.
  final bool allowLongUploads;

  /// Whether to ask for the notification permission (Android 13+, iOS) the
  /// first time an upload starts, if it was not granted yet. Uploads work
  /// whatever the answer.
  final bool requestPermission;

  /// A copy with the texts of [l10n], keeping the other settings.
  UploadNotifications localizedWith(UpCloudLocalizations l10n) => copyWith(
    running: UploadNotificationText(
      l10n.uploadNotificationRunningTitle,
      l10n.uploadNotificationRunningBody,
    ),
    complete: UploadNotificationText(
      l10n.uploadNotificationCompleteTitle,
      l10n.uploadNotificationCompleteBody,
    ),
    error: UploadNotificationText(
      l10n.uploadNotificationErrorTitle,
      l10n.uploadNotificationErrorBody,
    ),
    groupRunning: UploadNotificationText(
      l10n.uploadGroupNotificationRunningTitle,
      l10n.uploadGroupNotificationRunningBody,
    ),
    groupComplete: UploadNotificationText(
      l10n.uploadGroupNotificationCompleteTitle,
      l10n.uploadGroupNotificationCompleteBody,
    ),
    groupError: UploadNotificationText(
      l10n.uploadGroupNotificationErrorTitle,
      l10n.uploadGroupNotificationErrorBody,
    ),
    cancelLabel: l10n.cancel,
  );

  /// A copy with the given values replaced.
  UploadNotifications copyWith({
    bool? enabled,
    UploadNotificationText? running,
    UploadNotificationText? complete,
    UploadNotificationText? error,
    bool? grouped,
    UploadNotificationText? groupRunning,
    UploadNotificationText? groupComplete,
    UploadNotificationText? groupError,
    String? cancelLabel,
    bool? allowLongUploads,
    bool? requestPermission,
  }) => UploadNotifications(
    enabled: enabled ?? this.enabled,
    running: running ?? this.running,
    complete: complete ?? this.complete,
    error: error ?? this.error,
    grouped: grouped ?? this.grouped,
    groupRunning: groupRunning ?? this.groupRunning,
    groupComplete: groupComplete ?? this.groupComplete,
    groupError: groupError ?? this.groupError,
    cancelLabel: cancelLabel ?? this.cancelLabel,
    allowLongUploads: allowLongUploads ?? this.allowLongUploads,
    requestPermission: requestPermission ?? this.requestPermission,
  );

  @override
  bool operator ==(Object other) =>
      other is UploadNotifications &&
      other.enabled == enabled &&
      other.running == running &&
      other.complete == complete &&
      other.error == error &&
      other.grouped == grouped &&
      other.groupRunning == groupRunning &&
      other.groupComplete == groupComplete &&
      other.groupError == groupError &&
      other.cancelLabel == cancelLabel &&
      other.allowLongUploads == allowLongUploads &&
      other.requestPermission == requestPermission;

  @override
  int get hashCode => Object.hash(
    enabled,
    running,
    complete,
    error,
    grouped,
    groupRunning,
    groupComplete,
    groupError,
    cancelLabel,
    allowLongUploads,
    requestPermission,
  );
}
