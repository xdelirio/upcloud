// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadRequest _$UploadRequestFromJson(Map<String, dynamic> json) =>
    _UploadRequest(
      url: Uri.parse(json['url'] as String),
      method: json['method'] as String? ?? 'POST',
      encoding:
          $enumDecodeNullable(_$UploadEncodingEnumMap, json['encoding']) ??
          UploadEncoding.multipart,
      fileField: json['fileField'] as String? ?? 'file',
      fields:
          (json['fields'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      headers:
          (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      context:
          (json['context'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$UploadRequestToJson(_UploadRequest instance) =>
    <String, dynamic>{
      'url': instance.url.toString(),
      'method': instance.method,
      'encoding': _$UploadEncodingEnumMap[instance.encoding]!,
      'fileField': instance.fileField,
      'fields': instance.fields,
      'headers': instance.headers,
      'context': instance.context,
    };

const _$UploadEncodingEnumMap = {
  UploadEncoding.multipart: 'multipart',
  UploadEncoding.binary: 'binary',
};

_UploadResponse _$UploadResponseFromJson(Map<String, dynamic> json) =>
    _UploadResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      body: json['body'] as String,
      headers:
          (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$UploadResponseToJson(_UploadResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'body': instance.body,
      'headers': instance.headers,
    };
