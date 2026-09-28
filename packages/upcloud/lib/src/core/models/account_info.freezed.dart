// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountInfo {

 String? get login; String? get email; DataSize? get storageUsed;/// Remaining storage. `null` when unknown or unlimited.
 DataSize? get storageLeft; int? get filesTotal; bool get isPremium; DateTime? get premiumUntil;/// Account balance as reported by the provider (currency varies).
 String? get balance;/// Provider specific data not covered by the common fields.
 Map<String, Object?> get extra;
/// Create a copy of AccountInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountInfoCopyWith<AccountInfo> get copyWith => _$AccountInfoCopyWithImpl<AccountInfo>(this as AccountInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountInfo&&(identical(other.login, _this.login) || other.login == _this.login)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.storageUsed, _this.storageUsed) || other.storageUsed == _this.storageUsed)&&(identical(other.storageLeft, _this.storageLeft) || other.storageLeft == _this.storageLeft)&&(identical(other.filesTotal, _this.filesTotal) || other.filesTotal == _this.filesTotal)&&(identical(other.isPremium, _this.isPremium) || other.isPremium == _this.isPremium)&&(identical(other.premiumUntil, _this.premiumUntil) || other.premiumUntil == _this.premiumUntil)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&const DeepCollectionEquality().equals(other.extra, _this.extra));
}


@override
int get hashCode {
  final _this = this as AccountInfo;
  return Object.hash(runtimeType,_this.login,_this.email,_this.storageUsed,_this.storageLeft,_this.filesTotal,_this.isPremium,_this.premiumUntil,_this.balance,const DeepCollectionEquality().hash(_this.extra));
}

@override
String toString() {
  final _this = this as AccountInfo;
  return 'AccountInfo(login: ${_this.login}, email: ${_this.email}, storageUsed: ${_this.storageUsed}, storageLeft: ${_this.storageLeft}, filesTotal: ${_this.filesTotal}, isPremium: ${_this.isPremium}, premiumUntil: ${_this.premiumUntil}, balance: ${_this.balance}, extra: ${_this.extra})';
}


}

/// @nodoc
abstract mixin class $AccountInfoCopyWith<$Res>  {
  factory $AccountInfoCopyWith(AccountInfo value, $Res Function(AccountInfo) _then) = _$AccountInfoCopyWithImpl;
@useResult
$Res call({
 String? login, String? email, DataSize? storageUsed, DataSize? storageLeft, int? filesTotal, bool isPremium, DateTime? premiumUntil, String? balance, Map<String, Object?> extra
});




}
/// @nodoc
class _$AccountInfoCopyWithImpl<$Res>
    implements $AccountInfoCopyWith<$Res> {
  _$AccountInfoCopyWithImpl(this._self, this._then);

  final AccountInfo _self;
  final $Res Function(AccountInfo) _then;

/// Create a copy of AccountInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? login = freezed,Object? email = freezed,Object? storageUsed = freezed,Object? storageLeft = freezed,Object? filesTotal = freezed,Object? isPremium = null,Object? premiumUntil = freezed,Object? balance = freezed,Object? extra = null,}) {
  return _then(AccountInfo(
login: freezed == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,storageUsed: freezed == storageUsed ? _self.storageUsed : storageUsed // ignore: cast_nullable_to_non_nullable
as DataSize?,storageLeft: freezed == storageLeft ? _self.storageLeft : storageLeft // ignore: cast_nullable_to_non_nullable
as DataSize?,filesTotal: freezed == filesTotal ? _self.filesTotal : filesTotal // ignore: cast_nullable_to_non_nullable
as int?,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,premiumUntil: freezed == premiumUntil ? _self.premiumUntil : premiumUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,extra: null == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountInfo].
extension AccountInfoPatterns on AccountInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountInfo value)  $default,){
final _that = this;
switch (_that) {
case _AccountInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AccountInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? login,  String? email,  DataSize? storageUsed,  DataSize? storageLeft,  int? filesTotal,  bool isPremium,  DateTime? premiumUntil,  String? balance,  Map<String, Object?> extra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountInfo() when $default != null:
return $default(_that.login,_that.email,_that.storageUsed,_that.storageLeft,_that.filesTotal,_that.isPremium,_that.premiumUntil,_that.balance,_that.extra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? login,  String? email,  DataSize? storageUsed,  DataSize? storageLeft,  int? filesTotal,  bool isPremium,  DateTime? premiumUntil,  String? balance,  Map<String, Object?> extra)  $default,) {final _that = this;
switch (_that) {
case _AccountInfo():
return $default(_that.login,_that.email,_that.storageUsed,_that.storageLeft,_that.filesTotal,_that.isPremium,_that.premiumUntil,_that.balance,_that.extra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? login,  String? email,  DataSize? storageUsed,  DataSize? storageLeft,  int? filesTotal,  bool isPremium,  DateTime? premiumUntil,  String? balance,  Map<String, Object?> extra)?  $default,) {final _that = this;
switch (_that) {
case _AccountInfo() when $default != null:
return $default(_that.login,_that.email,_that.storageUsed,_that.storageLeft,_that.filesTotal,_that.isPremium,_that.premiumUntil,_that.balance,_that.extra);case _:
  return null;

}
}

}

/// @nodoc


class _AccountInfo implements AccountInfo {
  const _AccountInfo({this.login, this.email, this.storageUsed, this.storageLeft, this.filesTotal, this.isPremium = false, this.premiumUntil, this.balance,  Map<String, Object?> extra = const <String, Object?>{}}): _extra = extra;
  

@override final  String? login;
@override final  String? email;
@override final  DataSize? storageUsed;
/// Remaining storage. `null` when unknown or unlimited.
@override final  DataSize? storageLeft;
@override final  int? filesTotal;
@override@JsonKey() final  bool isPremium;
@override final  DateTime? premiumUntil;
/// Account balance as reported by the provider (currency varies).
@override final  String? balance;
/// Provider specific data not covered by the common fields.
 final  Map<String, Object?> _extra;
/// Provider specific data not covered by the common fields.
@override@JsonKey() Map<String, Object?> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}


/// Create a copy of AccountInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountInfoCopyWith<_AccountInfo> get copyWith => __$AccountInfoCopyWithImpl<_AccountInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountInfo&&(identical(other.login, login) || other.login == login)&&(identical(other.email, email) || other.email == email)&&(identical(other.storageUsed, storageUsed) || other.storageUsed == storageUsed)&&(identical(other.storageLeft, storageLeft) || other.storageLeft == storageLeft)&&(identical(other.filesTotal, filesTotal) || other.filesTotal == filesTotal)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.premiumUntil, premiumUntil) || other.premiumUntil == premiumUntil)&&(identical(other.balance, balance) || other.balance == balance)&&const DeepCollectionEquality().equals(other.extra, _extra));
}


@override
int get hashCode {
    return Object.hash(runtimeType,login,email,storageUsed,storageLeft,filesTotal,isPremium,premiumUntil,balance,const DeepCollectionEquality().hash(_extra));
}

@override
String toString() {
    return 'AccountInfo(login: $login, email: $email, storageUsed: $storageUsed, storageLeft: $storageLeft, filesTotal: $filesTotal, isPremium: $isPremium, premiumUntil: $premiumUntil, balance: $balance, extra: $extra)';
}


}

/// @nodoc
abstract mixin class _$AccountInfoCopyWith<$Res> implements $AccountInfoCopyWith<$Res> {
  factory _$AccountInfoCopyWith(_AccountInfo value, $Res Function(_AccountInfo) _then) = __$AccountInfoCopyWithImpl;
@override @useResult
$Res call({
 String? login, String? email, DataSize? storageUsed, DataSize? storageLeft, int? filesTotal, bool isPremium, DateTime? premiumUntil, String? balance, Map<String, Object?> extra
});




}
/// @nodoc
class __$AccountInfoCopyWithImpl<$Res>
    implements _$AccountInfoCopyWith<$Res> {
  __$AccountInfoCopyWithImpl(this._self, this._then);

  final _AccountInfo _self;
  final $Res Function(_AccountInfo) _then;

/// Create a copy of AccountInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? login = freezed,Object? email = freezed,Object? storageUsed = freezed,Object? storageLeft = freezed,Object? filesTotal = freezed,Object? isPremium = null,Object? premiumUntil = freezed,Object? balance = freezed,Object? extra = null,}) {
  return _then(_AccountInfo(
login: freezed == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,storageUsed: freezed == storageUsed ? _self.storageUsed : storageUsed // ignore: cast_nullable_to_non_nullable
as DataSize?,storageLeft: freezed == storageLeft ? _self.storageLeft : storageLeft // ignore: cast_nullable_to_non_nullable
as DataSize?,filesTotal: freezed == filesTotal ? _self.filesTotal : filesTotal // ignore: cast_nullable_to_non_nullable
as int?,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,premiumUntil: freezed == premiumUntil ? _self.premiumUntil : premiumUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
