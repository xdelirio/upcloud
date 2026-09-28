// Printing is the point of this command line example.
// ignore_for_file: avoid_print

// Command line example: lists the root folder of an account and uploads a
// file.
//
//   dart run example/upcloud_example.dart streamhg <api-key> [file]
import 'dart:io';

import 'package:upcloud/upcloud.dart';

import 'io_upload_executor.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('Usage: upcloud_example <provider-id> <api-key> [file]');
    exitCode = 64;
    return;
  }
  final [providerId, apiKey, ...rest] = args;

  final upcloud = UpCloud(uploadExecutor: IoUploadExecutor());
  await upcloud.init();
  print('Providers: ${upcloud.providers.map((p) => p.id).join(', ')}');

  try {
    final account = await upcloud.addAccount(
      providerId: providerId,
      credentials: Credentials.apiKey(apiKey),
    );
    print('Connected as ${account.label}');

    final provider = upcloud.connect(account.id);
    print('Capabilities: ${provider.capabilities.map((c) => c.name)}');

    if (provider case final FolderBrowsing browser) {
      final page = await browser.listFolder(null);
      for (final entry in page.items) {
        switch (entry) {
          case CloudFolder(:final name):
            print('  [dir]  $name');
          case CloudFile(:final name, :final size):
            print('  [file] $name ${size ?? ''}');
        }
      }
    }

    if (rest.isNotEmpty) {
      final task = upcloud.upload(account.id, UploadSource.file(rest.first));
      task.changes.listen((state) {
        if (state case TransferRunning(:final progress)) {
          final percent = ((progress.fraction ?? 0) * 100).round();
          stdout.write('\rUploading... $percent %');
        }
      });
      final file = await task.result;
      print('\nUploaded ${file.name} (${file.id.value})');
    }
  } on UpCloudException catch (e) {
    stderr.writeln('Error: ${e.message}');
    exitCode = 1;
  } finally {
    await upcloud.dispose();
  }
}
