import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/models/file_length_stub.dart'
    if (dart.library.io) 'package:upcloud/src/core/models/file_length_io.dart';
import 'package:upcloud/src/core/models/ids.dart';

part 'upload.freezed.dart';

/// The content to upload.
///
/// * [UploadSource.file] reads from a local path (not available on web).
/// * [UploadSource.bytes] uploads an in-memory buffer.
/// * [UploadSource.stream] uploads from a stream factory. The factory is
///   called again on every retry, so it must return a fresh stream.
sealed class UploadSource {
  const UploadSource();

  /// Uploads the file at [path].
  ///
  /// [name] defaults to the last segment of [path]. Pass [length] when it is
  /// already known to avoid touching the file system.
  const factory UploadSource.file(String path, {String? name, int? length}) =
      FileUploadSource;

  /// Uploads [bytes] as a file called [name].
  const factory UploadSource.bytes(List<int> bytes, {required String name}) =
      BytesUploadSource;

  /// Uploads [length] bytes read from the streams returned by [open].
  const factory UploadSource.stream(
    Stream<List<int>> Function() open, {
    required String name,
    required int length,
  }) = StreamUploadSource;

  /// File name sent to the provider.
  String get name;

  /// Lowercase file extension without the dot, or an empty string.
  String get extension => fileExtension(name);

  /// Size in bytes, or `null` when it cannot be determined.
  Future<int?> resolveLength();

  /// The name and size of this content, as given to
  /// `FileUploading.prepareUpload`.
  Future<UploadFileInfo> resolveInfo() async =>
      UploadFileInfo(name: name, size: await resolveLength());
}

/// Uploads a file from the local file system.
final class FileUploadSource extends UploadSource {
  /// See [UploadSource.file].
  const FileUploadSource(this.path, {this._name, this.length});

  /// Path of the file on disk.
  final String path;

  /// Known size in bytes, if provided.
  final int? length;

  final String? _name;

  @override
  String get name => _name ?? path.split(RegExp(r'[/\\]')).last;

  @override
  Future<int?> resolveLength() async => length ?? await fileLength(path);
}

/// Uploads an in-memory buffer.
final class BytesUploadSource extends UploadSource {
  /// See [UploadSource.bytes].
  const BytesUploadSource(this.bytes, {required this.name});

  /// Content to upload.
  final List<int> bytes;

  @override
  final String name;

  @override
  Future<int?> resolveLength() async => bytes.length;
}

/// Uploads from a stream factory.
final class StreamUploadSource extends UploadSource {
  /// See [UploadSource.stream].
  const StreamUploadSource(
    this.open, {
    required this.name,
    required this.length,
  });

  /// Returns a new stream with the content each time it is called.
  final Stream<List<int>> Function() open;

  @override
  final String name;

  /// Size in bytes.
  final int length;

  @override
  Future<int?> resolveLength() async => length;
}

/// Name and size of a file about to be uploaded.
///
/// Providers prepare the upload request from it; the content itself is
/// sent later by an `UploadExecutor`.
@freezed
abstract class UploadFileInfo with _$UploadFileInfo {
  /// Creates the description of a file.
  const factory UploadFileInfo({
    /// File name sent to the provider.
    required String name,

    /// Size in bytes, `null` when unknown.
    int? size,
  }) = _UploadFileInfo;

  const UploadFileInfo._();

  /// Lowercase file extension without the dot, or an empty string.
  String get extension => fileExtension(name);
}

/// Lowercase extension of the file [name] without the dot, or an empty
/// string.
String fileExtension(String name) {
  final dot = name.lastIndexOf('.');
  return dot < 0 || dot == name.length - 1
      ? ''
      : name.substring(dot + 1).toLowerCase();
}

/// Metadata applied to an uploaded file.
///
/// Providers ignore the fields they do not support.
@freezed
abstract class UploadOptions with _$UploadOptions {
  /// Creates upload options.
  const factory UploadOptions({
    /// Destination folder, `null` for the root folder.
    FolderId? folderId,

    /// Title shown by the provider. Defaults to the file name.
    String? title,
    String? description,

    /// Visibility of the file. When `null`, the visibility given to the
    /// upload or the default one of the upload settings applies (which may
    /// keep the provider default).
    bool? isPublic,
    bool? isAdult,
    @Default(<String>[]) List<String> tags,

    /// Extra provider specific form fields, sent as-is.
    @Default(<String, String>{}) Map<String, String> fields,
  }) = _UploadOptions;
}

/// Progress of an upload.
@freezed
abstract class TransferProgress with _$TransferProgress {
  /// Creates a progress report.
  const factory TransferProgress({
    required int transferred,

    /// Total bytes, `null` when unknown.
    int? total,
  }) = _TransferProgress;

  const TransferProgress._();

  /// Progress between 0 and 1, or `null` when the total is unknown.
  double? get fraction {
    final t = total;
    if (t == null || t <= 0) return null;
    return (transferred / t).clamp(0, 1).toDouble();
  }
}
