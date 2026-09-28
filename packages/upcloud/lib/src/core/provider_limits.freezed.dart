// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_limits.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderLimits {

/// Largest file accepted by a single upload.
 DataSize? get maxFileSize;/// Accepted extensions (lowercase, without dot). `null` accepts all.
 Set<String>? get allowedExtensions;/// Uploads that may run at the same time for one account.
 int get maxConcurrentUploads;/// Minimum time between two API requests.
 Duration? get minRequestInterval;
/// Create a copy of ProviderLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderLimitsCopyWith<ProviderLimits> get copyWith => _$ProviderLimitsCopyWithImpl<ProviderLimits>(this as ProviderLimits, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProviderLimits;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderLimits&&(identical(other.maxFileSize, _this.maxFileSize) || other.maxFileSize == _this.maxFileSize)&&const DeepCollectionEquality().equals(other.allowedExtensions, _this.allowedExtensions)&&(identical(other.maxConcurrentUploads, _this.maxConcurrentUploads) || other.maxConcurrentUploads == _this.maxConcurrentUploads)&&(identical(other.minRequestInterval, _this.minRequestInterval) || other.minRequestInterval == _this.minRequestInterval));
}


@override
int get hashCode {
  final _this = this as ProviderLimits;
  return Object.hash(runtimeType,_this.maxFileSize,const DeepCollectionEquality().hash(_this.allowedExtensions),_this.maxConcurrentUploads,_this.minRequestInterval);
}

@override
String toString() {
  final _this = this as ProviderLimits;
  return 'ProviderLimits(maxFileSize: ${_this.maxFileSize}, allowedExtensions: ${_this.allowedExtensions}, maxConcurrentUploads: ${_this.maxConcurrentUploads}, minRequestInterval: ${_this.minRequestInterval})';
}


}

/// @nodoc
abstract mixin class $ProviderLimitsCopyWith<$Res>  {
  factory $ProviderLimitsCopyWith(ProviderLimits value, $Res Function(ProviderLimits) _then) = _$ProviderLimitsCopyWithImpl;
@useResult
$Res call({
 DataSize? maxFileSize, Set<String>? allowedExtensions, int maxConcurrentUploads, Duration? minRequestInterval
});




}
/// @nodoc
class _$ProviderLimitsCopyWithImpl<$Res>
    implements $ProviderLimitsCopyWith<$Res> {
  _$ProviderLimitsCopyWithImpl(this._self, this._then);

  final ProviderLimits _self;
  final $Res Function(ProviderLimits) _then;

/// Create a copy of ProviderLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxFileSize = freezed,Object? allowedExtensions = freezed,Object? maxConcurrentUploads = null,Object? minRequestInterval = freezed,}) {
  return _then(ProviderLimits(
maxFileSize: freezed == maxFileSize ? _self.maxFileSize : maxFileSize // ignore: cast_nullable_to_non_nullable
as DataSize?,allowedExtensions: freezed == allowedExtensions ? _self.allowedExtensions : allowedExtensions // ignore: cast_nullable_to_non_nullable
as Set<String>?,maxConcurrentUploads: null == maxConcurrentUploads ? _self.maxConcurrentUploads : maxConcurrentUploads // ignore: cast_nullable_to_non_nullable
as int,minRequestInterval: freezed == minRequestInterval ? _self.minRequestInterval : minRequestInterval // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderLimits].
extension ProviderLimitsPatterns on ProviderLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderLimits value)  $default,){
final _that = this;
switch (_that) {
case _ProviderLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderLimits value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DataSize? maxFileSize,  Set<String>? allowedExtensions,  int maxConcurrentUploads,  Duration? minRequestInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderLimits() when $default != null:
return $default(_that.maxFileSize,_that.allowedExtensions,_that.maxConcurrentUploads,_that.minRequestInterval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DataSize? maxFileSize,  Set<String>? allowedExtensions,  int maxConcurrentUploads,  Duration? minRequestInterval)  $default,) {final _that = this;
switch (_that) {
case _ProviderLimits():
return $default(_that.maxFileSize,_that.allowedExtensions,_that.maxConcurrentUploads,_that.minRequestInterval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DataSize? maxFileSize,  Set<String>? allowedExtensions,  int maxConcurrentUploads,  Duration? minRequestInterval)?  $default,) {final _that = this;
switch (_that) {
case _ProviderLimits() when $default != null:
return $default(_that.maxFileSize,_that.allowedExtensions,_that.maxConcurrentUploads,_that.minRequestInterval);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderLimits extends ProviderLimits {
  const _ProviderLimits({this.maxFileSize,  Set<String>? allowedExtensions, this.maxConcurrentUploads = 2, this.minRequestInterval}): _allowedExtensions = allowedExtensions,super._();
  

/// Largest file accepted by a single upload.
@override final  DataSize? maxFileSize;
/// Accepted extensions (lowercase, without dot). `null` accepts all.
 final  Set<String>? _allowedExtensions;
/// Accepted extensions (lowercase, without dot). `null` accepts all.
@override Set<String>? get allowedExtensions {
  final value = _allowedExtensions;
  if (value == null) return null;
  if (_allowedExtensions is EqualUnmodifiableSetView) return _allowedExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}

/// Uploads that may run at the same time for one account.
@override@JsonKey() final  int maxConcurrentUploads;
/// Minimum time between two API requests.
@override final  Duration? minRequestInterval;

/// Create a copy of ProviderLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderLimitsCopyWith<_ProviderLimits> get copyWith => __$ProviderLimitsCopyWithImpl<_ProviderLimits>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderLimits&&(identical(other.maxFileSize, maxFileSize) || other.maxFileSize == maxFileSize)&&const DeepCollectionEquality().equals(other.allowedExtensions, _allowedExtensions)&&(identical(other.maxConcurrentUploads, maxConcurrentUploads) || other.maxConcurrentUploads == maxConcurrentUploads)&&(identical(other.minRequestInterval, minRequestInterval) || other.minRequestInterval == minRequestInterval));
}


@override
int get hashCode {
    return Object.hash(runtimeType,maxFileSize,const DeepCollectionEquality().hash(_allowedExtensions),maxConcurrentUploads,minRequestInterval);
}

@override
String toString() {
    return 'ProviderLimits(maxFileSize: $maxFileSize, allowedExtensions: $allowedExtensions, maxConcurrentUploads: $maxConcurrentUploads, minRequestInterval: $minRequestInterval)';
}


}

/// @nodoc
abstract mixin class _$ProviderLimitsCopyWith<$Res> implements $ProviderLimitsCopyWith<$Res> {
  factory _$ProviderLimitsCopyWith(_ProviderLimits value, $Res Function(_ProviderLimits) _then) = __$ProviderLimitsCopyWithImpl;
@override @useResult
$Res call({
 DataSize? maxFileSize, Set<String>? allowedExtensions, int maxConcurrentUploads, Duration? minRequestInterval
});




}
/// @nodoc
class __$ProviderLimitsCopyWithImpl<$Res>
    implements _$ProviderLimitsCopyWith<$Res> {
  __$ProviderLimitsCopyWithImpl(this._self, this._then);

  final _ProviderLimits _self;
  final $Res Function(_ProviderLimits) _then;

/// Create a copy of ProviderLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxFileSize = freezed,Object? allowedExtensions = freezed,Object? maxConcurrentUploads = null,Object? minRequestInterval = freezed,}) {
  return _then(_ProviderLimits(
maxFileSize: freezed == maxFileSize ? _self.maxFileSize : maxFileSize // ignore: cast_nullable_to_non_nullable
as DataSize?,allowedExtensions: freezed == allowedExtensions ? _self._allowedExtensions : allowedExtensions // ignore: cast_nullable_to_non_nullable
as Set<String>?,maxConcurrentUploads: null == maxConcurrentUploads ? _self.maxConcurrentUploads : maxConcurrentUploads // ignore: cast_nullable_to_non_nullable
as int,minRequestInterval: freezed == minRequestInterval ? _self.minRequestInterval : minRequestInterval // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
