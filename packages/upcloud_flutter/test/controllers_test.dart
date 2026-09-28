import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

import 'helpers.dart';

void main() {
  group('TransfersController', () {
    test('tracks tasks and their states', () async {
      final (upcloud, account) = await upcloudWithAccount();
      addTearDown(upcloud.dispose);
      final controller = TransfersController.of(upcloud);
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      final task = upcloud.upload(
        account.id,
        UploadSource.bytes(List.filled(100, 1), name: 'a.bin'),
      );
      await task.result;
      await pumpEventQueue();

      final entry = controller.state.entry(task.id)!;
      expect(entry.state, const TransferState.completed());
      expect(entry.fraction, 1);
      expect(controller.state.isBusy, isFalse);
      expect(controller.state.hasFinished, isTrue);
      expect(notifications, greaterThan(0));

      controller.remove(task);
      await pumpEventQueue();
      expect(controller.state.entries, isEmpty);
    });

    test('reports speed while running', () async {
      final manager = TransferManager(
        resolveProvider: (_) => fastSample(),
        executor: FakeUploadExecutor(
          progressSteps: 8,
          stepDelay: const Duration(milliseconds: 1),
        ),
        progressInterval: Duration.zero,
      );
      addTearDown(manager.dispose);
      var now = DateTime(2026);
      final controller = TransfersController(manager, clock: () => now);
      addTearDown(controller.dispose);

      final running = <double?>[];
      controller.addListener(() {
        final entry = controller.state.entries.firstOrNull;
        if (entry?.state is TransferRunning) {
          running.add(entry!.bytesPerSecond);
          now = now.add(const Duration(seconds: 1));
        }
      });
      final task = manager.upload(
        'a',
        UploadSource.bytes(List.filled(2000, 0), name: 'b.bin'),
      );
      // Let the controller subscribe to the task before it starts.
      await pumpEventQueue();
      await task.result;

      expect(running, isNotEmpty);
      expect(running.whereType<double>(), isNotEmpty);
      expect(running.whereType<double>().every((s) => s > 0), isTrue);
    });

    test('cancels and retries', () async {
      final (upcloud, account) = await upcloudWithAccount();
      addTearDown(upcloud.dispose);
      final controller = TransfersController(upcloud.transfers);
      addTearDown(controller.dispose);

      final task = upcloud.upload(
        account.id,
        const UploadSource.bytes([1], name: 'c.bin'),
      );
      controller.cancel(task);
      await expectLater(task.result, throwsA(isA<CancelledException>()));
      await pumpEventQueue();
      expect(controller.state.entry(task.id)?.state, isA<TransferCancelled>());

      controller.retry(task);
      await task.result;
      await pumpEventQueue();
      expect(controller.state.entry(task.id)?.state, isA<TransferCompleted>());
    });
  });

  group('AccountsController', () {
    test('adds, verifies, renames and removes accounts', () async {
      final upcloud = UpCloud(
        uploadExecutor: FakeUploadExecutor(),
        registry: offlineRegistry(),
        providers: [memoryDefinition()],
      );
      addTearDown(upcloud.dispose);
      final controller = AccountsController(upcloud);
      addTearDown(controller.dispose);
      await controller.init();
      expect(controller.state.accounts, isEmpty);

      final account = await controller.add(
        providerId: 'memory',
        credentials: Credentials.apiKey('key'),
      );
      expect(controller.state.accounts, [account]);
      expect(controller.state.isBusy, isFalse);
      expect(account.label, 'Memory · demo');

      final status = await controller.verify(account.id);
      expect(status, isA<AccountStatusConnected>());
      final info = (status as AccountStatusConnected).info!;
      expect(info.storageUsed, isNotNull);
      expect(controller.state.statusOf(account.id), status);

      await controller.rename(account.id, 'Renamed');
      expect(controller.state.accounts.single.label, 'Renamed');

      await controller.remove(account.id);
      expect(controller.state.accounts, isEmpty);
      expect(controller.state.statuses, isEmpty);
    });

    test('stores errors and rethrows them', () async {
      final upcloud = UpCloud(
        uploadExecutor: FakeUploadExecutor(),
        registry: offlineRegistry(),
        providers: [memoryDefinition()],
      );
      addTearDown(upcloud.dispose);
      final controller = AccountsController(upcloud);
      addTearDown(controller.dispose);

      await expectLater(
        controller.add(
          providerId: 'memory',
          credentials: const Credentials({}),
        ),
        throwsA(isA<AuthenticationException>()),
      );
      expect(controller.state.error, isA<AuthenticationException>());
      expect(controller.state.isBusy, isFalse);

      controller.clearError();
      expect(controller.state.error, isNull);

      await expectLater(
        controller.add(
          providerId: 'nope',
          credentials: Credentials.apiKey('k'),
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('verify reports failures without throwing', () async {
      final upcloud = UpCloud(
        uploadExecutor: FakeUploadExecutor(),
        registry: offlineRegistry(),
        providers: [memoryDefinition()],
      );
      addTearDown(upcloud.dispose);
      final controller = AccountsController(upcloud);
      addTearDown(controller.dispose);

      final status = await controller.verify('missing');
      expect(status, isA<AccountStatusFailed>());
    });

    test('loads accounts from the store', () async {
      final store = InMemoryAccountStore([
        CloudAccount(
          id: 'saved',
          providerId: 'demo',
          label: 'Saved',
          credentials: Credentials.apiKey('k'),
        ),
      ]);
      final upcloud = UpCloud(
        uploadExecutor: FakeUploadExecutor(),
        registry: offlineRegistry(),
        providers: [inMemoryDemo],
        store: store,
      );
      addTearDown(upcloud.dispose);
      final controller = AccountsController(upcloud);
      addTearDown(controller.dispose);
      expect(controller.state.isLoading, isTrue);

      await pumpEventQueue();
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.accounts.single.label, 'Saved');
    });
  });
}
