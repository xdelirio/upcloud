import 'package:upcloud/src/core/cancellation.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/models/upload_request.dart';

/// Sends the bytes of an upload.
///
/// Providers only prepare the HTTP request (`FileUploading.prepareUpload`)
/// and read its response (`FileUploading.completeUpload`); an executor
/// sends it. The app uses `BackgroundUploadExecutor` (background
/// uploads); tests use `FakeUploadExecutor` from
/// `test/support`.
///
/// Implementations must:
///
/// * send [UploadRequest.fields] and the file as described by
///   [UploadRequest.encoding], and never send [UploadRequest.context];
/// * return the server response whatever its status code, so the provider
///   can read the error message of the body;
/// * report sent bytes of the file through `onProgress`;
/// * throw `UpCloudException`s: `CancelledException` when `cancelToken` is
///   cancelled, `NetworkException` when no response was received and
///   `NotFoundException` when the source cannot be read.
abstract interface class UploadExecutor {
  /// Sends [request] with the content of [source] and returns the server
  /// response.
  Future<UploadResponse> execute(
    UploadRequest request,
    UploadSource source, {
    void Function(TransferProgress progress)? onProgress,
    CancellationToken? cancelToken,
  });
}
