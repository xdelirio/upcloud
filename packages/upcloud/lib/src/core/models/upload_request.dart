import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_request.freezed.dart';
part 'upload_request.g.dart';

/// How an [UploadRequest] sends the file.
enum UploadEncoding {
  /// A `multipart/form-data` body with [UploadRequest.fields] followed by
  /// the file in the part named [UploadRequest.fileField].
  multipart,

  /// The raw bytes of the file as the body. [UploadRequest.fields] are not
  /// sent: providers put their parameters in the URL and headers.
  binary,
}

/// An HTTP request that uploads a file, prepared by
/// `FileUploading.prepareUpload`.
///
/// The request is sent by an `UploadExecutor` (in Flutter apps, a
/// background upload) and its [UploadResponse] is given back to
/// `FileUploading.completeUpload` together with this request.
///
/// It can be converted to JSON, so a background upload can be persisted
/// and completed after the app restarts. Note that [url], [fields] and
/// [headers] may contain credentials (API keys, session tokens): do not log
/// them and store them like the account credentials.
@freezed
abstract class UploadRequest with _$UploadRequest {
  /// Creates an upload request.
  const factory UploadRequest({
    /// Where the file is sent, including any query parameter.
    required Uri url,

    /// HTTP method.
    @Default('POST') String method,

    /// How the file is sent.
    @Default(UploadEncoding.multipart) UploadEncoding encoding,

    /// Name of the multipart part that carries the file.
    @Default('file') String fileField,

    /// Form fields sent before the file (multipart only).
    @Default(<String, String>{}) Map<String, String> fields,

    /// HTTP headers.
    @Default(<String, String>{}) Map<String, String> headers,

    /// Opaque data of the provider, needed by
    /// `FileUploading.completeUpload`. Executors must not send it.
    @Default(<String, String>{}) Map<String, String> context,
  }) = _UploadRequest;

  /// Restores a request saved with [toJson].
  factory UploadRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadRequestFromJson(json);
}

/// The server response to an [UploadRequest].
///
/// Executors return every response the server sends, including HTTP error
/// statuses, so the provider can read the error message of the body.
@freezed
abstract class UploadResponse with _$UploadResponse {
  /// Creates an upload response.
  const factory UploadResponse({
    /// HTTP status code.
    required int statusCode,

    /// Body decoded as text (usually JSON).
    required String body,

    /// Response headers.
    @Default(<String, String>{}) Map<String, String> headers,
  }) = _UploadResponse;

  const UploadResponse._();

  /// Restores a response saved with [toJson].
  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseFromJson(json);

  /// Whether [statusCode] is a `2xx` status.
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  /// Value of the header [name], compared case-insensitively.
  String? header(String name) {
    final lower = name.toLowerCase();
    for (final MapEntry(:key, :value) in headers.entries) {
      if (key.toLowerCase() == lower) return value;
    }
    return null;
  }
}
