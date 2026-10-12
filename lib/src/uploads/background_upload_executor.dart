import 'package:upcloud/src/uploads/background_upload_io.dart' as platform;
import 'package:upcloud/src/uploads/upload_notifications.dart';
import 'package:upcloud/upcloud.dart';

/// An [UploadExecutor] that sends uploads with
/// [background_downloader](https://pub.dev/packages/background_downloader),
/// so they keep running while the app is in the background.
///
/// ```dart
/// final upcloud = UpCloud(uploadExecutor: BackgroundUploadExecutor());
/// ```
///
/// `UpCloudFlutter.create` uses it by default.
///
/// How requests are sent:
///
/// * `multipart` requests send the form fields, then the file in the part
///   named `UploadRequest.fileField`, called `UploadSource.name`.
/// * `binary` requests send the file as the body. No `Content-Disposition`
///   header is added unless the request has one, and its `Content-Type`
///   header (or the type guessed from the file name) is the file type.
/// * `UploadRequest.method` and `UploadRequest.headers` are used as is;
///   `UploadRequest.context` is never sent.
/// * background_downloader does not retry (`retries: 0`): the
///   `TransferManager` retries by preparing the request again.
///
/// Uploads show system [notifications] on Android and iOS (see
/// [UploadNotifications]): the file name and a progress bar while running,
/// then complete or failed. The first upload asks for the notification
/// permission. On Android, with notifications allowed, uploads run as
/// user-initiated data transfers (Android 14+) or in a foreground service,
/// so they are not stopped after about 10 minutes (only for uploads that
/// start while the app is visible, as Android requires); without them,
/// Android stops background uploads after about 10 minutes (the queue then
/// retries them from the start). The Cancel button of a notification
/// cancels the upload (a [CancelledException]). Change [notifications] at
/// any time, e.g. when the language of the app changes (see
/// `LocalizedUploadNotifications`); running uploads keep their texts.
///
/// Files ([FileUploadSource]) are uploaded from their path. Bytes and
/// streams ([BytesUploadSource], [StreamUploadSource]) are first written to
/// a temporary file, deleted when the upload ends (whatever the outcome).
/// A multipart upload whose [FileUploadSource.name] differs from the file
/// name on disk also goes through a temporary link (or copy) with that name.
///
/// Every HTTP response is returned, including error statuses. For error
/// statuses the body is the one received by background_downloader: it is
/// the response body on iOS, Android and desktop, but when the server sends
/// an empty body some platforms return the HTTP reason phrase instead.
///
/// Errors:
///
/// * [CancelledException] as soon as the `cancelToken` is cancelled; the
///   background task is cancelled too.
/// * [NetworkException] when no response was received (connection errors,
///   timeouts, or the device went offline: background_downloader would hold
///   the task until the network is back, so it is cancelled instead and the
///   `TransferManager` decides whether to retry).
/// * [NotFoundException] when the source cannot be read.
/// * [UnsupportedOperationException] for HTTP methods background_downloader
///   cannot send (only `GET`, `POST`, `HEAD`, `PUT`, `DELETE` and `PATCH`
///   are accepted).
///
/// Platform notes: uploads survive the app going to the background, not
/// the app being killed (the upload queue lives in memory). iOS stops
/// background transfers after 4 hours by default. Empty files cannot be
/// sent as `binary` requests. The executor sets background_downloader's
/// `Config.runInForeground` on Android, which also applies to other tasks
/// of the app that have a running notification.
final class BackgroundUploadExecutor implements UploadExecutor {
  /// Creates an executor whose background_downloader tasks belong to
  /// [group].
  BackgroundUploadExecutor({
    this.group = defaultGroup,
    this.notifications = const UploadNotifications(),
    this.responseTimeout = defaultResponseTimeout,
  });

  /// Default of [responseTimeout].
  static const defaultResponseTimeout = Duration(minutes: 5);

  /// Default background_downloader group of the uploads.
  static const defaultGroup = 'upcloud';

  /// background_downloader group of the tasks, to tell them apart from the
  /// other transfers of the app. Uploads without notifications use the
  /// group `'$group.silent'`.
  final String group;

  /// Notifications of the uploads started from now on.
  UploadNotifications notifications;

  /// How long to wait for the server once the file is sent (on iOS, the
  /// idle time between packets).
  ///
  /// Hosting servers may answer slowly after receiving a large file; a
  /// timeout makes the queue retry, which could upload the file twice, so
  /// the default (5 minutes) is generous. It is background_downloader's
  /// global `Config.requestTimeout`, applied before the first upload.
  final Duration responseTimeout;

  @override
  Future<UploadResponse> execute(
    UploadRequest request,
    UploadSource source, {
    void Function(TransferProgress progress)? onProgress,
    CancellationToken? cancelToken,
  }) => platform.executeBackgroundUpload(
    request,
    source,
    group: group,
    notifications: notifications,
    responseTimeout: responseTimeout,
    onProgress: onProgress,
    cancelToken: cancelToken,
  );
}
