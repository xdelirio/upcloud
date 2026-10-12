// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediafire_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaFireFileDto _$MediaFireFileDtoFromJson(
  Map<String, dynamic> json,
) => _MediaFireFileDto(
  quickkey: const LenientStringConverter().fromJson(json['quickkey']),
  filename: const LenientStringConverter().fromJson(json['filename']),
  hash: const LenientStringConverter().fromJson(json['hash']),
  description: const LenientStringConverter().fromJson(json['description']),
  size: const LenientIntConverter().fromJson(json['size']),
  privacy: const LenientStringConverter().fromJson(json['privacy']),
  created: const LenientDateTimeConverter().fromJson(json['created']),
  createdUtc: const LenientDateTimeConverter().fromJson(json['created_utc']),
  mimetype: const LenientStringConverter().fromJson(json['mimetype']),
  filetype: const LenientStringConverter().fromJson(json['filetype']),
  downloads: const LenientIntConverter().fromJson(json['downloads']),
  views: const LenientIntConverter().fromJson(json['views']),
  revision: const LenientStringConverter().fromJson(json['revision']),
  parentFolderKey: const LenientStringConverter().fromJson(
    json['parent_folderkey'],
  ),
  ready: const LenientBoolConverter().fromJson(json['ready']),
  passwordProtected: const LenientBoolConverter().fromJson(
    json['password_protected'],
  ),
  deleteDate: const LenientDateTimeConverter().fromJson(json['delete_date']),
  links: _readLinks(json['links']),
);

_MediaFireLinksDto _$MediaFireLinksDtoFromJson(
  Map<String, dynamic> json,
) => _MediaFireLinksDto(
  quickkey: const LenientStringConverter().fromJson(json['quickkey']),
  view: const LenientUriConverter().fromJson(json['view']),
  watch: const LenientUriConverter().fromJson(json['watch']),
  listen: const LenientUriConverter().fromJson(json['listen']),
  normalDownload: const LenientUriConverter().fromJson(json['normal_download']),
  directDownload: const LenientUriConverter().fromJson(json['direct_download']),
  directDownloadError: const LenientIntConverter().fromJson(
    json['direct_download_error'],
  ),
  directDownloadErrorMessage: const LenientStringConverter().fromJson(
    json['direct_download_error_message'],
  ),
  error: const LenientStringConverter().fromJson(json['error']),
);

_MediaFireFolderDto _$MediaFireFolderDtoFromJson(Map<String, dynamic> json) =>
    _MediaFireFolderDto(
      folderkey: const LenientStringConverter().fromJson(
        _readFolderKey(json, 'folderkey'),
      ),
      name: const LenientStringConverter().fromJson(json['name']),
      description: const LenientStringConverter().fromJson(json['description']),
      privacy: const LenientStringConverter().fromJson(json['privacy']),
      created: const LenientDateTimeConverter().fromJson(json['created']),
      createdUtc: const LenientDateTimeConverter().fromJson(
        json['created_utc'],
      ),
      fileCount: const LenientIntConverter().fromJson(json['file_count']),
      folderCount: const LenientIntConverter().fromJson(json['folder_count']),
      parentFolderKey: const LenientStringConverter().fromJson(
        json['parent_folderkey'],
      ),
      revision: const LenientStringConverter().fromJson(json['revision']),
    );

_MediaFireFolderContentDto _$MediaFireFolderContentDtoFromJson(
  Map<String, dynamic> json,
) => _MediaFireFolderContentDto(
  chunkSize: const LenientIntConverter().fromJson(json['chunk_size']),
  chunkNumber: const LenientIntConverter().fromJson(json['chunk_number']),
  contentType: const LenientStringConverter().fromJson(json['content_type']),
  moreChunks: const LenientBoolConverter().fromJson(json['more_chunks']),
  folders: json['folders'] == null
      ? const <MediaFireFolderDto>[]
      : _readFolders(json['folders']),
  files: json['files'] == null
      ? const <MediaFireFileDto>[]
      : _readFiles(json['files']),
);

_MediaFireUserInfoDto _$MediaFireUserInfoDtoFromJson(
  Map<String, dynamic> json,
) => _MediaFireUserInfoDto(
  email: const LenientStringConverter().fromJson(json['email']),
  firstName: const LenientStringConverter().fromJson(json['first_name']),
  lastName: const LenientStringConverter().fromJson(json['last_name']),
  displayName: const LenientStringConverter().fromJson(json['display_name']),
  premium: const LenientBoolConverter().fromJson(json['premium']),
  validated: const LenientBoolConverter().fromJson(json['validated']),
  bandwidth: const LenientIntConverter().fromJson(json['bandwidth']),
  created: const LenientDateTimeConverter().fromJson(json['created']),
  usedStorageSize: const LenientIntConverter().fromJson(
    json['used_storage_size'],
  ),
  baseStorage: const LenientIntConverter().fromJson(json['base_storage']),
  bonusStorage: const LenientIntConverter().fromJson(json['bonus_storage']),
  storageLimit: const LenientIntConverter().fromJson(json['storage_limit']),
  storageLimitExceeded: const LenientBoolConverter().fromJson(
    json['storage_limit_exceeded'],
  ),
);

_MediaFireWebUploadDto _$MediaFireWebUploadDtoFromJson(
  Map<String, dynamic> json,
) => _MediaFireWebUploadDto(
  uploadkey: const LenientStringConverter().fromJson(json['uploadkey']),
  active: const LenientBoolConverter().fromJson(json['active']),
  quickkey: const LenientStringConverter().fromJson(json['quickkey']),
  filename: const LenientStringConverter().fromJson(json['filename']),
  created: const LenientDateTimeConverter().fromJson(json['created']),
  statusCode: const LenientIntConverter().fromJson(json['status_code']),
  status: const LenientStringConverter().fromJson(json['status']),
  errorStatus: const LenientIntConverter().fromJson(json['error_status']),
  url: const LenientUriConverter().fromJson(json['url']),
  eta: const LenientStringConverter().fromJson(json['eta']),
  size: const LenientIntConverter().fromJson(json['size']),
  percentage: const LenientIntConverter().fromJson(json['percentage']),
);

_MediaFireDoUploadDto _$MediaFireDoUploadDtoFromJson(
  Map<String, dynamic> json,
) => _MediaFireDoUploadDto(
  key: const LenientStringConverter().fromJson(json['key']),
  result: const LenientIntConverter().fromJson(json['result']),
  status: const LenientIntConverter().fromJson(json['status']),
  description: const LenientStringConverter().fromJson(json['description']),
  fileerror: const LenientIntConverter().fromJson(json['fileerror']),
  quickkey: const LenientStringConverter().fromJson(json['quickkey']),
  filename: const LenientStringConverter().fromJson(json['filename']),
  size: const LenientIntConverter().fromJson(json['size']),
);
