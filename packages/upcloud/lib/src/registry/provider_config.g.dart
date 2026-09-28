// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderConfig _$ProviderConfigFromJson(Map<String, dynamic> json) =>
    _ProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      driver: json['driver'] as String,
      description: json['description'] as String?,
      website: json['website'] == null
          ? null
          : Uri.parse(json['website'] as String),
      iconUrl: json['iconUrl'] == null
          ? null
          : Uri.parse(json['iconUrl'] as String),
      apiBase: json['apiBase'] == null
          ? null
          : Uri.parse(json['apiBase'] as String),
      mirrors:
          (json['mirrors'] as List<dynamic>?)
              ?.map((e) => Uri.parse(e as String))
              .toList() ??
          const <Uri>[],
      limits: json['limits'] == null
          ? null
          : LimitsConfig.fromJson(json['limits'] as Map<String, dynamic>),
      credentials: (json['credentials'] as List<dynamic>?)
          ?.map((e) => CredentialField.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings:
          json['settings'] as Map<String, dynamic>? ??
          const <String, Object?>{},
      disabledCapabilities:
          (json['disabledCapabilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$ProviderConfigToJson(_ProviderConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'driver': instance.driver,
      'description': instance.description,
      'website': instance.website?.toString(),
      'iconUrl': instance.iconUrl?.toString(),
      'apiBase': instance.apiBase?.toString(),
      'mirrors': instance.mirrors.map((e) => e.toString()).toList(),
      'limits': instance.limits?.toJson(),
      'credentials': instance.credentials?.map((e) => e.toJson()).toList(),
      'settings': instance.settings,
      'disabledCapabilities': instance.disabledCapabilities,
      'enabled': instance.enabled,
    };

_LimitsConfig _$LimitsConfigFromJson(Map<String, dynamic> json) =>
    _LimitsConfig(
      maxFileSizeMb: (json['maxFileSizeMb'] as num?)?.toDouble(),
      allowedExtensions: (json['allowedExtensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxConcurrentUploads: (json['maxConcurrentUploads'] as num?)?.toInt(),
      minRequestIntervalMs: (json['minRequestIntervalMs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LimitsConfigToJson(_LimitsConfig instance) =>
    <String, dynamic>{
      'maxFileSizeMb': instance.maxFileSizeMb,
      'allowedExtensions': instance.allowedExtensions,
      'maxConcurrentUploads': instance.maxConcurrentUploads,
      'minRequestIntervalMs': instance.minRequestIntervalMs,
    };
