import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:upcloud/upcloud.dart';

/// A minimal [UploadExecutor] for command line apps, built on `dart:io`.
///
/// Flutter apps should use the background executor of `upcloud_flutter`,
/// which keeps uploads running when the app is in the background.
final class IoUploadExecutor implements UploadExecutor {
  @override
  Future<UploadResponse> execute(
    UploadRequest request,
    UploadSource source, {
    void Function(TransferProgress progress)? onProgress,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) throw const CancelledException();
    final client = HttpClient();
    try {
      final length = await source.resolveLength();
      final http = await client.openUrl(request.method, request.url);
      unawaited(
        cancelToken?.whenCancelled.then(
          (_) => http.abort(const CancelledException()),
        ),
      );
      request.headers.forEach(http.headers.set);

      var sent = 0;
      final file = _read(source).map((chunk) {
        sent += chunk.length;
        onProgress?.call(TransferProgress(transferred: sent, total: length));
        return chunk;
      });
      final Stream<List<int>> body;
      switch (request.encoding) {
        case UploadEncoding.binary:
          body = file;
          if (length != null) http.contentLength = length;
        case UploadEncoding.multipart:
          final boundary = 'upcloud${DateTime.now().microsecondsSinceEpoch}';
          http.headers.contentType = ContentType(
            'multipart',
            'form-data',
            parameters: {'boundary': boundary},
          );
          final head = utf8.encode(_multipartHead(request, source, boundary));
          final tail = utf8.encode('\r\n--$boundary--\r\n');
          if (length != null) {
            http.contentLength = head.length + length + tail.length;
          }
          body = _concat([Stream.value(head), file, Stream.value(tail)]);
      }

      await http.addStream(body);
      final response = await http.close();
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name] = values.join(', ');
      });
      return UploadResponse(
        statusCode: response.statusCode,
        body: await response.transform(utf8.decoder).join(),
        headers: headers,
      );
    } on UpCloudException {
      rethrow;
    } on FileSystemException catch (e, st) {
      throw NotFoundException(
        'Cannot read ${source.name}: ${e.message}',
        cause: e,
        stackTrace: st,
      );
    } on IOException catch (e, st) {
      throw NetworkException('$e', cause: e, stackTrace: st);
    } finally {
      client.close(force: true);
    }
  }

  /// Form fields followed by the header of the file part.
  static String _multipartHead(
    UploadRequest request,
    UploadSource source,
    String boundary,
  ) {
    String quote(String value) => value.replaceAll('"', '%22');
    final head = StringBuffer();
    for (final MapEntry(:key, :value) in request.fields.entries) {
      head
        ..write('--$boundary\r\n')
        ..write('content-disposition: form-data; name="${quote(key)}"\r\n\r\n')
        ..write('$value\r\n');
    }
    return (head
          ..write('--$boundary\r\n')
          ..write(
            'content-disposition: form-data; '
            'name="${quote(request.fileField)}"; '
            'filename="${quote(source.name)}"\r\n',
          )
          ..write('content-type: application/octet-stream\r\n\r\n'))
        .toString();
  }

  static Stream<List<int>> _read(UploadSource source) => switch (source) {
    FileUploadSource(:final path) => File(path).openRead(),
    BytesUploadSource(:final bytes) => Stream.value(bytes),
    StreamUploadSource(:final open) => open(),
  };

  static Stream<List<int>> _concat(List<Stream<List<int>>> parts) async* {
    for (final part in parts) {
      yield* part;
    }
  }
}
