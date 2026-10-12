// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudAccount _$CloudAccountFromJson(Map<String, dynamic> json) =>
    _CloudAccount(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      label: json['label'] as String,
      credentials: Credentials.fromJson(
        json['credentials'] as Map<String, dynamic>,
      ),
      baseUrl: json['baseUrl'] == null
          ? null
          : Uri.parse(json['baseUrl'] as String),
      maxFileSizeBytes: (json['maxFileSizeBytes'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CloudAccountToJson(_CloudAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'providerId': instance.providerId,
      'label': instance.label,
      'credentials': instance.credentials.toJson(),
      'baseUrl': instance.baseUrl?.toString(),
      'maxFileSizeBytes': instance.maxFileSizeBytes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
