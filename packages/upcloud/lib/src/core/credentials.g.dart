// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Credentials _$CredentialsFromJson(Map<String, dynamic> json) =>
    _Credentials(Map<String, String>.from(json['values'] as Map));

Map<String, dynamic> _$CredentialsToJson(_Credentials instance) =>
    <String, dynamic>{'values': instance.values};

_CredentialField _$CredentialFieldFromJson(Map<String, dynamic> json) =>
    _CredentialField(
      id: json['id'] as String,
      label: json['label'] as String,
      kind:
          $enumDecodeNullable(_$CredentialInputKindEnumMap, json['kind']) ??
          CredentialInputKind.text,
      isRequired: json['isRequired'] as bool? ?? true,
      hint: json['hint'] as String?,
      helpUrl: json['helpUrl'] == null
          ? null
          : Uri.parse(json['helpUrl'] as String),
      defaultValue: json['defaultValue'] as String?,
    );

Map<String, dynamic> _$CredentialFieldToJson(_CredentialField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'kind': _$CredentialInputKindEnumMap[instance.kind]!,
      'isRequired': instance.isRequired,
      'hint': instance.hint,
      'helpUrl': instance.helpUrl?.toString(),
      'defaultValue': instance.defaultValue,
    };

const _$CredentialInputKindEnumMap = {
  CredentialInputKind.text: 'text',
  CredentialInputKind.secret: 'secret',
  CredentialInputKind.email: 'email',
  CredentialInputKind.url: 'url',
};
