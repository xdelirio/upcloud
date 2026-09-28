// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xvs_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$XvsAccountDto {

@LenientStringConverter() String? get login;@LenientStringConverter() String? get email;@JsonKey(name: 'storage_used')@LenientIntConverter() int? get storageUsed;@JsonKey(name: 'storage_left')@LenientIntConverter() int? get storageLeft;@JsonKey(name: 'files_total')@LenientIntConverter() int? get filesTotal;@LenientBoolConverter() bool? get premium;@JsonKey(name: 'premium_expire')@LenientDateTimeConverter() DateTime? get premiumExpire;@LenientStringConverter() String? get balance;
/// Create a copy of XvsAccountDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XvsAccountDtoCopyWith<XvsAccountDto> get copyWith => _$XvsAccountDtoCopyWithImpl<XvsAccountDto>(this as XvsAccountDto, _$identity);

  /// Serializes this XvsAccountDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as XvsAccountDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XvsAccountDto&&(identical(other.login, _this.login) || other.login == _this.login)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.storageUsed, _this.storageUsed) || other.storageUsed == _this.storageUsed)&&(identical(other.storageLeft, _this.storageLeft) || other.storageLeft == _this.storageLeft)&&(identical(other.filesTotal, _this.filesTotal) || other.filesTotal == _this.filesTotal)&&(identical(other.premium, _this.premium) || other.premium == _this.premium)&&(identical(other.premiumExpire, _this.premiumExpire) || other.premiumExpire == _this.premiumExpire)&&(identical(other.balance, _this.balance) || other.balance == _this.balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as XvsAccountDto;
  return Object.hash(runtimeType,_this.login,_this.email,_this.storageUsed,_this.storageLeft,_this.filesTotal,_this.premium,_this.premiumExpire,_this.balance);
}

@override
String toString() {
  final _this = this as XvsAccountDto;
  return 'XvsAccountDto(login: ${_this.login}, email: ${_this.email}, storageUsed: ${_this.storageUsed}, storageLeft: ${_this.storageLeft}, filesTotal: ${_this.filesTotal}, premium: ${_this.premium}, premiumExpire: ${_this.premiumExpire}, balance: ${_this.balance})';
}


}

/// @nodoc
abstract mixin class $XvsAccountDtoCopyWith<$Res>  {
  factory $XvsAccountDtoCopyWith(XvsAccountDto value, $Res Function(XvsAccountDto) _then) = _$XvsAccountDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? login,@LenientStringConverter() String? email,@JsonKey(name: 'storage_used')@LenientIntConverter() int? storageUsed,@JsonKey(name: 'storage_left')@LenientIntConverter() int? storageLeft,@JsonKey(name: 'files_total')@LenientIntConverter() int? filesTotal,@LenientBoolConverter() bool? premium,@JsonKey(name: 'premium_expire')@LenientDateTimeConverter() DateTime? premiumExpire,@LenientStringConverter() String? balance
});




}
/// @nodoc
class _$XvsAccountDtoCopyWithImpl<$Res>
    implements $XvsAccountDtoCopyWith<$Res> {
  _$XvsAccountDtoCopyWithImpl(this._self, this._then);

  final XvsAccountDto _self;
  final $Res Function(XvsAccountDto) _then;

/// Create a copy of XvsAccountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? login = freezed,Object? email = freezed,Object? storageUsed = freezed,Object? storageLeft = freezed,Object? filesTotal = freezed,Object? premium = freezed,Object? premiumExpire = freezed,Object? balance = freezed,}) {
  return _then(XvsAccountDto(
login: freezed == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,storageUsed: freezed == storageUsed ? _self.storageUsed : storageUsed // ignore: cast_nullable_to_non_nullable
as int?,storageLeft: freezed == storageLeft ? _self.storageLeft : storageLeft // ignore: cast_nullable_to_non_nullable
as int?,filesTotal: freezed == filesTotal ? _self.filesTotal : filesTotal // ignore: cast_nullable_to_non_nullable
as int?,premium: freezed == premium ? _self.premium : premium // ignore: cast_nullable_to_non_nullable
as bool?,premiumExpire: freezed == premiumExpire ? _self.premiumExpire : premiumExpire // ignore: cast_nullable_to_non_nullable
as DateTime?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [XvsAccountDto].
extension XvsAccountDtoPatterns on XvsAccountDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XvsAccountDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XvsAccountDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XvsAccountDto value)  $default,){
final _that = this;
switch (_that) {
case _XvsAccountDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XvsAccountDto value)?  $default,){
final _that = this;
switch (_that) {
case _XvsAccountDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? login, @LenientStringConverter()  String? email, @JsonKey(name: 'storage_used')@LenientIntConverter()  int? storageUsed, @JsonKey(name: 'storage_left')@LenientIntConverter()  int? storageLeft, @JsonKey(name: 'files_total')@LenientIntConverter()  int? filesTotal, @LenientBoolConverter()  bool? premium, @JsonKey(name: 'premium_expire')@LenientDateTimeConverter()  DateTime? premiumExpire, @LenientStringConverter()  String? balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XvsAccountDto() when $default != null:
return $default(_that.login,_that.email,_that.storageUsed,_that.storageLeft,_that.filesTotal,_that.premium,_that.premiumExpire,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? login, @LenientStringConverter()  String? email, @JsonKey(name: 'storage_used')@LenientIntConverter()  int? storageUsed, @JsonKey(name: 'storage_left')@LenientIntConverter()  int? storageLeft, @JsonKey(name: 'files_total')@LenientIntConverter()  int? filesTotal, @LenientBoolConverter()  bool? premium, @JsonKey(name: 'premium_expire')@LenientDateTimeConverter()  DateTime? premiumExpire, @LenientStringConverter()  String? balance)  $default,) {final _that = this;
switch (_that) {
case _XvsAccountDto():
return $default(_that.login,_that.email,_that.storageUsed,_that.storageLeft,_that.filesTotal,_that.premium,_that.premiumExpire,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? login, @LenientStringConverter()  String? email, @JsonKey(name: 'storage_used')@LenientIntConverter()  int? storageUsed, @JsonKey(name: 'storage_left')@LenientIntConverter()  int? storageLeft, @JsonKey(name: 'files_total')@LenientIntConverter()  int? filesTotal, @LenientBoolConverter()  bool? premium, @JsonKey(name: 'premium_expire')@LenientDateTimeConverter()  DateTime? premiumExpire, @LenientStringConverter()  String? balance)?  $default,) {final _that = this;
switch (_that) {
case _XvsAccountDto() when $default != null:
return $default(_that.login,_that.email,_that.storageUsed,_that.storageLeft,_that.filesTotal,_that.premium,_that.premiumExpire,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XvsAccountDto implements XvsAccountDto {
  const _XvsAccountDto({@LenientStringConverter() this.login, @LenientStringConverter() this.email, @JsonKey(name: 'storage_used')@LenientIntConverter() this.storageUsed, @JsonKey(name: 'storage_left')@LenientIntConverter() this.storageLeft, @JsonKey(name: 'files_total')@LenientIntConverter() this.filesTotal, @LenientBoolConverter() this.premium, @JsonKey(name: 'premium_expire')@LenientDateTimeConverter() this.premiumExpire, @LenientStringConverter() this.balance});
  factory _XvsAccountDto.fromJson(Map<String, dynamic> json) => _$XvsAccountDtoFromJson(json);

@override@LenientStringConverter() final  String? login;
@override@LenientStringConverter() final  String? email;
@override@JsonKey(name: 'storage_used')@LenientIntConverter() final  int? storageUsed;
@override@JsonKey(name: 'storage_left')@LenientIntConverter() final  int? storageLeft;
@override@JsonKey(name: 'files_total')@LenientIntConverter() final  int? filesTotal;
@override@LenientBoolConverter() final  bool? premium;
@override@JsonKey(name: 'premium_expire')@LenientDateTimeConverter() final  DateTime? premiumExpire;
@override@LenientStringConverter() final  String? balance;

/// Create a copy of XvsAccountDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XvsAccountDtoCopyWith<_XvsAccountDto> get copyWith => __$XvsAccountDtoCopyWithImpl<_XvsAccountDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XvsAccountDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _XvsAccountDto&&(identical(other.login, login) || other.login == login)&&(identical(other.email, email) || other.email == email)&&(identical(other.storageUsed, storageUsed) || other.storageUsed == storageUsed)&&(identical(other.storageLeft, storageLeft) || other.storageLeft == storageLeft)&&(identical(other.filesTotal, filesTotal) || other.filesTotal == filesTotal)&&(identical(other.premium, premium) || other.premium == premium)&&(identical(other.premiumExpire, premiumExpire) || other.premiumExpire == premiumExpire)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,login,email,storageUsed,storageLeft,filesTotal,premium,premiumExpire,balance);
}

@override
String toString() {
    return 'XvsAccountDto(login: $login, email: $email, storageUsed: $storageUsed, storageLeft: $storageLeft, filesTotal: $filesTotal, premium: $premium, premiumExpire: $premiumExpire, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$XvsAccountDtoCopyWith<$Res> implements $XvsAccountDtoCopyWith<$Res> {
  factory _$XvsAccountDtoCopyWith(_XvsAccountDto value, $Res Function(_XvsAccountDto) _then) = __$XvsAccountDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? login,@LenientStringConverter() String? email,@JsonKey(name: 'storage_used')@LenientIntConverter() int? storageUsed,@JsonKey(name: 'storage_left')@LenientIntConverter() int? storageLeft,@JsonKey(name: 'files_total')@LenientIntConverter() int? filesTotal,@LenientBoolConverter() bool? premium,@JsonKey(name: 'premium_expire')@LenientDateTimeConverter() DateTime? premiumExpire,@LenientStringConverter() String? balance
});




}
/// @nodoc
class __$XvsAccountDtoCopyWithImpl<$Res>
    implements _$XvsAccountDtoCopyWith<$Res> {
  __$XvsAccountDtoCopyWithImpl(this._self, this._then);

  final _XvsAccountDto _self;
  final $Res Function(_XvsAccountDto) _then;

/// Create a copy of XvsAccountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? login = freezed,Object? email = freezed,Object? storageUsed = freezed,Object? storageLeft = freezed,Object? filesTotal = freezed,Object? premium = freezed,Object? premiumExpire = freezed,Object? balance = freezed,}) {
  return _then(_XvsAccountDto(
login: freezed == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,storageUsed: freezed == storageUsed ? _self.storageUsed : storageUsed // ignore: cast_nullable_to_non_nullable
as int?,storageLeft: freezed == storageLeft ? _self.storageLeft : storageLeft // ignore: cast_nullable_to_non_nullable
as int?,filesTotal: freezed == filesTotal ? _self.filesTotal : filesTotal // ignore: cast_nullable_to_non_nullable
as int?,premium: freezed == premium ? _self.premium : premium // ignore: cast_nullable_to_non_nullable
as bool?,premiumExpire: freezed == premiumExpire ? _self.premiumExpire : premiumExpire // ignore: cast_nullable_to_non_nullable
as DateTime?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$XvsFolderDto {

@JsonKey(readValue: _readFolderId)@LenientStringConverter() String? get id;@LenientStringConverter() String? get name;/// Public code of the folder (used in shared folder links).
@LenientStringConverter() String? get code;@JsonKey(readValue: _readParentId)@LenientStringConverter() String? get parentId;@JsonKey(readValue: _readFileCount)@LenientIntConverter() int? get fileCount;
/// Create a copy of XvsFolderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XvsFolderDtoCopyWith<XvsFolderDto> get copyWith => _$XvsFolderDtoCopyWithImpl<XvsFolderDto>(this as XvsFolderDto, _$identity);

  /// Serializes this XvsFolderDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as XvsFolderDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XvsFolderDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.fileCount, _this.fileCount) || other.fileCount == _this.fileCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as XvsFolderDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code,_this.parentId,_this.fileCount);
}

@override
String toString() {
  final _this = this as XvsFolderDto;
  return 'XvsFolderDto(id: ${_this.id}, name: ${_this.name}, code: ${_this.code}, parentId: ${_this.parentId}, fileCount: ${_this.fileCount})';
}


}

/// @nodoc
abstract mixin class $XvsFolderDtoCopyWith<$Res>  {
  factory $XvsFolderDtoCopyWith(XvsFolderDto value, $Res Function(XvsFolderDto) _then) = _$XvsFolderDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readFolderId)@LenientStringConverter() String? id,@LenientStringConverter() String? name,@LenientStringConverter() String? code,@JsonKey(readValue: _readParentId)@LenientStringConverter() String? parentId,@JsonKey(readValue: _readFileCount)@LenientIntConverter() int? fileCount
});




}
/// @nodoc
class _$XvsFolderDtoCopyWithImpl<$Res>
    implements $XvsFolderDtoCopyWith<$Res> {
  _$XvsFolderDtoCopyWithImpl(this._self, this._then);

  final XvsFolderDto _self;
  final $Res Function(XvsFolderDto) _then;

/// Create a copy of XvsFolderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? code = freezed,Object? parentId = freezed,Object? fileCount = freezed,}) {
  return _then(XvsFolderDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,fileCount: freezed == fileCount ? _self.fileCount : fileCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [XvsFolderDto].
extension XvsFolderDtoPatterns on XvsFolderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XvsFolderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XvsFolderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XvsFolderDto value)  $default,){
final _that = this;
switch (_that) {
case _XvsFolderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XvsFolderDto value)?  $default,){
final _that = this;
switch (_that) {
case _XvsFolderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFolderId)@LenientStringConverter()  String? id, @LenientStringConverter()  String? name, @LenientStringConverter()  String? code, @JsonKey(readValue: _readParentId)@LenientStringConverter()  String? parentId, @JsonKey(readValue: _readFileCount)@LenientIntConverter()  int? fileCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XvsFolderDto() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.parentId,_that.fileCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFolderId)@LenientStringConverter()  String? id, @LenientStringConverter()  String? name, @LenientStringConverter()  String? code, @JsonKey(readValue: _readParentId)@LenientStringConverter()  String? parentId, @JsonKey(readValue: _readFileCount)@LenientIntConverter()  int? fileCount)  $default,) {final _that = this;
switch (_that) {
case _XvsFolderDto():
return $default(_that.id,_that.name,_that.code,_that.parentId,_that.fileCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readFolderId)@LenientStringConverter()  String? id, @LenientStringConverter()  String? name, @LenientStringConverter()  String? code, @JsonKey(readValue: _readParentId)@LenientStringConverter()  String? parentId, @JsonKey(readValue: _readFileCount)@LenientIntConverter()  int? fileCount)?  $default,) {final _that = this;
switch (_that) {
case _XvsFolderDto() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.parentId,_that.fileCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XvsFolderDto implements XvsFolderDto {
  const _XvsFolderDto({@JsonKey(readValue: _readFolderId)@LenientStringConverter() this.id, @LenientStringConverter() this.name, @LenientStringConverter() this.code, @JsonKey(readValue: _readParentId)@LenientStringConverter() this.parentId, @JsonKey(readValue: _readFileCount)@LenientIntConverter() this.fileCount});
  factory _XvsFolderDto.fromJson(Map<String, dynamic> json) => _$XvsFolderDtoFromJson(json);

@override@JsonKey(readValue: _readFolderId)@LenientStringConverter() final  String? id;
@override@LenientStringConverter() final  String? name;
/// Public code of the folder (used in shared folder links).
@override@LenientStringConverter() final  String? code;
@override@JsonKey(readValue: _readParentId)@LenientStringConverter() final  String? parentId;
@override@JsonKey(readValue: _readFileCount)@LenientIntConverter() final  int? fileCount;

/// Create a copy of XvsFolderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XvsFolderDtoCopyWith<_XvsFolderDto> get copyWith => __$XvsFolderDtoCopyWithImpl<_XvsFolderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XvsFolderDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _XvsFolderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.fileCount, fileCount) || other.fileCount == fileCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code,parentId,fileCount);
}

@override
String toString() {
    return 'XvsFolderDto(id: $id, name: $name, code: $code, parentId: $parentId, fileCount: $fileCount)';
}


}

/// @nodoc
abstract mixin class _$XvsFolderDtoCopyWith<$Res> implements $XvsFolderDtoCopyWith<$Res> {
  factory _$XvsFolderDtoCopyWith(_XvsFolderDto value, $Res Function(_XvsFolderDto) _then) = __$XvsFolderDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readFolderId)@LenientStringConverter() String? id,@LenientStringConverter() String? name,@LenientStringConverter() String? code,@JsonKey(readValue: _readParentId)@LenientStringConverter() String? parentId,@JsonKey(readValue: _readFileCount)@LenientIntConverter() int? fileCount
});




}
/// @nodoc
class __$XvsFolderDtoCopyWithImpl<$Res>
    implements _$XvsFolderDtoCopyWith<$Res> {
  __$XvsFolderDtoCopyWithImpl(this._self, this._then);

  final _XvsFolderDto _self;
  final $Res Function(_XvsFolderDto) _then;

/// Create a copy of XvsFolderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? code = freezed,Object? parentId = freezed,Object? fileCount = freezed,}) {
  return _then(_XvsFolderDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,fileCount: freezed == fileCount ? _self.fileCount : fileCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$XvsFileDto {

@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? get code;@JsonKey(readValue: _readTitle)@LenientStringConverter() String? get title;@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() String? get folderId;@JsonKey(readValue: _readLength)@_SecondsConverter() Duration? get length;@JsonKey(readValue: _readViews)@LenientIntConverter() int? get views;@JsonKey(readValue: _readCreated)@LenientDateTimeConverter() DateTime? get createdAt;@JsonKey(readValue: _readPublic)@LenientBoolConverter() bool? get isPublic;@JsonKey(readValue: _readCanPlay)@LenientBoolConverter() bool? get canPlay;@JsonKey(readValue: _readThumbnail)@LenientUriConverter() Uri? get thumbnail;/// Public page of the file.
@JsonKey(readValue: _readLink)@LenientUriConverter() Uri? get link;/// Size in bytes, when the clone reports it.
@JsonKey(readValue: _readSize)@LenientIntConverter() int? get size;/// Size of every encoded version (StreamHG `file_sizes`).
@JsonKey(readValue: _readSizes) List<XvsVersionDto> get sizes;/// Per-file status of `file/info` (`404` for unknown codes).
@LenientIntConverter() int? get status;
/// Create a copy of XvsFileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XvsFileDtoCopyWith<XvsFileDto> get copyWith => _$XvsFileDtoCopyWithImpl<XvsFileDto>(this as XvsFileDto, _$identity);

  /// Serializes this XvsFileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as XvsFileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XvsFileDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.folderId, _this.folderId) || other.folderId == _this.folderId)&&(identical(other.length, _this.length) || other.length == _this.length)&&(identical(other.views, _this.views) || other.views == _this.views)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.isPublic, _this.isPublic) || other.isPublic == _this.isPublic)&&(identical(other.canPlay, _this.canPlay) || other.canPlay == _this.canPlay)&&(identical(other.thumbnail, _this.thumbnail) || other.thumbnail == _this.thumbnail)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.size, _this.size) || other.size == _this.size)&&const DeepCollectionEquality().equals(other.sizes, _this.sizes)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as XvsFileDto;
  return Object.hash(runtimeType,_this.code,_this.title,_this.folderId,_this.length,_this.views,_this.createdAt,_this.isPublic,_this.canPlay,_this.thumbnail,_this.link,_this.size,const DeepCollectionEquality().hash(_this.sizes),_this.status);
}

@override
String toString() {
  final _this = this as XvsFileDto;
  return 'XvsFileDto(code: ${_this.code}, title: ${_this.title}, folderId: ${_this.folderId}, length: ${_this.length}, views: ${_this.views}, createdAt: ${_this.createdAt}, isPublic: ${_this.isPublic}, canPlay: ${_this.canPlay}, thumbnail: ${_this.thumbnail}, link: ${_this.link}, size: ${_this.size}, sizes: ${_this.sizes}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $XvsFileDtoCopyWith<$Res>  {
  factory $XvsFileDtoCopyWith(XvsFileDto value, $Res Function(XvsFileDto) _then) = _$XvsFileDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? code,@JsonKey(readValue: _readTitle)@LenientStringConverter() String? title,@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() String? folderId,@JsonKey(readValue: _readLength)@_SecondsConverter() Duration? length,@JsonKey(readValue: _readViews)@LenientIntConverter() int? views,@JsonKey(readValue: _readCreated)@LenientDateTimeConverter() DateTime? createdAt,@JsonKey(readValue: _readPublic)@LenientBoolConverter() bool? isPublic,@JsonKey(readValue: _readCanPlay)@LenientBoolConverter() bool? canPlay,@JsonKey(readValue: _readThumbnail)@LenientUriConverter() Uri? thumbnail,@JsonKey(readValue: _readLink)@LenientUriConverter() Uri? link,@JsonKey(readValue: _readSize)@LenientIntConverter() int? size,@JsonKey(readValue: _readSizes) List<XvsVersionDto> sizes,@LenientIntConverter() int? status
});




}
/// @nodoc
class _$XvsFileDtoCopyWithImpl<$Res>
    implements $XvsFileDtoCopyWith<$Res> {
  _$XvsFileDtoCopyWithImpl(this._self, this._then);

  final XvsFileDto _self;
  final $Res Function(XvsFileDto) _then;

/// Create a copy of XvsFileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? title = freezed,Object? folderId = freezed,Object? length = freezed,Object? views = freezed,Object? createdAt = freezed,Object? isPublic = freezed,Object? canPlay = freezed,Object? thumbnail = freezed,Object? link = freezed,Object? size = freezed,Object? sizes = null,Object? status = freezed,}) {
  return _then(XvsFileDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,length: freezed == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as Duration?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,canPlay: freezed == canPlay ? _self.canPlay : canPlay // ignore: cast_nullable_to_non_nullable
as bool?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as Uri?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as Uri?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,sizes: null == sizes ? _self.sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<XvsVersionDto>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [XvsFileDto].
extension XvsFileDtoPatterns on XvsFileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XvsFileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XvsFileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XvsFileDto value)  $default,){
final _that = this;
switch (_that) {
case _XvsFileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XvsFileDto value)?  $default,){
final _that = this;
switch (_that) {
case _XvsFileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readTitle)@LenientStringConverter()  String? title, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter()  String? folderId, @JsonKey(readValue: _readLength)@_SecondsConverter()  Duration? length, @JsonKey(readValue: _readViews)@LenientIntConverter()  int? views, @JsonKey(readValue: _readCreated)@LenientDateTimeConverter()  DateTime? createdAt, @JsonKey(readValue: _readPublic)@LenientBoolConverter()  bool? isPublic, @JsonKey(readValue: _readCanPlay)@LenientBoolConverter()  bool? canPlay, @JsonKey(readValue: _readThumbnail)@LenientUriConverter()  Uri? thumbnail, @JsonKey(readValue: _readLink)@LenientUriConverter()  Uri? link, @JsonKey(readValue: _readSize)@LenientIntConverter()  int? size, @JsonKey(readValue: _readSizes)  List<XvsVersionDto> sizes, @LenientIntConverter()  int? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XvsFileDto() when $default != null:
return $default(_that.code,_that.title,_that.folderId,_that.length,_that.views,_that.createdAt,_that.isPublic,_that.canPlay,_that.thumbnail,_that.link,_that.size,_that.sizes,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readTitle)@LenientStringConverter()  String? title, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter()  String? folderId, @JsonKey(readValue: _readLength)@_SecondsConverter()  Duration? length, @JsonKey(readValue: _readViews)@LenientIntConverter()  int? views, @JsonKey(readValue: _readCreated)@LenientDateTimeConverter()  DateTime? createdAt, @JsonKey(readValue: _readPublic)@LenientBoolConverter()  bool? isPublic, @JsonKey(readValue: _readCanPlay)@LenientBoolConverter()  bool? canPlay, @JsonKey(readValue: _readThumbnail)@LenientUriConverter()  Uri? thumbnail, @JsonKey(readValue: _readLink)@LenientUriConverter()  Uri? link, @JsonKey(readValue: _readSize)@LenientIntConverter()  int? size, @JsonKey(readValue: _readSizes)  List<XvsVersionDto> sizes, @LenientIntConverter()  int? status)  $default,) {final _that = this;
switch (_that) {
case _XvsFileDto():
return $default(_that.code,_that.title,_that.folderId,_that.length,_that.views,_that.createdAt,_that.isPublic,_that.canPlay,_that.thumbnail,_that.link,_that.size,_that.sizes,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readTitle)@LenientStringConverter()  String? title, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter()  String? folderId, @JsonKey(readValue: _readLength)@_SecondsConverter()  Duration? length, @JsonKey(readValue: _readViews)@LenientIntConverter()  int? views, @JsonKey(readValue: _readCreated)@LenientDateTimeConverter()  DateTime? createdAt, @JsonKey(readValue: _readPublic)@LenientBoolConverter()  bool? isPublic, @JsonKey(readValue: _readCanPlay)@LenientBoolConverter()  bool? canPlay, @JsonKey(readValue: _readThumbnail)@LenientUriConverter()  Uri? thumbnail, @JsonKey(readValue: _readLink)@LenientUriConverter()  Uri? link, @JsonKey(readValue: _readSize)@LenientIntConverter()  int? size, @JsonKey(readValue: _readSizes)  List<XvsVersionDto> sizes, @LenientIntConverter()  int? status)?  $default,) {final _that = this;
switch (_that) {
case _XvsFileDto() when $default != null:
return $default(_that.code,_that.title,_that.folderId,_that.length,_that.views,_that.createdAt,_that.isPublic,_that.canPlay,_that.thumbnail,_that.link,_that.size,_that.sizes,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XvsFileDto implements XvsFileDto {
  const _XvsFileDto({@JsonKey(readValue: _readFileCode)@LenientStringConverter() this.code, @JsonKey(readValue: _readTitle)@LenientStringConverter() this.title, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter() this.folderId, @JsonKey(readValue: _readLength)@_SecondsConverter() this.length, @JsonKey(readValue: _readViews)@LenientIntConverter() this.views, @JsonKey(readValue: _readCreated)@LenientDateTimeConverter() this.createdAt, @JsonKey(readValue: _readPublic)@LenientBoolConverter() this.isPublic, @JsonKey(readValue: _readCanPlay)@LenientBoolConverter() this.canPlay, @JsonKey(readValue: _readThumbnail)@LenientUriConverter() this.thumbnail, @JsonKey(readValue: _readLink)@LenientUriConverter() this.link, @JsonKey(readValue: _readSize)@LenientIntConverter() this.size, @JsonKey(readValue: _readSizes)  List<XvsVersionDto> sizes = const <XvsVersionDto>[], @LenientIntConverter() this.status}): _sizes = sizes;
  factory _XvsFileDto.fromJson(Map<String, dynamic> json) => _$XvsFileDtoFromJson(json);

@override@JsonKey(readValue: _readFileCode)@LenientStringConverter() final  String? code;
@override@JsonKey(readValue: _readTitle)@LenientStringConverter() final  String? title;
@override@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() final  String? folderId;
@override@JsonKey(readValue: _readLength)@_SecondsConverter() final  Duration? length;
@override@JsonKey(readValue: _readViews)@LenientIntConverter() final  int? views;
@override@JsonKey(readValue: _readCreated)@LenientDateTimeConverter() final  DateTime? createdAt;
@override@JsonKey(readValue: _readPublic)@LenientBoolConverter() final  bool? isPublic;
@override@JsonKey(readValue: _readCanPlay)@LenientBoolConverter() final  bool? canPlay;
@override@JsonKey(readValue: _readThumbnail)@LenientUriConverter() final  Uri? thumbnail;
/// Public page of the file.
@override@JsonKey(readValue: _readLink)@LenientUriConverter() final  Uri? link;
/// Size in bytes, when the clone reports it.
@override@JsonKey(readValue: _readSize)@LenientIntConverter() final  int? size;
/// Size of every encoded version (StreamHG `file_sizes`).
 final  List<XvsVersionDto> _sizes;
/// Size of every encoded version (StreamHG `file_sizes`).
@override@JsonKey(readValue: _readSizes) List<XvsVersionDto> get sizes {
  if (_sizes is EqualUnmodifiableListView) return _sizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sizes);
}

/// Per-file status of `file/info` (`404` for unknown codes).
@override@LenientIntConverter() final  int? status;

/// Create a copy of XvsFileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XvsFileDtoCopyWith<_XvsFileDto> get copyWith => __$XvsFileDtoCopyWithImpl<_XvsFileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XvsFileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _XvsFileDto&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.length, length) || other.length == length)&&(identical(other.views, views) || other.views == views)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.canPlay, canPlay) || other.canPlay == canPlay)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.link, link) || other.link == link)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.sizes, _sizes)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,title,folderId,length,views,createdAt,isPublic,canPlay,thumbnail,link,size,const DeepCollectionEquality().hash(_sizes),status);
}

@override
String toString() {
    return 'XvsFileDto(code: $code, title: $title, folderId: $folderId, length: $length, views: $views, createdAt: $createdAt, isPublic: $isPublic, canPlay: $canPlay, thumbnail: $thumbnail, link: $link, size: $size, sizes: $sizes, status: $status)';
}


}

/// @nodoc
abstract mixin class _$XvsFileDtoCopyWith<$Res> implements $XvsFileDtoCopyWith<$Res> {
  factory _$XvsFileDtoCopyWith(_XvsFileDto value, $Res Function(_XvsFileDto) _then) = __$XvsFileDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? code,@JsonKey(readValue: _readTitle)@LenientStringConverter() String? title,@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() String? folderId,@JsonKey(readValue: _readLength)@_SecondsConverter() Duration? length,@JsonKey(readValue: _readViews)@LenientIntConverter() int? views,@JsonKey(readValue: _readCreated)@LenientDateTimeConverter() DateTime? createdAt,@JsonKey(readValue: _readPublic)@LenientBoolConverter() bool? isPublic,@JsonKey(readValue: _readCanPlay)@LenientBoolConverter() bool? canPlay,@JsonKey(readValue: _readThumbnail)@LenientUriConverter() Uri? thumbnail,@JsonKey(readValue: _readLink)@LenientUriConverter() Uri? link,@JsonKey(readValue: _readSize)@LenientIntConverter() int? size,@JsonKey(readValue: _readSizes) List<XvsVersionDto> sizes,@LenientIntConverter() int? status
});




}
/// @nodoc
class __$XvsFileDtoCopyWithImpl<$Res>
    implements _$XvsFileDtoCopyWith<$Res> {
  __$XvsFileDtoCopyWithImpl(this._self, this._then);

  final _XvsFileDto _self;
  final $Res Function(_XvsFileDto) _then;

/// Create a copy of XvsFileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? title = freezed,Object? folderId = freezed,Object? length = freezed,Object? views = freezed,Object? createdAt = freezed,Object? isPublic = freezed,Object? canPlay = freezed,Object? thumbnail = freezed,Object? link = freezed,Object? size = freezed,Object? sizes = null,Object? status = freezed,}) {
  return _then(_XvsFileDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,length: freezed == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as Duration?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,canPlay: freezed == canPlay ? _self.canPlay : canPlay // ignore: cast_nullable_to_non_nullable
as bool?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as Uri?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as Uri?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,sizes: null == sizes ? _self._sizes : sizes // ignore: cast_nullable_to_non_nullable
as List<XvsVersionDto>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$XvsVersionDto {

/// Quality code: `o` (original), `h` (high), `n` (normal), `l` (low).
@LenientStringConverter() String? get name;@LenientUriConverter() Uri? get url;@LenientIntConverter() int? get size;
/// Create a copy of XvsVersionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XvsVersionDtoCopyWith<XvsVersionDto> get copyWith => _$XvsVersionDtoCopyWithImpl<XvsVersionDto>(this as XvsVersionDto, _$identity);

  /// Serializes this XvsVersionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as XvsVersionDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XvsVersionDto&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.size, _this.size) || other.size == _this.size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as XvsVersionDto;
  return Object.hash(runtimeType,_this.name,_this.url,_this.size);
}

@override
String toString() {
  final _this = this as XvsVersionDto;
  return 'XvsVersionDto(name: ${_this.name}, url: ${_this.url}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $XvsVersionDtoCopyWith<$Res>  {
  factory $XvsVersionDtoCopyWith(XvsVersionDto value, $Res Function(XvsVersionDto) _then) = _$XvsVersionDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? name,@LenientUriConverter() Uri? url,@LenientIntConverter() int? size
});




}
/// @nodoc
class _$XvsVersionDtoCopyWithImpl<$Res>
    implements $XvsVersionDtoCopyWith<$Res> {
  _$XvsVersionDtoCopyWithImpl(this._self, this._then);

  final XvsVersionDto _self;
  final $Res Function(XvsVersionDto) _then;

/// Create a copy of XvsVersionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = freezed,Object? size = freezed,}) {
  return _then(XvsVersionDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [XvsVersionDto].
extension XvsVersionDtoPatterns on XvsVersionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XvsVersionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XvsVersionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XvsVersionDto value)  $default,){
final _that = this;
switch (_that) {
case _XvsVersionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XvsVersionDto value)?  $default,){
final _that = this;
switch (_that) {
case _XvsVersionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? name, @LenientUriConverter()  Uri? url, @LenientIntConverter()  int? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XvsVersionDto() when $default != null:
return $default(_that.name,_that.url,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? name, @LenientUriConverter()  Uri? url, @LenientIntConverter()  int? size)  $default,) {final _that = this;
switch (_that) {
case _XvsVersionDto():
return $default(_that.name,_that.url,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? name, @LenientUriConverter()  Uri? url, @LenientIntConverter()  int? size)?  $default,) {final _that = this;
switch (_that) {
case _XvsVersionDto() when $default != null:
return $default(_that.name,_that.url,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XvsVersionDto implements XvsVersionDto {
  const _XvsVersionDto({@LenientStringConverter() this.name, @LenientUriConverter() this.url, @LenientIntConverter() this.size});
  factory _XvsVersionDto.fromJson(Map<String, dynamic> json) => _$XvsVersionDtoFromJson(json);

/// Quality code: `o` (original), `h` (high), `n` (normal), `l` (low).
@override@LenientStringConverter() final  String? name;
@override@LenientUriConverter() final  Uri? url;
@override@LenientIntConverter() final  int? size;

/// Create a copy of XvsVersionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XvsVersionDtoCopyWith<_XvsVersionDto> get copyWith => __$XvsVersionDtoCopyWithImpl<_XvsVersionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XvsVersionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _XvsVersionDto&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,url,size);
}

@override
String toString() {
    return 'XvsVersionDto(name: $name, url: $url, size: $size)';
}


}

/// @nodoc
abstract mixin class _$XvsVersionDtoCopyWith<$Res> implements $XvsVersionDtoCopyWith<$Res> {
  factory _$XvsVersionDtoCopyWith(_XvsVersionDto value, $Res Function(_XvsVersionDto) _then) = __$XvsVersionDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? name,@LenientUriConverter() Uri? url,@LenientIntConverter() int? size
});




}
/// @nodoc
class __$XvsVersionDtoCopyWithImpl<$Res>
    implements _$XvsVersionDtoCopyWith<$Res> {
  __$XvsVersionDtoCopyWithImpl(this._self, this._then);

  final _XvsVersionDto _self;
  final $Res Function(_XvsVersionDto) _then;

/// Create a copy of XvsVersionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = freezed,Object? size = freezed,}) {
  return _then(_XvsVersionDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$XvsUploadedFileDto {

@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? get code;@JsonKey(readValue: _readFileName)@LenientStringConverter() String? get name;/// `OK` on success, otherwise an error message.
@LenientStringConverter() String? get status;
/// Create a copy of XvsUploadedFileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XvsUploadedFileDtoCopyWith<XvsUploadedFileDto> get copyWith => _$XvsUploadedFileDtoCopyWithImpl<XvsUploadedFileDto>(this as XvsUploadedFileDto, _$identity);

  /// Serializes this XvsUploadedFileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as XvsUploadedFileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XvsUploadedFileDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as XvsUploadedFileDto;
  return Object.hash(runtimeType,_this.code,_this.name,_this.status);
}

@override
String toString() {
  final _this = this as XvsUploadedFileDto;
  return 'XvsUploadedFileDto(code: ${_this.code}, name: ${_this.name}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $XvsUploadedFileDtoCopyWith<$Res>  {
  factory $XvsUploadedFileDtoCopyWith(XvsUploadedFileDto value, $Res Function(XvsUploadedFileDto) _then) = _$XvsUploadedFileDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? code,@JsonKey(readValue: _readFileName)@LenientStringConverter() String? name,@LenientStringConverter() String? status
});




}
/// @nodoc
class _$XvsUploadedFileDtoCopyWithImpl<$Res>
    implements $XvsUploadedFileDtoCopyWith<$Res> {
  _$XvsUploadedFileDtoCopyWithImpl(this._self, this._then);

  final XvsUploadedFileDto _self;
  final $Res Function(XvsUploadedFileDto) _then;

/// Create a copy of XvsUploadedFileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? name = freezed,Object? status = freezed,}) {
  return _then(XvsUploadedFileDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [XvsUploadedFileDto].
extension XvsUploadedFileDtoPatterns on XvsUploadedFileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XvsUploadedFileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XvsUploadedFileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XvsUploadedFileDto value)  $default,){
final _that = this;
switch (_that) {
case _XvsUploadedFileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XvsUploadedFileDto value)?  $default,){
final _that = this;
switch (_that) {
case _XvsUploadedFileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readFileName)@LenientStringConverter()  String? name, @LenientStringConverter()  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XvsUploadedFileDto() when $default != null:
return $default(_that.code,_that.name,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readFileName)@LenientStringConverter()  String? name, @LenientStringConverter()  String? status)  $default,) {final _that = this;
switch (_that) {
case _XvsUploadedFileDto():
return $default(_that.code,_that.name,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readFileName)@LenientStringConverter()  String? name, @LenientStringConverter()  String? status)?  $default,) {final _that = this;
switch (_that) {
case _XvsUploadedFileDto() when $default != null:
return $default(_that.code,_that.name,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XvsUploadedFileDto implements XvsUploadedFileDto {
  const _XvsUploadedFileDto({@JsonKey(readValue: _readFileCode)@LenientStringConverter() this.code, @JsonKey(readValue: _readFileName)@LenientStringConverter() this.name, @LenientStringConverter() this.status});
  factory _XvsUploadedFileDto.fromJson(Map<String, dynamic> json) => _$XvsUploadedFileDtoFromJson(json);

@override@JsonKey(readValue: _readFileCode)@LenientStringConverter() final  String? code;
@override@JsonKey(readValue: _readFileName)@LenientStringConverter() final  String? name;
/// `OK` on success, otherwise an error message.
@override@LenientStringConverter() final  String? status;

/// Create a copy of XvsUploadedFileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XvsUploadedFileDtoCopyWith<_XvsUploadedFileDto> get copyWith => __$XvsUploadedFileDtoCopyWithImpl<_XvsUploadedFileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XvsUploadedFileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _XvsUploadedFileDto&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name,status);
}

@override
String toString() {
    return 'XvsUploadedFileDto(code: $code, name: $name, status: $status)';
}


}

/// @nodoc
abstract mixin class _$XvsUploadedFileDtoCopyWith<$Res> implements $XvsUploadedFileDtoCopyWith<$Res> {
  factory _$XvsUploadedFileDtoCopyWith(_XvsUploadedFileDto value, $Res Function(_XvsUploadedFileDto) _then) = __$XvsUploadedFileDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? code,@JsonKey(readValue: _readFileName)@LenientStringConverter() String? name,@LenientStringConverter() String? status
});




}
/// @nodoc
class __$XvsUploadedFileDtoCopyWithImpl<$Res>
    implements _$XvsUploadedFileDtoCopyWith<$Res> {
  __$XvsUploadedFileDtoCopyWithImpl(this._self, this._then);

  final _XvsUploadedFileDto _self;
  final $Res Function(_XvsUploadedFileDto) _then;

/// Create a copy of XvsUploadedFileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? name = freezed,Object? status = freezed,}) {
  return _then(_XvsUploadedFileDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$XvsRemoteUploadDto {

@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? get code;@JsonKey(readValue: _readRemoteUrl)@LenientUriConverter() Uri? get url;/// `PENDING`, `WORKING`, `ERROR`, `OK`...
@LenientStringConverter() String? get status;/// Percentage between 0 and 100.
@LenientDoubleConverter() double? get progress;@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() String? get folderId;@JsonKey(readValue: _readError)@LenientStringConverter() String? get error;
/// Create a copy of XvsRemoteUploadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$XvsRemoteUploadDtoCopyWith<XvsRemoteUploadDto> get copyWith => _$XvsRemoteUploadDtoCopyWithImpl<XvsRemoteUploadDto>(this as XvsRemoteUploadDto, _$identity);

  /// Serializes this XvsRemoteUploadDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as XvsRemoteUploadDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is XvsRemoteUploadDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.folderId, _this.folderId) || other.folderId == _this.folderId)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as XvsRemoteUploadDto;
  return Object.hash(runtimeType,_this.code,_this.url,_this.status,_this.progress,_this.folderId,_this.error);
}

@override
String toString() {
  final _this = this as XvsRemoteUploadDto;
  return 'XvsRemoteUploadDto(code: ${_this.code}, url: ${_this.url}, status: ${_this.status}, progress: ${_this.progress}, folderId: ${_this.folderId}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $XvsRemoteUploadDtoCopyWith<$Res>  {
  factory $XvsRemoteUploadDtoCopyWith(XvsRemoteUploadDto value, $Res Function(XvsRemoteUploadDto) _then) = _$XvsRemoteUploadDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? code,@JsonKey(readValue: _readRemoteUrl)@LenientUriConverter() Uri? url,@LenientStringConverter() String? status,@LenientDoubleConverter() double? progress,@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() String? folderId,@JsonKey(readValue: _readError)@LenientStringConverter() String? error
});




}
/// @nodoc
class _$XvsRemoteUploadDtoCopyWithImpl<$Res>
    implements $XvsRemoteUploadDtoCopyWith<$Res> {
  _$XvsRemoteUploadDtoCopyWithImpl(this._self, this._then);

  final XvsRemoteUploadDto _self;
  final $Res Function(XvsRemoteUploadDto) _then;

/// Create a copy of XvsRemoteUploadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? url = freezed,Object? status = freezed,Object? progress = freezed,Object? folderId = freezed,Object? error = freezed,}) {
  return _then(XvsRemoteUploadDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [XvsRemoteUploadDto].
extension XvsRemoteUploadDtoPatterns on XvsRemoteUploadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _XvsRemoteUploadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _XvsRemoteUploadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _XvsRemoteUploadDto value)  $default,){
final _that = this;
switch (_that) {
case _XvsRemoteUploadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _XvsRemoteUploadDto value)?  $default,){
final _that = this;
switch (_that) {
case _XvsRemoteUploadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readRemoteUrl)@LenientUriConverter()  Uri? url, @LenientStringConverter()  String? status, @LenientDoubleConverter()  double? progress, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter()  String? folderId, @JsonKey(readValue: _readError)@LenientStringConverter()  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _XvsRemoteUploadDto() when $default != null:
return $default(_that.code,_that.url,_that.status,_that.progress,_that.folderId,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readRemoteUrl)@LenientUriConverter()  Uri? url, @LenientStringConverter()  String? status, @LenientDoubleConverter()  double? progress, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter()  String? folderId, @JsonKey(readValue: _readError)@LenientStringConverter()  String? error)  $default,) {final _that = this;
switch (_that) {
case _XvsRemoteUploadDto():
return $default(_that.code,_that.url,_that.status,_that.progress,_that.folderId,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readFileCode)@LenientStringConverter()  String? code, @JsonKey(readValue: _readRemoteUrl)@LenientUriConverter()  Uri? url, @LenientStringConverter()  String? status, @LenientDoubleConverter()  double? progress, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter()  String? folderId, @JsonKey(readValue: _readError)@LenientStringConverter()  String? error)?  $default,) {final _that = this;
switch (_that) {
case _XvsRemoteUploadDto() when $default != null:
return $default(_that.code,_that.url,_that.status,_that.progress,_that.folderId,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _XvsRemoteUploadDto implements XvsRemoteUploadDto {
  const _XvsRemoteUploadDto({@JsonKey(readValue: _readFileCode)@LenientStringConverter() this.code, @JsonKey(readValue: _readRemoteUrl)@LenientUriConverter() this.url, @LenientStringConverter() this.status, @LenientDoubleConverter() this.progress, @JsonKey(readValue: _readFileFolderId)@LenientStringConverter() this.folderId, @JsonKey(readValue: _readError)@LenientStringConverter() this.error});
  factory _XvsRemoteUploadDto.fromJson(Map<String, dynamic> json) => _$XvsRemoteUploadDtoFromJson(json);

@override@JsonKey(readValue: _readFileCode)@LenientStringConverter() final  String? code;
@override@JsonKey(readValue: _readRemoteUrl)@LenientUriConverter() final  Uri? url;
/// `PENDING`, `WORKING`, `ERROR`, `OK`...
@override@LenientStringConverter() final  String? status;
/// Percentage between 0 and 100.
@override@LenientDoubleConverter() final  double? progress;
@override@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() final  String? folderId;
@override@JsonKey(readValue: _readError)@LenientStringConverter() final  String? error;

/// Create a copy of XvsRemoteUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$XvsRemoteUploadDtoCopyWith<_XvsRemoteUploadDto> get copyWith => __$XvsRemoteUploadDtoCopyWithImpl<_XvsRemoteUploadDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$XvsRemoteUploadDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _XvsRemoteUploadDto&&(identical(other.code, code) || other.code == code)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,url,status,progress,folderId,error);
}

@override
String toString() {
    return 'XvsRemoteUploadDto(code: $code, url: $url, status: $status, progress: $progress, folderId: $folderId, error: $error)';
}


}

/// @nodoc
abstract mixin class _$XvsRemoteUploadDtoCopyWith<$Res> implements $XvsRemoteUploadDtoCopyWith<$Res> {
  factory _$XvsRemoteUploadDtoCopyWith(_XvsRemoteUploadDto value, $Res Function(_XvsRemoteUploadDto) _then) = __$XvsRemoteUploadDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readFileCode)@LenientStringConverter() String? code,@JsonKey(readValue: _readRemoteUrl)@LenientUriConverter() Uri? url,@LenientStringConverter() String? status,@LenientDoubleConverter() double? progress,@JsonKey(readValue: _readFileFolderId)@LenientStringConverter() String? folderId,@JsonKey(readValue: _readError)@LenientStringConverter() String? error
});




}
/// @nodoc
class __$XvsRemoteUploadDtoCopyWithImpl<$Res>
    implements _$XvsRemoteUploadDtoCopyWith<$Res> {
  __$XvsRemoteUploadDtoCopyWithImpl(this._self, this._then);

  final _XvsRemoteUploadDto _self;
  final $Res Function(_XvsRemoteUploadDto) _then;

/// Create a copy of XvsRemoteUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? url = freezed,Object? status = freezed,Object? progress = freezed,Object? folderId = freezed,Object? error = freezed,}) {
  return _then(_XvsRemoteUploadDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
