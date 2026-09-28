import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:upcloud_flutter/src/uploads/background_upload_io.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

// The executor itself runs against a local server in
// example/integration_test/background_upload_executor_test.dart.
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('upcloud_test_');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  Future<Directory> tempDir() async => temp;

  group('buildUploadTask', () {
    test('multipart: fields, file field, method and headers', () {
      final task = buildUploadTask(
        UploadRequest(
          url: Uri.parse('https://up.example/upload?key=1'),
          method: 'put',
          fileField: 'file_0',
          fields: {'sess_id': 'x', 'utype': 'prem'},
          headers: {'Authorization': 'Bearer t'},
          context: {'secret': 's'},
        ),
        path: '/tmp/movie.mp4',
        displayName: 'movie.mp4',
        group: 'upcloud',
      );

      expect(task.url, 'https://up.example/upload?key=1');
      expect(task.httpRequestMethod, 'PUT');
      expect(task.post, isNull);
      expect(task.fileField, 'file_0');
      expect(task.fields, {'sess_id': 'x', 'utype': 'prem'});
      expect(task.headers, {'Authorization': 'Bearer t'});
      expect(task.filename, 'movie.mp4');
      expect(task.mimeType, 'video/mp4');
      expect(task.retries, 0);
      expect(task.updates, bd.Updates.statusAndProgress);
      expect(task.group, 'upcloud');
      expect(task.toJson().toString().contains('secret'), isFalse);
    });

    test('binary: content type and disposition', () {
      final task = buildUploadTask(
        UploadRequest(
          url: Uri.parse('https://up.example/simple'),
          encoding: UploadEncoding.binary,
          fields: {'ignored': 'yes'},
          headers: {'x-filename': 'a.mkv', 'content-type': 'video/x-matroska'},
        ),
        path: '/tmp/a.mkv',
        displayName: 'a.mkv',
        group: 'g',
      );

      expect(task.post, 'binary');
      expect(task.fields, isEmpty);
      expect(task.mimeType, 'video/x-matroska');
      // An empty Content-Disposition tells background_downloader to omit it.
      expect(task.headers, {'x-filename': 'a.mkv', 'Content-Disposition': ''});

      final withDisposition = buildUploadTask(
        UploadRequest(
          url: Uri.parse('https://up.example/simple'),
          encoding: UploadEncoding.binary,
          headers: {'content-disposition': 'attachment; filename="a.mkv"'},
        ),
        path: '/tmp/a.mkv',
        displayName: 'a.mkv',
        group: 'g',
      );
      expect(withDisposition.headers, {
        'Content-Disposition': 'attachment; filename="a.mkv"',
      });
    });

    test('rejects methods background_downloader cannot send', () {
      expect(
        () => buildUploadTask(
          UploadRequest(url: Uri.parse('https://x.example'), method: 'MKCOL'),
          path: '/tmp/a',
          displayName: 'a',
          group: 'g',
        ),
        throwsA(isA<UnsupportedOperationException>()),
      );
    });
  });

  group('uploadResponseFromUpdate', () {
    final task = bd.UploadTask(url: 'https://x.example', filename: 'a.mp4');

    UploadResponse map(
      bd.TaskStatus status, {
      bd.TaskException? exception,
      String? body,
      int? code,
      Map<String, String>? headers,
    }) => uploadResponseFromUpdate(
      bd.TaskStatusUpdate(task, status, exception, body, headers, code),
      fileName: 'a.mp4',
    );

    test('complete', () {
      final response = map(
        bd.TaskStatus.complete,
        body: '{"ok":1}',
        code: 201,
        headers: {'x-id': '1'},
      );
      expect(response.statusCode, 201);
      expect(response.body, '{"ok":1}');
      expect(response.header('X-Id'), '1');
    });

    test('HTTP errors are responses (body in responseBody)', () {
      final response = map(
        bd.TaskStatus.failed,
        exception: bd.TaskHttpException('Bad Request', 400),
        body: '{"msg":"bad"}',
      );
      expect(response.statusCode, 400);
      expect(response.body, '{"msg":"bad"}');
    });

    test('HTTP errors are responses (body in the exception, Android)', () {
      final response = map(
        bd.TaskStatus.failed,
        exception: bd.TaskHttpException('{"msg":"quota"}', 507),
      );
      expect(response.statusCode, 507);
      expect(response.body, '{"msg":"quota"}');
    });

    test('404 is a response', () {
      final response = map(
        bd.TaskStatus.notFound,
        exception: bd.TaskHttpException('not found', 404),
        body: 'missing',
        code: 404,
      );
      expect(response.statusCode, 404);
      expect(response.body, 'missing');
    });

    test('errors without response', () {
      expect(
        () => map(bd.TaskStatus.canceled),
        throwsA(isA<CancelledException>()),
      );
      expect(
        () => map(
          bd.TaskStatus.failed,
          exception: bd.TaskConnectionException('timed out'),
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(
        () => map(
          bd.TaskStatus.failed,
          exception: bd.TaskException('ClientException: Connection refused'),
        ),
        throwsA(isA<NetworkException>()),
      );
      // Android reports network I/O errors as file system errors: only a
      // missing file is a NotFoundException.
      expect(
        () => uploadResponseFromUpdate(
          bd.TaskStatusUpdate(
            task,
            bd.TaskStatus.failed,
            bd.TaskFileSystemException('File does not exist'),
          ),
          fileName: 'a.mp4',
          fileExists: false,
        ),
        throwsA(isA<NotFoundException>()),
      );
      expect(
        () => map(
          bd.TaskStatus.failed,
          exception: bd.TaskFileSystemException(
            'java.io.IOException: Cleartext HTTP traffic to 10.0.2.2 not '
            'permitted',
          ),
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(
        () => map(
          bd.TaskStatus.failed,
          exception: bd.TaskFileSystemException(
            'java.net.UnknownHostException: Unable to resolve host',
          ),
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('stageUploadSource', () {
    test('uses files in place when the name matches', () async {
      final file = File(p.join(temp.path, 'movie.mp4'))
        ..writeAsBytesSync([1, 2, 3]);
      final staged = await stageUploadSource(
        UploadSource.file(file.path),
        keepName: true,
        temporaryDirectory: tempDir,
      );
      expect(staged.path, file.path);
      expect(staged.length, 3);
      expect(staged.directory, isNull);
      await staged.delete();
      expect(file.existsSync(), isTrue);
    });

    test('links files under the source name for multipart', () async {
      final file = File(p.join(temp.path, 'tmp_1234'))
        ..writeAsBytesSync([1, 2, 3, 4]);
      final staged = await stageUploadSource(
        UploadSource.file(file.path, name: 'holiday.mp4'),
        keepName: true,
        temporaryDirectory: tempDir,
      );
      expect(p.basename(staged.path), 'holiday.mp4');
      expect(File(staged.path).readAsBytesSync(), [1, 2, 3, 4]);
      await staged.delete();
      expect(File(staged.path).existsSync(), isFalse);
      expect(file.existsSync(), isTrue);

      // Binary uploads do not send the name.
      final binary = await stageUploadSource(
        UploadSource.file(file.path, name: 'holiday.mp4'),
        keepName: false,
        temporaryDirectory: tempDir,
      );
      expect(binary.path, file.path);
    });

    test('writes bytes and streams to temporary files', () async {
      final bytes = await stageUploadSource(
        const UploadSource.bytes([5, 6], name: 'a/b.txt'),
        keepName: true,
        temporaryDirectory: tempDir,
      );
      expect(p.basename(bytes.path), 'a_b.txt');
      expect(File(bytes.path).readAsBytesSync(), [5, 6]);

      final stream = await stageUploadSource(
        UploadSource.stream(
          () => Stream.fromIterable([
            [1],
            [2, 3],
          ]),
          name: 'c.bin',
          length: 3,
        ),
        keepName: false,
        temporaryDirectory: tempDir,
      );
      expect(File(stream.path).readAsBytesSync(), [1, 2, 3]);
      expect(stream.length, 3);

      await bytes.delete();
      await stream.delete();
      expect(bytes.directory!.existsSync(), isFalse);
      expect(stream.directory!.existsSync(), isFalse);
    });

    test('unreadable sources are NotFoundExceptions', () async {
      await expectLater(
        stageUploadSource(
          UploadSource.file(p.join(temp.path, 'missing.mp4')),
          keepName: true,
          temporaryDirectory: tempDir,
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        stageUploadSource(
          UploadSource.stream(
            () => Stream.error(const FileSystemException('gone')),
            name: 'x.bin',
            length: 1,
          ),
          keepName: true,
          temporaryDirectory: tempDir,
        ),
        throwsA(isA<NotFoundException>()),
      );
      // Nothing is left behind.
      final root = Directory(p.join(temp.path, 'upcloud_uploads'));
      expect(root.listSync(), isEmpty);
    });
  });

  test('safeFileName', () {
    expect(safeFileName('movie.mp4'), 'movie.mp4');
    expect(safeFileName(r'a/b\c.txt'), 'a_b_c.txt');
    expect(safeFileName('..'), 'file');
    expect(safeFileName('  '), 'file');
  });
}
