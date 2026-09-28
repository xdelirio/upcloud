import 'dart:convert';

import 'package:test/test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  late UpCloud upcloud;
  late InMemoryAccountStore store;
  late InMemoryKeyValueStore settingsStore;
  late FakeUploadExecutor executor;

  /// In-memory accounts without latency, one per API key.
  final memories = <String, InMemoryProvider>{};
  final fast = ProviderDefinition(
    info: const ProviderInfo(id: 'fast', name: 'Fast'),
    credentialSchema: CredentialSchema.apiKey(),
    capabilities: memoryDriver.capabilities,
    factory: (definition, credentials, options) => memories.putIfAbsent(
      credentials.apiKey,
      () => InMemoryProvider(
        info: definition.info,
        limits: definition.limitsFor(options),
      ),
    ),
  );

  UpCloud create({AccountStore? accounts, KeyValueStore? settings}) => UpCloud(
    uploadExecutor: executor,
    registry: ProviderRegistry(useRemote: false),
    providers: [inMemoryDemo, fast],
    store: accounts ?? store,
    settingsStore: settings ?? settingsStore,
  );

  Future<CloudAccount> addFast(String key) => upcloud.addAccount(
    providerId: 'fast',
    credentials: Credentials.apiKey(key),
    verify: false,
  );

  UploadSource video(String name, [int length = 10]) =>
      UploadSource.bytes(List.filled(length, 0), name: name);

  setUp(() async {
    memories.clear();
    store = InMemoryAccountStore();
    settingsStore = InMemoryKeyValueStore();
    executor = FakeUploadExecutor();
    upcloud = create();
    await upcloud.init();
  });

  tearDown(() => upcloud.dispose());

  group('dispose', () {
    Future<bool> registryClosedBy({bool? disposeRegistry}) async {
      final registry = ProviderRegistry(useRemote: false);
      var closed = false;
      registry.changes.listen(null, onDone: () => closed = true);
      final instance = disposeRegistry == null
          ? UpCloud(uploadExecutor: executor, registry: registry)
          : UpCloud(
              uploadExecutor: executor,
              registry: registry,
              disposeRegistry: disposeRegistry,
            );
      await instance.dispose();
      await Future<void>.delayed(Duration.zero);
      final result = closed;
      if (!result) await registry.dispose();
      return result;
    }

    test('leaves a given registry open by default', () async {
      expect(await registryClosedBy(), isFalse);
      expect(await registryClosedBy(disposeRegistry: false), isFalse);
    });

    test('disposes a given registry when asked', () async {
      expect(await registryClosedBy(disposeRegistry: true), isTrue);
    });
  });

  test('lists code providers first, then registry providers', () {
    final ids = upcloud.providers.map((p) => p.id).toList();
    expect(ids.take(2), ['demo', 'fast']);
    expect(ids, containsAll(['streamhg', 'earnvids', 'byse', 'mediafire']));
    expect(upcloud.provider('demo'), inMemoryDemo);
    expect(upcloud.provider('streamhg')?.info.driver, 'xvs');
    expect(upcloud.provider('nope'), isNull);
  });

  test('reconnects accounts when their registry entry changes', () async {
    final account = await upcloud.addAccount(
      providerId: 'streamhg',
      credentials: Credentials.apiKey('key'),
      verify: false,
    );
    final before = upcloud.connect(account.id);
    expect(upcloud.connect(account.id), same(before));

    final changes = upcloud.providerChanges.first;
    final config = upcloud.registry.config('streamhg')!;
    await upcloud.registry.save(
      config.copyWith(apiBase: Uri.parse('https://new-domain.test/api')),
    );
    await changes;

    final after = upcloud.connect(account.id);
    expect(after, isNot(same(before)));
    expect(
      upcloud.provider('streamhg')?.defaultBaseUrl,
      Uri.parse('https://new-domain.test/api'),
    );
  });

  test('disabled registry providers are not available', () async {
    await upcloud.registry.setEnabled('byse', enabled: false);
    expect(upcloud.provider('byse'), isNull);
    expect(upcloud.providers.map((p) => p.id), isNot(contains('byse')));
    await expectLater(
      upcloud.addAccount(
        providerId: 'byse',
        credentials: Credentials.apiKey('k'),
        verify: false,
      ),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('adds, persists and removes accounts', () async {
    final changes = <List<CloudAccount>>[];
    upcloud.accountChanges.listen(changes.add);

    final account = await upcloud.addAccount(
      providerId: 'demo',
      credentials: Credentials.apiKey('key'),
    );

    expect(account.label, 'Demo (in memory) · demo');
    expect(upcloud.accounts, [account]);
    expect(await store.load(), [account]);

    await upcloud.removeAccount(account.id);
    expect(upcloud.accounts, isEmpty);
    expect(await store.load(), isEmpty);
    await Future<void>.delayed(Duration.zero);
    expect(changes.map((c) => c.length), [1, 0]);
  });

  test('restores accounts from the store on init', () async {
    final saved = CloudAccount(
      id: 'saved',
      providerId: 'demo',
      label: 'Saved',
      credentials: Credentials.apiKey('k'),
    );
    final other = create(accounts: InMemoryAccountStore([saved]));
    await other.init();
    expect(other.accounts, [saved]);
    expect(other.connect('saved'), isA<FolderBrowsing>());
    await other.dispose();
  });

  test('rejects missing credentials and unknown providers', () async {
    await expectLater(
      upcloud.addAccount(
        providerId: 'demo',
        credentials: const Credentials({}),
      ),
      throwsA(isA<AuthenticationException>()),
    );
    await expectLater(
      upcloud.addAccount(
        providerId: 'nope',
        credentials: Credentials.apiKey('k'),
      ),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('caches connections and drops them on update', () async {
    final account = await upcloud.addAccount(
      providerId: 'demo',
      credentials: Credentials.apiKey('key'),
      label: 'Mine',
      verify: false,
    );
    final first = upcloud.connect(account.id);
    expect(upcloud.connect(account.id), same(first));

    await upcloud.updateAccount(account.copyWith(label: 'Renamed'));
    expect(upcloud.connect(account.id), isNot(same(first)));
    expect(upcloud.account(account.id)?.label, 'Renamed');
  });

  test('applies the per account max file size override', () async {
    final account = await upcloud.addAccount(
      providerId: 'demo',
      credentials: Credentials.apiKey('key'),
      verify: false,
    );
    await upcloud.updateAccount(account.copyWith(maxFileSizeBytes: 10));
    final provider = upcloud.connect(account.id);
    expect(provider.limits.maxFileSize, const DataSize(10));

    final task = upcloud.upload(
      account.id,
      UploadSource.bytes(List.filled(11, 0), name: 'a.mp4'),
    );
    await expectLater(task.result, throwsA(isA<UploadRejectedException>()));
  });

  test('uploads to several accounts at once', () async {
    final a = await addFast('a');
    final b = await addFast('b');

    final tasks = upcloud.uploadToMany([a.id, b.id], video('m.mp4'));
    final files = await Future.wait(tasks.map((t) => t.result));

    expect(files.map((f) => f.name), ['m.mp4', 'm.mp4']);
    expect(tasks.map((t) => t.batchId).toSet(), hasLength(1));
  });

  test('removing an account cancels its transfers', () async {
    final account = await upcloud.addAccount(
      providerId: 'demo',
      credentials: Credentials.apiKey('a'),
      verify: false,
    );
    executor.pause();
    final task = upcloud.upload(account.id, video('big.mp4'));
    await upcloud.removeAccount(account.id);
    await expectLater(task.result, throwsA(isA<CancelledException>()));
    expect(upcloud.transfers.tasks, isEmpty);
  });

  group('batch uploads', () {
    test('uploads every file to every account in a folder path', () async {
      final a = await addFast('a');
      final b = await addFast('b');
      final memory = upcloud.connect(a.id) as InMemoryProvider;
      final existing = await memory.createFolder('Movies');

      final batch = upcloud.uploadBatch(
        files: [video('1.mp4'), video('2.mp4'), video('3.mp4')],
        accountIds: [a.id, b.id],
        folderPath: 'movies/2026',
      );
      final files = await batch.results;

      expect(files, hasLength(6));
      expect(batch.completedCount, 6);
      expect(batch.isFinished, isTrue);
      expect(batch.progress, 1);
      expect(batch.transferredBytes, 60);
      expect(batch.totalBytes, 60);
      expect(batch.failures, isEmpty);
      // Account a reuses its "Movies" folder, account b gets a new one.
      expect(
        [for (final f in memories['a']!.folders) f.name],
        ['Movies', '2026'],
      );
      expect(
        [for (final f in memories['b']!.folders) f.name],
        ['movies', '2026'],
      );
      for (final memory in memories.values) {
        final year = memory.folders.last;
        expect(year.parentId, memory.folders.first.id);
        expect(memory.files.map((f) => f.folderId).toSet(), {year.id});
      }
      expect(memories['a']!.folders.first, existing);
    });

    test('collects failures without failing the results', () async {
      final ok = await addFast('ok');
      final small = await addFast('small');
      await upcloud.updateAccount(small.copyWith(maxFileSizeBytes: 5));
      memories.remove('small');

      final batch = upcloud.uploadBatch(
        files: [video('1.mp4'), video('2.mp4')],
        accountIds: [ok.id, small.id],
      );
      final changes = <UploadBatch>[];
      final sub = batch.changes.listen(changes.add);
      final files = await batch.results;
      await sub.cancel();

      expect(files, hasLength(2));
      expect(batch.completedCount, 2);
      expect(batch.failedCount, 2);
      expect(batch.cancelledCount, 0);
      expect(batch.finishedCount, 4);
      expect(batch.progress, 1);
      expect(
        batch.failures.map((f) => (f.task.accountId, f.error.runtimeType)),
        everyElement((small.id, UploadRejectedException)),
      );
      expect(changes, isNotEmpty);
      expect(changes.every((c) => identical(c, batch)), isTrue);
    });

    test('reports the overall progress', () async {
      final a = await addFast('a');
      executor.pause();

      final batch = upcloud.uploadBatch(
        files: [video('1.mp4', 30), video('2.mp4')],
        accountIds: [a.id],
      );
      await batch.changes.firstWhere(
        (b) => b.tasks.every((t) => t.totalBytes != null),
      );
      expect(batch.progress, 0);
      expect(batch.totalBytes, 40);

      executor.resume();
      await batch.results;
      expect(batch.progress, 1);
    });

    test('uses the default folder path of the settings', () async {
      final a = await addFast('a');
      await upcloud.updateSettings(
        const UploadSettings(defaultFolderPath: 'Uploads'),
      );

      final batch = upcloud.uploadBatch(
        files: [video('1.mp4')],
        accountIds: [a.id],
      );
      await batch.results;

      expect(batch.folderPath, 'Uploads');
      expect(memories['a']!.folders.single.name, 'Uploads');
    });

    test('skips pairs and applies an explicit visibility', () async {
      final a = await addFast('a');
      final b = await addFast('b');
      await upcloud.updateSettings(
        upcloud.settings.copyWith(defaultVisibility: UploadVisibility.private),
      );

      final batch = upcloud.uploadBatch(
        files: [video('x.mp4'), video('y.mp4')],
        accountIds: [a.id, b.id],
        folderPath: 'Only/B',
        visibility: UploadVisibility.public,
        skip: (file, accountId) => accountId == a.id,
      );

      expect(batch.tasks.map((t) => t.accountId).toSet(), {b.id});
      expect(batch.tasks.every((t) => t.options.isPublic ?? false), isTrue);
      await batch.results;
      // Account a was never even connected (no folder lookup, no storage
      // check).
      expect(memories.containsKey('a'), isFalse);
      expect(memories['b']!.files.map((f) => f.isPublic), [true, true]);
      expect(upcloud.recentFolderPaths, ['Only/B']);

      // Nothing queued: the path is not remembered.
      upcloud.uploadBatch(
        files: [video('z.mp4')],
        accountIds: [a.id],
        folderPath: 'Never',
        skip: (_, _) => true,
      );
      expect(upcloud.recentFolderPaths, ['Only/B']);

      final single = upcloud.upload(
        a.id,
        video('w.mp4'),
        visibility: UploadVisibility.providerDefault,
      );
      expect(single.options.isPublic, isNull);
      final many = upcloud.uploadToMany(
        [a.id, b.id],
        video('v.mp4'),
        visibility: UploadVisibility.public,
      );
      expect(many.map((t) => t.options.isPublic), [true, true]);
    });

    test('an empty batch finishes immediately', () async {
      final batch = upcloud.uploadBatch(files: const [], accountIds: const []);
      expect(await batch.results, isEmpty);
      expect(batch.isFinished, isTrue);
      expect(batch.progress, 1);
    });
  });

  group('folder paths', () {
    test('resolveFolderPath finds and creates folders', () async {
      final a = await addFast('a');

      await expectLater(
        upcloud.resolveFolderPath(a.id, 'Movies/2026', create: false),
        throwsA(isA<NotFoundException>()),
      );
      final id = await upcloud.resolveFolderPath(a.id, 'Movies/2026');
      expect(await upcloud.resolveFolderPath(a.id, 'MOVIES/2026'), id);
      expect(await upcloud.resolveFolderPath(a.id, ''), isNull);
      expect(memories['a']!.folders.last.id, id);
    });

    test('remembers recently used paths', () async {
      final a = await addFast('a');
      final tasks = [
        upcloud.upload(a.id, video('1.mp4'), folderPath: 'A'),
        upcloud
            .uploadBatch(
              files: [video('2.mp4')],
              accountIds: [a.id],
              folderPath: ' B/C ',
            )
            .tasks
            .single,
        upcloud.upload(a.id, video('3.mp4'), folderPath: 'a'),
        upcloud.upload(a.id, video('4.mp4')),
        upcloud.upload(a.id, video('5.mp4'), folderPath: ''),
      ];
      await Future.wait(tasks.map((t) => t.result));

      expect(upcloud.recentFolderPaths, ['a', 'B/C']);
      expect(jsonDecode(settingsStore.values[UpCloud.recentFolderPathsKey]!), [
        'a',
        'B/C',
      ]);

      for (var i = 0; i < 12; i++) {
        upcloud.upload(a.id, video('$i.mp4'), folderPath: 'P$i');
      }
      expect(
        upcloud.recentFolderPaths,
        hasLength(UpCloud.maxRecentFolderPaths),
      );
      expect(upcloud.recentFolderPaths.first, 'P11');

      final restored = create();
      await restored.init();
      expect(restored.recentFolderPaths, upcloud.recentFolderPaths);
      await restored.dispose();
    });
  });

  group('settings', () {
    test('are saved and restored on init', () async {
      const settings = UploadSettings(
        maxConcurrentUploads: 5,
        retries: 4,
        checkStorage: false,
        autoClearAfterSeconds: 60,
        defaultFolderPath: 'Movies',
        defaultVisibility: UploadVisibility.private,
      );
      final changes = upcloud.settingsChanges.first;

      await upcloud.updateSettings(settings);

      expect(await changes, settings);
      expect(upcloud.settings, settings);
      expect(upcloud.transfers.settings, settings);
      expect(settingsStore.values, contains(UpCloud.settingsKey));

      final restored = create();
      expect(restored.settings, const UploadSettings());
      await restored.init();
      expect(restored.settings, settings);
      await restored.dispose();
    });

    test('are normalized before being applied', () async {
      await upcloud.updateSettings(
        const UploadSettings(maxConcurrentUploads: 99, defaultFolderPath: '/'),
      );

      expect(upcloud.settings.maxConcurrentUploads, 10);
      expect(upcloud.settings.defaultFolderPath, isNull);
    });

    test('invalid saved values fall back to the defaults', () async {
      final broken = create(
        settings: InMemoryKeyValueStore({
          UpCloud.settingsKey: '{"maxConcurrentUploads": "many"',
          UpCloud.recentFolderPathsKey: '{"not": "a list"}',
        }),
      );
      await broken.init();

      expect(broken.settings, const UploadSettings());
      expect(broken.recentFolderPaths, isEmpty);
      await broken.dispose();
    });

    test('apply to the uploads right away', () async {
      final a = await addFast('a');
      await upcloud.updateSettings(
        const UploadSettings(defaultVisibility: UploadVisibility.public),
      );

      final file = await upcloud.upload(a.id, video('1.mp4')).result;

      expect(file.isPublic, isTrue);
    });
  });
}
