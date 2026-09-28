import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/models/ids.dart';

part 'remote_upload.freezed.dart';

/// Status of a [RemoteUploadJob].
enum RemoteUploadStatus {
  /// Waiting to be processed by the provider.
  pending,

  /// Being downloaded by the provider.
  working,

  /// Finished; the file is available.
  completed,

  /// Failed; see [RemoteUploadJob.error].
  failed,

  /// The provider returned a status this package does not recognise.
  unknown,
}

/// A "remote upload" (upload by URL) processed by the provider's servers.
@freezed
abstract class RemoteUploadJob with _$RemoteUploadJob {
  /// Creates a remote upload job.
  const factory RemoteUploadJob({
    /// Identifier of the job. Many providers use the future file id.
    required String id,
    @Default(RemoteUploadStatus.pending) RemoteUploadStatus status,

    /// Id of the resulting file, if already known.
    FileId? fileId,
    Uri? sourceUrl,
    FolderId? folderId,

    /// Progress between 0 and 1, if reported.
    double? progress,
    String? error,

    /// Provider specific data not covered by the common fields.
    @Default(<String, Object?>{}) Map<String, Object?> extra,
  }) = _RemoteUploadJob;
}
