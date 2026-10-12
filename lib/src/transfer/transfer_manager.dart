import 'dart:async';
import 'dart:math' as math;

import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/settings/upload_settings.dart';
import 'package:upcloud/src/transfer/folder_path_resolver.dart';
import 'package:upcloud/src/transfer/transfer_task.dart';
import 'package:upcloud/src/transfer/upload_batch.dart';
import 'package:upcloud/src/transfer/upload_executor.dart';

/// Returns true to leave the upload of [file] to the account [accountId] out
/// of a batch (see `TransferManager.uploadBatch`).
typedef UploadPairFilter = bool Function(UploadSource file, String accountId);

/// Queues uploads and runs them with limited concurrency.
///
/// Each upload is validated against the provider limits (and the free
/// storage, see [UploadSettings.checkStorage]), its destination folder path
/// is resolved, then the provider prepares the request
/// (`FileUploading.prepareUpload`), the [UploadExecutor] sends it and the
/// provider completes it (`FileUploading.completeUpload`).
///
/// Concurrency is limited globally by [UploadSettings.maxConcurrentUploads]
/// and per account by the provider's `ProviderLimits.maxConcurrentUploads`.
/// Transient failures are retried automatically (see [isRetryable]).
///
/// ```dart
/// final task = manager.upload('account-1', UploadSource.file(path));
/// task.changes.listen(print);
/// final file = await task.result;
/// ```
final class TransferManager {
  /// Creates a manager that finds providers with [resolveProvider] and
  /// sends uploads with `executor`.
  ///
  /// [folders] resolves folder paths; by default a new resolver caches
  /// them for the lifetime of the manager. Retries wait [retryBaseDelay],
  /// doubled on every retry up to [maxRetryDelay].
  TransferManager({
    required ProviderResolver resolveProvider,
    required this._executor,
    UploadSettings settings = const UploadSettings(),
    FolderPathResolver? folders,
    this.progressInterval = const Duration(milliseconds: 150),
    this.retryBaseDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 30),
  }) : _resolve = resolveProvider,
       _settings = settings.normalized(),
       folders = folders ?? FolderPathResolver(resolveProvider);

  /// Resolves the destination folder paths of the uploads.
  final FolderPathResolver folders;

  /// Minimum time between two progress notifications of the same task.
  final Duration progressInterval;

  /// Delay before the first automatic retry.
  final Duration retryBaseDelay;

  /// Longest delay between two automatic retries (unless the provider asks
  /// for a longer one with `RateLimitedException.retryAfter`).
  final Duration maxRetryDelay;

  final ProviderResolver _resolve;
  final UploadExecutor _executor;
  UploadSettings _settings;
  final _tasks = <UploadTask>[];
  final _running = <UploadTask>{};
  final _subscriptions = <UploadTask, StreamSubscription<Type>>{};
  final _completedAt = <UploadTask, DateTime>{};
  final _clearTimers = <UploadTask, Timer>{};
  final _changes = StreamController<List<UploadTask>>.broadcast();
  var _nextId = 0;
  var _nextBatchId = 0;
  var _disposed = false;

  /// Current settings.
  UploadSettings get settings => _settings;

  /// All tasks, oldest first.
  List<UploadTask> get tasks => List.unmodifiable(_tasks);

  /// Emits [tasks] when a task is added, removed or changes status.
  ///
  /// Progress updates are not emitted here; listen to
  /// [TransferTask.changes] for them.
  Stream<List<UploadTask>> get changes => _changes.stream;

  /// Whether any task is queued or running.
  bool get isBusy => _tasks.any((t) => !t.state.isFinished);

  /// Applies new [settings] (normalized) immediately: a higher concurrency
  /// starts queued uploads, and completed uploads are cleared according to
  /// the new [UploadSettings.autoClearAfterSeconds].
  ///
  /// Default visibility and folder apply to uploads queued afterwards.
  void updateSettings(UploadSettings settings) {
    _settings = settings.normalized();
    [..._completedAt.keys].forEach(_scheduleAutoClear);
    _pump();
  }

  /// Queues the upload of [source] to [accountId].
  ///
  /// When [folderPath] is given (e.g. `Movies/2026`, empty for the root)
  /// the folder is found by name, or created, before the upload and
  /// replaces [UploadOptions.folderId].
  ///
  /// The visibility of the file is [UploadOptions.isPublic] when set, else
  /// [visibility] when given, else [UploadSettings.defaultVisibility]
  /// ([UploadVisibility.providerDefault] keeps the provider default).
  UploadTask upload(
    String accountId,
    UploadSource source, {
    UploadOptions options = const UploadOptions(),
    String? folderPath,
    UploadVisibility? visibility,
  }) {
    final task = _createTask(
      accountId,
      source,
      options,
      folderPath,
      null,
      visibility,
    );
    _add([task]);
    return task;
  }

  /// Queues the upload of every file of [files] to every account of
  /// [accountIds], all in the folder at [folderPath].
  ///
  /// Each folder is resolved (and created when missing) once per account.
  /// When neither [folderPath] nor [UploadOptions.folderId] is given,
  /// [UploadSettings.defaultFolderPath] is used; pass an empty path for the
  /// root folder.
  ///
  /// Pairs for which [skip] returns true (e.g. files a provider would
  /// reject) are left out: no task is created for them. [visibility]
  /// applies as in [upload].
  UploadBatch uploadBatch({
    required List<UploadSource> files,
    required List<String> accountIds,
    String? folderPath,
    UploadOptions options = const UploadOptions(),
    UploadVisibility? visibility,
    UploadPairFilter? skip,
  }) {
    final rawPath =
        folderPath ??
        (options.folderId == null ? settings.defaultFolderPath : null);
    final path = rawPath == null ? null : normalizeFolderPath(rawPath);
    final batchId = 'b${_nextBatchId++}';
    final accounts = {...accountIds};
    final tasks = [
      for (final source in files)
        for (final accountId in accounts)
          if (!(skip?.call(source, accountId) ?? false))
            _createTask(accountId, source, options, path, batchId, visibility),
    ];
    _add(tasks);
    return UploadBatch(id: batchId, tasks: tasks, folderPath: path);
  }

  /// Cancels [task]. Queued tasks are cancelled immediately.
  void cancel(UploadTask task) {
    if (task.state.isFinished) return;
    if (_running.contains(task)) {
      task.cancelToken.cancel();
    } else {
      task.fail(const CancelledException());
      _pump();
    }
  }

  /// Cancels every unfinished task.
  void cancelAll() => [..._tasks].forEach(cancel);

  /// Queues a failed or cancelled [task] again, with a new budget of
  /// automatic retries.
  void retry(UploadTask task) {
    if (!task.state.isFinished || task.state is TransferCompleted) return;
    task.reset();
    _pump();
  }

  /// Removes [task] from the list, cancelling it if needed.
  void remove(UploadTask task) {
    cancel(task);
    if (_tasks.remove(task)) {
      _clearTimers.remove(task)?.cancel();
      _completedAt.remove(task);
      unawaited(_subscriptions.remove(task)?.cancel());
      unawaited(task.dispose());
      _emit();
    }
  }

  /// Removes every finished task.
  void clearFinished() {
    for (final task in [..._tasks]) {
      if (task.state.isFinished) remove(task);
    }
  }

  /// Cancels all tasks and releases resources.
  Future<void> dispose() async {
    if (_disposed) return;
    cancelAll();
    _disposed = true;
    for (final timer in _clearTimers.values) {
      timer.cancel();
    }
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    for (final task in _tasks) {
      await task.dispose();
    }
    await _changes.close();
  }

  /// Whether an upload that failed with [error] is retried automatically.
  ///
  /// Network errors, rate limits and server errors (a [ProviderException]
  /// without status or with a `5xx` status) are retried; errors that would
  /// happen again (authentication, rejected or missing files, cancellation,
  /// quotas...) are not.
  static bool isRetryable(UpCloudException error) => switch (error) {
    NetworkException() || RateLimitedException() => true,
    ProviderException(:final statusCode) =>
      statusCode == null || statusCode >= 500,
    _ => false,
  };

  /// Delay before automatic retry number [retry] (1 for the first) after
  /// [error].
  ///
  /// [retryBaseDelay] doubled on every retry, up to [maxRetryDelay]; never
  /// shorter than the `retryAfter` of a [RateLimitedException].
  Duration retryDelay(int retry, UpCloudException error) {
    final exponent = math.min(math.max(retry - 1, 0), 20);
    final backoff = retryBaseDelay * (1 << exponent);
    final delay = backoff > maxRetryDelay ? maxRetryDelay : backoff;
    if (error case RateLimitedException(:final retryAfter?)
        when retryAfter > delay) {
      return retryAfter;
    }
    return delay;
  }

  String _newId() => 't${_nextId++}';

  UploadTask _createTask(
    String accountId,
    UploadSource source,
    UploadOptions options,
    String? folderPath,
    String? batchId,
    UploadVisibility? visibility,
  ) {
    if (_disposed) throw StateError('TransferManager was disposed');
    final task = UploadTask(
      id: _newId(),
      accountId: accountId,
      source: source,
      options: options.isPublic == null
          ? options.copyWith(
              isPublic: (visibility ?? settings.defaultVisibility).isPublic,
            )
          : options,
      batchId: batchId,
      folderPath: folderPath == null ? null : normalizeFolderPath(folderPath),
    );
    unawaited(
      source.resolveLength().then((length) {
        if (task.totalBytes == null) task.setTotalBytes(length);
      }, onError: (Object _) {}),
    );
    return task;
  }

  void _add(List<UploadTask> tasks) {
    for (final task in tasks) {
      _tasks.add(task);
      _subscriptions[task] = task.changes
          .map((s) => s.runtimeType)
          .distinct()
          .listen((_) => _emit());
    }
    _emit();
    _pump();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(tasks);
  }

  void _pump() {
    if (_disposed) return;
    for (final task in _tasks) {
      if (_running.length >= settings.maxConcurrentUploads) return;
      if (task.state is! TransferQueued || _running.contains(task)) continue;

      final CloudProvider provider;
      try {
        provider = _resolve(task.accountId);
      } on UpCloudException catch (e) {
        task.fail(e);
        continue;
      } on Object catch (e, st) {
        task.fail(ProviderException('$e', cause: e, stackTrace: st));
        continue;
      }

      final sameAccount = _running.where((t) => t.accountId == task.accountId);
      if (sameAccount.length >= provider.limits.maxConcurrentUploads) {
        continue;
      }

      _running.add(task);
      unawaited(_run(task, provider));
    }
  }

  Future<void> _run(UploadTask task, CloudProvider provider) async {
    try {
      task.complete(await _uploadWithRetries(task, provider));
      if (_tasks.contains(task)) {
        _completedAt[task] = DateTime.now();
        _scheduleAutoClear(task);
      }
    } on UpCloudException catch (e) {
      task.fail(e);
    } on Object catch (e, st) {
      task.fail(ProviderException('$e', cause: e, stackTrace: st));
    } finally {
      _running.remove(task);
      _pump();
    }
  }

  Future<CloudFile> _uploadWithRetries(
    UploadTask task,
    CloudProvider provider,
  ) async {
    for (var retry = 1; ; retry++) {
      task.startAttempt();
      try {
        return await _attempt(task, provider);
      } on UpCloudException catch (e) {
        final path = task.folderPath;
        if (e is NotFoundException && path != null && path.isNotEmpty) {
          // The cached folder may have been deleted: find it again next time.
          folders.invalidate(task.accountId, path);
        }
        if (retry > settings.retries ||
            !isRetryable(e) ||
            task.cancelToken.isCancelled) {
          rethrow;
        }
        await _untilCancelled(task, Future<void>.delayed(retryDelay(retry, e)));
      }
    }
  }

  /// One run of the upload steps.
  Future<CloudFile> _attempt(UploadTask task, CloudProvider provider) async {
    if (provider is! FileUploading) {
      throw UnsupportedOperationException(
        '${provider.info.name} does not support uploads',
      );
    }
    _throwIfCancelled(task);
    task.setState(
      TransferState.running(
        TransferProgress(transferred: 0, total: task.totalBytes),
      ),
    );
    final file = await task.source.resolveInfo();
    task.setTotalBytes(file.size);
    await _validate(task, provider, file);

    var options = task.options;
    final path = task.folderPath;
    if (path != null) {
      final folderId = await _untilCancelled(
        task,
        folders.resolve(task.accountId, path),
      );
      options = options.copyWith(folderId: folderId);
    }

    final request = await _untilCancelled(
      task,
      provider.prepareUpload(file, options: options),
    );
    final response = await _executor.execute(
      request,
      task.source,
      onProgress: _throttledProgress(task),
      cancelToken: task.cancelToken,
    );
    return await _untilCancelled(
      task,
      provider.completeUpload(request, response),
    );
  }

  /// Throws [UploadRejectedException] when [file] breaks the limits of
  /// [provider] or does not fit in the account.
  Future<void> _validate(
    UploadTask task,
    CloudProvider provider,
    UploadFileInfo file,
  ) async {
    final length = file.size;
    final size = length == null ? null : DataSize(length);
    DataSize? storageLeft;
    if (settings.checkStorage &&
        size != null &&
        provider is AccountInfoProviding &&
        provider.supports(Capability.accountInfo)) {
      try {
        storageLeft = (await _untilCancelled(
          task,
          provider.accountInfo(),
        )).storageLeft;
      } on CancelledException {
        rethrow;
      } on UpCloudException {
        // Unknown storage: let the provider decide.
      }
    }
    final rejection = provider.limits.check(
      extension: file.extension,
      size: size,
      storageLeft: storageLeft,
    );
    if (rejection != null) {
      throw UploadRejectedException(
        describeRejection(rejection),
        reason: rejection,
      );
    }
  }

  /// Completes like [future], or throws [CancelledException] as soon as
  /// [task] is cancelled.
  static Future<T> _untilCancelled<T>(UploadTask task, Future<T> future) async {
    final token = task.cancelToken;
    if (token.isCancelled) {
      future.ignore();
      throw const CancelledException();
    }
    return await Future.any([
      future,
      token.whenCancelled.then<T>((_) => throw const CancelledException()),
    ]);
  }

  static void _throwIfCancelled(UploadTask task) {
    if (task.cancelToken.isCancelled) throw const CancelledException();
  }

  void _scheduleAutoClear(UploadTask task) {
    _clearTimers.remove(task)?.cancel();
    final after = settings.autoClearAfter;
    final completedAt = _completedAt[task];
    if (after == null || completedAt == null || _disposed) return;
    final remaining = completedAt.add(after).difference(DateTime.now());
    _clearTimers[task] = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        _clearTimers.remove(task);
        if (task.state is TransferCompleted) remove(task);
      },
    );
  }

  void Function(TransferProgress) _throttledProgress(UploadTask task) {
    var last = DateTime.fromMillisecondsSinceEpoch(0);
    return (progress) {
      final now = DateTime.now();
      final done =
          progress.total != null && progress.transferred >= progress.total!;
      if (!done && now.difference(last) < progressInterval) return;
      last = now;
      if (!task.state.isFinished) {
        task.setState(TransferState.running(progress));
      }
    };
  }
}

/// A short English description of [rejection].
String describeRejection(UploadRejection rejection) => switch (rejection) {
  FileTooLarge(:final size, :final maxSize) =>
    'File is too large ($size, max $maxSize)',
  ExtensionNotAllowed(:final extension) =>
    'File type ".$extension" is not allowed',
  NotEnoughStorage(:final size, :final available) =>
    'Not enough storage ($size needed, $available available)',
};
