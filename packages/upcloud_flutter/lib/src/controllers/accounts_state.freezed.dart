// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accounts_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AccountStatus()';
}


}

/// @nodoc
class $AccountStatusCopyWith<$Res>  {
$AccountStatusCopyWith(AccountStatus _, $Res Function(AccountStatus) __);
}


/// Adds pattern-matching-related methods to [AccountStatus].
extension AccountStatusPatterns on AccountStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AccountStatusChecking value)?  checking,TResult Function( AccountStatusConnected value)?  connected,TResult Function( AccountStatusFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AccountStatusChecking() when checking != null:
return checking(_that);case AccountStatusConnected() when connected != null:
return connected(_that);case AccountStatusFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AccountStatusChecking value)  checking,required TResult Function( AccountStatusConnected value)  connected,required TResult Function( AccountStatusFailed value)  failed,}){
final _that = this;
switch (_that) {
case AccountStatusChecking():
return checking(_that);case AccountStatusConnected():
return connected(_that);case AccountStatusFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AccountStatusChecking value)?  checking,TResult? Function( AccountStatusConnected value)?  connected,TResult? Function( AccountStatusFailed value)?  failed,}){
final _that = this;
switch (_that) {
case AccountStatusChecking() when checking != null:
return checking(_that);case AccountStatusConnected() when connected != null:
return connected(_that);case AccountStatusFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  checking,TResult Function( AccountInfo? info)?  connected,TResult Function( UpCloudException error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AccountStatusChecking() when checking != null:
return checking();case AccountStatusConnected() when connected != null:
return connected(_that.info);case AccountStatusFailed() when failed != null:
return failed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  checking,required TResult Function( AccountInfo? info)  connected,required TResult Function( UpCloudException error)  failed,}) {final _that = this;
switch (_that) {
case AccountStatusChecking():
return checking();case AccountStatusConnected():
return connected(_that.info);case AccountStatusFailed():
return failed(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  checking,TResult? Function( AccountInfo? info)?  connected,TResult? Function( UpCloudException error)?  failed,}) {final _that = this;
switch (_that) {
case AccountStatusChecking() when checking != null:
return checking();case AccountStatusConnected() when connected != null:
return connected(_that.info);case AccountStatusFailed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AccountStatusChecking implements AccountStatus {
  const AccountStatusChecking();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountStatusChecking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AccountStatus.checking()';
}


}




/// @nodoc


class AccountStatusConnected implements AccountStatus {
  const AccountStatusConnected({this.info});
  

/// Account details, when the provider reports them.
 final  AccountInfo? info;

/// Create a copy of AccountStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountStatusConnectedCopyWith<AccountStatusConnected> get copyWith => _$AccountStatusConnectedCopyWithImpl<AccountStatusConnected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountStatusConnected&&(identical(other.info, info) || other.info == info));
}


@override
int get hashCode {
    return Object.hash(runtimeType,info);
}

@override
String toString() {
    return 'AccountStatus.connected(info: $info)';
}


}

/// @nodoc
abstract mixin class $AccountStatusConnectedCopyWith<$Res> implements $AccountStatusCopyWith<$Res> {
  factory $AccountStatusConnectedCopyWith(AccountStatusConnected value, $Res Function(AccountStatusConnected) _then) = _$AccountStatusConnectedCopyWithImpl;
@useResult
$Res call({
 AccountInfo? info
});


$AccountInfoCopyWith<$Res>? get info;

}
/// @nodoc
class _$AccountStatusConnectedCopyWithImpl<$Res>
    implements $AccountStatusConnectedCopyWith<$Res> {
  _$AccountStatusConnectedCopyWithImpl(this._self, this._then);

  final AccountStatusConnected _self;
  final $Res Function(AccountStatusConnected) _then;

/// Create a copy of AccountStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? info = freezed,}) {
  return _then(AccountStatusConnected(
info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AccountInfo?,
  ));
}

/// Create a copy of AccountStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $AccountInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

/// @nodoc


class AccountStatusFailed implements AccountStatus {
  const AccountStatusFailed(this.error);
  

 final  UpCloudException error;

/// Create a copy of AccountStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountStatusFailedCopyWith<AccountStatusFailed> get copyWith => _$AccountStatusFailedCopyWithImpl<AccountStatusFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountStatusFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error);
}

@override
String toString() {
    return 'AccountStatus.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $AccountStatusFailedCopyWith<$Res> implements $AccountStatusCopyWith<$Res> {
  factory $AccountStatusFailedCopyWith(AccountStatusFailed value, $Res Function(AccountStatusFailed) _then) = _$AccountStatusFailedCopyWithImpl;
@useResult
$Res call({
 UpCloudException error
});




}
/// @nodoc
class _$AccountStatusFailedCopyWithImpl<$Res>
    implements $AccountStatusFailedCopyWith<$Res> {
  _$AccountStatusFailedCopyWithImpl(this._self, this._then);

  final AccountStatusFailed _self;
  final $Res Function(AccountStatusFailed) _then;

/// Create a copy of AccountStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AccountStatusFailed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UpCloudException,
  ));
}


}

/// @nodoc
mixin _$AccountsState {

/// Saved accounts, in insertion order.
 List<CloudAccount> get accounts;/// Whether saved accounts are being loaded.
 bool get isLoading;/// Whether an account is being added, updated or removed.
 bool get isBusy;/// Error of the last failed operation.
 UpCloudException? get error;/// Result of the last connection check of each account, by id.
 Map<String, AccountStatus> get statuses;
/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountsStateCopyWith<AccountsState> get copyWith => _$AccountsStateCopyWithImpl<AccountsState>(this as AccountsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountsState&&const DeepCollectionEquality().equals(other.accounts, _this.accounts)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isBusy, _this.isBusy) || other.isBusy == _this.isBusy)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.statuses, _this.statuses));
}


@override
int get hashCode {
  final _this = this as AccountsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.accounts),_this.isLoading,_this.isBusy,_this.error,const DeepCollectionEquality().hash(_this.statuses));
}

@override
String toString() {
  final _this = this as AccountsState;
  return 'AccountsState(accounts: ${_this.accounts}, isLoading: ${_this.isLoading}, isBusy: ${_this.isBusy}, error: ${_this.error}, statuses: ${_this.statuses})';
}


}

/// @nodoc
abstract mixin class $AccountsStateCopyWith<$Res>  {
  factory $AccountsStateCopyWith(AccountsState value, $Res Function(AccountsState) _then) = _$AccountsStateCopyWithImpl;
@useResult
$Res call({
 List<CloudAccount> accounts, bool isLoading, bool isBusy, UpCloudException? error, Map<String, AccountStatus> statuses
});




}
/// @nodoc
class _$AccountsStateCopyWithImpl<$Res>
    implements $AccountsStateCopyWith<$Res> {
  _$AccountsStateCopyWithImpl(this._self, this._then);

  final AccountsState _self;
  final $Res Function(AccountsState) _then;

/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accounts = null,Object? isLoading = null,Object? isBusy = null,Object? error = freezed,Object? statuses = null,}) {
  return _then(AccountsState(
accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<CloudAccount>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UpCloudException?,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as Map<String, AccountStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountsState].
extension AccountsStatePatterns on AccountsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountsState value)  $default,){
final _that = this;
switch (_that) {
case _AccountsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountsState value)?  $default,){
final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CloudAccount> accounts,  bool isLoading,  bool isBusy,  UpCloudException? error,  Map<String, AccountStatus> statuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
return $default(_that.accounts,_that.isLoading,_that.isBusy,_that.error,_that.statuses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CloudAccount> accounts,  bool isLoading,  bool isBusy,  UpCloudException? error,  Map<String, AccountStatus> statuses)  $default,) {final _that = this;
switch (_that) {
case _AccountsState():
return $default(_that.accounts,_that.isLoading,_that.isBusy,_that.error,_that.statuses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CloudAccount> accounts,  bool isLoading,  bool isBusy,  UpCloudException? error,  Map<String, AccountStatus> statuses)?  $default,) {final _that = this;
switch (_that) {
case _AccountsState() when $default != null:
return $default(_that.accounts,_that.isLoading,_that.isBusy,_that.error,_that.statuses);case _:
  return null;

}
}

}

/// @nodoc


class _AccountsState extends AccountsState {
  const _AccountsState({ List<CloudAccount> accounts = const <CloudAccount>[], this.isLoading = false, this.isBusy = false, this.error,  Map<String, AccountStatus> statuses = const <String, AccountStatus>{}}): _accounts = accounts,_statuses = statuses,super._();
  

/// Saved accounts, in insertion order.
 final  List<CloudAccount> _accounts;
/// Saved accounts, in insertion order.
@override@JsonKey() List<CloudAccount> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

/// Whether saved accounts are being loaded.
@override@JsonKey() final  bool isLoading;
/// Whether an account is being added, updated or removed.
@override@JsonKey() final  bool isBusy;
/// Error of the last failed operation.
@override final  UpCloudException? error;
/// Result of the last connection check of each account, by id.
 final  Map<String, AccountStatus> _statuses;
/// Result of the last connection check of each account, by id.
@override@JsonKey() Map<String, AccountStatus> get statuses {
  if (_statuses is EqualUnmodifiableMapView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_statuses);
}


/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountsStateCopyWith<_AccountsState> get copyWith => __$AccountsStateCopyWithImpl<_AccountsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountsState&&const DeepCollectionEquality().equals(other.accounts, _accounts)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.statuses, _statuses));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_accounts),isLoading,isBusy,error,const DeepCollectionEquality().hash(_statuses));
}

@override
String toString() {
    return 'AccountsState(accounts: $accounts, isLoading: $isLoading, isBusy: $isBusy, error: $error, statuses: $statuses)';
}


}

/// @nodoc
abstract mixin class _$AccountsStateCopyWith<$Res> implements $AccountsStateCopyWith<$Res> {
  factory _$AccountsStateCopyWith(_AccountsState value, $Res Function(_AccountsState) _then) = __$AccountsStateCopyWithImpl;
@override @useResult
$Res call({
 List<CloudAccount> accounts, bool isLoading, bool isBusy, UpCloudException? error, Map<String, AccountStatus> statuses
});




}
/// @nodoc
class __$AccountsStateCopyWithImpl<$Res>
    implements _$AccountsStateCopyWith<$Res> {
  __$AccountsStateCopyWithImpl(this._self, this._then);

  final _AccountsState _self;
  final $Res Function(_AccountsState) _then;

/// Create a copy of AccountsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accounts = null,Object? isLoading = null,Object? isBusy = null,Object? error = freezed,Object? statuses = null,}) {
  return _then(_AccountsState(
accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<CloudAccount>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UpCloudException?,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as Map<String, AccountStatus>,
  ));
}


}

// dart format on
