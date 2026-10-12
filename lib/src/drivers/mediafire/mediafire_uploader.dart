import 'dart:async';

import 'package:upcloud/src/core/cancellation.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/models/upload_request.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_api.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_dtos.dart';

/// Prepares MediaFire uploads (`upload/simple`) and waits until the
/// uploaded file gets a quickkey.
///
/// The file is sent as the raw request body with the `x-filename` and
/// `x-filesize` headers; `upload/poll_upload` is then polled until
/// MediaFire finishes processing it.
final class MediaFireUploader {
  /// Creates an uploader that calls MediaFire through a [MediaFireApi].
  MediaFireUploader(
    this._api, {
    this.pollInterval = const Duration(seconds: 2),
    this.pollTimeout = const Duration(minutes: 10),
  });

  final MediaFireApi _api;

  /// Delay between two `upload/poll_upload` calls.
  final Duration pollInterval;

  /// Maximum time to wait for MediaFire to process an upload.
  final Duration pollTimeout;

  /// Prepares the upload of [file] into [folderKey].
  ///
  /// [fields] are added to the query and override the defaults (e.g.
  /// `{'action_on_duplicate': 'replace'}`); [context] is kept in the
  /// request for the provider.
  Future<UploadRequest> prepare(
    UploadFileInfo file, {
    required String folderKey,
    Map<String, String> fields = const {},
    Map<String, String> context = const {},
  }) async {
    final url = await _api.authenticatedUrl('upload/simple', {
      'folder_key': folderKey,
      'action_on_duplicate': 'keep',
      ...fields,
    });
    return UploadRequest(
      url: url,
      encoding: UploadEncoding.binary,
      headers: {
        'content-type': 'application/octet-stream',
        'x-filename': file.name,
        'x-filesize': ?file.size?.toString(),
      },
      context: context,
    );
  }

  /// Reads the upload key of [response] and polls `upload/poll_upload`
  /// until the file has a quickkey.
  ///
  /// Errors reported once MediaFire accepted the file carry the HTTP
  /// status of [response], so the file is not uploaded again. Polling
  /// stops with a [CancelledException] when [cancelToken] is cancelled.
  Future<MediaFireDoUploadDto> complete(
    UploadRequest request,
    UploadResponse response, {
    CancellationToken? cancelToken,
  }) async {
    final body = _api.parseUploadResponse(request, response);
    final status = response.statusCode;
    final upload = _doUpload(body);
    _checkUploadResult(upload?.result);
    final key = upload?.key;
    if (key == null) {
      throw ProviderException(
        'MediaFire did not return an upload key',
        statusCode: status,
        response: body,
      );
    }
    return await _poll(key, status, cancelToken);
  }

  /// Polls `upload/poll_upload` until the upload has a quickkey.
  ///
  /// MediaFire already has the file, so transient failures of the poll
  /// are tried again until [pollTimeout] instead of being thrown:
  /// uploading the file again would duplicate it.
  Future<MediaFireDoUploadDto> _poll(
    String key,
    int status,
    CancellationToken? cancelToken,
  ) async {
    final watch = Stopwatch()..start();
    while (true) {
      if (cancelToken?.isCancelled ?? false) throw const CancelledException();
      final Map<String, Object?> body;
      try {
        body = await _api.request(
          'upload/poll_upload',
          params: {'key': key},
          retryable: true,
        );
      } on UpCloudException catch (e) {
        if (!_isTransient(e)) rethrow;
        if (watch.elapsed >= pollTimeout) {
          throw ProviderException(
            'MediaFire did not confirm the upload (key $key)',
            statusCode: status,
            cause: e,
          );
        }
        await _pause(cancelToken);
        continue;
      }
      final upload = _doUpload(body);
      if (upload == null) {
        throw ProviderException(
          'Unexpected poll response from MediaFire',
          statusCode: status,
          response: body,
        );
      }
      _checkUploadResult(upload.result);
      final fileError = upload.fileerror;
      if (fileError != null && fileError != 0) {
        throw _fileErrorException(fileError, upload.description);
      }
      if (upload.status == 99) {
        if (upload.quickkey != null) return upload;
        throw ProviderException(
          'MediaFire finished the upload without creating a file',
          statusCode: status,
          response: body,
        );
      }
      if (watch.elapsed >= pollTimeout) {
        throw ProviderException(
          'MediaFire is still processing the upload (key $key)',
          statusCode: status,
          response: body,
        );
      }
      await _pause(cancelToken);
    }
  }

  /// Waits [pollInterval], or less when [cancelToken] is cancelled.
  Future<void> _pause(CancellationToken? cancelToken) => Future.any([
    Future<void>.delayed(pollInterval),
    ?cancelToken?.whenCancelled,
  ]);

  /// Whether a poll that failed with [error] may work if sent again.
  static bool _isTransient(UpCloudException error) => switch (error) {
    NetworkException() || RateLimitedException() => true,
    ProviderException(:final statusCode) =>
      statusCode == null || statusCode >= 500,
    _ => false,
  };

  static MediaFireDoUploadDto? _doUpload(Map<String, Object?> body) {
    final single = readMap(body['doupload']);
    final map = single ?? readMap(readList(body['douploads']).firstOrNull);
    return map == null ? null : MediaFireDoUploadDto.fromJson(map);
  }

  /// Maps the `doupload.result` codes documented for `upload/simple`.
  static void _checkUploadResult(int? result) {
    if (result == null || result == 0) return;
    throw switch (result) {
      -14 || -206 => NotFoundException(
        'The destination folder does not exist ($result)',
      ),
      -41 || -42 || -700 || -701 || -881 || -882 => ProviderException(
        result == -881
            ? 'The file exceeds the size limit of free MediaFire accounts'
            : 'The file exceeds the maximum size allowed by MediaFire',
        statusCode: result,
      ),
      -205 => ProviderException(
        'No permission to upload to the destination folder',
        statusCode: result,
      ),
      _ => ProviderException('Upload failed ($result)', statusCode: result),
    };
  }

  /// Maps the `fileerror` codes of `upload/poll_upload`.
  static UpCloudException _fileErrorException(int code, String? description) {
    final message = switch (code) {
      1 => 'The file exceeds the maximum size',
      2 => 'The file is empty',
      5 => 'The file contains a virus',
      7 => 'Hash or size mismatch',
      13 => 'A file with the same name already exists in the destination',
      14 => 'The destination folder does not exist',
      15 => 'The MediaFire storage is full',
      18 => 'The account is blocked',
      _ => description ?? 'Upload failed',
    };
    return switch (code) {
      14 => NotFoundException(message),
      15 => QuotaExceededException(message),
      _ => ProviderException('$message (file error $code)', statusCode: code),
    };
  }
}
