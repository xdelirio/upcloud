// Live tests: they call the real APIs of the bundled providers with the
// credentials of the `.env` file at the root of the repository, and are
// skipped by default. See "Live tests" in CONTRIBUTING.md:
//
//   dart test -P live
//
// Every run works in its own folder, `upcloud-live-test/<run id>`, and
// deletes what it created where the API allows it. StreamHG, EarnVids and
// Byse cannot delete files or folders: the run prints what it left behind.
@Tags(['live'])
@TestOn('vm')
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

import '../support/io_upload_executor.dart';
import 'live_support.dart';

/// Folder of the account holding the folders of every run.
const testRoot = 'upcloud-live-test';

final LiveEnv env = LiveEnv.load();
final String runId = liveRunId();
final String folderPath = '$testRoot/$runId';

/// Provider ids from [LiveVars.providers], or `null` for all of them.
final Set<String>? selected = env[LiveVars.providers]
    ?.split(',')
    .map((id) => id.trim().toLowerCase())
    .where((id) => id.isNotEmpty)
    .toSet();

/// A provider under test and what the run created in its account.
final class LiveAccount {
  LiveAccount(
    this.providerId, {
    required this.variables,
    required this.credentials,
  });

  final String providerId;

  /// Variables that must be set to test the provider.
  final List<String> variables;

  final Credentials Function() credentials;

  String? accountId;

  /// Why the remaining tests of the provider cannot run.
  String? blocked;

  /// [testRoot] and the folder of this run.
  FolderId? rootId;
  FolderId? folderId;

  /// Files uploaded into [folderId].
  final files = <CloudFile>[];

  /// What the cleanup could not delete.
  final leftovers = <String>[];
  bool cleanedUp = false;

  bool get usesApiKey => providerId != 'mediafire';

  /// Why the provider is not tested, or `null`.
  String? get skipReason {
    if (selected case final ids? when !ids.contains(providerId)) {
      return 'Not listed in ${LiveVars.providers}';
    }
    final missing = env.missing(variables);
    return missing.isEmpty ? null : 'Set ${missing.join(', ')} in .env';
  }
}

final List<LiveAccount> accounts = [
  LiveAccount(
    'streamhg',
    variables: const [LiveVars.streamHgKey],
    credentials: () => Credentials.apiKey(env[LiveVars.streamHgKey]!),
  ),
  LiveAccount(
    'earnvids',
    variables: const [LiveVars.earnVidsKey],
    credentials: () => Credentials.apiKey(env[LiveVars.earnVidsKey]!),
  ),
  LiveAccount(
    'byse',
    variables: const [LiveVars.byseKey],
    credentials: () => Credentials.apiKey(env[LiveVars.byseKey]!),
  ),
  LiveAccount(
    'mediafire',
    variables: const [LiveVars.mediaFireEmail, LiveVars.mediaFirePassword],
    credentials: () => MediaFireCredentials.create(
      email: env[LiveVars.mediaFireEmail]!,
      password: env[LiveVars.mediaFirePassword]!,
      applicationId:
          env[LiveVars.mediaFireApplicationId] ??
          MediaFireCredentials.defaultApplicationId,
      apiKey: env[LiveVars.mediaFireApiKey],
    ),
  ),
];

/// The MediaFire error code and message of a failed call.
String mediaFireError(UpCloudException error) {
  final body = error.cause;
  final code = body is Map ? body['error'] : null;
  final message = body is Map
      ? body['message'] ?? error.message
      : error.message;
  return '${error.runtimeType}, MediaFire error ${code ?? '(no code)'}: '
      '$message';
}

void main() {
  UpCloud? upcloudOrNull;
  UpCloud upcloud() => upcloudOrNull!;
  Directory? tempOrNull;
  Directory temp() => tempOrNull!;
  final sample = File('test/fixtures/live/sample.mp4');
  final active = [
    for (final account in accounts)
      if (account.skipReason == null) account,
  ];

  CloudProvider connect(LiveAccount account) =>
      upcloud().connect(account.accountId!);

  /// Deletes what the run created in [account] where the API allows it.
  /// Returns the errors; what is left is added to `account.leftovers`.
  Future<List<String>> cleanUp(LiveAccount account) async {
    final errors = <String>[];
    if (account.accountId == null || account.cleanedUp) return errors;
    account.cleanedUp = true;
    final provider = connect(account);
    final manager = provider.capability<FileManaging>();
    final folders = provider.capability<FolderManaging>();
    final browser = provider.capability<FolderBrowsing>()!;
    final canDeleteFiles = provider.supports(Capability.deleteFile);
    final canDeleteFolders = provider.supports(Capability.deleteFolder);

    final kept = <String>[];
    for (final file in account.files) {
      if (!canDeleteFiles) {
        kept.add('"${file.name}" (${file.id.value})');
        continue;
      }
      try {
        await manager!.deleteFile(file.id);
        env.log('${account.providerId}: deleted file ${file.id.value}');
      } on UpCloudException catch (e) {
        errors.add('delete file ${file.id.value}: ${describeError(e)}');
        kept.add('"${file.name}" (${file.id.value})');
      }
    }
    final folderId = account.folderId;
    if (folderId != null) {
      var deleted = false;
      if (canDeleteFolders) {
        try {
          await folders!.deleteFolder(folderId);
          deleted = true;
          env.log('${account.providerId}: deleted folder "$folderPath"');
        } on UpCloudException catch (e) {
          errors.add('delete folder "$folderPath": ${describeError(e)}');
        }
      }
      if (!deleted) {
        account.leftovers.add(
          'folder "$folderPath" (id ${folderId.value})'
          '${kept.isEmpty ? '' : ' with files ${kept.join(', ')}'}',
        );
      } else if (kept.isNotEmpty) {
        account.leftovers.add('files ${kept.join(', ')}');
      }
    } else if (kept.isNotEmpty) {
      account.leftovers.add('files ${kept.join(', ')}');
    }

    // The root test folder goes once no run uses it.
    final rootId = account.rootId;
    if (rootId != null) {
      if (!canDeleteFolders) {
        account.leftovers.add('folder "$testRoot" (id ${rootId.value})');
      } else {
        try {
          final entries = await eventually(
            () => listAll(browser, rootId),
            until: (entries) => entries.isEmpty,
            timeout: const Duration(seconds: 30),
          );
          if (entries.isEmpty) {
            await folders!.deleteFolder(rootId);
            env.log('${account.providerId}: deleted folder "$testRoot"');
          } else {
            env.log(
              '${account.providerId}: kept "$testRoot", it still has '
              '${entries.length} entries: '
              '${entries.map((e) => '"${e.name}"').join(', ')}',
            );
            account.leftovers.add(
              'folder "$testRoot" (id ${rootId.value}), not empty',
            );
          }
        } on UpCloudException catch (e) {
          errors.add('delete folder "$testRoot": ${describeError(e)}');
          account.leftovers.add('folder "$testRoot" (id ${rootId.value})');
        }
      }
    }
    return errors;
  }

  setUpAll(
    () => env.guard(() async {
      tempOrNull = await Directory.systemTemp.createTemp('upcloud_live_');
      final verbose = env[LiveVars.verbose] == '1';
      final upcloud = upcloudOrNull = UpCloud(
        uploadExecutor: LoggingExecutor(IoUploadExecutor(), env),
        registry: ProviderRegistry(useRemote: false),
        disposeRegistry: true,
        optionsBuilder: (account, definition) => ProviderOptions(
          logger: verbose ? (line) => env.log('    $line') : null,
          // Never repeat a MediaFire sign-in: failed ones can lock the
          // account.
          maxRetries: definition.id == 'mediafire' ? 0 : 2,
        ),
      );
      await upcloud.init(refreshRegistry: false);
      // Report failures instead of uploading the files again.
      await upcloud.updateSettings(upcloud.settings.copyWith(retries: 0));
      for (final account in active) {
        final added = await upcloud.addAccount(
          providerId: account.providerId,
          credentials: account.credentials(),
          verify: false,
        );
        account.accountId = added.id;
      }
      final ids = active.map((a) => a.providerId).join(', ');
      env.log(
        'Live run $runId: ${ids.isEmpty ? 'no provider' : ids} '
        'into "$folderPath"',
      );
    }),
  );

  tearDownAll(
    () => env.guard(() async {
      final upcloud = upcloudOrNull;
      if (upcloud != null) {
        // Whatever the cleanup tests did not get to (e.g. filtered out).
        for (final account in active) {
          for (final error in await cleanUp(account)) {
            env.log('${account.providerId}: cleanup error: $error');
          }
        }
        await upcloud.dispose();
      }
      await tempOrNull?.delete(recursive: true);
      final leftovers = [
        for (final account in active)
          for (final leftover in account.leftovers)
            '  ${account.providerId}: $leftover',
      ];
      env.log(
        leftovers.isEmpty
            ? 'Live run $runId: nothing left on the accounts'
            : 'Live run $runId left on the accounts:\n${leftovers.join('\n')}',
      );
    }),
  );

  for (final account in accounts) {
    final id = account.providerId;

    /// A test of the provider, skipped once [LiveAccount.blocked] is set.
    ///
    /// The group is also skipped statically, but `--run-skipped` ignores
    /// that: the reason is checked again when the test runs.
    void liveTest(
      String description,
      Future<void> Function(CloudProvider provider) body, {
      Timeout? timeout,
      bool evenIfBlocked = false,
    }) {
      test(
        description,
        timeout: timeout,
        () => env.guard(() async {
          final reason =
              account.skipReason ?? (evenIfBlocked ? null : account.blocked);
          if (reason != null) {
            markTestSkipped(reason);
            return;
          }
          await body(connect(account));
        }),
      );
    }

    group(id, skip: account.skipReason ?? false, () {
      if (!account.usesApiKey) {
        // One sign-in for the whole group: the provider keeps its session.
        liveTest('signs in', (provider) async {
          try {
            await (provider as MediaFireProvider).signIn();
            env.log('$id: signed in');
          } on UpCloudException catch (e) {
            final reason = account.blocked =
                'Sign-in failed: ${mediaFireError(e)}';
            env.log('$id: $reason');
            fail(reason);
          }
        });
      }

      liveTest('accountInfo reports the login', (provider) async {
        final AccountInfo info;
        try {
          info = await provider
              .capability<AccountInfoProviding>()!
              .accountInfo();
        } on AuthenticationException catch (e) {
          account.blocked = 'Credentials rejected: ${e.message}';
          rethrow;
        }
        env.log(
          '$id: login ${info.login == null ? 'missing' : 'present'}, '
          'used ${info.storageUsed}, left ${info.storageLeft ?? 'unknown'}, '
          'files ${info.filesTotal ?? '?'}, premium ${info.isPremium}',
        );
        expect(info.login, isNotNull);
        expect(info.login, isNotEmpty);
      });

      liveTest('listFolder(null) lists the root folder', (provider) async {
        final browser = provider.capability<FolderBrowsing>()!;
        final page = await browser.listFolder(null);
        final folders = page.items.whereType<CloudFolder>().toList();
        final files = page.items.whereType<CloudFile>().toList();
        env.log(
          '$id: root has ${folders.length} folders and ${files.length} '
          'files on the first page (more: ${page.hasMore})',
        );
        // Folders first, and everything is in the root.
        expect(
          page.items.skipWhile((e) => e is CloudFolder),
          everyElement(isA<CloudFile>()),
        );
        expect(folders.map((f) => f.parentId), everyElement(isNull));
        expect(files.map((f) => f.folderId), everyElement(isNull));
        for (final file in files) {
          expect(file.pageUrl?.scheme, 'https', reason: file.id.value);
        }
      });

      liveTest(
        'resolveFolderPath creates the folders once',
        timeout: const Timeout(Duration(minutes: 3)),
        (provider) async {
          final accountId = account.accountId!;
          final browser = provider.capability<FolderBrowsing>()!;

          final created = await upcloud().resolveFolderPath(
            accountId,
            folderPath,
          );
          expect(created, isNotNull);
          account.folderId = created;
          final rootMatches = await eventually(
            () async => foldersNamed(await listAll(browser, null), testRoot),
            until: (found) => found.isNotEmpty,
          );
          expect(rootMatches, hasLength(1), reason: 'one "$testRoot"');
          account.rootId = rootMatches.single.id;
          env.log(
            '$id: "$folderPath" is folder ${created!.value} '
            '("$testRoot" is ${account.rootId!.value})',
          );

          // A new session (no cache) finds them instead of creating them.
          final runFolders = await eventually(
            () async =>
                foldersNamed(await listAll(browser, account.rootId), runId),
            until: (found) => found.isNotEmpty,
          );
          expect(runFolders.map((f) => f.id), [created]);
          expect(runFolders.single.parentId, account.rootId);
          upcloud().transfers.folders.invalidate(accountId);
          expect(
            await upcloud().resolveFolderPath(
              accountId,
              folderPath,
              create: false,
            ),
            created,
          );
          upcloud().transfers.folders.invalidate(accountId);
          expect(
            await upcloud().resolveFolderPath(accountId, folderPath),
            created,
          );
          expect(
            foldersNamed(await listAll(browser, null), testRoot),
            hasLength(1),
          );
          expect(
            foldersNamed(await listAll(browser, account.rootId), runId),
            hasLength(1),
          );
        },
      );

      if (account.usesApiKey) {
        liveTest('rejects an invalid API key', evenIfBlocked: true, (_) async {
          final provider = upcloud()
              .provider(id)!
              .create(
                Credentials.apiKey('upcloudLiveInvalidKey0'),
                options: const ProviderOptions(maxRetries: 0),
              );
          try {
            await expectLater(
              provider.capability<AccountInfoProviding>()!.accountInfo(),
              throwsA(isA<AuthenticationException>()),
            );
          } finally {
            provider.close();
          }
        });
      }

      liveTest('fileInfo of an unknown file is not found', (provider) async {
        await expectLater(
          provider.capability<FileManaging>()!.fileInfo(
            // Valid looking codes that do not exist.
            FileId(account.usesApiKey ? 'zzzzzzzzzzzz' : 'zzzzzzzzzzzzzzz'),
          ),
          throwsA(isA<NotFoundException>()),
        );
      });

      liveTest(
        'uploads a video into the folder path',
        timeout: const Timeout(Duration(minutes: 5)),
        (provider) async {
          if (account.folderId == null) {
            markTestSkipped('The folder of the run was not created');
            return;
          }
          final name = 'upcloud-live-$runId-$id.mp4';
          final video = uniqueVideo(
            sample,
            '${temp().path}/$name',
            '$runId $id',
          );
          final length = video.lengthSync();

          final task = upcloud().upload(
            account.accountId!,
            UploadSource.file(video.path),
            folderPath: folderPath,
          );
          var lastProgress = 0;
          final progress = task.changes.listen((state) {
            if (state case TransferRunning(:final progress)) {
              lastProgress = progress.transferred;
            }
          });
          final CloudFile file;
          try {
            file = await task.result;
          } finally {
            await progress.cancel();
          }
          account.files.add(file);
          env.log(
            '$id: uploaded ${file.id.value}: "${file.name}", size '
            '${file.size?.bytes ?? 'unknown'}, folder ${file.folderId?.value}, '
            'ready ${file.isReady}, page ${file.pageUrl}',
          );

          expect(lastProgress, length, reason: 'progress of the upload');
          expect(file.id.value, isNotEmpty);
          expect(alphanumeric(file.name), contains(alphanumeric(runId)));
          if (file.size case final size?) expect(size.bytes, length);
          expect(file.folderId, account.folderId);
          final pageUrl = file.pageUrl;
          expect(pageUrl, isNotNull);
          expect(pageUrl!.scheme, 'https');
          expect('$pageUrl', contains(file.id.value));

          final info = await eventually(
            () => provider.capability<FileManaging>()!.fileInfo(file.id),
          );
          env.log(
            '$id: fileInfo: "${info.name}", size '
            '${info.size?.bytes ?? 'unknown'}, folder ${info.folderId?.value}, '
            'ready ${info.isReady}, page ${info.pageUrl}',
          );
          expect(info.id, file.id);
          expect(alphanumeric(info.name), contains(alphanumeric(runId)));
          expect(info.folderId, account.folderId);
          if (info.size case final size?) expect(size.bytes, length);
          expect('${info.pageUrl}', contains(file.id.value));

          final listed = await eventually(
            () => listAll(
              provider.capability<FolderBrowsing>()!,
              account.folderId,
            ),
            until: (entries) => entries.any((e) => e.id == file.id),
          );
          final entry = listed.whereType<CloudFile>().singleWhere(
            (e) => e.id == file.id,
          );
          expect(entry.folderId, account.folderId);
          expect(alphanumeric(entry.name), contains(alphanumeric(runId)));
        },
      );
    });
  }

  group('batch', () {
    test(
      'uploads 2 files to 2 providers into the same folder path',
      timeout: const Timeout(Duration(minutes: 8)),
      () => env.guard(() async {
        // Prefer providers that can delete what the test uploads.
        final ready = [
          for (final account in active)
            if (account.blocked == null && account.folderId != null) account,
        ];
        bool canDelete(LiveAccount account) =>
            connect(account).supports(Capability.deleteFile);
        final targets = [
          ...ready.where(canDelete),
          ...ready.where((account) => !canDelete(account)),
        ].take(2).toList();
        if (targets.length < 2) {
          markTestSkipped('Needs 2 providers whose run folder was created');
          return;
        }
        final videos = [
          for (final label in ['a', 'b'])
            uniqueVideo(
              sample,
              '${temp().path}/upcloud-live-$runId-batch-$label.mp4',
              '$runId batch $label',
            ),
        ];

        final batch = upcloud().uploadBatch(
          files: [for (final video in videos) UploadSource.file(video.path)],
          accountIds: [for (final target in targets) target.accountId!],
          folderPath: folderPath,
        );
        expect(batch.tasks, hasLength(4));
        final errors = <String>[];
        for (final task in batch.tasks) {
          final target = targets.singleWhere(
            (t) => t.accountId == task.accountId,
          );
          try {
            final file = await task.result;
            target.files.add(file);
            env.log(
              'batch: ${target.providerId} uploaded ${file.id.value} '
              '"${file.name}" into folder ${file.folderId?.value}',
            );
            expect(file.folderId, target.folderId);
          } on UpCloudException catch (e) {
            errors.add('${target.providerId}: ${describeError(e)}');
          }
        }
        expect(errors, isEmpty);
        expect(batch.completedCount, 4);
        expect(await batch.results, hasLength(4));

        for (final target in targets) {
          final browser = connect(target).capability<FolderBrowsing>()!;
          final ids = {for (final file in target.files) file.id};
          final listed = await eventually(
            () => listAll(browser, target.folderId),
            until: (entries) =>
                ids.every((id) => entries.any((e) => e.id == id)),
          );
          expect(listed.map((e) => e.id), containsAll(ids));
          // The batch used the folder of the run, not a new one.
          expect(
            foldersNamed(await listAll(browser, target.rootId), runId),
            hasLength(1),
          );
        }
      }),
    );
  });

  group('cleanup', () {
    for (final account in accounts) {
      test(
        account.providerId,
        skip: account.skipReason ?? false,
        timeout: const Timeout(Duration(minutes: 3)),
        () => env.guard(() async {
          if (account.skipReason case final reason?) {
            markTestSkipped(reason);
            return;
          }
          final errors = await cleanUp(account);
          expect(errors, isEmpty);
          final accountId = account.accountId;
          final provider = connect(account);
          if (account.folderId != null &&
              provider.supports(Capability.deleteFolder)) {
            // A new session no longer finds the folder of the run.
            upcloud().transfers.folders.invalidate(accountId!);
            await expectLater(
              eventually(
                () async {
                  try {
                    await upcloud().resolveFolderPath(
                      accountId,
                      folderPath,
                      create: false,
                    );
                    upcloud().transfers.folders.invalidate(accountId);
                    return false;
                  } on NotFoundException {
                    return true;
                  }
                },
                until: (gone) => gone,
                timeout: const Duration(seconds: 45),
              ),
              completion(isTrue),
            );
          }
          if (account.leftovers.isNotEmpty) {
            markTestSkipped(
              '${account.providerId} cannot delete everything, left: '
              '${account.leftovers.join('; ')}',
            );
          }
        }),
      );
    }
  });
}
