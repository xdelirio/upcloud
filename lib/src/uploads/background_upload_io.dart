import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:upcloud/src/uploads/upload_notifications.dart';
import 'package:upcloud/upcloud.dart';

/// Sends [request] with the content of [source] as a background_downloader
/// upload task. See `BackgroundUploadExecutor`.
Future<UploadResponse> executeBackgroundUpload(
  UploadRequest request,
  UploadSource source, {
  required String group,
  required UploadNotifications notifications,
  Duration responseTimeout = const Duration(minutes: 5),
  void Function(TransferProgress progress)? onProgress,
  CancellationToken? cancelToken,
}) async {
  _throwIfCancelled(cancelToken);
  final binary = request.encoding == UploadEncoding.binary;
  final staged = await stageUploadSource(source, keepName: !binary);
  var started = false;
  try {
    _throwIfCancelled(cancelToken);
    if (binary && staged.length == 0) {
      throw UnsupportedOperationException(
        '${source.name} is empty: background uploads cannot send an empty '
        'body',
      );
    }
    await _applyResponseTimeout(responseTimeout);
    final setup = await _notificationSetup.prepare(notifications, group);
    _throwIfCancelled(cancelToken);
    final upload = _BackgroundUpload(
      task: buildUploadTask(
        request,
        path: staged.path,
        displayName: source.name,
        group: setup.group,
        priority: setup.priority,
      ),
      path: staged.path,
      fileName: source.name,
      length: staged.length,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
    final response = upload.start();
    started = true;
    // The background task may still read the file after a cancellation:
    // delete it once background_downloader reports the end of the task.
    unawaited(upload.finished.whenComplete(staged.delete));
    return await response;
  } finally {
    if (!started) await staged.delete();
  }
}

/// HTTP methods accepted by background_downloader.
const _methods = {'GET', 'POST', 'HEAD', 'PUT', 'DELETE', 'PATCH'};

/// The background_downloader task that sends [request] with the file at
/// [path].
///
/// Binary requests take their `Content-Type` header as the file type and
/// omit `Content-Disposition` unless the request sets it. Tasks report
/// status and progress and are never retried by background_downloader.
@visibleForTesting
bd.UploadTask buildUploadTask(
  UploadRequest request, {
  required String path,
  required String displayName,
  required String group,
  int priority = normalPriority,
}) {
  final method = request.method.toUpperCase();
  if (!_methods.contains(method)) {
    throw UnsupportedOperationException(
      'Background uploads cannot send $method requests',
    );
  }
  final binary = request.encoding == UploadEncoding.binary;
  final headers = <String, String>{};
  String? contentType;
  String? disposition;
  for (final MapEntry(:key, :value) in request.headers.entries) {
    switch (key.toLowerCase()) {
      case 'content-type' when binary:
        contentType = value;
      case 'content-disposition' when binary:
        disposition = value;
      default:
        headers[key] = value;
    }
  }
  // An empty value tells background_downloader not to send the header.
  if (binary) headers['Content-Disposition'] = disposition ?? '';
  return bd.UploadTask.fromFile(
    file: File(path),
    url: request.url.toString(),
    headers: headers,
    httpRequestMethod: method,
    post: binary ? 'binary' : null,
    fileField: request.fileField,
    mimeType: contentType,
    fields: binary ? null : {...request.fields},
    group: group,
    priority: priority,
    updates: bd.Updates.statusAndProgress,
    // The TransferManager retries by preparing the request again.
    // ignore: avoid_redundant_argument_values
    retries: 0,
    displayName: displayName,
  );
}

/// Priority of tasks that may run for a long time on Android: with a
/// notification, Android 14+ runs them as user-initiated data transfers.
const longUploadPriority = 0;

/// Priority of the other tasks (background_downloader's default).
const normalPriority = 5;

/// background_downloader group of the tasks sent with [notifications].
///
/// Notifications are configured per group, so uploads without them use a
/// group of their own.
@visibleForTesting
String taskGroupFor(UploadNotifications notifications, String group) =>
    notifications.enabled ? group : '$group.silent';

/// Priority of the tasks: [longUploadPriority] when notifications are
/// shown and long uploads are allowed. Android requires a visible
/// notification for user-initiated data transfers.
@visibleForTesting
int taskPriorityFor(
  UploadNotifications notifications, {
  required bool notificationsAllowed,
}) =>
    notifications.enabled &&
        notifications.allowLongUploads &&
        notificationsAllowed
    ? longUploadPriority
    : normalPriority;

/// The background_downloader notifications of the tasks of [group], or
/// `null` when [notifications] are disabled.
@visibleForTesting
bd.TaskNotificationConfig? notificationConfigFor(
  UploadNotifications notifications,
  String group,
) {
  if (!notifications.enabled) return null;
  bd.TaskNotification text(UploadNotificationText value) =>
      bd.TaskNotification(value.title, value.body);
  final grouped = notifications.grouped;
  return bd.TaskNotificationConfig(
    taskOrGroup: group,
    running: text(grouped ? notifications.groupRunning : notifications.running),
    complete: text(
      grouped ? notifications.groupComplete : notifications.complete,
    ),
    error: text(grouped ? notifications.groupError : notifications.error),
    progressBar: true,
    groupNotificationId: grouped ? 'upcloud.$group' : '',
  );
}

/// The background_downloader configuration for [notifications]: long
/// uploads run in a foreground service on Android (it only applies to
/// tasks with a running notification), and the Cancel button is
/// translated on iOS.
@visibleForTesting
({(String, Object) android, (String, Object) ios}) platformConfigFor(
  UploadNotifications notifications,
) => (
  android: (
    bd.Config.runInForeground,
    notifications.enabled && notifications.allowLongUploads
        ? bd.Config.always
        : bd.Config.never,
  ),
  ios: (bd.Config.localize, {'Cancel': notifications.cancelLabel}),
);

final _notificationSetup = _NotificationSetup();

Duration? _appliedResponseTimeout;

/// Sets background_downloader's global request timeout once per value.
Future<void> _applyResponseTimeout(Duration timeout) async {
  if (_appliedResponseTimeout == timeout) return;
  _appliedResponseTimeout = timeout;
  try {
    await bd.FileDownloader().configure(
      globalConfig: (bd.Config.requestTimeout, timeout),
    );
  } on Object {
    // The package default (60 s) keeps working.
  }
}

/// Applies the notification settings to background_downloader, and asks
/// for the notification permission once.
final class _NotificationSetup {
  final _applied = <String, UploadNotifications>{};
  (bool, String)? _platformKey;
  Future<bool>? _permissionRequest;

  /// The group and priority of a task sent with [notifications].
  Future<({String group, int priority})> prepare(
    UploadNotifications notifications,
    String group,
  ) async {
    final taskGroup = taskGroupFor(notifications, group);
    final downloader = bd.FileDownloader();
    final config = notificationConfigFor(notifications, taskGroup);
    if (config != null && _applied[taskGroup] != notifications) {
      _applied[taskGroup] = notifications;
      downloader.configureNotificationForGroup(
        taskGroup,
        running: config.running,
        complete: config.complete,
        error: config.error,
        progressBar: config.progressBar,
        groupNotificationId: config.groupNotificationId,
      );
    }
    final platformKey = (
      notifications.enabled && notifications.allowLongUploads,
      notifications.cancelLabel,
    );
    if (platformKey != _platformKey) {
      _platformKey = platformKey;
      final platformConfig = platformConfigFor(notifications);
      try {
        await downloader.configure(
          androidConfig: platformConfig.android,
          iOSConfig: platformConfig.ios,
        );
      } on Object {
        // Uploads work without it.
      }
    }
    final allowed = notifications.enabled && await _allowed(notifications);
    return (
      group: taskGroup,
      priority: taskPriorityFor(notifications, notificationsAllowed: allowed),
    );
  }

  /// Whether notifications may be shown, asking the user once if needed.
  Future<bool> _allowed(UploadNotifications notifications) async {
    const type = bd.PermissionType.notifications;
    final permissions = bd.FileDownloader().permissions;
    try {
      if (_isAllowed(await permissions.status(type))) return true;
      if (!notifications.requestPermission) return false;
      return await (_permissionRequest ??= permissions
          .request(type)
          .then(_isAllowed, onError: (Object _) => false));
    } on Object {
      return false;
    }
  }

  static bool _isAllowed(bd.PermissionStatus status) =>
      status == bd.PermissionStatus.granted ||
      status == bd.PermissionStatus.partial;
}

/// The [UploadResponse] of a finished background task, or the
/// [UpCloudException] that stopped it.
///
/// HTTP error statuses are responses: background_downloader reports them as
/// failed tasks, with the body in `responseBody` (iOS, desktop) or in the
/// description of the [bd.TaskHttpException] (Android).
///
/// Android and desktop report most I/O errors, network ones included
/// (unknown host, TLS, cleartext traffic...), as file system errors: they
/// are a [NotFoundException] only when the file to send is gone
/// ([fileExists] is false), else a [NetworkException].
@visibleForTesting
UploadResponse uploadResponseFromUpdate(
  bd.TaskStatusUpdate update, {
  required String fileName,
  bool fileExists = true,
}) {
  final headers = {...?update.responseHeaders};
  switch (update.status) {
    case bd.TaskStatus.complete:
      return UploadResponse(
        statusCode: update.responseStatusCode ?? 200,
        body: update.responseBody ?? '',
        headers: headers,
      );
    case bd.TaskStatus.notFound:
      return UploadResponse(
        statusCode: update.responseStatusCode ?? 404,
        body: _errorBody(update),
        headers: headers,
      );
    case bd.TaskStatus.canceled:
      throw const CancelledException();
    case bd.TaskStatus.failed:
      final exception = update.exception;
      switch (exception) {
        case bd.TaskHttpException(:final httpResponseCode)
            when httpResponseCode > 0:
          return UploadResponse(
            statusCode: httpResponseCode,
            body: _errorBody(update),
            headers: headers,
          );
        case bd.TaskFileSystemException(:final description) when !fileExists:
          throw NotFoundException(
            'Cannot read $fileName: $description',
            cause: exception,
          );
        default:
          final description = exception?.description ?? '';
          throw NetworkException(
            description.isEmpty ? 'Upload failed' : description,
            cause: exception,
          );
      }
    case bd.TaskStatus.enqueued ||
        bd.TaskStatus.running ||
        bd.TaskStatus.waitingToRetry ||
        bd.TaskStatus.paused:
      throw NetworkException('Upload stopped (${update.status.name})');
  }
}

String _errorBody(bd.TaskStatusUpdate update) {
  final body = update.responseBody;
  if (body != null && body.isNotEmpty) return body;
  return switch (update.exception) {
    bd.TaskHttpException(:final description) => description,
    _ => '',
  };
}

void _throwIfCancelled(CancellationToken? token) {
  if (token?.isCancelled ?? false) throw const CancelledException();
}

/// One run of a background_downloader task.
final class _BackgroundUpload {
  _BackgroundUpload({
    required this.task,
    required this.path,
    required this.fileName,
    required this.length,
    required this.onProgress,
    required this.cancelToken,
  });

  final bd.UploadTask task;

  /// File sent by [task].
  final String path;
  final String fileName;
  final int length;
  final void Function(TransferProgress progress)? onProgress;
  final CancellationToken? cancelToken;

  final _response = Completer<UploadResponse>();
  final _finished = Completer<void>();
  var _sent = -1;
  var _stopped = false;

  /// Completes, never with an error, once background_downloader reports
  /// the end of the task.
  Future<void> get finished => _finished.future;

  /// Enqueues the task and returns its response.
  Future<UploadResponse> start() {
    unawaited(
      bd.FileDownloader()
          .upload(task, onStatus: _onStatus, onProgress: _onProgress)
          .then(
            _onFinished,
            onError: (Object e, StackTrace st) =>
                _fail(NetworkException('$e', cause: e, stackTrace: st)),
          )
          .whenComplete(_finished.complete),
    );
    final token = cancelToken;
    if (token != null) {
      unawaited(
        token.whenCancelled.then((_) => _stop(const CancelledException())),
      );
    }
    return _response.future;
  }

  void _onStatus(bd.TaskStatus status) {
    if (status.isFinalState) return;
    if (status == bd.TaskStatus.waitingToRetry ||
        status == bd.TaskStatus.paused) {
      // Only happens while offline (tasks have no retries): background_
      // downloader would hold the task until the network comes back.
      _stop(const NetworkException('No network connection'));
    } else if (_stopped) {
      // Cancelled before background_downloader knew the task.
      _cancelTask();
    }
  }

  void _onProgress(double fraction) {
    if (fraction < 0 || _response.isCompleted) return;
    _report(fraction >= 1 ? length : (fraction * length).round());
  }

  void _report(int sent) {
    final clamped = sent.clamp(0, length);
    if (clamped <= _sent) return;
    _sent = clamped;
    onProgress?.call(TransferProgress(transferred: clamped, total: length));
  }

  void _onFinished(bd.TaskStatusUpdate update) {
    if (_response.isCompleted) return;
    try {
      final response = uploadResponseFromUpdate(
        update,
        fileName: fileName,
        fileExists: File(path).existsSync(),
      );
      if (response.isSuccessful) _report(length);
      _response.complete(response);
    } on UpCloudException catch (e) {
      _fail(e);
    }
  }

  void _fail(UpCloudException error) {
    if (!_response.isCompleted) _response.completeError(error);
  }

  /// Completes with [error] right away and cancels the background task.
  void _stop(UpCloudException error) {
    if (_response.isCompleted) return;
    _stopped = true;
    _fail(error);
    // Deferred: status callbacks run before background_downloader
    // registers a task as waiting to retry.
    Timer.run(_cancelTask);
  }

  void _cancelTask() => unawaited(
    bd.FileDownloader()
        .cancelTaskWithId(task.taskId)
        .then<void>((_) {}, onError: (Object _) {}),
  );
}

/// A file ready to be uploaded by background_downloader.
@visibleForTesting
final class StagedUpload {
  /// Creates a staged file; [directory] is deleted by [delete].
  StagedUpload(this.path, this.length, [this.directory]);

  /// Path of the file to upload.
  final String path;

  /// Size of the file in bytes.
  final int length;

  /// Temporary directory holding the file, if one was created.
  final Directory? directory;

  /// Deletes the temporary files, if any.
  Future<void> delete() async {
    try {
      await directory?.delete(recursive: true);
    } on FileSystemException {
      // Already gone, or still in use (Windows): the next sweep removes it.
    }
  }
}

/// Makes [source] available as a file.
///
/// Files are used in place, unless [keepName] is true and the name on disk
/// differs from [UploadSource.name] (multipart uploads send the name of
/// the file): then a temporary link (or copy) with the right name is
/// created. Bytes and streams are written to a temporary file.
///
/// Throws [NotFoundException] when the source cannot be read.
@visibleForTesting
Future<StagedUpload> stageUploadSource(
  UploadSource source, {
  required bool keepName,
  Future<Directory> Function()? temporaryDirectory,
}) async {
  Directory? directory;
  try {
    final name = safeFileName(source.name);
    Future<File> target() async {
      directory = await _newStagingDirectory(temporaryDirectory);
      return File(p.join(directory!.path, name));
    }

    switch (source) {
      case FileUploadSource(:final path):
        final file = File(path);
        final length = await file.length();
        if (!keepName || p.basename(path) == name) {
          return StagedUpload(path, length);
        }
        final copy = await target();
        try {
          await Link(copy.path).create(file.absolute.path);
        } on FileSystemException {
          await file.copy(copy.path);
        }
        return StagedUpload(copy.path, length, directory);
      case BytesUploadSource(:final bytes):
        final file = await target();
        await file.writeAsBytes(bytes, flush: true);
        return StagedUpload(file.path, bytes.length, directory);
      case StreamUploadSource(:final open):
        final file = await target();
        final sink = file.openWrite();
        try {
          await sink.addStream(open());
          await sink.flush();
        } finally {
          await sink.close();
        }
        return StagedUpload(file.path, await file.length(), directory);
    }
  } on Object catch (e, st) {
    await StagedUpload('', 0, directory).delete();
    if (e is UpCloudException) rethrow;
    throw NotFoundException(
      'Cannot read ${source.name}: ${e is FileSystemException ? e.message : e}',
      cause: e,
      stackTrace: st,
    );
  }
}

/// [name] usable as a file name: path separators and control characters
/// are replaced.
@visibleForTesting
String safeFileName(String name) {
  final safe = name.replaceAll(RegExp(r'[/\\\x00-\x1f]'), '_').trim();
  return safe.isEmpty || safe == '.' || safe == '..' ? 'file' : safe;
}

/// Temporary files older than this are removed on the first upload.
const _staleAfter = Duration(days: 1);
var _swept = false;

Future<Directory> _newStagingDirectory(
  Future<Directory> Function()? temporaryDirectory,
) async {
  final temp = await (temporaryDirectory ?? getTemporaryDirectory)();
  final root = Directory(p.join(temp.path, 'upcloud_uploads'));
  await root.create(recursive: true);
  if (!_swept) {
    _swept = true;
    await _sweep(root);
  }
  return await root.createTemp('upload_');
}

/// Removes files left by uploads interrupted by the app being killed.
Future<void> _sweep(Directory root) async {
  final limit = DateTime.now().subtract(_staleAfter);
  try {
    await for (final entry in root.list(followLinks: false)) {
      final stat = entry.statSync();
      if (stat.modified.isBefore(limit)) {
        await entry.delete(recursive: true);
      }
    }
  } on FileSystemException {
    // Best effort.
  }
}
