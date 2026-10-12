// Live check of BackgroundUploadExecutor against a real provider. It is
// skipped by default (tag `live`, see dart_test.yaml): each file of
// integration_test/ launches the app, and macOS cannot start it twice in
// one `flutter test integration_test` run. Run it on its own, with the
// credentials of the repository's .env file as defines:
//
//   flutter test integration_test/live_upload_test.dart -d macos \
//     --run-skipped --dart-define-from-file=.env
//
// Without credentials it skips itself. See "Live tests" in
// CONTRIBUTING.md.
//
// Printing is how the test reports what it did.
// ignore_for_file: avoid_print
@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:upcloud/ui.dart';

import 'live_sample.dart';

const _streamHgKey = String.fromEnvironment('STREAMHG_API_KEY');
const _earnVidsKey = String.fromEnvironment('EARNVIDS_API_KEY');
const _byseKey = String.fromEnvironment('BYSE_API_KEY');
const _mediaFireEmail = String.fromEnvironment('MEDIAFIRE_EMAIL');
const _mediaFirePassword = String.fromEnvironment('MEDIAFIRE_PASSWORD');

/// Optional: comma separated provider ids to choose from.
const _providers = String.fromEnvironment('UPCLOUD_LIVE_PROVIDERS');

const List<String> _secrets = [
  _streamHgKey,
  _earnVidsKey,
  _byseKey,
  _mediaFireEmail,
  _mediaFirePassword,
];

/// [value] as text without credentials.
String scrub(Object? value) {
  var text = '$value';
  for (final secret in _secrets) {
    if (secret.length < 3) continue;
    for (final form in {
      secret,
      Uri.encodeComponent(secret),
      Uri.encodeQueryComponent(secret),
    }) {
      text = text.replaceAll(
        RegExp(RegExp.escape(form), caseSensitive: false),
        '<redacted>',
      );
    }
  }
  return text;
}

void log(String message) => print(scrub(message));

/// The first provider with credentials: StreamHG, EarnVids, Byse, then
/// MediaFire.
(String, Credentials)? _pickProvider() {
  final wanted = _providers
      .split(',')
      .map((id) => id.trim().toLowerCase())
      .where((id) => id.isNotEmpty)
      .toSet();
  final candidates = <(String, Credentials?)>[
    (
      'streamhg',
      _streamHgKey.isEmpty ? null : Credentials.apiKey(_streamHgKey),
    ),
    (
      'earnvids',
      _earnVidsKey.isEmpty ? null : Credentials.apiKey(_earnVidsKey),
    ),
    ('byse', _byseKey.isEmpty ? null : Credentials.apiKey(_byseKey)),
    (
      'mediafire',
      _mediaFireEmail.isEmpty || _mediaFirePassword.isEmpty
          ? null
          : MediaFireCredentials.create(
              email: _mediaFireEmail,
              password: _mediaFirePassword,
            ),
    ),
  ];
  for (final (id, credentials) in candidates) {
    if (credentials == null) continue;
    if (wanted.isNotEmpty && !wanted.contains(id)) continue;
    return (id, credentials);
  }
  return null;
}

/// Calls [action] until it stops throwing [NotFoundException] (new files
/// are indexed with some delay), for up to [timeout].
Future<T> eventually<T>(
  Future<T> Function() action, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final watch = Stopwatch()..start();
  while (true) {
    try {
      return await action();
    } on NotFoundException {
      if (watch.elapsed >= timeout) rethrow;
    }
    await Future<void>.delayed(const Duration(seconds: 3));
  }
}

/// Runs [body] and rethrows its errors without credentials.
Future<void> guard(Future<void> Function() body) async {
  try {
    await body();
  } on TestFailure catch (e, st) {
    Error.throwWithStackTrace(TestFailure(scrub(e.message)), st);
  } on UpCloudException catch (e, st) {
    Error.throwWithStackTrace(
      StateError(scrub('${e.runtimeType}: ${e.message}')),
      st,
    );
  } on Object catch (e, st) {
    Error.throwWithStackTrace(StateError(scrub(e)), st);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final picked = _pickProvider();

  testWidgets(
    'BackgroundUploadExecutor uploads a video to '
    '${picked?.$1 ?? 'a live provider (no credentials defined: skipped)'}',
    timeout: const Timeout(Duration(minutes: 5)),
    (_) => guard(() async {
      // Checked here: `--run-skipped` also ignores a `skip` argument.
      if (picked == null) {
        markTestSkipped('No credentials defined');
        return;
      }
      final (providerId, credentials) = picked;
      final now = DateTime.now().toUtc();
      final runId = 'flutter-${now.millisecondsSinceEpoch.toRadixString(36)}';
      const testRoot = 'upcloud-live-test';
      final folderPath = '$testRoot/$runId';

      final upcloud = UpCloud(
        uploadExecutor: BackgroundUploadExecutor(),
        registry: ProviderRegistry(useRemote: false),
        disposeRegistry: true,
      );
      final dir = await Directory(
        p.join((await getTemporaryDirectory()).path, 'upcloud_live'),
      ).create(recursive: true);
      try {
        await upcloud.init(refreshRegistry: false);
        // Report failures instead of uploading the file again.
        await upcloud.updateSettings(upcloud.settings.copyWith(retries: 0));
        final account = await upcloud.addAccount(
          providerId: providerId,
          credentials: credentials,
          verify: false,
        );
        final provider = upcloud.connect(account.id);

        final video = File(p.join(dir.path, 'upcloud-live-$runId.mp4'))
          ..writeAsBytesSync(base64Decode(liveSampleBase64));
        final length = video.lengthSync();
        final task = upcloud.upload(
          account.id,
          UploadSource.file(video.path),
          folderPath: folderPath,
        );
        var sent = 0;
        final subscription = task.changes.listen((state) {
          if (state case TransferRunning(:final progress)) {
            sent = progress.transferred;
          }
        });
        final CloudFile file;
        try {
          file = await task.result;
        } finally {
          await subscription.cancel();
        }
        final folderId = await upcloud.resolveFolderPath(
          account.id,
          folderPath,
          create: false,
        );
        log(
          '$providerId: uploaded ${file.id.value} "${file.name}" into '
          '"$folderPath" (${folderId?.value}), page ${file.pageUrl}',
        );

        expect(sent, length);
        expect(file.id.value, isNotEmpty);
        expect(file.folderId, folderId);
        expect(file.pageUrl?.scheme, 'https');
        expect('${file.pageUrl}', contains(file.id.value));
        final info = await eventually(
          () => provider.capability<FileManaging>()!.fileInfo(file.id),
        );
        expect(info.id, file.id);
        expect(info.folderId, folderId);

        // Delete what the test created, where the API allows it.
        final left = <String>[];
        if (provider.supports(Capability.deleteFile)) {
          await provider.capability<FileManaging>()!.deleteFile(file.id);
        } else {
          left.add('file "${file.name}" (${file.id.value})');
        }
        if (provider.supports(Capability.deleteFolder)) {
          await provider.capability<FolderManaging>()!.deleteFolder(folderId!);
        } else {
          left.add('folder "$folderPath" (${folderId?.value})');
        }
        log(
          left.isEmpty
              ? '$providerId: deleted the file and its folder'
              : '$providerId cannot delete through its API, left: '
                    '${left.join(', ')}',
        );
      } finally {
        await upcloud.dispose();
        await dir.delete(recursive: true);
      }
    }),
  );
}
