import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('SharedPreferencesKeyValueStore', () {
    test('reads, writes and deletes strings', () async {
      final store = SharedPreferencesKeyValueStore(keyPrefix: 'app.');
      expect(await store.read('a'), isNull);

      await store.write('a', '{"x":1}');
      expect(await store.read('a'), '{"x":1}');
      expect(await SharedPreferencesAsync().getString('app.a'), '{"x":1}');

      await store.write('a', null);
      expect(await store.read('a'), isNull);
    });
  });

  group('UpCloudFlutter.create', () {
    test(
      'persists settings and registry data in the key/value store',
      () async {
        final store = InMemoryKeyValueStore();
        final accounts = InMemoryAccountStore();
        final executor = FakeUploadExecutor();
        final upcloud = UpCloudFlutter.create(
          accounts: accounts,
          store: store,
          providers: [inMemoryDemo],
          useRemoteRegistry: false,
          uploadExecutor: executor,
        );
        addTearDown(upcloud.dispose);
        await upcloud.init();

        expect(upcloud.registry.store, same(store));
        expect(upcloud.registry.remoteUrl, isNull);
        expect(upcloud.provider('demo'), isNotNull);

        await upcloud.updateSettings(
          upcloud.settings.copyWith(maxConcurrentUploads: 5),
        );
        expect(
          store.values[UpCloud.settingsKey],
          contains('"maxConcurrentUploads":5'),
        );

        final account = await upcloud.addAccount(
          providerId: 'demo',
          credentials: Credentials.apiKey('k'),
          verify: false,
        );
        expect((await accounts.load()).single.id, account.id);

        // Uploads go through the given executor.
        final task = upcloud.upload(
          account.id,
          const UploadSource.bytes([1, 2, 3], name: 'a.mp4'),
        );
        await task.result;
        expect(executor.requests, hasLength(1));
      },
    );

    test('defaults to shared preferences and background uploads', () async {
      final upcloud = UpCloudFlutter.create(
        accounts: InMemoryAccountStore(),
        useRemoteRegistry: false,
      );
      addTearDown(upcloud.dispose);
      await upcloud.init();
      expect(upcloud.registry.store, isA<SharedPreferencesKeyValueStore>());

      await upcloud.updateSettings(upcloud.settings.copyWith(retries: 4));
      final saved = await SharedPreferencesAsync().getString(
        UpCloud.settingsKey,
      );
      expect(saved, contains('"retries":4'));

      // A new instance loads the saved settings.
      final again = UpCloudFlutter.create(
        accounts: InMemoryAccountStore(),
        useRemoteRegistry: false,
      );
      addTearDown(again.dispose);
      await again.init();
      expect(again.settings.retries, 4);
    });
  });
}
