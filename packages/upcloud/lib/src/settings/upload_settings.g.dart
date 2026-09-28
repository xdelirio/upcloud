// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadSettings _$UploadSettingsFromJson(Map<String, dynamic> json) =>
    _UploadSettings(
      maxConcurrentUploads:
          (json['maxConcurrentUploads'] as num?)?.toInt() ?? 3,
      retries: (json['retries'] as num?)?.toInt() ?? 2,
      checkStorage: json['checkStorage'] as bool? ?? true,
      autoClearAfterSeconds: (json['autoClearAfterSeconds'] as num?)?.toInt(),
      defaultFolderPath: json['defaultFolderPath'] as String?,
      defaultVisibility:
          $enumDecodeNullable(
            _$UploadVisibilityEnumMap,
            json['defaultVisibility'],
            unknownValue: UploadVisibility.providerDefault,
          ) ??
          UploadVisibility.providerDefault,
    );

Map<String, dynamic> _$UploadSettingsToJson(
  _UploadSettings instance,
) => <String, dynamic>{
  'maxConcurrentUploads': instance.maxConcurrentUploads,
  'retries': instance.retries,
  'checkStorage': instance.checkStorage,
  'autoClearAfterSeconds': instance.autoClearAfterSeconds,
  'defaultFolderPath': instance.defaultFolderPath,
  'defaultVisibility': _$UploadVisibilityEnumMap[instance.defaultVisibility]!,
};

const _$UploadVisibilityEnumMap = {
  UploadVisibility.providerDefault: 'providerDefault',
  UploadVisibility.public: 'public',
  UploadVisibility.private: 'private',
};
