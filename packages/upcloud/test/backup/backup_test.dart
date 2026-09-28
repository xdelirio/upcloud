import 'dart:convert';

import 'package:test/test.dart';
import 'package:upcloud/src/backup/backup_envelope.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud/upcloud.dart';

/// Cheap key derivation so tests run fast (production uses
/// [Argon2idParams.recommended]).
const cheapKdf = Argon2idParams(memoryKiB: 64, iterations: 1);

const password = 'correct horse';

void main() {
  late FakeUploadExecutor executor;

  /// A provider written in code whose accounts never touch the network.
  final fast = ProviderDefinition(
    info: const ProviderInfo(id: 'fast', name: 'Fast'),
    credentialSchema: CredentialSchema.apiKey(),
    capabilities: memoryDriver.capabilities,
    factory: (definition, credentials, options) => InMemoryProvider(
      info: definition.info,
      limits: definition.limitsFor(options),
    ),
  );

  final instances = <UpCloud>[];

  Future<UpCloud> create({
    AccountStore? accounts,
    KeyValueStore? settings,
    Argon2idParams kdf = cheapKdf,
  }) async {
    final upcloud = UpCloud(
      uploadExecutor: executor,
      registry: ProviderRegistry(useRemote: false),
      disposeRegistry: true,
      providers: [fast],
      store: accounts,
      settingsStore: settings,
      backupKdf: kdf,
    );
    instances.add(upcloud);
    await upcloud.init(refreshRegistry: false);
    return upcloud;
  }

  CloudAccount account(String id, {String? label, String key = 'key'}) =>
      CloudAccount(
        id: id,
        providerId: 'fast',
        label: label ?? id,
        credentials: Credentials.apiKey(key),
      );

  Map<String, Object?> decode(String json) =>
      jsonDecode(json) as Map<String, Object?>;

  String edit(String json, void Function(Map<String, Object?> envelope) f) {
    final envelope = decode(json);
    f(envelope);
    return jsonEncode(envelope);
  }

  setUp(() => executor = FakeUploadExecutor());

  tearDown(() async {
    for (final upcloud in instances) {
      await upcloud.dispose();
    }
    instances.clear();
  });

  group('export', () {
    test('writes a readable envelope with an encrypted payload', () async {
      final upcloud = await create(
        accounts: InMemoryAccountStore([account('a', key: 'SECRET-KEY')]),
      );
      final json = await upcloud.exportBackup(password: password);
      final envelope = decode(json);

      expect(envelope['format'], 'upcloud-backup');
      expect(envelope['version'], 1);
      expect(envelope['encrypted'], isTrue);
      expect(DateTime.parse(envelope['createdAt']! as String).isUtc, isTrue);
      final kdf = envelope['kdf']! as Map<String, Object?>;
      expect(kdf['algorithm'], 'argon2id');
      expect(kdf['memoryKiB'], 64);
      expect(kdf['iterations'], 1);
      expect(kdf['parallelism'], 1);
      expect(base64.decode(kdf['salt']! as String), hasLength(16));
      final cipher = envelope['cipher']! as Map<String, Object?>;
      expect(cipher['algorithm'], 'aes-256-gcm');
      expect(base64.decode(cipher['nonce']! as String), hasLength(12));
      final data = base64.decode(envelope['data']! as String);
      expect(data.length, greaterThan(16));
      // Secrets never appear in clear.
      expect(json, isNot(contains('SECRET-KEY')));
      expect(json, isNot(contains('"accounts"')));
    });

    test('uses a new salt and nonce every time', () async {
      final upcloud = await create();
      final a = decode(await upcloud.exportBackup(password: password));
      final b = decode(await upcloud.exportBackup(password: password));
      expect((a['kdf']! as Map)['salt'], isNot((b['kdf']! as Map)['salt']));
      expect(
        (a['cipher']! as Map)['nonce'],
        isNot((b['cipher']! as Map)['nonce']),
      );
      expect(a['data'], isNot(b['data']));
    });

    test('uses the OWASP minimum by default, off the main isolate', () async {
      final upcloud = UpCloud(uploadExecutor: executor);
      instances.add(upcloud);
      await upcloud.init(refreshRegistry: false);
      expect(upcloud.backupKdf, Argon2idParams.recommended);
      const recommended = Argon2idParams.recommended;
      expect(recommended.memoryKiB, 19456);
      expect(recommended.iterations, 2);
      expect(recommended.parallelism, 1);

      final json = await upcloud.exportBackup(password: password);
      final kdf = decode(json)['kdf']! as Map<String, Object?>;
      expect(kdf['memoryKiB'], 19456);
      expect(kdf['iterations'], 2);
      expect(kdf['parallelism'], 1);
      final result = await upcloud.importBackup(json, password: password);
      expect(result.settingsApplied, isTrue);
    });

    test('requires a password of at least 8 characters', () async {
      final upcloud = await create();
      expect(UpCloud.minBackupPasswordLength, 8);
      await expectLater(
        upcloud.exportBackup(password: 'short'),
        throwsA(
          isA<WeakBackupPasswordException>()
              .having((e) => e.minLength, 'minLength', 8)
              .having((e) => e.message, 'message', isNot(contains('short'))),
        ),
      );
      // Characters, not UTF-16 code units: 7 emoji are 14 code units.
      await expectLater(
        upcloud.exportBackup(password: '🔑' * 7),
        throwsA(isA<WeakBackupPasswordException>()),
      );
      expect(await upcloud.exportBackup(password: '🔑' * 8), isNotEmpty);
    });

    test('rejects extra data that is not JSON', () async {
      final upcloud = await create();
      await expectLater(
        upcloud.exportBackup(
          password: password,
          extra: {'when': DateTime(2026)},
        ),
        throwsArgumentError,
      );
      await expectLater(
        upcloud.exportBackup(password: password, extra: {'n': double.nan}),
        throwsArgumentError,
      );
    });

    test('needs init first', () async {
      final upcloud = UpCloud(uploadExecutor: executor, backupKdf: cheapKdf);
      instances.add(upcloud);
      await expectLater(
        upcloud.exportBackup(password: password),
        throwsStateError,
      );
      await expectLater(
        upcloud.importBackup('{}', password: password),
        throwsStateError,
      );
    });

    test('rejects invalid key derivation parameters', () {
      expect(
        () => UpCloud(
          uploadExecutor: executor,
          backupKdf: const Argon2idParams(memoryKiB: 4, iterations: 1),
        ),
        throwsArgumentError,
      );
      expect(
        const Argon2idParams(memoryKiB: 262145, iterations: 1).isValid,
        isFalse,
      );
      expect(
        const Argon2idParams(memoryKiB: 64, iterations: 33).isValid,
        isFalse,
      );
      expect(
        const Argon2idParams(
          memoryKiB: 64,
          iterations: 1,
          parallelism: 17,
        ).isValid,
        isFalse,
      );
    });
  });

  group('inspect', () {
    test('reads the envelope without the password', () async {
      final upcloud = await create();
      final before = DateTime.now().toUtc().subtract(
        const Duration(seconds: 1),
      );
      final info = UpCloud.inspectBackup(
        await upcloud.exportBackup(password: password),
      );
      expect(info.version, 1);
      expect(info.kdf, cheapKdf);
      expect(info.createdAt!.isAfter(before), isTrue);
    });

    test('tells why a file cannot be read', () {
      Matcher reason(InvalidBackupReason reason) => throwsA(
        isA<InvalidBackupException>().having((e) => e.reason, 'reason', reason),
      );
      expect(
        () => UpCloud.inspectBackup('not json'),
        reason(InvalidBackupReason.notABackup),
      );
      expect(
        () => UpCloud.inspectBackup('{"schemaVersion":1,"providers":[]}'),
        reason(InvalidBackupReason.notABackup),
      );
      expect(
        () => UpCloud.inspectBackup('[1, 2]'),
        reason(InvalidBackupReason.notABackup),
      );
    });
  });

  group('import', () {
    test('restores everything in another instance', () async {
      final source = await create(
        accounts: InMemoryAccountStore([
          account('a', key: 'key-a'),
          CloudAccount(
            id: 'mf',
            providerId: 'mediafire',
            label: 'MediaFire',
            credentials: const Credentials({
              'email': 'me@example.com',
              'password': 'hunter22',
              'application_id': '42',
            }),
            baseUrl: Uri.parse('https://mirror.test/api'),
            maxFileSizeBytes: 1024,
            createdAt: DateTime.utc(2026, 9),
          ),
        ]),
      );
      await source.registry.save(
        ProviderConfig(
          id: 'myhost',
          name: 'MyHost',
          driver: 'xvs',
          apiBase: Uri.parse('https://myhost.test/api'),
        ),
      );
      await source.registry.setEnabled('byse', enabled: false);
      await source.updateSettings(
        const UploadSettings(
          maxConcurrentUploads: 5,
          retries: 0,
          defaultFolderPath: 'Movies/2026',
          defaultVisibility: UploadVisibility.private,
        ),
      );
      final upload = source.upload(
        'a',
        const UploadSource.bytes([1, 2, 3], name: 'a.mp4'),
        folderPath: 'Movies/2026',
      );
      await upload.result;
      expect(source.recentFolderPaths, ['Movies/2026']);

      final json = await source.exportBackup(
        password: password,
        extra: {
          'themeMode': 'dark',
          'nested': {
            'list': [1, 2.5, true, null],
          },
        },
      );

      final store = InMemoryAccountStore();
      final settingsStore = InMemoryKeyValueStore();
      final target = await create(accounts: store, settings: settingsStore);
      final result = await target.importBackup(json, password: password);

      expect(result.mode, BackupImportMode.merge);
      expect(result.accountsAdded, 2);
      expect(result.accountsUpdated, 0);
      expect(result.accountsRemoved, 0);
      expect(result.providersImported, 2);
      expect(result.providersSkipped, 0);
      expect(result.settingsApplied, isTrue);
      expect(result.createdAt, isNotNull);
      expect(result.extra, {
        'themeMode': 'dark',
        'nested': {
          'list': [1, 2.5, true, null],
        },
      });

      expect(target.accounts, source.accounts);
      expect(await store.load(), source.accounts);
      expect(target.registry.definition('myhost'), isNotNull);
      expect(target.provider('byse'), isNull);
      expect(target.settings, source.settings);
      expect(target.transfers.settings.maxConcurrentUploads, 5);
      expect(
        settingsStore.values[UpCloud.settingsKey],
        contains('"retries":0'),
      );
      expect(target.recentFolderPaths, ['Movies/2026']);
      expect(
        settingsStore.values[UpCloud.recentFolderPathsKey],
        '["Movies/2026"]',
      );
      // Restored accounts work.
      expect(target.connect('a'), isA<FolderBrowsing>());
    });

    test('a wrong password changes nothing', () async {
      final source = await create(
        accounts: InMemoryAccountStore([account('a')]),
      );
      final json = await source.exportBackup(password: password);
      final target = await create();

      await expectLater(
        target.importBackup(json, password: 'wrong password'),
        throwsA(
          isA<WrongBackupPasswordException>().having(
            (e) => e.message,
            'message',
            isNot(contains('wrong password')),
          ),
        ),
      );
      expect(target.accounts, isEmpty);
    });

    test('detects a modified payload', () async {
      final json = await (await create()).exportBackup(password: password);
      final tampered = edit(json, (envelope) {
        final data = base64.decode(envelope['data']! as String);
        data[0] ^= 1;
        envelope['data'] = base64.encode(data);
      });
      final target = await create();
      await expectLater(
        target.importBackup(tampered, password: password),
        throwsA(isA<WrongBackupPasswordException>()),
      );
    });

    test('detects a modified header', () async {
      final json = await (await create()).exportBackup(password: password);
      final target = await create();
      final edits = <void Function(Map<String, Object?>)>[
        (e) => e['createdAt'] = '2020-01-01T00:00:00.000Z',
        (e) => (e['kdf']! as Map)['iterations'] = 2,
        (e) => (e['kdf']! as Map)['memoryKiB'] = 128,
        (e) => (e['kdf']! as Map)['salt'] = base64.encode(List.filled(16, 7)),
        (e) =>
            (e['cipher']! as Map)['nonce'] = base64.encode(List.filled(12, 7)),
      ];
      for (final change in edits) {
        await expectLater(
          target.importBackup(edit(json, change), password: password),
          throwsA(isA<WrongBackupPasswordException>()),
        );
      }
      // Fields outside the header are ignored.
      final extraField = edit(json, (e) => e['comment'] = 'hello');
      final result = await target.importBackup(extraField, password: password);
      expect(result.settingsApplied, isTrue);
    });

    test('rejects newer versions and unknown algorithms', () async {
      final json = await (await create()).exportBackup(password: password);
      final target = await create();
      Future<void> expectReason(String file, InvalidBackupReason reason) =>
          expectLater(
            target.importBackup(file, password: password),
            throwsA(
              isA<InvalidBackupException>().having(
                (e) => e.reason,
                'reason',
                reason,
              ),
            ),
          );

      await expectReason(
        edit(json, (e) => e['version'] = 2),
        InvalidBackupReason.unsupported,
      );
      expect(
        () => UpCloud.inspectBackup(edit(json, (e) => e['version'] = 2)),
        throwsA(isA<InvalidBackupException>()),
      );
      await expectReason(
        edit(json, (e) => (e['kdf']! as Map)['algorithm'] = 'scrypt'),
        InvalidBackupReason.unsupported,
      );
      await expectReason(
        edit(json, (e) => (e['cipher']! as Map)['algorithm'] = 'aes-128-cbc'),
        InvalidBackupReason.unsupported,
      );
      // A crafted file cannot make the app allocate gigabytes.
      await expectReason(
        edit(json, (e) => (e['kdf']! as Map)['memoryKiB'] = 4 * 1024 * 1024),
        InvalidBackupReason.unsupported,
      );
      await expectReason(
        edit(json, (e) => e['format'] = 'other'),
        InvalidBackupReason.notABackup,
      );
      await expectReason(
        edit(json, (e) => e['encrypted'] = false),
        InvalidBackupReason.corrupted,
      );
      await expectReason(
        edit(json, (e) => (e['cipher']! as Map).remove('nonce')),
        InvalidBackupReason.corrupted,
      );
      await expectReason(
        edit(json, (e) => e['data'] = base64.encode([1, 2, 3])),
        InvalidBackupReason.corrupted,
      );
      await expectReason(
        edit(json, (e) => e['data'] = '*not base64*'),
        InvalidBackupReason.corrupted,
      );
      await expectReason(
        edit(json, (e) => e['version'] = '1'),
        InvalidBackupReason.corrupted,
      );
    });

    test('rejects newer or malformed content', () async {
      final target = await create();
      Future<String> seal(Map<String, Object?> payload) =>
          sealBackup(payload, password: password, kdf: cheapKdf);

      await expectLater(
        target.importBackup(await seal({'version': 2}), password: password),
        throwsA(
          isA<InvalidBackupException>().having(
            (e) => e.reason,
            'reason',
            InvalidBackupReason.unsupported,
          ),
        ),
      );
      await expectLater(
        target.importBackup(
          await seal({
            'version': 1,
            'accounts': [
              {'id': 'x', 'credentials': 'SECRET'},
            ],
          }),
          password: password,
        ),
        throwsA(
          isA<InvalidBackupException>()
              .having((e) => e.reason, 'reason', InvalidBackupReason.corrupted)
              .having((e) => '$e', 'text', isNot(contains('SECRET'))),
        ),
      );
      expect(target.accounts, isEmpty);
    });

    test('skips providers whose driver is unknown', () async {
      final target = await create();
      final json = await sealBackup(
        {
          'version': 1,
          'providers': {
            'schemaVersion': 1,
            'providers': [
              {'id': 'future', 'name': 'Future', 'driver': 'from-the-future'},
              {
                'id': 'mine',
                'name': 'Mine',
                'driver': 'xvs',
                'apiBase': 'https://mine.test/api',
              },
            ],
          },
        },
        password: password,
        kdf: cheapKdf,
      );
      final result = await target.importBackup(json, password: password);
      expect(result.providersImported, 1);
      expect(result.providersSkipped, 1);
      expect(result.settingsApplied, isFalse);
      expect(result.extra, isEmpty);
      expect(target.registry.definition('mine'), isNotNull);
    });
  });

  group('merge and replace', () {
    late UpCloud target;
    late InMemoryAccountStore store;
    late InMemoryKeyValueStore settingsStore;
    late String backup;

    setUp(() async {
      // The backup: account a renamed with a new key, a new account c, the
      // same account d, streamhg moved to a new domain, a custom provider
      // and new settings.
      final source = await create(
        accounts: InMemoryAccountStore([
          account('c', label: 'C'),
          account('a', label: 'A (new)', key: 'new-key'),
          account('d'),
        ]),
        settings: InMemoryKeyValueStore({
          UpCloud.recentFolderPathsKey: '["Movies/2026","Shows"]',
        }),
      );
      final streamhg = source.registry.config('streamhg')!;
      await source.registry.save(
        streamhg.copyWith(apiBase: Uri.parse('https://new.test/api')),
      );
      await source.registry.save(
        ProviderConfig(
          id: 'myhost',
          name: 'MyHost',
          driver: 'xvs',
          apiBase: Uri.parse('https://myhost.test/api'),
        ),
      );
      await source.updateSettings(
        const UploadSettings(
          maxConcurrentUploads: 7,
          defaultVisibility: UploadVisibility.public,
        ),
      );
      backup = await source.exportBackup(password: password);

      // The device: accounts a, b and d, byse disabled, other settings.
      store = InMemoryAccountStore([
        account('a', label: 'A'),
        account('b', label: 'B'),
        account('d'),
      ]);
      settingsStore = InMemoryKeyValueStore({
        UpCloud.recentFolderPathsKey: '["Docs","movies/2026"]',
      });
      target = await create(accounts: store, settings: settingsStore);
      await target.registry.setEnabled('byse', enabled: false);
      await target.updateSettings(const UploadSettings(retries: 5));
    });

    test('merge adds and updates, and removes nothing', () async {
      final before = target.connect('a');
      final unchanged = target.connect('d');
      final result = await target.importBackup(backup, password: password);

      expect(result.mode, BackupImportMode.merge);
      expect(result.accountsAdded, 1);
      expect(result.accountsUpdated, 1);
      expect(result.accountsRemoved, 0);
      expect(result.providersImported, 2);

      expect(target.accounts.map((a) => a.id), ['a', 'b', 'd', 'c']);
      expect(target.account('a')!.label, 'A (new)');
      expect(target.account('a')!.credentials.apiKey, 'new-key');
      expect((await store.load()).map((a) => a.id), ['a', 'b', 'd', 'c']);
      // Updated accounts reconnect with their new credentials; the others
      // keep their connection.
      expect(target.connect('a'), isNot(same(before)));
      expect(target.connect('d'), same(unchanged));

      expect(
        target.provider('streamhg')!.defaultBaseUrl,
        Uri.parse('https://new.test/api'),
      );
      expect(target.provider('myhost'), isNotNull);
      expect(target.provider('byse'), isNull, reason: 'edit kept');

      expect(target.settings.maxConcurrentUploads, 7);
      expect(target.settings.defaultVisibility, UploadVisibility.public);
      expect(target.settings.retries, 2, reason: 'settings are applied');

      expect(target.recentFolderPaths, ['Docs', 'movies/2026', 'Shows']);
      expect(
        settingsStore.values[UpCloud.recentFolderPathsKey],
        '["Docs","movies/2026","Shows"]',
      );
    });

    test('merging the same backup twice changes nothing more', () async {
      await target.importBackup(backup, password: password);
      final again = await target.importBackup(backup, password: password);
      expect(again.accountsAdded, 0);
      expect(again.accountsUpdated, 0);
      expect(target.accounts, hasLength(4));
    });

    test('replace makes the configuration equal to the backup', () async {
      final result = await target.importBackup(
        backup,
        password: password,
        mode: BackupImportMode.replace,
      );

      expect(result.mode, BackupImportMode.replace);
      expect(result.accountsAdded, 1);
      expect(result.accountsUpdated, 1);
      expect(result.accountsRemoved, 1);
      expect(result.providersImported, 2);

      // In the order of the backup.
      expect(target.accounts.map((a) => a.id), ['c', 'a', 'd']);
      expect((await store.load()).map((a) => a.id), ['c', 'a', 'd']);
      expect(target.account('b'), isNull);

      expect(
        target.provider('streamhg')!.defaultBaseUrl,
        Uri.parse('https://new.test/api'),
      );
      expect(target.provider('myhost'), isNotNull);
      expect(target.provider('byse'), isNotNull, reason: 'edit discarded');
      expect(target.registry.isModified('byse'), isFalse);

      expect(target.settings.maxConcurrentUploads, 7);
      expect(target.settings.retries, 2);
      expect(target.recentFolderPaths, ['Movies/2026', 'Shows']);
    });

    test('replace cancels the uploads of removed accounts', () async {
      executor.pause();
      final removed = target.upload(
        'b',
        const UploadSource.bytes([1, 2, 3], name: 'b.mp4'),
      );
      final kept = target.upload(
        'd',
        const UploadSource.bytes([1, 2, 3], name: 'd.mp4'),
      );
      await Future<void>.delayed(Duration.zero);

      await target.importBackup(
        backup,
        password: password,
        mode: BackupImportMode.replace,
      );

      await expectLater(removed.result, throwsA(isA<CancelledException>()));
      expect(target.transfers.tasks, [kept]);
      executor.resume();
      await kept.result;
    });

    test('merge keeps every upload', () async {
      executor.pause();
      final task = target.upload(
        'b',
        const UploadSource.bytes([1, 2, 3], name: 'b.mp4'),
      );
      await target.importBackup(backup, password: password);
      expect(target.transfers.tasks, [task]);
      executor.resume();
      await task.result;
    });
  });
}
