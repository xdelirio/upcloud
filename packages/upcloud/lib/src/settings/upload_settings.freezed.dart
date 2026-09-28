// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadSettings {

/// Uploads running at the same time across all accounts, between
/// [minConcurrentUploads] and [maxConcurrentUploadsLimit]. Each account
/// is also limited by its provider (`ProviderLimits`).
 int get maxConcurrentUploads;/// Automatic retries after a transient failure (network errors, rate
/// limits, server errors), between 0 and [maxRetries].
 int get retries;/// Whether to check the free storage of the account before each upload.
///
/// Costs one extra request per upload on providers that report it.
 bool get checkStorage;/// Seconds after which completed uploads are removed from the queue;
/// `null` keeps them. Failed and cancelled uploads are always kept.
 int? get autoClearAfterSeconds;/// Folder path (by name, e.g. `Movies/2026`) used by batch uploads when
/// no destination is given; `null` is the root folder.
 String? get defaultFolderPath;/// Visibility of uploads that set neither `UploadOptions.isPublic` nor
/// an explicit visibility.
@JsonKey(unknownEnumValue: UploadVisibility.providerDefault) UploadVisibility get defaultVisibility;
/// Create a copy of UploadSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadSettingsCopyWith<UploadSettings> get copyWith => _$UploadSettingsCopyWithImpl<UploadSettings>(this as UploadSettings, _$identity);

  /// Serializes this UploadSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadSettings&&(identical(other.maxConcurrentUploads, _this.maxConcurrentUploads) || other.maxConcurrentUploads == _this.maxConcurrentUploads)&&(identical(other.retries, _this.retries) || other.retries == _this.retries)&&(identical(other.checkStorage, _this.checkStorage) || other.checkStorage == _this.checkStorage)&&(identical(other.autoClearAfterSeconds, _this.autoClearAfterSeconds) || other.autoClearAfterSeconds == _this.autoClearAfterSeconds)&&(identical(other.defaultFolderPath, _this.defaultFolderPath) || other.defaultFolderPath == _this.defaultFolderPath)&&(identical(other.defaultVisibility, _this.defaultVisibility) || other.defaultVisibility == _this.defaultVisibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadSettings;
  return Object.hash(runtimeType,_this.maxConcurrentUploads,_this.retries,_this.checkStorage,_this.autoClearAfterSeconds,_this.defaultFolderPath,_this.defaultVisibility);
}

@override
String toString() {
  final _this = this as UploadSettings;
  return 'UploadSettings(maxConcurrentUploads: ${_this.maxConcurrentUploads}, retries: ${_this.retries}, checkStorage: ${_this.checkStorage}, autoClearAfterSeconds: ${_this.autoClearAfterSeconds}, defaultFolderPath: ${_this.defaultFolderPath}, defaultVisibility: ${_this.defaultVisibility})';
}


}

/// @nodoc
abstract mixin class $UploadSettingsCopyWith<$Res>  {
  factory $UploadSettingsCopyWith(UploadSettings value, $Res Function(UploadSettings) _then) = _$UploadSettingsCopyWithImpl;
@useResult
$Res call({
 int maxConcurrentUploads, int retries, bool checkStorage, int? autoClearAfterSeconds, String? defaultFolderPath,@JsonKey(unknownEnumValue: UploadVisibility.providerDefault) UploadVisibility defaultVisibility
});




}
/// @nodoc
class _$UploadSettingsCopyWithImpl<$Res>
    implements $UploadSettingsCopyWith<$Res> {
  _$UploadSettingsCopyWithImpl(this._self, this._then);

  final UploadSettings _self;
  final $Res Function(UploadSettings) _then;

/// Create a copy of UploadSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxConcurrentUploads = null,Object? retries = null,Object? checkStorage = null,Object? autoClearAfterSeconds = freezed,Object? defaultFolderPath = freezed,Object? defaultVisibility = null,}) {
  return _then(UploadSettings(
maxConcurrentUploads: null == maxConcurrentUploads ? _self.maxConcurrentUploads : maxConcurrentUploads // ignore: cast_nullable_to_non_nullable
as int,retries: null == retries ? _self.retries : retries // ignore: cast_nullable_to_non_nullable
as int,checkStorage: null == checkStorage ? _self.checkStorage : checkStorage // ignore: cast_nullable_to_non_nullable
as bool,autoClearAfterSeconds: freezed == autoClearAfterSeconds ? _self.autoClearAfterSeconds : autoClearAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,defaultFolderPath: freezed == defaultFolderPath ? _self.defaultFolderPath : defaultFolderPath // ignore: cast_nullable_to_non_nullable
as String?,defaultVisibility: null == defaultVisibility ? _self.defaultVisibility : defaultVisibility // ignore: cast_nullable_to_non_nullable
as UploadVisibility,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadSettings].
extension UploadSettingsPatterns on UploadSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadSettings value)  $default,){
final _that = this;
switch (_that) {
case _UploadSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UploadSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxConcurrentUploads,  int retries,  bool checkStorage,  int? autoClearAfterSeconds,  String? defaultFolderPath, @JsonKey(unknownEnumValue: UploadVisibility.providerDefault)  UploadVisibility defaultVisibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadSettings() when $default != null:
return $default(_that.maxConcurrentUploads,_that.retries,_that.checkStorage,_that.autoClearAfterSeconds,_that.defaultFolderPath,_that.defaultVisibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxConcurrentUploads,  int retries,  bool checkStorage,  int? autoClearAfterSeconds,  String? defaultFolderPath, @JsonKey(unknownEnumValue: UploadVisibility.providerDefault)  UploadVisibility defaultVisibility)  $default,) {final _that = this;
switch (_that) {
case _UploadSettings():
return $default(_that.maxConcurrentUploads,_that.retries,_that.checkStorage,_that.autoClearAfterSeconds,_that.defaultFolderPath,_that.defaultVisibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxConcurrentUploads,  int retries,  bool checkStorage,  int? autoClearAfterSeconds,  String? defaultFolderPath, @JsonKey(unknownEnumValue: UploadVisibility.providerDefault)  UploadVisibility defaultVisibility)?  $default,) {final _that = this;
switch (_that) {
case _UploadSettings() when $default != null:
return $default(_that.maxConcurrentUploads,_that.retries,_that.checkStorage,_that.autoClearAfterSeconds,_that.defaultFolderPath,_that.defaultVisibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadSettings extends UploadSettings {
  const _UploadSettings({this.maxConcurrentUploads = 3, this.retries = 2, this.checkStorage = true, this.autoClearAfterSeconds, this.defaultFolderPath, @JsonKey(unknownEnumValue: UploadVisibility.providerDefault) this.defaultVisibility = UploadVisibility.providerDefault}): super._();
  factory _UploadSettings.fromJson(Map<String, dynamic> json) => _$UploadSettingsFromJson(json);

/// Uploads running at the same time across all accounts, between
/// [minConcurrentUploads] and [maxConcurrentUploadsLimit]. Each account
/// is also limited by its provider (`ProviderLimits`).
@override@JsonKey() final  int maxConcurrentUploads;
/// Automatic retries after a transient failure (network errors, rate
/// limits, server errors), between 0 and [maxRetries].
@override@JsonKey() final  int retries;
/// Whether to check the free storage of the account before each upload.
///
/// Costs one extra request per upload on providers that report it.
@override@JsonKey() final  bool checkStorage;
/// Seconds after which completed uploads are removed from the queue;
/// `null` keeps them. Failed and cancelled uploads are always kept.
@override final  int? autoClearAfterSeconds;
/// Folder path (by name, e.g. `Movies/2026`) used by batch uploads when
/// no destination is given; `null` is the root folder.
@override final  String? defaultFolderPath;
/// Visibility of uploads that set neither `UploadOptions.isPublic` nor
/// an explicit visibility.
@override@JsonKey(unknownEnumValue: UploadVisibility.providerDefault) final  UploadVisibility defaultVisibility;

/// Create a copy of UploadSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadSettingsCopyWith<_UploadSettings> get copyWith => __$UploadSettingsCopyWithImpl<_UploadSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadSettings&&(identical(other.maxConcurrentUploads, maxConcurrentUploads) || other.maxConcurrentUploads == maxConcurrentUploads)&&(identical(other.retries, retries) || other.retries == retries)&&(identical(other.checkStorage, checkStorage) || other.checkStorage == checkStorage)&&(identical(other.autoClearAfterSeconds, autoClearAfterSeconds) || other.autoClearAfterSeconds == autoClearAfterSeconds)&&(identical(other.defaultFolderPath, defaultFolderPath) || other.defaultFolderPath == defaultFolderPath)&&(identical(other.defaultVisibility, defaultVisibility) || other.defaultVisibility == defaultVisibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,maxConcurrentUploads,retries,checkStorage,autoClearAfterSeconds,defaultFolderPath,defaultVisibility);
}

@override
String toString() {
    return 'UploadSettings(maxConcurrentUploads: $maxConcurrentUploads, retries: $retries, checkStorage: $checkStorage, autoClearAfterSeconds: $autoClearAfterSeconds, defaultFolderPath: $defaultFolderPath, defaultVisibility: $defaultVisibility)';
}


}

/// @nodoc
abstract mixin class _$UploadSettingsCopyWith<$Res> implements $UploadSettingsCopyWith<$Res> {
  factory _$UploadSettingsCopyWith(_UploadSettings value, $Res Function(_UploadSettings) _then) = __$UploadSettingsCopyWithImpl;
@override @useResult
$Res call({
 int maxConcurrentUploads, int retries, bool checkStorage, int? autoClearAfterSeconds, String? defaultFolderPath,@JsonKey(unknownEnumValue: UploadVisibility.providerDefault) UploadVisibility defaultVisibility
});




}
/// @nodoc
class __$UploadSettingsCopyWithImpl<$Res>
    implements _$UploadSettingsCopyWith<$Res> {
  __$UploadSettingsCopyWithImpl(this._self, this._then);

  final _UploadSettings _self;
  final $Res Function(_UploadSettings) _then;

/// Create a copy of UploadSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxConcurrentUploads = null,Object? retries = null,Object? checkStorage = null,Object? autoClearAfterSeconds = freezed,Object? defaultFolderPath = freezed,Object? defaultVisibility = null,}) {
  return _then(_UploadSettings(
maxConcurrentUploads: null == maxConcurrentUploads ? _self.maxConcurrentUploads : maxConcurrentUploads // ignore: cast_nullable_to_non_nullable
as int,retries: null == retries ? _self.retries : retries // ignore: cast_nullable_to_non_nullable
as int,checkStorage: null == checkStorage ? _self.checkStorage : checkStorage // ignore: cast_nullable_to_non_nullable
as bool,autoClearAfterSeconds: freezed == autoClearAfterSeconds ? _self.autoClearAfterSeconds : autoClearAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,defaultFolderPath: freezed == defaultFolderPath ? _self.defaultFolderPath : defaultFolderPath // ignore: cast_nullable_to_non_nullable
as String?,defaultVisibility: null == defaultVisibility ? _self.defaultVisibility : defaultVisibility // ignore: cast_nullable_to_non_nullable
as UploadVisibility,
  ));
}


}

// dart format on
