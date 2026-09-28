// DTOs of the XVideoSharing API.
//
// XVS clones return the same objects with small differences (field
// prefixes, `filecode` vs `file_code`, numbers as strings...). Every field
// is nullable and read with lenient converters, and `readValue` functions
// accept the known aliases of each field.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/http/json_readers.dart';

part 'xvs_dtos.freezed.dart';
part 'xvs_dtos.g.dart';

/// Result of `account/info`.
@freezed
abstract class XvsAccountDto with _$XvsAccountDto {
  /// Creates the DTO.
  const factory XvsAccountDto({
    @LenientStringConverter() String? login,
    @LenientStringConverter() String? email,
    @JsonKey(name: 'storage_used') @LenientIntConverter() int? storageUsed,
    @JsonKey(name: 'storage_left') @LenientIntConverter() int? storageLeft,
    @JsonKey(name: 'files_total') @LenientIntConverter() int? filesTotal,
    @LenientBoolConverter() bool? premium,
    @JsonKey(name: 'premium_expire')
    @LenientDateTimeConverter()
    DateTime? premiumExpire,
    @LenientStringConverter() String? balance,
  }) = _XvsAccountDto;

  /// Parses the `result` object of `account/info`.
  factory XvsAccountDto.fromJson(Map<String, dynamic> json) =>
      _$XvsAccountDtoFromJson(json);

  /// Keys mapped by this DTO; other keys are kept as extra data.
  static const knownKeys = {
    'login',
    'email',
    'storage_used',
    'storage_left',
    'files_total',
    'premium',
    'premium_expire',
    'balance',
  };
}

/// A folder returned by `folder/list`.
@freezed
abstract class XvsFolderDto with _$XvsFolderDto {
  /// Creates the DTO.
  const factory XvsFolderDto({
    @JsonKey(readValue: _readFolderId) @LenientStringConverter() String? id,
    @LenientStringConverter() String? name,

    /// Public code of the folder (used in shared folder links).
    @LenientStringConverter() String? code,
    @JsonKey(readValue: _readParentId)
    @LenientStringConverter()
    String? parentId,
    @JsonKey(readValue: _readFileCount) @LenientIntConverter() int? fileCount,
  }) = _XvsFolderDto;

  /// Parses a folder object.
  factory XvsFolderDto.fromJson(Map<String, dynamic> json) =>
      _$XvsFolderDtoFromJson(json);

  /// Keys mapped by this DTO; other keys are kept as extra data.
  static const knownKeys = {
    'fld_id',
    'id',
    'name',
    'parent_id',
    'fld_parent_id',
    'files_total',
    'total_files',
    'files',
  };
}

/// A file returned by `file/list`, `folder/list` or `file/info`.
///
/// `file/info` prefixes most fields with `file_` (`file_title`,
/// `file_fld_id`...); both spellings are accepted.
@freezed
abstract class XvsFileDto with _$XvsFileDto {
  /// Creates the DTO.
  const factory XvsFileDto({
    @JsonKey(readValue: _readFileCode) @LenientStringConverter() String? code,
    @JsonKey(readValue: _readTitle) @LenientStringConverter() String? title,
    @JsonKey(readValue: _readFileFolderId)
    @LenientStringConverter()
    String? folderId,
    @JsonKey(readValue: _readLength) @_SecondsConverter() Duration? length,
    @JsonKey(readValue: _readViews) @LenientIntConverter() int? views,
    @JsonKey(readValue: _readCreated)
    @LenientDateTimeConverter()
    DateTime? createdAt,
    @JsonKey(readValue: _readPublic) @LenientBoolConverter() bool? isPublic,
    @JsonKey(readValue: _readCanPlay) @LenientBoolConverter() bool? canPlay,
    @JsonKey(readValue: _readThumbnail) @LenientUriConverter() Uri? thumbnail,

    /// Public page of the file.
    @JsonKey(readValue: _readLink) @LenientUriConverter() Uri? link,

    /// Size in bytes, when the clone reports it.
    @JsonKey(readValue: _readSize) @LenientIntConverter() int? size,

    /// Size of every encoded version (StreamHG `file_sizes`).
    @JsonKey(readValue: _readSizes)
    @Default(<XvsVersionDto>[])
    List<XvsVersionDto> sizes,

    /// Per-file status of `file/info` (`404` for unknown codes).
    @LenientIntConverter() int? status,
  }) = _XvsFileDto;

  /// Parses a file object.
  factory XvsFileDto.fromJson(Map<String, dynamic> json) =>
      _$XvsFileDtoFromJson(json);

  /// Keys mapped by this DTO; other keys (including the raw `file_sizes`)
  /// are kept as extra data.
  static const knownKeys = {
    'file_code',
    'filecode',
    'title',
    'file_title',
    'name',
    'file_name',
    'fld_id',
    'file_fld_id',
    'length',
    'file_length',
    'views',
    'file_views',
    'uploaded',
    'file_created',
    'created',
    'public',
    'file_public',
    'canplay',
    'thumbnail',
    'player_img',
    'splash_img',
    'link',
    'size',
    'file_size',
    'status',
  };
}

/// An encoded version of a video (`file_sizes` of `file/info`), used to
/// know the size of the file.
@freezed
abstract class XvsVersionDto with _$XvsVersionDto {
  /// Creates the DTO.
  const factory XvsVersionDto({
    /// Quality code: `o` (original), `h` (high), `n` (normal), `l` (low).
    @LenientStringConverter() String? name,
    @LenientUriConverter() Uri? url,
    @LenientIntConverter() int? size,
  }) = _XvsVersionDto;

  /// Parses a version object.
  factory XvsVersionDto.fromJson(Map<String, dynamic> json) =>
      _$XvsVersionDtoFromJson(json);
}

/// A file of the upload server response.
@freezed
abstract class XvsUploadedFileDto with _$XvsUploadedFileDto {
  /// Creates the DTO.
  const factory XvsUploadedFileDto({
    @JsonKey(readValue: _readFileCode) @LenientStringConverter() String? code,
    @JsonKey(readValue: _readFileName) @LenientStringConverter() String? name,

    /// `OK` on success, otherwise an error message.
    @LenientStringConverter() String? status,
  }) = _XvsUploadedFileDto;

  /// Parses an entry of the `files` array.
  factory XvsUploadedFileDto.fromJson(Map<String, dynamic> json) =>
      _$XvsUploadedFileDtoFromJson(json);
}

/// An entry of `file/url_uploads`.
@freezed
abstract class XvsRemoteUploadDto with _$XvsRemoteUploadDto {
  /// Creates the DTO.
  const factory XvsRemoteUploadDto({
    @JsonKey(readValue: _readFileCode) @LenientStringConverter() String? code,
    @JsonKey(readValue: _readRemoteUrl) @LenientUriConverter() Uri? url,

    /// `PENDING`, `WORKING`, `ERROR`, `OK`...
    @LenientStringConverter() String? status,

    /// Percentage between 0 and 100.
    @LenientDoubleConverter() double? progress,
    @JsonKey(readValue: _readFileFolderId)
    @LenientStringConverter()
    String? folderId,
    @JsonKey(readValue: _readError) @LenientStringConverter() String? error,
  }) = _XvsRemoteUploadDto;

  /// Parses an entry of `file/url_uploads`.
  factory XvsRemoteUploadDto.fromJson(Map<String, dynamic> json) =>
      _$XvsRemoteUploadDtoFromJson(json);

  /// Keys mapped by this DTO; other keys (including the raw `status`) are
  /// kept as extra data.
  static const knownKeys = {
    'file_code',
    'filecode',
    'remote_url',
    'url',
    'progress',
    'fld_id',
    'error',
    'err',
  };
}

/// Reads a duration expressed in seconds (`"60"`, `60`, `"01:00"`).
final class _SecondsConverter implements JsonConverter<Duration?, Object?> {
  const _SecondsConverter();

  @override
  Duration? fromJson(Object? json) => readSecondsDuration(json);

  @override
  Object? toJson(Duration? object) => object?.inSeconds;
}

/// First non-null value of [keys] in [json].
Object? _first(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value != '') return value;
  }
  return null;
}

/// Objects of the list [value], ignoring anything else.
List<Map<String, dynamic>> _objects(Object? value) => [
  for (final item in readList(value))
    if (item is Map<String, dynamic>) item,
];

Object? _readFileCode(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['file_code', 'filecode']);

Object? _readFolderId(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['fld_id', 'id']);

Object? _readFileFolderId(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['fld_id', 'file_fld_id']);

Object? _readParentId(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['parent_id', 'fld_parent_id']);

Object? _readFileCount(Map<dynamic, dynamic> json, String _) {
  final value = _first(json, const ['files_total', 'total_files', 'files']);
  // `files` may also be a list of files in some responses.
  return value is List ? value.length : value;
}

Object? _readTitle(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['title', 'file_title', 'name', 'file_name']);

Object? _readFileName(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['filename', 'file_name', 'name']);

Object? _readLength(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['length', 'file_length']);

Object? _readViews(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['views', 'file_views']);

Object? _readCreated(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['uploaded', 'file_created', 'created']);

Object? _readPublic(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['public', 'file_public']);

Object? _readCanPlay(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['canplay', 'can_play']);

Object? _readThumbnail(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['thumbnail', 'player_img', 'splash_img']);

Object? _readLink(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['link', 'file_link']);

Object? _readSize(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['size', 'file_size']);

Object? _readSizes(Map<dynamic, dynamic> json, String _) =>
    _objects(json['file_sizes']);

Object? _readRemoteUrl(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['remote_url', 'url']);

Object? _readError(Map<dynamic, dynamic> json, String _) =>
    _first(json, const ['error', 'err']);
