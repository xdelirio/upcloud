import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import '../support/testing.dart';
import 'helpers.dart';

Finder key(String value) => find.byKey(ValueKey(value));

/// An [UpCloud] with two accounts whose uploads wait in a paused
/// [FakeUploadExecutor].
Future<(UpCloud, FakeUploadExecutor, List<CloudAccount>)> twoAccounts() async {
  final executor = FakeUploadExecutor()..pause();
  final upcloud = UpCloud(
    uploadExecutor: executor,
    registry: offlineRegistry(),
    providers: [memoryDefinition()],
  );
  await upcloud.init();
  final accounts = [
    for (final label in ['Main', 'Backup'])
      await upcloud.addAccount(
        providerId: 'memory',
        credentials: Credentials.apiKey('k'),
        label: label,
        verify: false,
      ),
  ];
  return (upcloud, executor, accounts);
}

void main() {
  final a = UploadSource.bytes(List.filled(1000, 1), name: 'a.mp4');
  final b = UploadSource.bytes(List.filled(3000, 2), name: 'b.mkv');

  group('TransfersState', () {
    test('groups uploads by batch and aggregates them', () async {
      final (upcloud, executor, accounts) = await twoAccounts();
      addTearDown(upcloud.dispose);
      final controller = TransfersController.of(upcloud);
      addTearDown(controller.dispose);

      final single = upcloud.upload(accounts.first.id, a);
      final batch = upcloud.uploadBatch(
        files: [a, b],
        accountIds: [for (final account in accounts) account.id],
        folderPath: 'Movies/2026',
      );
      await pumpEventQueue();

      final state = controller.state;
      expect(state.entries, hasLength(5));
      expect(state.entry(single.id)!.batchId, isNull);
      final group = state.batches.single;
      expect(group.id, batch.id);
      expect(state.batch(batch.id)!.entries, hasLength(4));
      expect(group.fileCount, 2);
      expect(group.accountCount, 2);
      expect(group.folderPath, 'Movies/2026');
      expect(group.totalBytes, 8000);
      expect(group.isFinished, isFalse);

      executor.resume();
      await batch.results;
      await single.result;
      await pumpEventQueue();
      final done = controller.state.batch(batch.id)!;
      expect(done.completedCount, 4);
      expect(done.progress, 1);
      expect(done.transferredBytes, 8000);
      expect(done.isFinished, isTrue);
    });

    test('batch actions: cancel, retry failed and clear', () async {
      final (upcloud, executor, accounts) = await twoAccounts();
      addTearDown(upcloud.dispose);
      final controller = TransfersController.of(upcloud);
      addTearDown(controller.dispose);
      final batch = upcloud.uploadBatch(
        files: [a, b],
        accountIds: [for (final account in accounts) account.id],
      );
      final other = upcloud.upload(accounts.first.id, a);
      await pumpEventQueue();

      controller.cancelBatch(batch.id);
      await batch.results;
      expect(batch.cancelledCount, 4);
      // The other upload takes a free slot and waits in the executor.
      await pumpEventQueue();
      expect(other.state, isA<TransferRunning>());
      expect(executor.running, 1);

      // Only failed uploads are retried.
      batch.tasks.take(2).forEach(upcloud.transfers.retry);
      executor
        ..failNext(2, const AuthenticationException('Denied'))
        ..resume();
      await batch.results;
      await pumpEventQueue();
      expect(batch.failedCount, 2);
      controller.retryFailed(batch.id);
      await batch.results;
      expect(batch.completedCount, 2);
      expect(batch.cancelledCount, 2);

      controller.clearBatch(batch.id);
      await pumpEventQueue();
      expect(controller.state.batch(batch.id), isNull);
      expect(controller.state.entries.single.task, other);
    });
  });

  group('TransferTile', () {
    testWidgets('shows the automatic retry', (tester) async {
      final task = UploadTask(
        id: 't1',
        accountId: 'a',
        source: const UploadSource.bytes([1], name: 'a.mp4'),
      );
      await pumpApp(
        tester,
        TransferTile(
          task: task,
          state: const TransferState.running(
            TransferProgress(transferred: 256, total: 1024),
          ),
          attempt: 2,
          maxRetries: 3,
        ),
      );
      expect(
        find.text('Retrying (1/3) · 256 B of 1.0 KB · 25 %'),
        findsOneWidget,
      );

      await pumpApp(
        tester,
        TransferTile(
          task: task,
          state: const TransferState.queued(),
          attempt: 3,
        ),
        locale: const Locale('es'),
      );
      expect(find.text('Reintentando (2)'), findsOneWidget);
    });
  });

  group('TransferList', () {
    testWidgets('groups batches under a header', (tester) async {
      final (upcloud, executor, accounts) = await twoAccounts();
      addTearDown(upcloud.dispose);
      upcloud.upload(
        accounts.first.id,
        const UploadSource.bytes([1, 2], name: 'single.txt'),
      );
      final batch = upcloud.uploadBatch(
        files: [a, b],
        accountIds: [for (final account in accounts) account.id],
        folderPath: 'Movies/2026',
      );

      await pumpApp(
        tester,
        const TransferList(),
        upcloud: upcloud,
        size: const Size(800, 1600),
      );
      await tester.pump();

      expect(find.text('2 files → 2 accounts'), findsOneWidget);
      expect(find.text('Movies/2026'), findsOneWidget);
      expect(find.byType(TransferBatchHeader), findsOneWidget);
      expect(find.text('0 of 4 done · 0 %'), findsOneWidget);
      expect(find.text('a.mp4'), findsNWidgets(2));
      expect(find.text('b.mkv'), findsNWidgets(2));
      expect(find.text('single.txt'), findsOneWidget);
      expect(find.text('Backup'), findsNWidgets(2));
      // The newest row (the batch) comes first.
      expect(
        tester.getTopLeft(find.text('2 files → 2 accounts')).dy,
        lessThan(tester.getTopLeft(find.text('single.txt')).dy),
      );

      // Collapse and expand the batch.
      await tester.tap(key('upcloud-batch-expand-${batch.id}'));
      await tester.pump();
      expect(find.text('a.mp4'), findsNothing);
      await tester.tap(key('upcloud-batch-expand-${batch.id}'));
      await tester.pump();
      expect(find.text('a.mp4'), findsNWidgets(2));

      executor
        ..failNext(1, const AuthenticationException('Denied'))
        ..resume();
      await tester.pumpAndSettle();
      expect(find.text('4 of 4 done · 1 failed'), findsOneWidget);
      expect(key('upcloud-batch-cancel-${batch.id}'), findsNothing);

      await tester.tap(key('upcloud-batch-retry-${batch.id}'));
      await tester.pumpAndSettle();
      expect(find.text('4 of 4 done'), findsOneWidget);

      await tester.tap(key('upcloud-batch-clear-${batch.id}'));
      await tester.pumpAndSettle();
      expect(find.byType(TransferBatchHeader), findsNothing);
      expect(find.text('single.txt'), findsOneWidget);
    });

    testWidgets('cancels a running batch', (tester) async {
      final (upcloud, _, accounts) = await twoAccounts();
      addTearDown(upcloud.dispose);
      final batch = upcloud.uploadBatch(
        files: [a],
        accountIds: [for (final account in accounts) account.id],
        folderPath: '',
      );
      await pumpApp(tester, const TransferList(), upcloud: upcloud);
      await tester.pump();
      expect(find.text('1 file → 2 accounts'), findsOneWidget);
      expect(find.text('My files'), findsOneWidget); // The root folder.

      await tester.tap(key('upcloud-batch-cancel-${batch.id}'));
      await tester.pumpAndSettle();
      expect(batch.cancelledCount, 2);
      expect(find.text('2 of 2 done · 2 cancelled'), findsOneWidget);
    });

    testWidgets('lists batch uploads one by one when not grouping', (
      tester,
    ) async {
      final (upcloud, _, accounts) = await twoAccounts();
      addTearDown(upcloud.dispose);
      upcloud.uploadBatch(
        files: [a],
        accountIds: [for (final account in accounts) account.id],
      );
      await pumpApp(
        tester,
        const TransferList(groupBatches: false),
        upcloud: upcloud,
      );
      await tester.pump();
      expect(find.byType(TransferBatchHeader), findsNothing);
      expect(find.byType(TransferTile), findsNWidgets(2));
    });
  });
}
