import 'package:upcloud/src/uploads/upload_notifications.dart';
import 'package:upcloud/upcloud.dart';

/// Background uploads are not available on this platform (the web).
Future<UploadResponse> executeBackgroundUpload(
  UploadRequest request,
  UploadSource source, {
  required String group,
  required UploadNotifications notifications,
  Duration responseTimeout = const Duration(minutes: 5),
  void Function(TransferProgress progress)? onProgress,
  CancellationToken? cancelToken,
}) async => throw const UnsupportedOperationException(
  'BackgroundUploadExecutor is not supported on the web: '
  'background_downloader has no web implementation. Use another '
  'UploadExecutor.',
);
