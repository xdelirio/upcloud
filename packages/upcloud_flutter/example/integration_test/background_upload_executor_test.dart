// Runs BackgroundUploadExecutor against a local HTTP server:
//
//   flutter test integration_test -d macos
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

/// A part of a multipart request.
typedef Part = ({
  String name,
  String? filename,
  String? contentType,
  Uint8List bytes,
});

/// A request received by [TestServer].
final class Received {
  Received(this.method, this.uri, this.headers, this.body, this.parts);

  final String method;
  final Uri uri;
  final HttpHeaders headers;
  final Uint8List body;

  /// Parts of a multipart body, in order; empty otherwise.
  final List<Part> parts;
}

/// A local server whose routes answer like upload endpoints.
final class TestServer {
  TestServer._(this._server) {
    _server.listen(_handle);
  }

  static Future<TestServer> start() async =>
      TestServer._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  final HttpServer _server;
  final requests = <Received>[];
  final _received = StreamController<Received>.broadcast();

  /// Emits every request once its body was read.
  Stream<Received> get received => _received.stream;

  Uri url(String path, [Map<String, String>? query]) => Uri(
    scheme: 'http',
    host: '127.0.0.1',
    port: _server.port,
    path: path,
    queryParameters: query,
  );

  Future<void> close() async {
    await _server.close(force: true);
    await _received.close();
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      // `/slow` reads the body at about 4 MB/s, like a slow network.
      final slow = request.uri.path == '/slow';
      final builder = BytesBuilder(copy: false);
      await for (final chunk in request) {
        builder.add(chunk);
        if (slow) {
          await Future<void>.delayed(Duration(microseconds: chunk.length ~/ 4));
        }
      }
      final body = builder.takeBytes();
      final received = Received(
        request.method,
        request.uri,
        request.headers,
        body,
        await _parts(request.headers.contentType, body),
      );
      requests.add(received);
      if (!_received.isClosed) _received.add(received);

      final (status, answer) = switch (request.uri.path) {
        '/reject' => (
          HttpStatus.badRequest,
          {'error': 'File type not allowed'},
        ),
        '/missing' => (HttpStatus.notFound, {'error': 'No such folder'}),
        '/binary' => (HttpStatus.created, {'size': body.length}),
        _ => (HttpStatus.ok, {'ok': true, 'size': body.length}),
      };
      final response = request.response
        ..statusCode = status
        ..headers.set('x-upload-id', 'abc123')
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(answer));
      await response.close();
    } on Object {
      // The client went away (cancelled upload).
    }
  }

  static Future<List<Part>> _parts(ContentType? type, Uint8List body) async {
    final boundary = type?.parameters['boundary'];
    if (type?.mimeType != 'multipart/form-data' || boundary == null) {
      return const [];
    }
    final parts = <Part>[];
    final stream = MimeMultipartTransformer(boundary).bind(Stream.value(body));
    await for (final part in stream) {
      final disposition = HeaderValue.parse(
        part.headers['content-disposition']!,
        preserveBackslash: true,
      );
      final bytes = BytesBuilder(copy: false);
      await part.forEach(bytes.add);
      parts.add((
        name: disposition.parameters['name']!,
        filename: disposition.parameters['filename'],
        contentType: part.headers['content-type'],
        bytes: bytes.takeBytes(),
      ));
    }
    return parts;
  }
}

Uint8List sample(int length) =>
    Uint8List.fromList(List.generate(length, (i) => (i * 31 + 7) % 256));

Future<Directory> stagingRoot() async =>
    Directory(p.join((await getTemporaryDirectory()).path, 'upcloud_uploads'));

/// Waits until the temporary files of the uploads are gone.
Future<void> expectNoStagedFiles() async {
  final root = await stagingRoot();
  for (var i = 0; i < 100; i++) {
    if (!root.existsSync() || root.listSync().isEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  fail('Temporary upload files were not deleted: ${root.listSync()}');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // With the default notifications: desktop shows none, but the setup
  // must not get in the way.
  final executor = BackgroundUploadExecutor();
  late TestServer server;
  late Directory files;

  setUp(() async {
    server = await TestServer.start();
    files = await Directory.systemTemp.createTemp('upcloud_it_');
  });

  tearDown(() async {
    await server.close();
    await files.delete(recursive: true);
  });

  File writeFile(String name, List<int> bytes) =>
      File(p.join(files.path, name))..writeAsBytesSync(bytes);

  testWidgets('multipart: fields first, then the file part', (_) async {
    final bytes = sample(300 * 1024);
    final file = writeFile('on_disk.bin', bytes);
    final progress = <TransferProgress>[];

    final response = await executor.execute(
      UploadRequest(
        url: server.url('/upload', {'api_key': 'k'}),
        fileField: 'file_0',
        fields: {'sess_id': 'xyz', 'utype': 'prem', 'fld_id': '42'},
        headers: {'x-client': 'upcloud'},
        context: {'secret': 'never-sent'},
      ),
      // The provider gets the name of the source, not the one on disk.
      UploadSource.file(file.path, name: 'video.mp4'),
      onProgress: progress.add,
    );

    expect(response.statusCode, 200);
    expect(jsonDecode(response.body), {'ok': true, 'size': isPositive});
    expect(response.header('X-Upload-Id'), 'abc123');

    final request = server.requests.single;
    expect(request.method, 'POST');
    expect(request.uri.queryParameters, {'api_key': 'k'});
    expect(request.headers.value('x-client'), 'upcloud');
    expect(request.parts.map((part) => part.name), [
      'sess_id',
      'utype',
      'fld_id',
      'file_0',
    ]);
    expect(utf8.decode(request.parts[0].bytes), 'xyz');
    expect(utf8.decode(request.parts[2].bytes), '42');
    final filePart = request.parts.last;
    expect(filePart.filename, 'video.mp4');
    expect(filePart.contentType, 'video/mp4');
    expect(filePart.bytes, bytes);
    // The context stays on the device.
    expect(latin1.decode(request.body).contains('never-sent'), isFalse);
    expect(request.headers.toString().contains('never-sent'), isFalse);

    expect(progress, isNotEmpty);
    expect(progress.every((e) => e.total == bytes.length), isTrue);
    expect(progress.last.transferred, bytes.length);
    await expectNoStagedFiles();
  });

  testWidgets('binary: the file is the body, with the request headers', (
    _,
  ) async {
    final bytes = sample(200 * 1024);
    final file = writeFile('movie.mkv', bytes);

    final response = await executor.execute(
      UploadRequest(
        url: server.url('/binary'),
        method: 'PUT',
        encoding: UploadEncoding.binary,
        headers: {
          'x-filename': 'movie.mkv',
          'x-filesize': '${bytes.length}',
          'Content-Type': 'application/octet-stream',
        },
        fields: {'ignored': 'yes'},
        context: {'secret': 'never-sent'},
      ),
      UploadSource.file(file.path),
    );

    expect(response.statusCode, 201);
    expect(jsonDecode(response.body), {'size': bytes.length});
    final request = server.requests.single;
    expect(request.method, 'PUT');
    expect(request.body, bytes);
    expect(request.headers.value('x-filename'), 'movie.mkv');
    expect(request.headers.value('x-filesize'), '${bytes.length}');
    expect(request.headers.contentType?.mimeType, 'application/octet-stream');
    expect(request.headers.value('content-disposition'), isNull);
    expect(request.headers.toString().contains('never-sent'), isFalse);
  });

  testWidgets('bytes and streams go through temporary files', (_) async {
    final bytes = sample(64 * 1024);

    final fromBytes = await executor.execute(
      UploadRequest(url: server.url('/upload')),
      UploadSource.bytes(bytes, name: 'photo.jpg'),
    );
    final fromStream = await executor.execute(
      UploadRequest(
        url: server.url('/binary'),
        encoding: UploadEncoding.binary,
      ),
      UploadSource.stream(
        () =>
            Stream.fromIterable([bytes.sublist(0, 1000), bytes.sublist(1000)]),
        name: 'clip.webm',
        length: bytes.length,
      ),
    );

    expect(fromBytes.statusCode, 200);
    expect(fromStream.statusCode, 201);
    final [multipart, binary] = server.requests;
    expect(multipart.parts.single.filename, 'photo.jpg');
    expect(multipart.parts.single.bytes, bytes);
    expect(binary.body, bytes);
    await expectNoStagedFiles();
  });

  testWidgets('error statuses are returned with their body', (_) async {
    final file = writeFile('archive.zip', sample(1024));

    final rejected = await executor.execute(
      UploadRequest(url: server.url('/reject')),
      UploadSource.file(file.path),
    );
    expect(rejected.statusCode, 400);
    expect(rejected.isSuccessful, isFalse);
    expect(jsonDecode(rejected.body), {'error': 'File type not allowed'});
    expect(rejected.header('x-upload-id'), 'abc123');

    final missing = await executor.execute(
      UploadRequest(
        url: server.url('/missing'),
        encoding: UploadEncoding.binary,
      ),
      UploadSource.file(file.path),
    );
    expect(missing.statusCode, 404);
    expect(jsonDecode(missing.body), {'error': 'No such folder'});
  });

  testWidgets('reports progress while sending', (_) async {
    final bytes = sample(6 * 1024 * 1024);
    final file = writeFile('big.bin', bytes);
    final progress = <TransferProgress>[];

    final response = await executor.execute(
      UploadRequest(url: server.url('/slow'), encoding: UploadEncoding.binary),
      UploadSource.file(file.path),
      onProgress: progress.add,
    );

    expect(response.statusCode, 200);
    final sent = [for (final e in progress) e.transferred];
    expect(sent.first, 0);
    expect(sent.last, bytes.length);
    expect(sent.where((s) => s > 0 && s < bytes.length), isNotEmpty);
    for (var i = 1; i < sent.length; i++) {
      expect(sent[i], greaterThanOrEqualTo(sent[i - 1]));
    }
  });

  testWidgets('cancelling throws CancelledException right away', (_) async {
    final bytes = sample(24 * 1024 * 1024);
    final token = CancellationToken();
    final started = Completer<void>();

    final upload = executor.execute(
      UploadRequest(url: server.url('/slow')),
      UploadSource.bytes(bytes, name: 'big.mp4'),
      cancelToken: token,
      onProgress: (progress) {
        if (progress.transferred > 0 && !started.isCompleted) {
          started.complete();
        }
      },
    );
    await started.future.timeout(const Duration(seconds: 30));
    final stopwatch = Stopwatch()..start();
    token.cancel();

    await expectLater(upload, throwsA(isA<CancelledException>()));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    // The background task stops and its temporary file is deleted.
    await expectNoStagedFiles();
  });

  testWidgets('a cancelled token stops before sending', (_) async {
    final token = CancellationToken()..cancel();
    await expectLater(
      executor.execute(
        UploadRequest(url: server.url('/upload')),
        const UploadSource.bytes([1, 2, 3], name: 'a.txt'),
        cancelToken: token,
      ),
      throwsA(isA<CancelledException>()),
    );
    expect(server.requests, isEmpty);
  });

  testWidgets('no response is a NetworkException', (_) async {
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = closed.port;
    await closed.close();
    final file = writeFile('a.mp4', sample(1024));

    await expectLater(
      executor.execute(
        UploadRequest(url: Uri.parse('http://127.0.0.1:$port/upload')),
        UploadSource.file(file.path),
      ),
      throwsA(isA<NetworkException>()),
    );
  });

  testWidgets('a missing file is a NotFoundException', (_) async {
    await expectLater(
      executor.execute(
        UploadRequest(url: server.url('/upload')),
        UploadSource.file(p.join(files.path, 'nope.mp4')),
      ),
      throwsA(isA<NotFoundException>()),
    );
    expect(server.requests, isEmpty);
  });
}
