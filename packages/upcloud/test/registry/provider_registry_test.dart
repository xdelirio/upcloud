import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';
import 'package:upcloud/src/registry/bundled_registry_data.dart';
import 'package:upcloud/src/registry/registry_document.dart';
import 'package:upcloud/upcloud.dart';

final Uri _remoteUrl = Uri.parse('https://registry.test/providers.json');

/// Headers of raw.githubusercontent.com responses.
const _plainText = {
  'content-type': ['text/plain; charset=utf-8'],
};

RegistryDocument _document(
  List<Map<String, Object?>> providers, {
  DateTime? updatedAt,
  int schemaVersion = 1,
}) => RegistryDocument(
  providers: providers,
  updatedAt: updatedAt ?? DateTime.utc(2026),
  schemaVersion: schemaVersion,
);

Map<String, Object?> _xvs(String id, {String? apiBase}) => {
  'id': id,
  'name': id.toUpperCase(),
  'driver': 'xvs',
  'website': 'https://$id.test',
  'apiBase': apiBase ?? 'https://$id.test/api',
};

void main() {
  group('bundled registry', () {
    test('is in sync with registry/providers.json', () {
      final file = File('../../registry/providers.json');
      if (!file.existsSync()) {
        markTestSkipped('Repository file not available');
        return;
      }
      expect(
        bundledRegistryJson.trim(),
        file.readAsStringSync().trim(),
        reason: 'Run `dart run tool/sync_registry.dart`',
      );
    });

    test('every entry is valid and uses a built-in driver', () {
      final registry = ProviderRegistry(useRemote: false);
      expect(registry.issues, isEmpty);
      expect(
        registry.definitions.map((d) => d.id),
        containsAll(['streamhg', 'earnvids', 'byse', 'mediafire']),
      );
    });
  });

  group('layers', () {
    late InMemoryRegistryStore store;
    late ProviderRegistry registry;

    setUp(() async {
      store = InMemoryRegistryStore();
      registry = ProviderRegistry(
        useRemote: false,
        store: store,
        bundled: _document([_xvs('alpha'), _xvs('beta')]),
      );
      await registry.load();
    });

    test('stores only the fields the user changed', () async {
      final alpha = registry.config('alpha')!;
      await registry.save(
        alpha.copyWith(
          limits: const LimitsConfig(maxFileSizeMb: 100),
          mirrors: [Uri.parse('https://alpha-mirror.test/api')],
        ),
      );

      final saved = jsonDecode(store.values[ProviderRegistry.overridesKey]!);
      expect(saved, [
        {
          'id': 'alpha',
          'mirrors': ['https://alpha-mirror.test/api'],
          'limits': {'maxFileSizeMb': 100.0},
        },
      ]);
      expect(registry.isModified('alpha'), isTrue);
      expect(
        registry.definition('alpha')!.defaultLimits.maxFileSize,
        const DataSize.mb(100),
      );
    });

    test('user edits survive registry updates of other fields', () async {
      await registry.save(registry.config('alpha')!.copyWith(name: 'My Alpha'));
      final updated = ProviderRegistry(
        useRemote: false,
        store: store,
        bundled: _document([
          _xvs('alpha', apiBase: 'https://alpha.new/api'),
          _xvs('beta'),
        ]),
      );
      await updated.load();

      final alpha = updated.config('alpha')!;
      expect(alpha.name, 'My Alpha');
      expect(alpha.apiBase, Uri.parse('https://alpha.new/api'));
    });

    test('saving the original values removes the override', () async {
      final alpha = registry.config('alpha')!;
      await registry.save(alpha.copyWith(name: 'Changed'));
      await registry.save(alpha);
      expect(registry.isModified('alpha'), isFalse);
      expect(store.values, isNot(contains(ProviderRegistry.overridesKey)));
    });

    test('adds custom providers based on a driver', () async {
      await registry.save(
        ProviderConfig(
          id: 'mine',
          name: 'Mine',
          driver: 'xvs',
          apiBase: Uri.parse('https://mine.test/api'),
        ),
      );
      expect(registry.isCustom('mine'), isTrue);
      expect(registry.definition('mine')?.info.driver, 'xvs');
      expect(registry.configs.last.id, 'mine');

      await registry.reset('mine');
      expect(registry.config('mine'), isNull);
    });

    test('rejects unknown drivers and invalid configs', () async {
      await expectLater(
        registry.save(const ProviderConfig(id: 'x', name: 'X', driver: 'nope')),
        throwsA(
          isA<InvalidProviderConfigException>().having(
            (e) => e.problems.single.code,
            'code',
            ConfigProblemCode.unknownDriver,
          ),
        ),
      );
      await expectLater(
        registry.save(const ProviderConfig(id: 'x', name: 'X', driver: 'xvs')),
        throwsA(isA<InvalidProviderConfigException>()),
      );
      expect(
        registry.validate(
          ProviderConfig(
            id: 'x',
            name: 'X',
            driver: 'xvs',
            apiBase: Uri.parse('https://x.test/api'),
          ),
        ),
        isEmpty,
      );
    });

    test('disables and re-enables providers', () async {
      await registry.setEnabled('beta', enabled: false);
      expect(registry.definition('beta'), isNull);
      expect(registry.config('beta')?.enabled, isFalse);

      await registry.setEnabled('beta', enabled: true);
      expect(registry.definition('beta'), isNotNull);
      expect(registry.isModified('beta'), isFalse);
    });

    test('reports entries of unknown drivers instead of failing', () {
      final future = ProviderRegistry(
        useRemote: false,
        bundled: _document([
          _xvs('alpha'),
          {'id': 'next', 'name': 'Next', 'driver': 'from-the-future'},
          {'name': 'no id'},
        ]),
      );
      expect(future.definitions.map((d) => d.id), ['alpha']);
      expect(future.issues.map((i) => i.providerId), ['next', '?']);
    });

    test('exports and imports user changes', () async {
      await registry.save(
        ProviderConfig(
          id: 'mine',
          name: 'Mine',
          driver: 'xvs',
          apiBase: Uri.parse('https://mine.test/api'),
        ),
      );
      final exported = registry.exportUserChanges();

      final other = ProviderRegistry(
        useRemote: false,
        bundled: _document([_xvs('alpha')]),
      );
      final imported = await other.importProviders(
        RegistryDocument.parse(exported.encode()),
      );
      expect(imported, ['mine']);
      expect(other.definition('mine'), isNotNull);
    });

    test('emits changes', () async {
      final events = <void>[];
      registry.changes.listen(events.add);
      await registry.setEnabled('beta', enabled: false);
      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(1));
    });
  });

  group('remote updates', () {
    late Dio http;
    late DioAdapter adapter;
    late InMemoryRegistryStore store;

    ProviderRegistry create({RegistryDocument? bundled}) => ProviderRegistry(
      remoteUrl: _remoteUrl,
      store: store,
      httpClient: http,
      bundled: bundled ?? _document([_xvs('alpha')]),
      minRefreshInterval: const Duration(hours: 1),
    );

    setUp(() {
      http = Dio();
      adapter = DioAdapter(dio: http);
      store = InMemoryRegistryStore();
    });

    test('downloads, caches and applies a newer registry', () async {
      final remote = _document([
        _xvs('alpha', apiBase: 'https://alpha.moved/api'),
        _xvs('gamma'),
      ], updatedAt: DateTime.utc(2027));
      adapter.onGet(
        _remoteUrl.toString(),
        (server) => server.reply(
          200,
          remote.encode(),
          headers: {
            ..._plainText,
            'etag': ['"v2"'],
          },
        ),
      );
      final registry = create();
      await registry.load();

      final result = await registry.refresh();

      expect(result.status, RegistryRefreshStatus.updated);
      expect(registry.definition('gamma'), isNotNull);
      expect(
        registry.definition('alpha')!.defaultBaseUrl,
        Uri.parse('https://alpha.moved/api'),
      );
      expect(store.values[ProviderRegistry.etagKey], '"v2"');

      // A new instance starts from the cached copy, offline.
      final offline = ProviderRegistry(
        useRemote: false,
        store: store,
        bundled: _document([_xvs('alpha')]),
      );
      await offline.load();
      expect(offline.definition('gamma'), isNotNull);
    });

    test('skips downloads within the refresh interval', () async {
      adapter.onGet(
        _remoteUrl.toString(),
        (server) => server.reply(
          200,
          _document([_xvs('alpha')]).encode(),
          headers: _plainText,
        ),
      );
      final registry = create();
      await registry.load();

      final first = await registry.refresh();
      expect(
        first.status,
        RegistryRefreshStatus.updated,
        reason: '${first.error}',
      );
      expect((await registry.refresh()).status, RegistryRefreshStatus.skipped);
    });

    test('keeps the current registry when the download fails', () async {
      adapter.onGet(
        _remoteUrl.toString(),
        (server) => server.reply(500, 'boom'),
      );
      final registry = create();
      await registry.load();

      final result = await registry.refresh(force: true);

      expect(result.status, RegistryRefreshStatus.failed);
      expect(result.error, isA<ProviderException>());
      expect(registry.definition('alpha'), isNotNull);
    });

    test('rejects registries with a newer schema', () async {
      adapter.onGet(
        _remoteUrl.toString(),
        (server) => server.reply(
          200,
          _document([_xvs('gamma')], schemaVersion: 99).encode(),
          headers: _plainText,
        ),
      );
      final registry = create();
      await registry.load();

      final result = await registry.refresh(force: true);

      expect(result.status, RegistryRefreshStatus.failed);
      expect(result.error, isA<FormatException>());
      expect(registry.definition('gamma'), isNull);
    });

    test('prefers the bundled registry when it is newer', () async {
      adapter.onGet(
        _remoteUrl.toString(),
        (server) => server.reply(
          200,
          _document([_xvs('old')], updatedAt: DateTime.utc(2020)).encode(),
          headers: _plainText,
        ),
      );
      final registry = create();
      await registry.load();
      await registry.refresh(force: true);

      expect(registry.definition('old'), isNull);
      expect(registry.definition('alpha'), isNotNull);
    });

    test('requires https', () {
      expect(
        () => ProviderRegistry(remoteUrl: Uri.parse('http://insecure.test')),
        throwsArgumentError,
      );
    });

    test('can be disabled', () async {
      final registry = ProviderRegistry(useRemote: false);
      expect(registry.remoteUrl, isNull);
      expect((await registry.refresh()).status, RegistryRefreshStatus.disabled);
    });
  });

  group('json helpers', () {
    test('mergeJson merges nested objects and removes nulls', () {
      expect(
        mergeJson(
          {
            'a': 1,
            'b': {'x': 1, 'y': 2},
            'c': 3,
          },
          {
            'b': {'y': null, 'z': 3},
            'c': null,
          },
        ),
        {
          'a': 1,
          'b': {'x': 1, 'z': 3},
        },
      );
    });

    test('diffJson is the inverse of mergeJson', () {
      final base = {
        'a': 1,
        'b': {'x': 1, 'y': 2},
        'l': [1, 2],
      };
      final target = {
        'a': 1,
        'b': {'x': 5},
        'l': [1, 2, 3],
      };
      final patch = diffJson(base, target);
      expect(patch, {
        'b': {'x': 5, 'y': null},
        'l': [1, 2, 3],
      });
      expect(mergeJson(base, patch), target);
    });
  });

  group('LimitsConfig', () {
    test('applies human friendly values', () {
      final limits = const LimitsConfig(
        maxFileSizeMb: 1.5,
        allowedExtensions: ['.MP4', 'mkv'],
        maxConcurrentUploads: 3,
        minRequestIntervalMs: 250,
      ).applyTo(ProviderLimits.none);

      expect(limits.maxFileSize, DataSize((1.5 * 1024 * 1024).round()));
      expect(limits.allowedExtensions, {'mp4', 'mkv'});
      expect(limits.maxConcurrentUploads, 3);
      expect(limits.minRequestInterval, const Duration(milliseconds: 250));
    });

    test('0 and "*" remove limits', () {
      final limits =
          const LimitsConfig(
            maxFileSizeMb: 0,
            allowedExtensions: ['*'],
          ).applyTo(
            const ProviderLimits(
              maxFileSize: DataSize.mb(1),
              allowedExtensions: {'mp4'},
            ),
          );
      expect(limits.maxFileSize, isNull);
      expect(limits.allowedExtensions, isNull);
    });
  });

  test('credential defaults fill empty fields', () {
    const schema = CredentialSchema([
      CredentialField(id: 'app', label: 'App', defaultValue: '42'),
    ]);
    expect(schema.missingFields(const Credentials({})), isEmpty);
    expect(schema.applyDefaults(const Credentials({}))['app'], '42');
    expect(schema.applyDefaults(const Credentials({'app': '7'}))['app'], '7');
  });
}
