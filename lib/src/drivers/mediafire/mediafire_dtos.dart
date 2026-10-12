// DTOs mirror the MediaFire Core API 1.5 JSON payloads. The API returns
// almost every value as a string ("yes"/"no" flags, numeric strings, "" for
// empty objects), so every field goes through the lenient readers.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:upcloud/src/core/http/json_readers.dart';

part 'mediafire_dtos.freezed.dart';
part 'mediafire_dtos.g.dart';

/// A file as returned by `file/get_info`, `folder/get_content` and
/// `folder/search`.
@Freezed(toJson: false)
abstract class MediaFireFileDto with _$MediaFireFileDto {
  /// Creates a file DTO.
  const factory MediaFireFileDto({
    @LenientStringConverter() String? quickkey,
    @LenientStringConverter() String? filename,
    @LenientStringConverter() String? hash,
    @LenientStringConverter() String? description,
    @LenientIntConverter() int? size,
    @LenientStringConverter() String? privacy,
    @LenientDateTimeConverter() DateTime? created,
    @JsonKey(name: 'created_utc')
    @LenientDateTimeConverter()
    DateTime? createdUtc,
    @LenientStringConverter() String? mimetype,
    @LenientStringConverter() String? filetype,
    @LenientIntConverter() int? downloads,
    @LenientIntConverter() int? views,
    @LenientStringConverter() String? revision,
    @JsonKey(name: 'parent_folderkey')
    @LenientStringConverter()
    String? parentFolderKey,
    @LenientBoolConverter() bool? ready,
    @JsonKey(name: 'password_protected')
    @LenientBoolConverter()
    bool? passwordProtected,
    @JsonKey(name: 'delete_date')
    @LenientDateTimeConverter()
    DateTime? deleteDate,
    @JsonKey(fromJson: _readLinks) MediaFireLinksDto? links,
  }) = _MediaFireFileDto;

  /// Parses a file object.
  factory MediaFireFileDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireFileDtoFromJson(json);
}

/// Links of a file (`links` of `file/get_info`, items of `file/get_links`).
@Freezed(toJson: false)
abstract class MediaFireLinksDto with _$MediaFireLinksDto {
  /// Creates a links DTO.
  const factory MediaFireLinksDto({
    @LenientStringConverter() String? quickkey,
    @LenientUriConverter() Uri? view,
    @LenientUriConverter() Uri? watch,
    @LenientUriConverter() Uri? listen,
    @JsonKey(name: 'normal_download')
    @LenientUriConverter()
    Uri? normalDownload,
    @JsonKey(name: 'direct_download')
    @LenientUriConverter()
    Uri? directDownload,
    @JsonKey(name: 'direct_download_error')
    @LenientIntConverter()
    int? directDownloadError,
    @JsonKey(name: 'direct_download_error_message')
    @LenientStringConverter()
    String? directDownloadErrorMessage,

    /// Set when the session user cannot access the file.
    @LenientStringConverter() String? error,
  }) = _MediaFireLinksDto;

  /// Parses a links object.
  factory MediaFireLinksDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireLinksDtoFromJson(json);
}

/// A folder as returned by `folder/get_content`, `folder/get_info` and
/// `folder/create`.
@Freezed(toJson: false)
abstract class MediaFireFolderDto with _$MediaFireFolderDto {
  /// Creates a folder DTO.
  const factory MediaFireFolderDto({
    // `folder/create` names it `folder_key`, every other call `folderkey`.
    @JsonKey(readValue: _readFolderKey)
    @LenientStringConverter()
    String? folderkey,
    @LenientStringConverter() String? name,
    @LenientStringConverter() String? description,
    @LenientStringConverter() String? privacy,
    @LenientDateTimeConverter() DateTime? created,
    @JsonKey(name: 'created_utc')
    @LenientDateTimeConverter()
    DateTime? createdUtc,
    @JsonKey(name: 'file_count') @LenientIntConverter() int? fileCount,
    @JsonKey(name: 'folder_count') @LenientIntConverter() int? folderCount,
    @JsonKey(name: 'parent_folderkey')
    @LenientStringConverter()
    String? parentFolderKey,
    @LenientStringConverter() String? revision,
  }) = _MediaFireFolderDto;

  /// Parses a folder object.
  factory MediaFireFolderDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireFolderDtoFromJson(json);
}

/// One chunk of `folder/get_content` (`folder_content`).
@Freezed(toJson: false)
abstract class MediaFireFolderContentDto with _$MediaFireFolderContentDto {
  /// Creates a folder content DTO.
  const factory MediaFireFolderContentDto({
    @JsonKey(name: 'chunk_size') @LenientIntConverter() int? chunkSize,
    @JsonKey(name: 'chunk_number') @LenientIntConverter() int? chunkNumber,
    @JsonKey(name: 'content_type')
    @LenientStringConverter()
    String? contentType,
    @JsonKey(name: 'more_chunks') @LenientBoolConverter() bool? moreChunks,
    @JsonKey(fromJson: _readFolders)
    @Default(<MediaFireFolderDto>[])
    List<MediaFireFolderDto> folders,
    @JsonKey(fromJson: _readFiles)
    @Default(<MediaFireFileDto>[])
    List<MediaFireFileDto> files,
  }) = _MediaFireFolderContentDto;

  /// Parses a `folder_content` object.
  factory MediaFireFolderContentDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireFolderContentDtoFromJson(json);
}

/// `user_info` of `user/get_info`.
@Freezed(toJson: false)
abstract class MediaFireUserInfoDto with _$MediaFireUserInfoDto {
  /// Creates a user info DTO.
  const factory MediaFireUserInfoDto({
    @LenientStringConverter() String? email,
    @JsonKey(name: 'first_name') @LenientStringConverter() String? firstName,
    @JsonKey(name: 'last_name') @LenientStringConverter() String? lastName,
    @JsonKey(name: 'display_name')
    @LenientStringConverter()
    String? displayName,
    @LenientBoolConverter() bool? premium,
    @LenientBoolConverter() bool? validated,
    @LenientIntConverter() int? bandwidth,
    @LenientDateTimeConverter() DateTime? created,
    @JsonKey(name: 'used_storage_size')
    @LenientIntConverter()
    int? usedStorageSize,
    @JsonKey(name: 'base_storage') @LenientIntConverter() int? baseStorage,
    @JsonKey(name: 'bonus_storage') @LenientIntConverter() int? bonusStorage,
    @JsonKey(name: 'storage_limit') @LenientIntConverter() int? storageLimit,
    @JsonKey(name: 'storage_limit_exceeded')
    @LenientBoolConverter()
    bool? storageLimitExceeded,
  }) = _MediaFireUserInfoDto;

  /// Parses a `user_info` object.
  factory MediaFireUserInfoDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireUserInfoDtoFromJson(json);
}

/// An item of `web_uploads` in `upload/get_web_uploads`.
@Freezed(toJson: false)
abstract class MediaFireWebUploadDto with _$MediaFireWebUploadDto {
  /// Creates a web upload DTO.
  const factory MediaFireWebUploadDto({
    @LenientStringConverter() String? uploadkey,
    @LenientBoolConverter() bool? active,
    @LenientStringConverter() String? quickkey,
    @LenientStringConverter() String? filename,
    @LenientDateTimeConverter() DateTime? created,
    @JsonKey(name: 'status_code') @LenientIntConverter() int? statusCode,
    @LenientStringConverter() String? status,
    @JsonKey(name: 'error_status') @LenientIntConverter() int? errorStatus,
    @LenientUriConverter() Uri? url,
    @LenientStringConverter() String? eta,
    @LenientIntConverter() int? size,
    @LenientIntConverter() int? percentage,
  }) = _MediaFireWebUploadDto;

  /// Parses a web upload object.
  factory MediaFireWebUploadDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireWebUploadDtoFromJson(json);
}

/// `doupload` of `upload/simple` and `upload/poll_upload`.
@Freezed(toJson: false)
abstract class MediaFireDoUploadDto with _$MediaFireDoUploadDto {
  /// Creates a doupload DTO.
  const factory MediaFireDoUploadDto({
    /// Upload key to pass to `upload/poll_upload`.
    @LenientStringConverter() String? key,

    /// `0` on success, a negative code otherwise.
    @LenientIntConverter() int? result,

    /// Processing status; `99` means finished.
    @LenientIntConverter() int? status,
    @LenientStringConverter() String? description,

    /// Non zero when the file was rejected (`15` = storage full, ...).
    @LenientIntConverter() int? fileerror,
    @LenientStringConverter() String? quickkey,
    @LenientStringConverter() String? filename,
    @LenientIntConverter() int? size,
  }) = _MediaFireDoUploadDto;

  /// Parses a doupload object.
  factory MediaFireDoUploadDto.fromJson(Map<String, dynamic> json) =>
      _$MediaFireDoUploadDtoFromJson(json);
}

Object? _readFolderKey(Map<dynamic, dynamic> json, String key) =>
    json['folderkey'] ?? json['folder_key'];

MediaFireLinksDto? _readLinks(Object? json) => switch (readMap(json)) {
  final Map<String, Object?> map => MediaFireLinksDto.fromJson(map),
  null => null,
};

List<MediaFireFolderDto> _readFolders(Object? json) => [
  for (final item in readList(json))
    if (readMap(item) case final map?) MediaFireFolderDto.fromJson(map),
];

List<MediaFireFileDto> _readFiles(Object? json) => [
  for (final item in readList(json))
    if (readMap(item) case final map?) MediaFireFileDto.fromJson(map),
];
