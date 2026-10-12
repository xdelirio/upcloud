import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud/upcloud.dart';

import '../support/wait.dart';

void main() {
  late InMemoryProvider provider;
  late FakeUploadExecutor executor;
  late TransferManager manager;

  TransferManager createManager({
    UploadSettings settings = const UploadSettings(),
    Duration retryBaseDelay = const Duration(milliseconds: 1),
  }) => TransferManager(
    resolveProvider: (id) =>
        id == 'acc' ? provider : throw NotFoundException('Unknown account $id'),
    executor: executor,
    settings: settings,
    progressInterval: Duration.zero,
    retryBaseDelay: retryBaseDelay,
  );

  Future<void> recreate({
    InMemoryProvider? using,
    UploadSettings settings = const UploadSettings(),
    Duration retryBaseDelay = const Duration(milliseconds: 1),
  }) async {
    await manager.dispose();
    if (using != null) provider = using;
    manager = createManager(settings: settings, retryBaseDelay: retryBaseDelay);
  }

  setUp(() {
    provider = InMemoryProvider();
    executor = FakeUploadExecutor();
    manager = createManager();
  });

  tearDown(() {
    executor.resume();
    return manager.dispose();
  });

  UploadSource bytes(String name, [int length = 100]) =>
      UploadSource.bytes(List.filled(length, 0), name: name);

  group('uploads', () {
    test('prepares, executes and completes an upload', () async {
      final task = manager.upload('acc', bytes('a.mp4'));
      final states = <TransferState>[];
      task.changes.listen(states.add);

      final file = await task.result;

      expect(file.name, 'a.mp4');
      expect(file.size, const DataSize(100));
      expect(task.state, const TransferState.completed());
      expect(task.attempt, 1);
      expect(executor.requests.single.url.scheme, 'memory');
      final progress = [
        for (final state in states)
          if (state case TransferRunning(:final progress)) progress,
      ];
      expect(
        progress.last,
        const TransferProgress(transferred: 100, total: 100),
      );
      expect(provider.files, hasLength(1));
    });

    test('applies upload options', () async {
      final folder = await provider.createFolder('Videos');
      final task = manager.upload(
        'acc',
        bytes('a.mp4'),
        options: UploadOptions(folderId: folder.id, title: 'Title'),
      );
      final file = await task.result;
      expect(file.folderId, folder.id);
      expect(file.name, 'Title');
    });

    test('rejects files that break the provider limits', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(allowedExtensions: {'mp4'}),
        ),
      );

      final task = manager.upload('acc', bytes('a.exe'));

      await expectLater(
        task.result,
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<ExtensionNotAllowed>(),
          ),
        ),
      );
      expect(task.state, isA<TransferFailed>());
      expect(executor.requests, isEmpty);
    });

    test('fails tasks of unknown accounts', () async {
      final task = manager.upload('missing', bytes('a.mp4'));
      await expectLater(task.result, throwsA(isA<NotFoundException>()));
      expect(task.state, isA<TransferFailed>());
    });

    test('fails when the provider cannot upload', () async {
      final noUploads = TransferManager(
        resolveProvider: (_) => _BrowseOnlyProvider(),
        executor: executor,
      );
      addTearDown(noUploads.dispose);

      final task = noUploads.upload('acc', bytes('a.mp4'));

      await expectLater(
        task.result,
        throwsA(isA<UnsupportedOperationException>()),
      );
    });

    test('knows the size of queued uploads', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(maxConcurrentUploads: 1),
        ),
      );
      executor.pause();

      final first = manager.upload('acc', bytes('1.mp4', 20000));
      final second = manager.upload('acc', bytes('2.mp4', 1234));
      await until(() => second.totalBytes != null);

      expect(second.state, isA<TransferQueued>());
      expect(second.totalBytes, 1234);
      executor.resume();
      await first.result;
      await second.result;
    });

    test('isBusy reflects unfinished tasks', () async {
      final task = manager.upload('acc', bytes('a.mp4'));
      expect(manager.isBusy, isTrue);
      await task.result;
      expect(manager.isBusy, isFalse);
    });

    test('cannot add tasks after dispose', () async {
      await manager.dispose();
      expect(
        () => manager.upload('acc', bytes('a.mp4')),
        throwsA(isA<StateError>()),
      );
      manager = createManager();
    });

    test('describeRejection is readable', () {
      expect(
        describeRejection(
          const FileTooLarge(size: DataSize.gb(3), maxSize: DataSize.gb(2)),
        ),
        'File is too large (3.0 GB, max 2.0 GB)',
      );
    });
  });

  group('storage check', () {
    test('rejects uploads larger than the free space when enabled', () async {
      await recreate(using: InMemoryProvider(storage: const DataSize(50)));

      final task = manager.upload('acc', bytes('a.mp4'));

      await expectLater(
        task.result,
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<NotEnoughStorage>(),
          ),
        ),
      );
      expect(executor.requests, isEmpty);
    });

    test('lets the provider decide when disabled', () async {
      await recreate(
        using: InMemoryProvider(storage: const DataSize(50)),
        settings: const UploadSettings(checkStorage: false),
      );

      final task = manager.upload('acc', bytes('a.mp4'));

      await expectLater(task.result, throwsA(isA<QuotaExceededException>()));
      expect(executor.requests, hasLength(1), reason: 'quotas are final');
    });
  });

  group('concurrency', () {
    test('respects per account concurrency', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(maxConcurrentUploads: 1),
        ),
      );
      executor.pause();

      final first = manager.upload('acc', bytes('1.mp4'));
      final second = manager.upload('acc', bytes('2.mp4'));
      await until(() => executor.running == 1);

      expect(first.state, isA<TransferRunning>());
      expect(second.state, isA<TransferQueued>());
      executor.resume();
      await first.result;
      await second.result;
      expect(executor.maxRunning, 1);
    });

    test('applies a new global limit immediately', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(maxConcurrentUploads: 10),
        ),
        settings: const UploadSettings(maxConcurrentUploads: 1),
      );
      executor.pause();
      final tasks = [
        for (var i = 0; i < 5; i++) manager.upload('acc', bytes('$i.mp4')),
      ];
      await until(() => executor.running == 1);
      await pumpEventQueue();
      expect(executor.running, 1);

      manager.updateSettings(
        manager.settings.copyWith(maxConcurrentUploads: 3),
      );
      await until(() => executor.running == 3);

      expect(tasks.where((t) => t.state is TransferQueued), hasLength(2));
      executor.resume();
      await Future.wait(tasks.map((t) => t.result));
      expect(executor.maxRunning, 3);
    });

    test('clamps the settings to their valid range', () {
      manager.updateSettings(
        const UploadSettings(maxConcurrentUploads: 50, retries: -1),
      );
      expect(manager.settings.maxConcurrentUploads, 10);
      expect(manager.settings.retries, 0);
    });
  });

  group('cancellation', () {
    test('cancels a queued task immediately', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(maxConcurrentUploads: 1),
        ),
      );
      executor.pause();

      final first = manager.upload('acc', bytes('1.mp4'));
      final second = manager.upload('acc', bytes('2.mp4'));
      manager.cancel(second);

      expect(second.state, const TransferState.cancelled());
      await expectLater(second.result, throwsA(isA<CancelledException>()));
      executor.resume();
      await first.result;
    });

    test('cancels a running task', () async {
      executor.pause();

      final task = manager.upload('acc', bytes('1.mp4'));
      await until(() => executor.running == 1);
      manager.cancel(task);

      await expectLater(task.result, throwsA(isA<CancelledException>()));
      expect(task.state, const TransferState.cancelled());
      expect(provider.files, isEmpty);
    });

    test('retries a cancelled task', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(maxConcurrentUploads: 1),
        ),
      );
      executor.pause();

      final first = manager.upload('acc', bytes('1.mp4'));
      final second = manager.upload('acc', bytes('2.mp4'));
      manager
        ..cancel(second)
        ..retry(second);

      expect(second.state, isA<TransferQueued>());
      executor.resume();
      await first.result;
      final file = await second.result;
      expect(file.name, '2.mp4');
    });

    test('emits list changes and clears finished tasks', () async {
      final lists = <List<UploadTask>>[];
      final sub = manager.changes.listen(lists.add);

      final task = manager.upload('acc', bytes('a.mp4'));
      await task.result;
      await pumpEventQueue();
      manager.clearFinished();
      await pumpEventQueue();

      expect(lists.first, [task]);
      expect(manager.tasks, isEmpty);
      expect(lists.last, isEmpty);
      await sub.cancel();
    });
  });

  group('retries', () {
    test('retries transient failures until the upload succeeds', () async {
      executor.failNext(2);

      final task = manager.upload('acc', bytes('a.mp4'));
      final file = await task.result;

      expect(file.name, 'a.mp4');
      expect(task.attempt, 3);
      expect(executor.requests, hasLength(3));
      expect(provider.files, hasLength(1));
    });

    test('gives up after the configured retries', () async {
      await recreate(settings: const UploadSettings(retries: 1));
      executor.failNext(5);

      final task = manager.upload('acc', bytes('a.mp4'));

      await expectLater(task.result, throwsA(isA<NetworkException>()));
      expect(task.attempt, 2);
      expect(executor.requests, hasLength(2));
    });

    test('does not retry authentication errors', () async {
      executor.failNext(1, const AuthenticationException('Invalid key'));

      final task = manager.upload('acc', bytes('a.mp4'));

      await expectLater(task.result, throwsA(isA<AuthenticationException>()));
      expect(task.attempt, 1);
      expect(executor.requests, hasLength(1));
    });

    test('does not retry missing files', () async {
      executor.failNext(1, const NotFoundException('No such file'));

      final task = manager.upload('acc', bytes('a.mp4'));

      await expectLater(task.result, throwsA(isA<NotFoundException>()));
      expect(executor.requests, hasLength(1));
    });

    test('a manual retry starts a new budget', () async {
      await recreate(settings: const UploadSettings(retries: 0));
      executor.failNext(1);

      final task = manager.upload('acc', bytes('a.mp4'));
      await expectLater(task.result, throwsA(isA<NetworkException>()));
      expect(task.attempt, 1);

      manager.retry(task);
      await task.result;
      expect(task.attempt, 1);
      expect(executor.requests, hasLength(2));
    });

    test('cancelling stops the wait before a retry', () async {
      await recreate(retryBaseDelay: const Duration(minutes: 1));
      executor.failNext(1);

      final task = manager.upload('acc', bytes('a.mp4'));
      await until(() => executor.requests.length == 1);
      await pumpEventQueue();
      expect(task.state.isFinished, isFalse, reason: 'waiting to retry');
      manager.cancel(task);

      await expectLater(task.result, throwsA(isA<CancelledException>()));
      expect(executor.requests, hasLength(1));
    });

    test('backs off exponentially up to the maximum delay', () {
      final defaults = TransferManager(
        resolveProvider: (_) => provider,
        executor: executor,
      );
      addTearDown(defaults.dispose);
      const error = NetworkException('offline');

      expect(
        [
          for (var retry = 1; retry <= 7; retry++)
            defaults.retryDelay(retry, error),
        ],
        [
          for (final seconds in [1, 2, 4, 8, 16, 30, 30])
            Duration(seconds: seconds),
        ],
      );
    });

    test('waits at least the retryAfter of rate limits', () {
      const later = RateLimitedException(
        'Too many requests',
        retryAfter: Duration(seconds: 45),
      );
      const soon = RateLimitedException(
        'Too many requests',
        retryAfter: Duration(milliseconds: 10),
      );
      final defaults = TransferManager(
        resolveProvider: (_) => provider,
        executor: executor,
      );
      addTearDown(defaults.dispose);

      expect(defaults.retryDelay(1, later), const Duration(seconds: 45));
      expect(defaults.retryDelay(2, soon), const Duration(seconds: 2));
    });

    test('isRetryable only accepts transient errors', () {
      expect(TransferManager.isRetryable(const NetworkException('x')), isTrue);
      expect(
        TransferManager.isRetryable(const RateLimitedException('x')),
        isTrue,
      );
      expect(TransferManager.isRetryable(const ProviderException('x')), isTrue);
      expect(
        TransferManager.isRetryable(
          const ProviderException('x', statusCode: 503),
        ),
        isTrue,
      );
      for (final error in <UpCloudException>[
        const ProviderException('x', statusCode: 400),
        const ProviderException('x', statusCode: -881),
        const AuthenticationException('x'),
        const NotFoundException('x'),
        const QuotaExceededException('x'),
        const CancelledException(),
        const UnsupportedOperationException('x'),
        const UploadRejectedException(
          'x',
          reason: FileTooLarge(size: DataSize(2), maxSize: DataSize(1)),
        ),
      ]) {
        expect(TransferManager.isRetryable(error), isFalse, reason: '$error');
      }
    });
  });

  group('auto clear', () {
    test('removes completed tasks and keeps failed ones', () async {
      await recreate(
        using: InMemoryProvider(
          limits: const ProviderLimits(allowedExtensions: {'mp4'}),
        ),
        settings: const UploadSettings(autoClearAfterSeconds: 0),
      );

      final done = manager.upload('acc', bytes('a.mp4'));
      final failed = manager.upload('acc', bytes('a.exe'));
      await done.result;
      await expectLater(failed.result, throwsA(isA<UploadRejectedException>()));
      await until(() => manager.tasks.length == 1);

      expect(manager.tasks, [failed]);
    });

    test('waits the configured time', () async {
      await recreate(settings: const UploadSettings(autoClearAfterSeconds: 1));

      final task = manager.upload('acc', bytes('a.mp4'));
      await task.result;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(manager.tasks, [task]);
      await until(() => manager.tasks.isEmpty);
    });

    test('keeps completed tasks by default', () async {
      final task = manager.upload('acc', bytes('a.mp4'));
      await task.result;
      await pumpEventQueue();
      expect(manager.tasks, [task]);
    });

    test('applies to completed tasks when enabled later', () async {
      final task = manager.upload('acc', bytes('a.mp4'));
      await task.result;

      manager.updateSettings(
        manager.settings.copyWith(autoClearAfterSeconds: 0),
      );

      await until(() => manager.tasks.isEmpty);
    });
  });

  group('default visibility', () {
    Future<bool?> uploadedVisibility(
      UploadVisibility visibility, {
      bool? isPublic,
    }) async {
      manager.updateSettings(
        manager.settings.copyWith(defaultVisibility: visibility),
      );
      final task = manager.upload(
        'acc',
        bytes('a.mp4'),
        options: UploadOptions(isPublic: isPublic),
      );
      final file = await task.result;
      expect(task.options.isPublic, file.isPublic);
      return file.isPublic;
    }

    test('applies when the options do not set it', () async {
      expect(
        await uploadedVisibility(UploadVisibility.providerDefault),
        isNull,
      );
      expect(await uploadedVisibility(UploadVisibility.public), isTrue);
      expect(await uploadedVisibility(UploadVisibility.private), isFalse);
    });

    test('never overrides the options', () async {
      expect(
        await uploadedVisibility(UploadVisibility.public, isPublic: false),
        isFalse,
      );
      expect(
        await uploadedVisibility(UploadVisibility.private, isPublic: true),
        isTrue,
      );
    });

    test('an explicit visibility replaces the default one', () async {
      manager.updateSettings(
        manager.settings.copyWith(defaultVisibility: UploadVisibility.public),
      );
      bool? isPublicOf(UploadVisibility? visibility, {bool? isPublic}) =>
          manager
              .upload(
                'acc',
                bytes('a.mp4'),
                options: UploadOptions(isPublic: isPublic),
                visibility: visibility,
              )
              .options
              .isPublic;

      // Provider default: nothing is sent, the settings do not apply.
      expect(isPublicOf(UploadVisibility.providerDefault), isNull);
      expect(isPublicOf(UploadVisibility.private), isFalse);
      expect(isPublicOf(null), isTrue);
      // The options still win.
      expect(
        isPublicOf(UploadVisibility.providerDefault, isPublic: true),
        isTrue,
      );

      final batch = manager.uploadBatch(
        files: [bytes('b.mp4')],
        accountIds: ['acc'],
        visibility: UploadVisibility.providerDefault,
      );
      expect(batch.tasks.single.options.isPublic, isNull);
      final file = await batch.tasks.single.result;
      expect(file.isPublic, isNull);
    });
  });

  group('folder paths', () {
    test('uploads into a folder found or created by path', () async {
      final movies = await provider.createFolder('Movies');

      final task = manager.upload(
        'acc',
        bytes('a.mp4'),
        folderPath: ' movies / 2026 ',
      );
      final file = await task.result;

      expect(task.folderPath, 'movies/2026');
      final year = provider.folders.singleWhere((f) => f.name == '2026');
      expect(year.parentId, movies.id);
      expect(file.folderId, year.id);
    });

    test('an empty path is the root and overrides the folder id', () async {
      final folder = await provider.createFolder('Other');

      final task = manager.upload(
        'acc',
        bytes('a.mp4'),
        options: UploadOptions(folderId: folder.id),
        folderPath: '',
      );

      expect((await task.result).folderId, isNull);
    });

    test('finds the folder again after it was deleted', () async {
      await manager.upload('acc', bytes('a.mp4'), folderPath: 'A').result;
      final stale = provider.folders.single;
      await provider.deleteFile(provider.files.single.id);
      await provider.deleteFolder(stale.id);

      final task = manager.upload('acc', bytes('b.mp4'), folderPath: 'A');
      await expectLater(task.result, throwsA(isA<NotFoundException>()));

      manager.retry(task);
      final file = await task.result;
      final fresh = provider.folders.single;
      expect(fresh.id, isNot(stale.id));
      expect(file.folderId, fresh.id);
    });
  });

  group('batches', () {
    test('creates one task per file and account', () async {
      final other = InMemoryProvider();
      final batchManager = TransferManager(
        resolveProvider: (id) => id == 'acc' ? provider : other,
        executor: executor,
      );
      addTearDown(batchManager.dispose);

      final batch = batchManager.uploadBatch(
        files: [bytes('1.mp4'), bytes('2.mp4')],
        accountIds: ['acc', 'other', 'acc'],
        folderPath: 'Movies/2026',
      );

      expect(batch.tasks.map((t) => '${t.name}@${t.accountId}'), [
        '1.mp4@acc',
        '1.mp4@other',
        '2.mp4@acc',
        '2.mp4@other',
      ]);
      expect(batch.tasks.map((t) => t.batchId).toSet(), {batch.id});
      expect(batch.tasks.map((t) => t.folderPath).toSet(), {'Movies/2026'});
      expect(batch.folderPath, 'Movies/2026');
      expect(batchManager.tasks, batch.tasks);

      final files = await batch.results;
      expect(files, hasLength(4));
      for (final account in [provider, other]) {
        expect(account.folders.map((f) => f.name), ['Movies', '2026']);
        expect(account.files, hasLength(2));
      }
    });

    test('leaves out the pairs to skip', () async {
      final other = InMemoryProvider();
      final batchManager = TransferManager(
        resolveProvider: (id) => id == 'acc' ? provider : other,
        executor: executor,
      );
      addTearDown(batchManager.dispose);
      final a = bytes('a.mp4');
      final b = bytes('b.txt');
      final seen = <String>[];

      final batch = batchManager.uploadBatch(
        files: [a, b],
        accountIds: ['acc', 'other'],
        folderPath: 'Docs',
        skip: (file, accountId) {
          seen.add('${file.name}@$accountId');
          return file == b && accountId == 'acc';
        },
      );

      expect(seen, ['a.mp4@acc', 'a.mp4@other', 'b.txt@acc', 'b.txt@other']);
      expect(batch.tasks.map((t) => '${t.name}@${t.accountId}'), [
        'a.mp4@acc',
        'a.mp4@other',
        'b.txt@other',
      ]);
      expect(batchManager.tasks, batch.tasks);
      await batch.results;
      expect(provider.files.map((f) => f.name), ['a.mp4']);
      expect(other.files.map((f) => f.name), ['a.mp4', 'b.txt']);
      // Only the queued uploads were sent.
      expect(executor.requests, hasLength(3));

      // Skipping everything queues nothing.
      final none = batchManager.uploadBatch(
        files: [a],
        accountIds: ['acc'],
        skip: (_, _) => true,
      );
      expect(none.tasks, isEmpty);
      expect(none.isFinished, isTrue);
    });

    test('uses the default folder path', () async {
      final folder = await provider.createFolder('Default');
      manager.updateSettings(
        manager.settings.copyWith(defaultFolderPath: 'Default'),
      );

      final byDefault = manager.uploadBatch(
        files: [bytes('a.mp4')],
        accountIds: ['acc'],
      );
      final root = manager.uploadBatch(
        files: [bytes('b.mp4')],
        accountIds: ['acc'],
        folderPath: '',
      );
      final byId = manager.uploadBatch(
        files: [bytes('c.mp4')],
        accountIds: ['acc'],
        options: UploadOptions(folderId: folder.id),
      );

      expect(byDefault.folderPath, 'Default');
      expect(root.folderPath, '');
      expect(byId.folderPath, isNull);
      await Future.wait([byDefault.results, root.results, byId.results]);
      expect(provider.folders, [folder]);
      expect(
        {for (final f in provider.files) f.name: f.folderId},
        {'a.mp4': folder.id, 'b.mp4': null, 'c.mp4': folder.id},
      );
    });
  });
}

/// A provider that can only list folders.
final class _BrowseOnlyProvider implements FolderBrowsing {
  @override
  ProviderInfo get info => const ProviderInfo(id: 'browse', name: 'Browse');

  @override
  ProviderLimits get limits => ProviderLimits.none;

  @override
  Set<Capability> get capabilities => interfaceCapabilities(this);

  @override
  void close() {}

  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) async => PagedResult(items: const [], request: page);
}
