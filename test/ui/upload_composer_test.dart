import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import '../support/testing.dart';
import 'helpers.dart';

/// Two providers: a video host limited to 1 KB video files and a file host
/// without limits.
Future<(UpCloud, FakeUploadExecutor)> twoProviders({
  UploadSettings? settings,
  Map<String, String> saved = const {},
}) async {
  final executor = FakeUploadExecutor();
  final upcloud = UpCloud(
    uploadExecutor: executor,
    registry: offlineRegistry(),
    settingsStore: InMemoryKeyValueStore(saved),
    providers: [
      memoryDefinition(
        id: 'videohost',
        name: 'VideoHost',
        limits: const ProviderLimits(
          maxFileSize: DataSize.kb(1),
          allowedExtensions: ProviderLimits.videoExtensions,
        ),
      ),
      memoryDefinition(id: 'filehost', name: 'FileHost'),
    ],
  );
  await upcloud.init();
  if (settings != null) await upcloud.updateSettings(settings);
  for (final (provider, label) in [
    ('videohost', 'Video main'),
    ('filehost', 'Files main'),
    ('videohost', 'Video backup'),
  ]) {
    await upcloud.addAccount(
      providerId: provider,
      credentials: Credentials.apiKey('k'),
      label: label,
      verify: false,
    );
  }
  return (upcloud, executor);
}

final movie = UploadSource.bytes(List.filled(500, 1), name: 'movie.mp4');
final notes = UploadSource.bytes(List.filled(200, 2), name: 'notes.txt');
final huge = UploadSource.bytes(List.filled(4096, 3), name: 'huge.mkv');

Finder key(String value) => find.byKey(ValueKey(value));

void main() {
  group('UploadComposerController', () {
    test('plans uploads and skips the combinations providers reject', () async {
      final (upcloud, _) = await twoProviders();
      addTearDown(upcloud.dispose);
      final composer = UploadComposerController(upcloud);
      addTearDown(composer.dispose);

      expect(composer.accounts.map((a) => a.label), [
        'Video main',
        'Files main',
        'Video backup',
      ]);
      expect(composer.canSubmit, isFalse);

      composer
        ..addFiles([movie, notes, huge, movie])
        ..selectAll();
      expect(composer.files, [movie, notes, huge]);
      expect(composer.totalBytes, 500 + 200 + 4096);

      final skipped = [
        for (final s in composer.skipped)
          '${s.file.name}>${s.account.label}:${s.reason.runtimeType}',
      ];
      expect(skipped, [
        'notes.txt>Video main:ExtensionNotAllowed',
        'notes.txt>Video backup:ExtensionNotAllowed',
        'huge.mkv>Video main:FileTooLarge',
        'huge.mkv>Video backup:FileTooLarge',
      ]);
      expect(composer.uploadCount, 9 - 4);

      composer.folderPath = ' Movies // 2026 ';
      final queued = <UploadTask>{};
      final subscription = upcloud.transfers.changes.listen(queued.addAll);
      addTearDown(subscription.cancel);
      final batch = composer.submit();
      expect(batch.folderPath, 'Movies/2026');
      expect(batch.tasks, hasLength(5));
      expect(
        batch.tasks.map(
          (t) => '${t.name}>${upcloud.account(t.accountId)!.label}',
        ),
        [
          'movie.mp4>Video main',
          'movie.mp4>Files main',
          'movie.mp4>Video backup',
          'notes.txt>Files main',
          'huge.mkv>Files main',
        ],
      );
      // Skipped uploads never reach the queue.
      expect(upcloud.transfers.tasks, batch.tasks);
      expect(batch.tasks.every((t) => t.batchId == batch.id), isTrue);
      expect(upcloud.recentFolderPaths, ['Movies/2026']);
      expect(composer.files, isEmpty);

      final files = await batch.results;
      // Not even briefly queued.
      expect(queued, batch.tasks.toSet());
      expect(files, hasLength(5));
      expect(batch.failures, isEmpty);
    });

    test('remembers the account selection in memory', () async {
      final (upcloud, _) = await twoProviders();
      addTearDown(upcloud.dispose);
      final first = UploadComposerController(upcloud);
      final files = first.accounts[1].id;
      first
        ..toggleAccount(files)
        ..dispose();

      final second = UploadComposerController(upcloud);
      addTearDown(second.dispose);
      expect(second.selectedAccountIds, {files});
    });

    test('starts with the default folder and visibility', () async {
      final (upcloud, _) = await twoProviders(
        settings: const UploadSettings(
          defaultFolderPath: 'Backups',
          defaultVisibility: UploadVisibility.private,
        ),
      );
      addTearDown(upcloud.dispose);
      final composer = UploadComposerController(upcloud);
      addTearDown(composer.dispose);

      expect(composer.folderPath, 'Backups');
      expect(composer.visibility, UploadVisibility.private);

      composer
        ..addFiles([movie])
        ..selectAll()
        ..visibility = UploadVisibility.public;
      final batch = composer.submit();
      expect(batch.folderPath, 'Backups');
      expect(batch.tasks.every((t) => t.options.isPublic ?? false), isTrue);

      // "Provider default" wins over the private default of the settings.
      composer
        ..addFiles([notes])
        ..visibility = UploadVisibility.providerDefault;
      final keep = composer.submit();
      expect(keep.tasks, isNotEmpty);
      expect(keep.tasks.every((t) => t.options.isPublic == null), isTrue);
    });
  });

  group('UploadComposer', () {
    Future<(UpCloud, List<UploadBatch>)> pumpComposer(
      WidgetTester tester, {
      Locale? locale,
      List<UploadSource> Function()? pick,
    }) async {
      final (upcloud, _) = await twoProviders(
        saved: {UpCloud.recentFolderPathsKey: '["Movies/2025"]'},
      );
      addTearDown(upcloud.dispose);
      final submitted = <UploadBatch>[];
      await pumpApp(
        tester,
        UploadComposer(
          onPickFiles: () async => pick?.call() ?? [movie, notes],
          onSubmitted: submitted.add,
        ),
        upcloud: upcloud,
        locale: locale,
        size: const Size(800, 2400),
      );
      return (upcloud, submitted);
    }

    testWidgets('empty state until files are added', (tester) async {
      await pumpComposer(tester);

      expect(find.text('No files yet'), findsOneWidget);
      expect(find.text('VideoHost'), findsOneWidget);
      expect(find.text('FileHost'), findsOneWidget);
      expect(find.text('0 of 3 selected'), findsOneWidget);
      final submit = tester.widget<FilledButton>(
        key('upcloud-composer-submit'),
      );
      expect(submit.onPressed, isNull);
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('adds and removes files', (tester) async {
      await pumpComposer(tester);

      await tester.tap(key('upcloud-composer-add-files'));
      await tester.pumpAndSettle();
      expect(find.text('movie.mp4'), findsOneWidget);
      expect(find.text('notes.txt'), findsOneWidget);
      expect(find.text('2 files · 700 B'), findsOneWidget);
      expect(find.text('500 B · MP4'), findsOneWidget);

      await tester.tap(key('upcloud-composer-remove-1'));
      await tester.pumpAndSettle();
      expect(find.text('notes.txt'), findsNothing);
      expect(find.text('1 file · 500 B'), findsOneWidget);
    });

    testWidgets('warns about skipped uploads and submits the others', (
      tester,
    ) async {
      final (upcloud, submitted) = await pumpComposer(tester);

      await tester.tap(key('upcloud-composer-add-files'));
      await tester.pumpAndSettle();
      await tester.tap(key('upcloud-composer-select-all'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 3 selected'), findsOneWidget);
      expect(find.text('Select none'), findsOneWidget);

      expect(key('upcloud-composer-skipped'), findsOneWidget);
      expect(find.text('2 uploads will be skipped'), findsOneWidget);
      expect(
        find.text('notes.txt → Video main: Files of type .txt are not allowed'),
        findsOneWidget,
      );
      expect(find.text('Start 4 uploads'), findsOneWidget);
      // The file rows show which accounts skip them.
      expect(
        find.textContaining('Skipped for Video main, Video backup'),
        findsOneWidget,
      );

      await tester.enterText(key('upcloud-composer-folder'), 'Movies/2026');
      await tester.tap(key('upcloud-composer-submit'));
      await tester.pumpAndSettle();

      final batch = submitted.single;
      expect(batch.tasks, hasLength(4));
      expect(batch.folderPath, 'Movies/2026');
      expect(upcloud.transfers.tasks, hasLength(4));
      // Files are cleared, accounts and folder are kept.
      expect(find.text('No files yet'), findsOneWidget);
      expect(find.text('3 of 3 selected'), findsOneWidget);
      expect(find.text('Movies/2026'), findsOneWidget);
      expect(key('upcloud-composer-skipped'), findsNothing);
    });

    testWidgets('selects accounts one by one', (tester) async {
      final (upcloud, submitted) = await pumpComposer(
        tester,
        pick: () => [movie],
      );
      final files = upcloud.accounts[1];

      await tester.tap(key('upcloud-composer-add-files'));
      await tester.pumpAndSettle();
      await tester.tap(key('upcloud-composer-account-${files.id}'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 selected'), findsOneWidget);
      expect(find.text('Start 1 upload'), findsOneWidget);

      await tester.tap(key('upcloud-composer-submit'));
      await tester.pumpAndSettle();
      expect(submitted.single.tasks.single.accountId, files.id);
    });

    testWidgets('suggests recent folders', (tester) async {
      await pumpComposer(tester);

      await tester.enterText(key('upcloud-composer-folder'), 'mov');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Movies/2025'));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(key('upcloud-composer-folder'));
      expect(field.controller!.text, 'Movies/2025');
    });

    testWidgets('shows a message without upload accounts', (tester) async {
      final upcloud = UpCloud(
        uploadExecutor: FakeUploadExecutor(),
        registry: offlineRegistry(),
      );
      addTearDown(upcloud.dispose);
      await upcloud.init();
      await pumpApp(
        tester,
        UploadComposer(onPickFiles: () async => []),
        upcloud: upcloud,
        size: const Size(800, 2000),
      );
      expect(find.text('No account can receive uploads'), findsOneWidget);
    });

    testWidgets('is translated to Spanish', (tester) async {
      await pumpComposer(tester, locale: const Locale('es'));

      await tester.tap(key('upcloud-composer-add-files'));
      await tester.pumpAndSettle();
      await tester.tap(key('upcloud-composer-select-all'));
      await tester.pumpAndSettle();

      expect(find.text('Archivos'), findsOneWidget);
      expect(find.text('3 de 3 seleccionadas'), findsOneWidget);
      expect(find.text('Carpeta de destino'), findsOneWidget);
      expect(find.text('Se omitirán 2 subidas'), findsOneWidget);
      expect(find.text('Iniciar 4 subidas'), findsOneWidget);
    });
  });
}
