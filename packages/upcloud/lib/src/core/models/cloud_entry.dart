import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';

part 'cloud_entry.freezed.dart';

/// An item inside a folder: either a [CloudFile] or a [CloudFolder].
///
/// Use pattern matching to handle both cases:
///
/// ```dart
/// switch (entry) {
///   case CloudFile(:final name, :final size): ...
///   case CloudFolder(:final name): ...
/// }
/// ```
@freezed
sealed class CloudEntry with _$CloudEntry {
  /// A file stored in a provider.
  const factory CloudEntry.file({
    required FileId id,
    required String name,

    /// Folder that contains the file, `null` for the root folder.
    FolderId? folderId,
    DataSize? size,
    DateTime? createdAt,

    /// Preview image, when the provider generates one.
    Uri? thumbnailUrl,

    /// Link to share the file: its public watch/download page.
    Uri? pageUrl,

    /// Playback length for video/audio files.
    Duration? duration,
    int? views,
    bool? isPublic,

    /// Whether the file finished processing and can be played/downloaded.
    bool? isReady,

    /// Provider specific data not covered by the common fields.
    @Default(<String, Object?>{}) Map<String, Object?> extra,
  }) = CloudFile;

  /// A folder stored in a provider.
  const factory CloudEntry.folder({
    required FolderId id,
    required String name,

    /// Parent folder, `null` for the root folder.
    FolderId? parentId,
    DateTime? createdAt,

    /// Number of files inside, when the provider reports it.
    int? fileCount,

    /// Provider specific data not covered by the common fields.
    @Default(<String, Object?>{}) Map<String, Object?> extra,
  }) = CloudFolder;
}
