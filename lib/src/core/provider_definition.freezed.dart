// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderInfo {

/// Stable unique id (e.g. `streamhg`). Used to persist accounts.
 String get id;/// Display name (e.g. `StreamHG`).
 String get name;/// Home page of the service.
 Uri? get website;/// Logo or favicon.
 Uri? get iconUrl;/// Id of the driver that implements the provider's API (e.g. `xvs`).
 String? get driver; String? get description;
/// Create a copy of ProviderInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderInfoCopyWith<ProviderInfo> get copyWith => _$ProviderInfoCopyWithImpl<ProviderInfo>(this as ProviderInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProviderInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.website, _this.website) || other.website == _this.website)&&(identical(other.iconUrl, _this.iconUrl) || other.iconUrl == _this.iconUrl)&&(identical(other.driver, _this.driver) || other.driver == _this.driver)&&(identical(other.description, _this.description) || other.description == _this.description));
}


@override
int get hashCode {
  final _this = this as ProviderInfo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.website,_this.iconUrl,_this.driver,_this.description);
}

@override
String toString() {
  final _this = this as ProviderInfo;
  return 'ProviderInfo(id: ${_this.id}, name: ${_this.name}, website: ${_this.website}, iconUrl: ${_this.iconUrl}, driver: ${_this.driver}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ProviderInfoCopyWith<$Res>  {
  factory $ProviderInfoCopyWith(ProviderInfo value, $Res Function(ProviderInfo) _then) = _$ProviderInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, Uri? website, Uri? iconUrl, String? driver, String? description
});




}
/// @nodoc
class _$ProviderInfoCopyWithImpl<$Res>
    implements $ProviderInfoCopyWith<$Res> {
  _$ProviderInfoCopyWithImpl(this._self, this._then);

  final ProviderInfo _self;
  final $Res Function(ProviderInfo) _then;

/// Create a copy of ProviderInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? website = freezed,Object? iconUrl = freezed,Object? driver = freezed,Object? description = freezed,}) {
  return _then(ProviderInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as Uri?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as Uri?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderInfo].
extension ProviderInfoPatterns on ProviderInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderInfo value)  $default,){
final _that = this;
switch (_that) {
case _ProviderInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Uri? website,  Uri? iconUrl,  String? driver,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderInfo() when $default != null:
return $default(_that.id,_that.name,_that.website,_that.iconUrl,_that.driver,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Uri? website,  Uri? iconUrl,  String? driver,  String? description)  $default,) {final _that = this;
switch (_that) {
case _ProviderInfo():
return $default(_that.id,_that.name,_that.website,_that.iconUrl,_that.driver,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Uri? website,  Uri? iconUrl,  String? driver,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _ProviderInfo() when $default != null:
return $default(_that.id,_that.name,_that.website,_that.iconUrl,_that.driver,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderInfo implements ProviderInfo {
  const _ProviderInfo({required this.id, required this.name, this.website, this.iconUrl, this.driver, this.description});
  

/// Stable unique id (e.g. `streamhg`). Used to persist accounts.
@override final  String id;
/// Display name (e.g. `StreamHG`).
@override final  String name;
/// Home page of the service.
@override final  Uri? website;
/// Logo or favicon.
@override final  Uri? iconUrl;
/// Id of the driver that implements the provider's API (e.g. `xvs`).
@override final  String? driver;
@override final  String? description;

/// Create a copy of ProviderInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderInfoCopyWith<_ProviderInfo> get copyWith => __$ProviderInfoCopyWithImpl<_ProviderInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.website, website) || other.website == website)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,website,iconUrl,driver,description);
}

@override
String toString() {
    return 'ProviderInfo(id: $id, name: $name, website: $website, iconUrl: $iconUrl, driver: $driver, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ProviderInfoCopyWith<$Res> implements $ProviderInfoCopyWith<$Res> {
  factory _$ProviderInfoCopyWith(_ProviderInfo value, $Res Function(_ProviderInfo) _then) = __$ProviderInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Uri? website, Uri? iconUrl, String? driver, String? description
});




}
/// @nodoc
class __$ProviderInfoCopyWithImpl<$Res>
    implements _$ProviderInfoCopyWith<$Res> {
  __$ProviderInfoCopyWithImpl(this._self, this._then);

  final _ProviderInfo _self;
  final $Res Function(_ProviderInfo) _then;

/// Create a copy of ProviderInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? website = freezed,Object? iconUrl = freezed,Object? driver = freezed,Object? description = freezed,}) {
  return _then(_ProviderInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as Uri?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as Uri?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ProviderOptions {

/// Replaces the provider's API base URL. Useful when a service moves to
/// a new domain before the app is updated.
 Uri? get baseUrl;/// Alternative API base URLs tried in order when the base URL cannot be
/// reached (connection errors only).
 List<Uri> get mirrors;/// Replaces the provider's default limits.
 ProviderLimits? get limits;/// Custom Dio instance (proxies, extra interceptors, testing adapters).
/// Its `baseUrl` is overwritten by the provider.
 Dio? get dio;/// Receives request/response logs.
 HttpLogger? get logger;/// User agent sent with every request.
 String? get userAgent;/// Retries for idempotent requests that fail with network errors,
/// `429` or `5xx`.
 int get maxRetries; Duration get connectTimeout; Duration get receiveTimeout;
/// Create a copy of ProviderOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderOptionsCopyWith<ProviderOptions> get copyWith => _$ProviderOptionsCopyWithImpl<ProviderOptions>(this as ProviderOptions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProviderOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderOptions&&(identical(other.baseUrl, _this.baseUrl) || other.baseUrl == _this.baseUrl)&&const DeepCollectionEquality().equals(other.mirrors, _this.mirrors)&&(identical(other.limits, _this.limits) || other.limits == _this.limits)&&(identical(other.dio, _this.dio) || other.dio == _this.dio)&&(identical(other.logger, _this.logger) || other.logger == _this.logger)&&(identical(other.userAgent, _this.userAgent) || other.userAgent == _this.userAgent)&&(identical(other.maxRetries, _this.maxRetries) || other.maxRetries == _this.maxRetries)&&(identical(other.connectTimeout, _this.connectTimeout) || other.connectTimeout == _this.connectTimeout)&&(identical(other.receiveTimeout, _this.receiveTimeout) || other.receiveTimeout == _this.receiveTimeout));
}


@override
int get hashCode {
  final _this = this as ProviderOptions;
  return Object.hash(runtimeType,_this.baseUrl,const DeepCollectionEquality().hash(_this.mirrors),_this.limits,_this.dio,_this.logger,_this.userAgent,_this.maxRetries,_this.connectTimeout,_this.receiveTimeout);
}

@override
String toString() {
  final _this = this as ProviderOptions;
  return 'ProviderOptions(baseUrl: ${_this.baseUrl}, mirrors: ${_this.mirrors}, limits: ${_this.limits}, dio: ${_this.dio}, logger: ${_this.logger}, userAgent: ${_this.userAgent}, maxRetries: ${_this.maxRetries}, connectTimeout: ${_this.connectTimeout}, receiveTimeout: ${_this.receiveTimeout})';
}


}

/// @nodoc
abstract mixin class $ProviderOptionsCopyWith<$Res>  {
  factory $ProviderOptionsCopyWith(ProviderOptions value, $Res Function(ProviderOptions) _then) = _$ProviderOptionsCopyWithImpl;
@useResult
$Res call({
 Uri? baseUrl, List<Uri> mirrors, ProviderLimits? limits, Dio? dio, HttpLogger? logger, String? userAgent, int maxRetries, Duration connectTimeout, Duration receiveTimeout
});


$ProviderLimitsCopyWith<$Res>? get limits;

}
/// @nodoc
class _$ProviderOptionsCopyWithImpl<$Res>
    implements $ProviderOptionsCopyWith<$Res> {
  _$ProviderOptionsCopyWithImpl(this._self, this._then);

  final ProviderOptions _self;
  final $Res Function(ProviderOptions) _then;

/// Create a copy of ProviderOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseUrl = freezed,Object? mirrors = null,Object? limits = freezed,Object? dio = freezed,Object? logger = freezed,Object? userAgent = freezed,Object? maxRetries = null,Object? connectTimeout = null,Object? receiveTimeout = null,}) {
  return _then(ProviderOptions(
baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as Uri?,mirrors: null == mirrors ? _self.mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<Uri>,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as ProviderLimits?,dio: freezed == dio ? _self.dio : dio // ignore: cast_nullable_to_non_nullable
as Dio?,logger: freezed == logger ? _self.logger : logger // ignore: cast_nullable_to_non_nullable
as HttpLogger?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,connectTimeout: null == connectTimeout ? _self.connectTimeout : connectTimeout // ignore: cast_nullable_to_non_nullable
as Duration,receiveTimeout: null == receiveTimeout ? _self.receiveTimeout : receiveTimeout // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}
/// Create a copy of ProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderLimitsCopyWith<$Res>? get limits {
    if (_self.limits == null) {
    return null;
  }

  return $ProviderLimitsCopyWith<$Res>(_self.limits!, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProviderOptions].
extension ProviderOptionsPatterns on ProviderOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderOptions value)  $default,){
final _that = this;
switch (_that) {
case _ProviderOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri? baseUrl,  List<Uri> mirrors,  ProviderLimits? limits,  Dio? dio,  HttpLogger? logger,  String? userAgent,  int maxRetries,  Duration connectTimeout,  Duration receiveTimeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderOptions() when $default != null:
return $default(_that.baseUrl,_that.mirrors,_that.limits,_that.dio,_that.logger,_that.userAgent,_that.maxRetries,_that.connectTimeout,_that.receiveTimeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri? baseUrl,  List<Uri> mirrors,  ProviderLimits? limits,  Dio? dio,  HttpLogger? logger,  String? userAgent,  int maxRetries,  Duration connectTimeout,  Duration receiveTimeout)  $default,) {final _that = this;
switch (_that) {
case _ProviderOptions():
return $default(_that.baseUrl,_that.mirrors,_that.limits,_that.dio,_that.logger,_that.userAgent,_that.maxRetries,_that.connectTimeout,_that.receiveTimeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri? baseUrl,  List<Uri> mirrors,  ProviderLimits? limits,  Dio? dio,  HttpLogger? logger,  String? userAgent,  int maxRetries,  Duration connectTimeout,  Duration receiveTimeout)?  $default,) {final _that = this;
switch (_that) {
case _ProviderOptions() when $default != null:
return $default(_that.baseUrl,_that.mirrors,_that.limits,_that.dio,_that.logger,_that.userAgent,_that.maxRetries,_that.connectTimeout,_that.receiveTimeout);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderOptions implements ProviderOptions {
  const _ProviderOptions({this.baseUrl,  List<Uri> mirrors = const <Uri>[], this.limits, this.dio, this.logger, this.userAgent, this.maxRetries = 2, this.connectTimeout = const Duration(seconds: 20), this.receiveTimeout = const Duration(seconds: 60)}): _mirrors = mirrors;
  

/// Replaces the provider's API base URL. Useful when a service moves to
/// a new domain before the app is updated.
@override final  Uri? baseUrl;
/// Alternative API base URLs tried in order when the base URL cannot be
/// reached (connection errors only).
 final  List<Uri> _mirrors;
/// Alternative API base URLs tried in order when the base URL cannot be
/// reached (connection errors only).
@override@JsonKey() List<Uri> get mirrors {
  if (_mirrors is EqualUnmodifiableListView) return _mirrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mirrors);
}

/// Replaces the provider's default limits.
@override final  ProviderLimits? limits;
/// Custom Dio instance (proxies, extra interceptors, testing adapters).
/// Its `baseUrl` is overwritten by the provider.
@override final  Dio? dio;
/// Receives request/response logs.
@override final  HttpLogger? logger;
/// User agent sent with every request.
@override final  String? userAgent;
/// Retries for idempotent requests that fail with network errors,
/// `429` or `5xx`.
@override@JsonKey() final  int maxRetries;
@override@JsonKey() final  Duration connectTimeout;
@override@JsonKey() final  Duration receiveTimeout;

/// Create a copy of ProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderOptionsCopyWith<_ProviderOptions> get copyWith => __$ProviderOptionsCopyWithImpl<_ProviderOptions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderOptions&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&const DeepCollectionEquality().equals(other.mirrors, _mirrors)&&(identical(other.limits, limits) || other.limits == limits)&&(identical(other.dio, dio) || other.dio == dio)&&(identical(other.logger, logger) || other.logger == logger)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.maxRetries, maxRetries) || other.maxRetries == maxRetries)&&(identical(other.connectTimeout, connectTimeout) || other.connectTimeout == connectTimeout)&&(identical(other.receiveTimeout, receiveTimeout) || other.receiveTimeout == receiveTimeout));
}


@override
int get hashCode {
    return Object.hash(runtimeType,baseUrl,const DeepCollectionEquality().hash(_mirrors),limits,dio,logger,userAgent,maxRetries,connectTimeout,receiveTimeout);
}

@override
String toString() {
    return 'ProviderOptions(baseUrl: $baseUrl, mirrors: $mirrors, limits: $limits, dio: $dio, logger: $logger, userAgent: $userAgent, maxRetries: $maxRetries, connectTimeout: $connectTimeout, receiveTimeout: $receiveTimeout)';
}


}

/// @nodoc
abstract mixin class _$ProviderOptionsCopyWith<$Res> implements $ProviderOptionsCopyWith<$Res> {
  factory _$ProviderOptionsCopyWith(_ProviderOptions value, $Res Function(_ProviderOptions) _then) = __$ProviderOptionsCopyWithImpl;
@override @useResult
$Res call({
 Uri? baseUrl, List<Uri> mirrors, ProviderLimits? limits, Dio? dio, HttpLogger? logger, String? userAgent, int maxRetries, Duration connectTimeout, Duration receiveTimeout
});


@override $ProviderLimitsCopyWith<$Res>? get limits;

}
/// @nodoc
class __$ProviderOptionsCopyWithImpl<$Res>
    implements _$ProviderOptionsCopyWith<$Res> {
  __$ProviderOptionsCopyWithImpl(this._self, this._then);

  final _ProviderOptions _self;
  final $Res Function(_ProviderOptions) _then;

/// Create a copy of ProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseUrl = freezed,Object? mirrors = null,Object? limits = freezed,Object? dio = freezed,Object? logger = freezed,Object? userAgent = freezed,Object? maxRetries = null,Object? connectTimeout = null,Object? receiveTimeout = null,}) {
  return _then(_ProviderOptions(
baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as Uri?,mirrors: null == mirrors ? _self._mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<Uri>,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as ProviderLimits?,dio: freezed == dio ? _self.dio : dio // ignore: cast_nullable_to_non_nullable
as Dio?,logger: freezed == logger ? _self.logger : logger // ignore: cast_nullable_to_non_nullable
as HttpLogger?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,maxRetries: null == maxRetries ? _self.maxRetries : maxRetries // ignore: cast_nullable_to_non_nullable
as int,connectTimeout: null == connectTimeout ? _self.connectTimeout : connectTimeout // ignore: cast_nullable_to_non_nullable
as Duration,receiveTimeout: null == receiveTimeout ? _self.receiveTimeout : receiveTimeout // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

/// Create a copy of ProviderOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderLimitsCopyWith<$Res>? get limits {
    if (_self.limits == null) {
    return null;
  }

  return $ProviderLimitsCopyWith<$Res>(_self.limits!, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}

// dart format on
