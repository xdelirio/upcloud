// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderConfig {

/// Stable unique id (e.g. `streamhg`). Accounts reference it.
 String get id;/// Display name.
 String get name;/// Id of the `CloudDriver` that implements the API (e.g. `xvs`).
 String get driver; String? get description;/// Home page of the service.
 Uri? get website;/// Logo or favicon.
 Uri? get iconUrl;/// Base URL the API paths are appended to.
 Uri? get apiBase;/// Alternative API base URLs tried in order when [apiBase] cannot be
/// reached (connection errors only).
 List<Uri> get mirrors;/// Public link of a file, with [fileIdPlaceholder] where the file id
/// of the provider goes (e.g. `https://hgcloud.to/{id}`).
///
/// Drivers use the link returned by the API when there is one, then
/// this template, then the default of the driver, if any (see
/// `CloudDriver.defaultFileUrlTemplate`). See [fileUrl].
 String? get fileUrlTemplate;/// Overrides the driver's default limits.
 LimitsConfig? get limits;/// Overrides the driver's default credential fields.
 List<CredentialField>? get credentials;/// Driver specific settings (see `CloudDriver.settings`).
 Map<String, Object?> get settings;/// Names of [Capability] values the provider does not offer.
 List<String> get disabledCapabilities;/// Disabled providers are hidden from the app.
 bool get enabled;
/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderConfigCopyWith<ProviderConfig> get copyWith => _$ProviderConfigCopyWithImpl<ProviderConfig>(this as ProviderConfig, _$identity);

  /// Serializes this ProviderConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderConfig&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.driver, _this.driver) || other.driver == _this.driver)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.website, _this.website) || other.website == _this.website)&&(identical(other.iconUrl, _this.iconUrl) || other.iconUrl == _this.iconUrl)&&(identical(other.apiBase, _this.apiBase) || other.apiBase == _this.apiBase)&&const DeepCollectionEquality().equals(other.mirrors, _this.mirrors)&&(identical(other.fileUrlTemplate, _this.fileUrlTemplate) || other.fileUrlTemplate == _this.fileUrlTemplate)&&(identical(other.limits, _this.limits) || other.limits == _this.limits)&&const DeepCollectionEquality().equals(other.credentials, _this.credentials)&&const DeepCollectionEquality().equals(other.settings, _this.settings)&&const DeepCollectionEquality().equals(other.disabledCapabilities, _this.disabledCapabilities)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderConfig;
  return Object.hash(runtimeType,_this.id,_this.name,_this.driver,_this.description,_this.website,_this.iconUrl,_this.apiBase,const DeepCollectionEquality().hash(_this.mirrors),_this.fileUrlTemplate,_this.limits,const DeepCollectionEquality().hash(_this.credentials),const DeepCollectionEquality().hash(_this.settings),const DeepCollectionEquality().hash(_this.disabledCapabilities),_this.enabled);
}

@override
String toString() {
  final _this = this as ProviderConfig;
  return 'ProviderConfig(id: ${_this.id}, name: ${_this.name}, driver: ${_this.driver}, description: ${_this.description}, website: ${_this.website}, iconUrl: ${_this.iconUrl}, apiBase: ${_this.apiBase}, mirrors: ${_this.mirrors}, fileUrlTemplate: ${_this.fileUrlTemplate}, limits: ${_this.limits}, credentials: ${_this.credentials}, settings: ${_this.settings}, disabledCapabilities: ${_this.disabledCapabilities}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $ProviderConfigCopyWith<$Res>  {
  factory $ProviderConfigCopyWith(ProviderConfig value, $Res Function(ProviderConfig) _then) = _$ProviderConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name, String driver, String? description, Uri? website, Uri? iconUrl, Uri? apiBase, List<Uri> mirrors, String? fileUrlTemplate, LimitsConfig? limits, List<CredentialField>? credentials, Map<String, Object?> settings, List<String> disabledCapabilities, bool enabled
});


$LimitsConfigCopyWith<$Res>? get limits;

}
/// @nodoc
class _$ProviderConfigCopyWithImpl<$Res>
    implements $ProviderConfigCopyWith<$Res> {
  _$ProviderConfigCopyWithImpl(this._self, this._then);

  final ProviderConfig _self;
  final $Res Function(ProviderConfig) _then;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? driver = null,Object? description = freezed,Object? website = freezed,Object? iconUrl = freezed,Object? apiBase = freezed,Object? mirrors = null,Object? fileUrlTemplate = freezed,Object? limits = freezed,Object? credentials = freezed,Object? settings = null,Object? disabledCapabilities = null,Object? enabled = null,}) {
  return _then(ProviderConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,driver: null == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as Uri?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as Uri?,apiBase: freezed == apiBase ? _self.apiBase : apiBase // ignore: cast_nullable_to_non_nullable
as Uri?,mirrors: null == mirrors ? _self.mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<Uri>,fileUrlTemplate: freezed == fileUrlTemplate ? _self.fileUrlTemplate : fileUrlTemplate // ignore: cast_nullable_to_non_nullable
as String?,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as LimitsConfig?,credentials: freezed == credentials ? _self.credentials : credentials // ignore: cast_nullable_to_non_nullable
as List<CredentialField>?,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,disabledCapabilities: null == disabledCapabilities ? _self.disabledCapabilities : disabledCapabilities // ignore: cast_nullable_to_non_nullable
as List<String>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LimitsConfigCopyWith<$Res>? get limits {
    if (_self.limits == null) {
    return null;
  }

  return $LimitsConfigCopyWith<$Res>(_self.limits!, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProviderConfig].
extension ProviderConfigPatterns on ProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProviderConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String driver,  String? description,  Uri? website,  Uri? iconUrl,  Uri? apiBase,  List<Uri> mirrors,  String? fileUrlTemplate,  LimitsConfig? limits,  List<CredentialField>? credentials,  Map<String, Object?> settings,  List<String> disabledCapabilities,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.driver,_that.description,_that.website,_that.iconUrl,_that.apiBase,_that.mirrors,_that.fileUrlTemplate,_that.limits,_that.credentials,_that.settings,_that.disabledCapabilities,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String driver,  String? description,  Uri? website,  Uri? iconUrl,  Uri? apiBase,  List<Uri> mirrors,  String? fileUrlTemplate,  LimitsConfig? limits,  List<CredentialField>? credentials,  Map<String, Object?> settings,  List<String> disabledCapabilities,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _ProviderConfig():
return $default(_that.id,_that.name,_that.driver,_that.description,_that.website,_that.iconUrl,_that.apiBase,_that.mirrors,_that.fileUrlTemplate,_that.limits,_that.credentials,_that.settings,_that.disabledCapabilities,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String driver,  String? description,  Uri? website,  Uri? iconUrl,  Uri? apiBase,  List<Uri> mirrors,  String? fileUrlTemplate,  LimitsConfig? limits,  List<CredentialField>? credentials,  Map<String, Object?> settings,  List<String> disabledCapabilities,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.driver,_that.description,_that.website,_that.iconUrl,_that.apiBase,_that.mirrors,_that.fileUrlTemplate,_that.limits,_that.credentials,_that.settings,_that.disabledCapabilities,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderConfig extends ProviderConfig {
  const _ProviderConfig({required this.id, required this.name, required this.driver, this.description, this.website, this.iconUrl, this.apiBase,  List<Uri> mirrors = const <Uri>[], this.fileUrlTemplate, this.limits,  List<CredentialField>? credentials,  Map<String, Object?> settings = const <String, Object?>{},  List<String> disabledCapabilities = const <String>[], this.enabled = true}): _mirrors = mirrors,_credentials = credentials,_settings = settings,_disabledCapabilities = disabledCapabilities,super._();
  factory _ProviderConfig.fromJson(Map<String, dynamic> json) => _$ProviderConfigFromJson(json);

/// Stable unique id (e.g. `streamhg`). Accounts reference it.
@override final  String id;
/// Display name.
@override final  String name;
/// Id of the `CloudDriver` that implements the API (e.g. `xvs`).
@override final  String driver;
@override final  String? description;
/// Home page of the service.
@override final  Uri? website;
/// Logo or favicon.
@override final  Uri? iconUrl;
/// Base URL the API paths are appended to.
@override final  Uri? apiBase;
/// Alternative API base URLs tried in order when [apiBase] cannot be
/// reached (connection errors only).
 final  List<Uri> _mirrors;
/// Alternative API base URLs tried in order when [apiBase] cannot be
/// reached (connection errors only).
@override@JsonKey() List<Uri> get mirrors {
  if (_mirrors is EqualUnmodifiableListView) return _mirrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mirrors);
}

/// Public link of a file, with [fileIdPlaceholder] where the file id
/// of the provider goes (e.g. `https://hgcloud.to/{id}`).
///
/// Drivers use the link returned by the API when there is one, then
/// this template, then the default of the driver, if any (see
/// `CloudDriver.defaultFileUrlTemplate`). See [fileUrl].
@override final  String? fileUrlTemplate;
/// Overrides the driver's default limits.
@override final  LimitsConfig? limits;
/// Overrides the driver's default credential fields.
 final  List<CredentialField>? _credentials;
/// Overrides the driver's default credential fields.
@override List<CredentialField>? get credentials {
  final value = _credentials;
  if (value == null) return null;
  if (_credentials is EqualUnmodifiableListView) return _credentials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Driver specific settings (see `CloudDriver.settings`).
 final  Map<String, Object?> _settings;
/// Driver specific settings (see `CloudDriver.settings`).
@override@JsonKey() Map<String, Object?> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}

/// Names of [Capability] values the provider does not offer.
 final  List<String> _disabledCapabilities;
/// Names of [Capability] values the provider does not offer.
@override@JsonKey() List<String> get disabledCapabilities {
  if (_disabledCapabilities is EqualUnmodifiableListView) return _disabledCapabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disabledCapabilities);
}

/// Disabled providers are hidden from the app.
@override@JsonKey() final  bool enabled;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderConfigCopyWith<_ProviderConfig> get copyWith => __$ProviderConfigCopyWithImpl<_ProviderConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.description, description) || other.description == description)&&(identical(other.website, website) || other.website == website)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.apiBase, apiBase) || other.apiBase == apiBase)&&const DeepCollectionEquality().equals(other.mirrors, _mirrors)&&(identical(other.fileUrlTemplate, fileUrlTemplate) || other.fileUrlTemplate == fileUrlTemplate)&&(identical(other.limits, limits) || other.limits == limits)&&const DeepCollectionEquality().equals(other.credentials, _credentials)&&const DeepCollectionEquality().equals(other.settings, _settings)&&const DeepCollectionEquality().equals(other.disabledCapabilities, _disabledCapabilities)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,driver,description,website,iconUrl,apiBase,const DeepCollectionEquality().hash(_mirrors),fileUrlTemplate,limits,const DeepCollectionEquality().hash(_credentials),const DeepCollectionEquality().hash(_settings),const DeepCollectionEquality().hash(_disabledCapabilities),enabled);
}

@override
String toString() {
    return 'ProviderConfig(id: $id, name: $name, driver: $driver, description: $description, website: $website, iconUrl: $iconUrl, apiBase: $apiBase, mirrors: $mirrors, fileUrlTemplate: $fileUrlTemplate, limits: $limits, credentials: $credentials, settings: $settings, disabledCapabilities: $disabledCapabilities, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$ProviderConfigCopyWith<$Res> implements $ProviderConfigCopyWith<$Res> {
  factory _$ProviderConfigCopyWith(_ProviderConfig value, $Res Function(_ProviderConfig) _then) = __$ProviderConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String driver, String? description, Uri? website, Uri? iconUrl, Uri? apiBase, List<Uri> mirrors, String? fileUrlTemplate, LimitsConfig? limits, List<CredentialField>? credentials, Map<String, Object?> settings, List<String> disabledCapabilities, bool enabled
});


@override $LimitsConfigCopyWith<$Res>? get limits;

}
/// @nodoc
class __$ProviderConfigCopyWithImpl<$Res>
    implements _$ProviderConfigCopyWith<$Res> {
  __$ProviderConfigCopyWithImpl(this._self, this._then);

  final _ProviderConfig _self;
  final $Res Function(_ProviderConfig) _then;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? driver = null,Object? description = freezed,Object? website = freezed,Object? iconUrl = freezed,Object? apiBase = freezed,Object? mirrors = null,Object? fileUrlTemplate = freezed,Object? limits = freezed,Object? credentials = freezed,Object? settings = null,Object? disabledCapabilities = null,Object? enabled = null,}) {
  return _then(_ProviderConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,driver: null == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as Uri?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as Uri?,apiBase: freezed == apiBase ? _self.apiBase : apiBase // ignore: cast_nullable_to_non_nullable
as Uri?,mirrors: null == mirrors ? _self._mirrors : mirrors // ignore: cast_nullable_to_non_nullable
as List<Uri>,fileUrlTemplate: freezed == fileUrlTemplate ? _self.fileUrlTemplate : fileUrlTemplate // ignore: cast_nullable_to_non_nullable
as String?,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as LimitsConfig?,credentials: freezed == credentials ? _self._credentials : credentials // ignore: cast_nullable_to_non_nullable
as List<CredentialField>?,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,disabledCapabilities: null == disabledCapabilities ? _self._disabledCapabilities : disabledCapabilities // ignore: cast_nullable_to_non_nullable
as List<String>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LimitsConfigCopyWith<$Res>? get limits {
    if (_self.limits == null) {
    return null;
  }

  return $LimitsConfigCopyWith<$Res>(_self.limits!, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}


/// @nodoc
mixin _$LimitsConfig {

/// Maximum upload size in megabytes (MiB). `0` removes the limit.
 double? get maxFileSizeMb;/// Accepted extensions. `["*"]` or an empty list accepts any file.
 List<String>? get allowedExtensions; int? get maxConcurrentUploads;/// Minimum milliseconds between API requests.
 int? get minRequestIntervalMs;
/// Create a copy of LimitsConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LimitsConfigCopyWith<LimitsConfig> get copyWith => _$LimitsConfigCopyWithImpl<LimitsConfig>(this as LimitsConfig, _$identity);

  /// Serializes this LimitsConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LimitsConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LimitsConfig&&(identical(other.maxFileSizeMb, _this.maxFileSizeMb) || other.maxFileSizeMb == _this.maxFileSizeMb)&&const DeepCollectionEquality().equals(other.allowedExtensions, _this.allowedExtensions)&&(identical(other.maxConcurrentUploads, _this.maxConcurrentUploads) || other.maxConcurrentUploads == _this.maxConcurrentUploads)&&(identical(other.minRequestIntervalMs, _this.minRequestIntervalMs) || other.minRequestIntervalMs == _this.minRequestIntervalMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LimitsConfig;
  return Object.hash(runtimeType,_this.maxFileSizeMb,const DeepCollectionEquality().hash(_this.allowedExtensions),_this.maxConcurrentUploads,_this.minRequestIntervalMs);
}

@override
String toString() {
  final _this = this as LimitsConfig;
  return 'LimitsConfig(maxFileSizeMb: ${_this.maxFileSizeMb}, allowedExtensions: ${_this.allowedExtensions}, maxConcurrentUploads: ${_this.maxConcurrentUploads}, minRequestIntervalMs: ${_this.minRequestIntervalMs})';
}


}

/// @nodoc
abstract mixin class $LimitsConfigCopyWith<$Res>  {
  factory $LimitsConfigCopyWith(LimitsConfig value, $Res Function(LimitsConfig) _then) = _$LimitsConfigCopyWithImpl;
@useResult
$Res call({
 double? maxFileSizeMb, List<String>? allowedExtensions, int? maxConcurrentUploads, int? minRequestIntervalMs
});




}
/// @nodoc
class _$LimitsConfigCopyWithImpl<$Res>
    implements $LimitsConfigCopyWith<$Res> {
  _$LimitsConfigCopyWithImpl(this._self, this._then);

  final LimitsConfig _self;
  final $Res Function(LimitsConfig) _then;

/// Create a copy of LimitsConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxFileSizeMb = freezed,Object? allowedExtensions = freezed,Object? maxConcurrentUploads = freezed,Object? minRequestIntervalMs = freezed,}) {
  return _then(LimitsConfig(
maxFileSizeMb: freezed == maxFileSizeMb ? _self.maxFileSizeMb : maxFileSizeMb // ignore: cast_nullable_to_non_nullable
as double?,allowedExtensions: freezed == allowedExtensions ? _self.allowedExtensions : allowedExtensions // ignore: cast_nullable_to_non_nullable
as List<String>?,maxConcurrentUploads: freezed == maxConcurrentUploads ? _self.maxConcurrentUploads : maxConcurrentUploads // ignore: cast_nullable_to_non_nullable
as int?,minRequestIntervalMs: freezed == minRequestIntervalMs ? _self.minRequestIntervalMs : minRequestIntervalMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LimitsConfig].
extension LimitsConfigPatterns on LimitsConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LimitsConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LimitsConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LimitsConfig value)  $default,){
final _that = this;
switch (_that) {
case _LimitsConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LimitsConfig value)?  $default,){
final _that = this;
switch (_that) {
case _LimitsConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? maxFileSizeMb,  List<String>? allowedExtensions,  int? maxConcurrentUploads,  int? minRequestIntervalMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LimitsConfig() when $default != null:
return $default(_that.maxFileSizeMb,_that.allowedExtensions,_that.maxConcurrentUploads,_that.minRequestIntervalMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? maxFileSizeMb,  List<String>? allowedExtensions,  int? maxConcurrentUploads,  int? minRequestIntervalMs)  $default,) {final _that = this;
switch (_that) {
case _LimitsConfig():
return $default(_that.maxFileSizeMb,_that.allowedExtensions,_that.maxConcurrentUploads,_that.minRequestIntervalMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? maxFileSizeMb,  List<String>? allowedExtensions,  int? maxConcurrentUploads,  int? minRequestIntervalMs)?  $default,) {final _that = this;
switch (_that) {
case _LimitsConfig() when $default != null:
return $default(_that.maxFileSizeMb,_that.allowedExtensions,_that.maxConcurrentUploads,_that.minRequestIntervalMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LimitsConfig extends LimitsConfig {
  const _LimitsConfig({this.maxFileSizeMb,  List<String>? allowedExtensions, this.maxConcurrentUploads, this.minRequestIntervalMs}): _allowedExtensions = allowedExtensions,super._();
  factory _LimitsConfig.fromJson(Map<String, dynamic> json) => _$LimitsConfigFromJson(json);

/// Maximum upload size in megabytes (MiB). `0` removes the limit.
@override final  double? maxFileSizeMb;
/// Accepted extensions. `["*"]` or an empty list accepts any file.
 final  List<String>? _allowedExtensions;
/// Accepted extensions. `["*"]` or an empty list accepts any file.
@override List<String>? get allowedExtensions {
  final value = _allowedExtensions;
  if (value == null) return null;
  if (_allowedExtensions is EqualUnmodifiableListView) return _allowedExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? maxConcurrentUploads;
/// Minimum milliseconds between API requests.
@override final  int? minRequestIntervalMs;

/// Create a copy of LimitsConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LimitsConfigCopyWith<_LimitsConfig> get copyWith => __$LimitsConfigCopyWithImpl<_LimitsConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LimitsConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LimitsConfig&&(identical(other.maxFileSizeMb, maxFileSizeMb) || other.maxFileSizeMb == maxFileSizeMb)&&const DeepCollectionEquality().equals(other.allowedExtensions, _allowedExtensions)&&(identical(other.maxConcurrentUploads, maxConcurrentUploads) || other.maxConcurrentUploads == maxConcurrentUploads)&&(identical(other.minRequestIntervalMs, minRequestIntervalMs) || other.minRequestIntervalMs == minRequestIntervalMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,maxFileSizeMb,const DeepCollectionEquality().hash(_allowedExtensions),maxConcurrentUploads,minRequestIntervalMs);
}

@override
String toString() {
    return 'LimitsConfig(maxFileSizeMb: $maxFileSizeMb, allowedExtensions: $allowedExtensions, maxConcurrentUploads: $maxConcurrentUploads, minRequestIntervalMs: $minRequestIntervalMs)';
}


}

/// @nodoc
abstract mixin class _$LimitsConfigCopyWith<$Res> implements $LimitsConfigCopyWith<$Res> {
  factory _$LimitsConfigCopyWith(_LimitsConfig value, $Res Function(_LimitsConfig) _then) = __$LimitsConfigCopyWithImpl;
@override @useResult
$Res call({
 double? maxFileSizeMb, List<String>? allowedExtensions, int? maxConcurrentUploads, int? minRequestIntervalMs
});




}
/// @nodoc
class __$LimitsConfigCopyWithImpl<$Res>
    implements _$LimitsConfigCopyWith<$Res> {
  __$LimitsConfigCopyWithImpl(this._self, this._then);

  final _LimitsConfig _self;
  final $Res Function(_LimitsConfig) _then;

/// Create a copy of LimitsConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxFileSizeMb = freezed,Object? allowedExtensions = freezed,Object? maxConcurrentUploads = freezed,Object? minRequestIntervalMs = freezed,}) {
  return _then(_LimitsConfig(
maxFileSizeMb: freezed == maxFileSizeMb ? _self.maxFileSizeMb : maxFileSizeMb // ignore: cast_nullable_to_non_nullable
as double?,allowedExtensions: freezed == allowedExtensions ? _self._allowedExtensions : allowedExtensions // ignore: cast_nullable_to_non_nullable
as List<String>?,maxConcurrentUploads: freezed == maxConcurrentUploads ? _self.maxConcurrentUploads : maxConcurrentUploads // ignore: cast_nullable_to_non_nullable
as int?,minRequestIntervalMs: freezed == minRequestIntervalMs ? _self.minRequestIntervalMs : minRequestIntervalMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
