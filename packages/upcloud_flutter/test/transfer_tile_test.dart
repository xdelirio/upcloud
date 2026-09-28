import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

import 'helpers.dart';

void main() {
  final task = UploadTask(
    id: 't1',
    accountId: 'a1',
    source: const UploadSource.bytes([1, 2, 3], name: 'movie.mp4'),
  );

  Future<void> pumpTile(
    WidgetTester tester,
    TransferState state, {
    double? speed,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
    VoidCallback? onRemove,
    Locale? locale,
  }) async {
    final tile = TransferTile(
      task: task,
      state: state,
      bytesPerSecond: speed,
      subtitle: 'Main account',
      onCancel: onCancel,
      onRetry: onRetry,
      onRemove: onRemove,
    );
    await pumpApp(tester, tile, locale: locale);
  }

  testWidgets('queued: indeterminate progress and cancel', (tester) async {
    var cancelled = false;
    await pumpTile(
      tester,
      const TransferState.queued(),
      onCancel: () => cancelled = true,
      onRetry: () {},
      onRemove: () {},
    );

    expect(find.text('movie.mp4'), findsOneWidget);
    expect(find.text('Main account'), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, isNull);
    expect(find.byTooltip('Retry'), findsNothing);
    expect(find.byTooltip('Remove'), findsNothing);

    await tester.tap(find.byTooltip('Cancel'));
    expect(cancelled, isTrue);
  });

  testWidgets('running: progress, percentage and speed', (tester) async {
    await pumpTile(
      tester,
      const TransferState.running(
        TransferProgress(transferred: 512 * 1024, total: 2 * 1024 * 1024),
      ),
      speed: 1536 * 1024,
      onCancel: () {},
    );

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 0.25);
    expect(
      find.text('Uploading · 512.0 KB of 2.0 MB · 25 % · 1.5 MB/s'),
      findsOneWidget,
    );
    expect(find.byTooltip('Cancel'), findsOneWidget);
  });

  testWidgets('completed: remove only', (tester) async {
    var removed = false;
    await pumpTile(
      tester,
      const TransferState.completed(),
      onCancel: () {},
      onRetry: () {},
      onRemove: () => removed = true,
    );

    expect(find.text('Completed'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byTooltip('Cancel'), findsNothing);
    expect(find.byTooltip('Retry'), findsNothing);

    await tester.tap(find.byTooltip('Remove'));
    expect(removed, isTrue);
  });

  testWidgets('cancelled: retry and remove', (tester) async {
    var retried = false;
    await pumpTile(
      tester,
      const TransferState.cancelled(),
      onCancel: () {},
      onRetry: () => retried = true,
      onRemove: () {},
    );

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.byTooltip('Cancel'), findsNothing);
    expect(find.byTooltip('Remove'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry'));
    expect(retried, isTrue);
  });

  group('failed', () {
    const tooLarge = UploadRejectedException(
      'rejected',
      reason: FileTooLarge(size: DataSize.gb(3), maxSize: DataSize.gb(2)),
    );

    testWidgets('file too large', (tester) async {
      await pumpTile(
        tester,
        const TransferState.failed(tooLarge),
        onRetry: () {},
        onRemove: () {},
      );
      expect(
        find.text('File is too large (3.0 GB, max. 2.0 GB)'),
        findsOneWidget,
      );
      expect(find.byTooltip('Retry'), findsOneWidget);
      expect(find.byTooltip('Remove'), findsOneWidget);
    });

    testWidgets('extension not allowed', (tester) async {
      await pumpTile(
        tester,
        const TransferState.failed(
          UploadRejectedException(
            'rejected',
            reason: ExtensionNotAllowed(extension: 'exe', allowed: {'mp4'}),
          ),
        ),
      );
      expect(find.text('Files of type .exe are not allowed'), findsOneWidget);
    });

    testWidgets('not enough storage', (tester) async {
      await pumpTile(
        tester,
        const TransferState.failed(
          UploadRejectedException(
            'rejected',
            reason: NotEnoughStorage(
              size: DataSize.mb(700),
              available: DataSize.mb(100),
            ),
          ),
        ),
      );
      expect(
        find.text('Not enough storage (700.0 MB needed, 100.0 MB free)'),
        findsOneWidget,
      );
    });

    testWidgets('other errors', (tester) async {
      await pumpTile(
        tester,
        const TransferState.failed(NetworkException('timeout')),
      );
      expect(
        find.text('Network error. Check your connection.'),
        findsOneWidget,
      );
    });

    testWidgets('localized in Spanish', (tester) async {
      await pumpTile(
        tester,
        const TransferState.failed(tooLarge),
        locale: const Locale('es'),
        onRetry: () {},
      );
      expect(
        find.text('El archivo es demasiado grande (3,0 GB, máx. 2,0 GB)'),
        findsOneWidget,
      );
      expect(find.byTooltip('Reintentar'), findsOneWidget);
    });
  });

  group('TransferList', () {
    testWidgets('follows the transfer manager', (tester) async {
      final (upcloud, account) = await upcloudWithAccount(
        limits: const ProviderLimits(maxFileSize: DataSize(10)),
      );
      addTearDown(upcloud.dispose);
      final controller = TransfersController(upcloud.transfers);
      addTearDown(controller.dispose);

      await pumpApp(
        tester,
        TransferList(controller: controller),
        upcloud: upcloud,
      );
      expect(find.text('No transfers'), findsOneWidget);

      upcloud
        ..upload(
          account.id,
          UploadSource.bytes(List.filled(5, 0), name: 'a.txt'),
        )
        ..upload(
          account.id,
          UploadSource.bytes(List.filled(50, 0), name: 'big.txt'),
        );
      await tester.pumpAndSettle();

      expect(find.text('a.txt'), findsOneWidget);
      expect(find.text('big.txt'), findsOneWidget);
      expect(find.text('Main'), findsNWidgets(2)); // Account label.
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('File is too large (50 B, max. 10 B)'), findsOneWidget);
      expect(controller.state.activeCount, 0);
      expect(controller.state.finishedCount, 2);

      controller.clearFinished();
      await tester.pumpAndSettle();
      expect(find.text('No transfers'), findsOneWidget);
    });
  });
}
