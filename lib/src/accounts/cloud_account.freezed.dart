// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudAccount {

/// Unique id of the account inside the app.
 String get id;/// Id of the `ProviderDefinition` used to connect.
 String get providerId;/// Name shown to the user.
 String get label; Credentials get credentials;/// Overrides the provider's API base URL (e.g. after a domain change).
 Uri? get baseUrl;/// Overrides the provider's maximum upload size, in bytes.
 int? get maxFileSizeBytes; DateTime? get createdAt;
/// Create a copy of CloudAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudAccountCopyWith<CloudAccount> get copyWith => _$CloudAccountCopyWithImpl<CloudAccount>(this as CloudAccount, _$identity);

  /// Serializes this CloudAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CloudAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.providerId, _this.providerId) || other.providerId == _this.providerId)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.credentials, _this.credentials) || other.credentials == _this.credentials)&&(identical(other.baseUrl, _this.baseUrl) || other.baseUrl == _this.baseUrl)&&(identical(other.maxFileSizeBytes, _this.maxFileSizeBytes) || other.maxFileSizeBytes == _this.maxFileSizeBytes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CloudAccount;
  return Object.hash(runtimeType,_this.id,_this.providerId,_this.label,_this.credentials,_this.baseUrl,_this.maxFileSizeBytes,_this.createdAt);
}

@override
String toString() {
  final _this = this as CloudAccount;
  return 'CloudAccount(id: ${_this.id}, providerId: ${_this.providerId}, label: ${_this.label}, credentials: ${_this.credentials}, baseUrl: ${_this.baseUrl}, maxFileSizeBytes: ${_this.maxFileSizeBytes}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CloudAccountCopyWith<$Res>  {
  factory $CloudAccountCopyWith(CloudAccount value, $Res Function(CloudAccount) _then) = _$CloudAccountCopyWithImpl;
@useResult
$Res call({
 String id, String providerId, String label, Credentials credentials, Uri? baseUrl, int? maxFileSizeBytes, DateTime? createdAt
});


$CredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class _$CloudAccountCopyWithImpl<$Res>
    implements $CloudAccountCopyWith<$Res> {
  _$CloudAccountCopyWithImpl(this._self, this._then);

  final CloudAccount _self;
  final $Res Function(CloudAccount) _then;

/// Create a copy of CloudAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? providerId = null,Object? label = null,Object? credentials = null,Object? baseUrl = freezed,Object? maxFileSizeBytes = freezed,Object? createdAt = freezed,}) {
  return _then(CloudAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as Credentials,baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as Uri?,maxFileSizeBytes: freezed == maxFileSizeBytes ? _self.maxFileSizeBytes : maxFileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of CloudAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialsCopyWith<$Res> get credentials {
  
  return $CredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}


/// Adds pattern-matching-related methods to [CloudAccount].
extension CloudAccountPatterns on CloudAccount {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloudAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloudAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloudAccount value)  $default,){
final _that = this;
switch (_that) {
case _CloudAccount():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloudAccount value)?  $default,){
final _that = this;
switch (_that) {
case _CloudAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String providerId,  String label,  Credentials credentials,  Uri? baseUrl,  int? maxFileSizeBytes,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloudAccount() when $default != null:
return $default(_that.id,_that.providerId,_that.label,_that.credentials,_that.baseUrl,_that.maxFileSizeBytes,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String providerId,  String label,  Credentials credentials,  Uri? baseUrl,  int? maxFileSizeBytes,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CloudAccount():
return $default(_that.id,_that.providerId,_that.label,_that.credentials,_that.baseUrl,_that.maxFileSizeBytes,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String providerId,  String label,  Credentials credentials,  Uri? baseUrl,  int? maxFileSizeBytes,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CloudAccount() when $default != null:
return $default(_that.id,_that.providerId,_that.label,_that.credentials,_that.baseUrl,_that.maxFileSizeBytes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CloudAccount implements CloudAccount {
  const _CloudAccount({required this.id, required this.providerId, required this.label, required this.credentials, this.baseUrl, this.maxFileSizeBytes, this.createdAt});
  factory _CloudAccount.fromJson(Map<String, dynamic> json) => _$CloudAccountFromJson(json);

/// Unique id of the account inside the app.
@override final  String id;
/// Id of the `ProviderDefinition` used to connect.
@override final  String providerId;
/// Name shown to the user.
@override final  String label;
@override final  Credentials credentials;
/// Overrides the provider's API base URL (e.g. after a domain change).
@override final  Uri? baseUrl;
/// Overrides the provider's maximum upload size, in bytes.
@override final  int? maxFileSizeBytes;
@override final  DateTime? createdAt;

/// Create a copy of CloudAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloudAccountCopyWith<_CloudAccount> get copyWith => __$CloudAccountCopyWithImpl<_CloudAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CloudAccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloudAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.label, label) || other.label == label)&&(identical(other.credentials, credentials) || other.credentials == credentials)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.maxFileSizeBytes, maxFileSizeBytes) || other.maxFileSizeBytes == maxFileSizeBytes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,providerId,label,credentials,baseUrl,maxFileSizeBytes,createdAt);
}

@override
String toString() {
    return 'CloudAccount(id: $id, providerId: $providerId, label: $label, credentials: $credentials, baseUrl: $baseUrl, maxFileSizeBytes: $maxFileSizeBytes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CloudAccountCopyWith<$Res> implements $CloudAccountCopyWith<$Res> {
  factory _$CloudAccountCopyWith(_CloudAccount value, $Res Function(_CloudAccount) _then) = __$CloudAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String providerId, String label, Credentials credentials, Uri? baseUrl, int? maxFileSizeBytes, DateTime? createdAt
});


@override $CredentialsCopyWith<$Res> get credentials;

}
/// @nodoc
class __$CloudAccountCopyWithImpl<$Res>
    implements _$CloudAccountCopyWith<$Res> {
  __$CloudAccountCopyWithImpl(this._self, this._then);

  final _CloudAccount _self;
  final $Res Function(_CloudAccount) _then;

/// Create a copy of CloudAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? providerId = null,Object? label = null,Object? credentials = null,Object? baseUrl = freezed,Object? maxFileSizeBytes = freezed,Object? createdAt = freezed,}) {
  return _then(_CloudAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,credentials: null == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as Credentials,baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as Uri?,maxFileSizeBytes: freezed == maxFileSizeBytes ? _self.maxFileSizeBytes : maxFileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of CloudAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialsCopyWith<$Res> get credentials {
  
  return $CredentialsCopyWith<$Res>(_self.credentials, (value) {
    return _then(_self.copyWith(credentials: value));
  });
}
}

// dart format on
