import 'package:flutter/material.dart';
import 'package:upcloud/upcloud.dart';

/// Broad category of a [CloudEntry], used to pick icons and colors.
enum CloudFileKind {
  /// A folder.
  folder(Icons.folder_rounded),

  /// Video files.
  video(Icons.movie_outlined),

  /// Images.
  image(Icons.image_outlined),

  /// Audio files.
  audio(Icons.audiotrack_outlined),

  /// Compressed archives and disk images.
  archive(Icons.folder_zip_outlined),

  /// Documents, spreadsheets, presentations and plain text.
  document(Icons.description_outlined),

  /// Source code and structured data.
  code(Icons.code_rounded),

  /// Anything else.
  other(Icons.insert_drive_file_outlined);

  CloudFileKind(this.icon);

  /// Default icon of this kind.
  final IconData icon;

  static const _image = {
    'avif', 'bmp', 'gif', 'heic', 'heif', 'ico', 'jpeg', 'jpg', 'png', //
    'svg', 'tif', 'tiff', 'webp',
  };
  static const _audio = {
    'aac', 'aiff', 'alac', 'amr', 'flac', 'm4a', 'mid', 'mp3', 'oga', //
    'ogg', 'opus', 'wav', 'wma',
  };
  static const _archive = {
    '7z', 'apk', 'bz2', 'dmg', 'gz', 'iso', 'rar', 'tar', 'tgz', 'xz', //
    'zip', 'zst',
  };
  static const _document = {
    'csv', 'doc', 'docx', 'epub', 'md', 'odp', 'ods', 'odt', 'pdf', //
    'ppt', 'pptx', 'rtf', 'srt', 'txt', 'vtt', 'xls', 'xlsx',
  };
  static const _code = {
    'c', 'cpp', 'cs', 'css', 'dart', 'go', 'h', 'html', 'java', 'js', //
    'json', 'kt', 'php', 'py', 'rb', 'rs', 'sh', 'swift', 'ts', 'xml',
    'yaml', 'yml',
  };

  /// Kind of a file called [name], based on its extension.
  static CloudFileKind fromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return other;
    final ext = name.substring(dot + 1).toLowerCase();
    if (ProviderLimits.videoExtensions.contains(ext)) return video;
    if (_image.contains(ext)) return image;
    if (_audio.contains(ext)) return audio;
    if (_archive.contains(ext)) return archive;
    if (_document.contains(ext)) return document;
    if (_code.contains(ext)) return code;
    return other;
  }

  /// Kind of [entry].
  static CloudFileKind of(CloudEntry entry) => switch (entry) {
    CloudFolder() => folder,
    CloudFile(:final name) => fromName(name),
  };
}

/// UI helpers for [CloudEntry].
extension CloudEntryUi on CloudEntry {
  /// Key that identifies the entry inside a listing.
  ///
  /// Files and folders may share ids in some providers, so the key includes
  /// the entry type.
  String get selectionKey => switch (this) {
    CloudFile(:final id) => 'file:${id.value}',
    CloudFolder(:final id) => 'folder:${id.value}',
  };

  /// Whether this entry is a folder.
  bool get isFolder => this is CloudFolder;

  /// Kind of the entry, see [CloudFileKind].
  CloudFileKind get kind => CloudFileKind.of(this);
}
