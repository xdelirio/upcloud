// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xvs_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_XvsAccountDto _$XvsAccountDtoFromJson(Map<String, dynamic> json) =>
    _XvsAccountDto(
      login: const LenientStringConverter().fromJson(json['login']),
      email: const LenientStringConverter().fromJson(json['email']),
      storageUsed: const LenientIntConverter().fromJson(json['storage_used']),
      storageLeft: const LenientIntConverter().fromJson(json['storage_left']),
      filesTotal: const LenientIntConverter().fromJson(json['files_total']),
      premium: const LenientBoolConverter().fromJson(json['premium']),
      premiumExpire: const LenientDateTimeConverter().fromJson(
        json['premium_expire'],
      ),
      balance: const LenientStringConverter().fromJson(json['balance']),
    );

Map<String, dynamic> _$XvsAccountDtoToJson(_XvsAccountDto instance) =>
    <String, dynamic>{
      'login': const LenientStringConverter().toJson(instance.login),
      'email': const LenientStringConverter().toJson(instance.email),
      'storage_used': const LenientIntConverter().toJson(instance.storageUsed),
      'storage_left': const LenientIntConverter().toJson(instance.storageLeft),
      'files_total': const LenientIntConverter().toJson(instance.filesTotal),
      'premium': const LenientBoolConverter().toJson(instance.premium),
      'premium_expire': const LenientDateTimeConverter().toJson(
        instance.premiumExpire,
      ),
      'balance': const LenientStringConverter().toJson(instance.balance),
    };

_XvsFolderDto _$XvsFolderDtoFromJson(Map<String, dynamic> json) =>
    _XvsFolderDto(
      id: const LenientStringConverter().fromJson(_readFolderId(json, 'id')),
      name: const LenientStringConverter().fromJson(json['name']),
      code: const LenientStringConverter().fromJson(json['code']),
      parentId: const LenientStringConverter().fromJson(
        _readParentId(json, 'parentId'),
      ),
      fileCount: const LenientIntConverter().fromJson(
        _readFileCount(json, 'fileCount'),
      ),
    );

Map<String, dynamic> _$XvsFolderDtoToJson(_XvsFolderDto instance) =>
    <String, dynamic>{
      'id': const LenientStringConverter().toJson(instance.id),
      'name': const LenientStringConverter().toJson(instance.name),
      'code': const LenientStringConverter().toJson(instance.code),
      'parentId': const LenientStringConverter().toJson(instance.parentId),
      'fileCount': const LenientIntConverter().toJson(instance.fileCount),
    };

_XvsFileDto _$XvsFileDtoFromJson(Map<String, dynamic> json) => _XvsFileDto(
  code: const LenientStringConverter().fromJson(_readFileCode(json, 'code')),
  title: const LenientStringConverter().fromJson(_readTitle(json, 'title')),
  folderId: const LenientStringConverter().fromJson(
    _readFileFolderId(json, 'folderId'),
  ),
  length: const _SecondsConverter().fromJson(_readLength(json, 'length')),
  views: const LenientIntConverter().fromJson(_readViews(json, 'views')),
  createdAt: const LenientDateTimeConverter().fromJson(
    _readCreated(json, 'createdAt'),
  ),
  isPublic: const LenientBoolConverter().fromJson(
    _readPublic(json, 'isPublic'),
  ),
  canPlay: const LenientBoolConverter().fromJson(_readCanPlay(json, 'canPlay')),
  thumbnail: const LenientUriConverter().fromJson(
    _readThumbnail(json, 'thumbnail'),
  ),
  link: const LenientUriConverter().fromJson(_readLink(json, 'link')),
  size: const LenientIntConverter().fromJson(_readSize(json, 'size')),
  sizes:
      (_readSizes(json, 'sizes') as List<dynamic>?)
          ?.map((e) => XvsVersionDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <XvsVersionDto>[],
  status: const LenientIntConverter().fromJson(json['status']),
);

Map<String, dynamic> _$XvsFileDtoToJson(_XvsFileDto instance) =>
    <String, dynamic>{
      'code': const LenientStringConverter().toJson(instance.code),
      'title': const LenientStringConverter().toJson(instance.title),
      'folderId': const LenientStringConverter().toJson(instance.folderId),
      'length': const _SecondsConverter().toJson(instance.length),
      'views': const LenientIntConverter().toJson(instance.views),
      'createdAt': const LenientDateTimeConverter().toJson(instance.createdAt),
      'isPublic': const LenientBoolConverter().toJson(instance.isPublic),
      'canPlay': const LenientBoolConverter().toJson(instance.canPlay),
      'thumbnail': const LenientUriConverter().toJson(instance.thumbnail),
      'link': const LenientUriConverter().toJson(instance.link),
      'size': const LenientIntConverter().toJson(instance.size),
      'sizes': instance.sizes.map((e) => e.toJson()).toList(),
      'status': const LenientIntConverter().toJson(instance.status),
    };

_XvsVersionDto _$XvsVersionDtoFromJson(Map<String, dynamic> json) =>
    _XvsVersionDto(
      name: const LenientStringConverter().fromJson(json['name']),
      url: const LenientUriConverter().fromJson(json['url']),
      size: const LenientIntConverter().fromJson(json['size']),
    );

Map<String, dynamic> _$XvsVersionDtoToJson(_XvsVersionDto instance) =>
    <String, dynamic>{
      'name': const LenientStringConverter().toJson(instance.name),
      'url': const LenientUriConverter().toJson(instance.url),
      'size': const LenientIntConverter().toJson(instance.size),
    };

_XvsUploadedFileDto _$XvsUploadedFileDtoFromJson(
  Map<String, dynamic> json,
) => _XvsUploadedFileDto(
  code: const LenientStringConverter().fromJson(_readFileCode(json, 'code')),
  name: const LenientStringConverter().fromJson(_readFileName(json, 'name')),
  status: const LenientStringConverter().fromJson(json['status']),
);

Map<String, dynamic> _$XvsUploadedFileDtoToJson(_XvsUploadedFileDto instance) =>
    <String, dynamic>{
      'code': const LenientStringConverter().toJson(instance.code),
      'name': const LenientStringConverter().toJson(instance.name),
      'status': const LenientStringConverter().toJson(instance.status),
    };

_XvsRemoteUploadDto _$XvsRemoteUploadDtoFromJson(Map<String, dynamic> json) =>
    _XvsRemoteUploadDto(
      code: const LenientStringConverter().fromJson(
        _readFileCode(json, 'code'),
      ),
      url: const LenientUriConverter().fromJson(_readRemoteUrl(json, 'url')),
      status: const LenientStringConverter().fromJson(json['status']),
      progress: const LenientDoubleConverter().fromJson(json['progress']),
      folderId: const LenientStringConverter().fromJson(
        _readFileFolderId(json, 'folderId'),
      ),
      error: const LenientStringConverter().fromJson(_readError(json, 'error')),
    );

Map<String, dynamic> _$XvsRemoteUploadDtoToJson(_XvsRemoteUploadDto instance) =>
    <String, dynamic>{
      'code': const LenientStringConverter().toJson(instance.code),
      'url': const LenientUriConverter().toJson(instance.url),
      'status': const LenientStringConverter().toJson(instance.status),
      'progress': const LenientDoubleConverter().toJson(instance.progress),
      'folderId': const LenientStringConverter().toJson(instance.folderId),
      'error': const LenientStringConverter().toJson(instance.error),
    };
