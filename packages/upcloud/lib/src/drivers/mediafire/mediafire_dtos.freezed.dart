// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mediafire_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaFireFileDto {

@LenientStringConverter() String? get quickkey;@LenientStringConverter() String? get filename;@LenientStringConverter() String? get hash;@LenientStringConverter() String? get description;@LenientIntConverter() int? get size;@LenientStringConverter() String? get privacy;@LenientDateTimeConverter() DateTime? get created;@JsonKey(name: 'created_utc')@LenientDateTimeConverter() DateTime? get createdUtc;@LenientStringConverter() String? get mimetype;@LenientStringConverter() String? get filetype;@LenientIntConverter() int? get downloads;@LenientIntConverter() int? get views;@LenientStringConverter() String? get revision;@JsonKey(name: 'parent_folderkey')@LenientStringConverter() String? get parentFolderKey;@LenientBoolConverter() bool? get ready;@JsonKey(name: 'password_protected')@LenientBoolConverter() bool? get passwordProtected;@JsonKey(name: 'delete_date')@LenientDateTimeConverter() DateTime? get deleteDate;@JsonKey(fromJson: _readLinks) MediaFireLinksDto? get links;
/// Create a copy of MediaFireFileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireFileDtoCopyWith<MediaFireFileDto> get copyWith => _$MediaFireFileDtoCopyWithImpl<MediaFireFileDto>(this as MediaFireFileDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireFileDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireFileDto&&(identical(other.quickkey, _this.quickkey) || other.quickkey == _this.quickkey)&&(identical(other.filename, _this.filename) || other.filename == _this.filename)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.privacy, _this.privacy) || other.privacy == _this.privacy)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.createdUtc, _this.createdUtc) || other.createdUtc == _this.createdUtc)&&(identical(other.mimetype, _this.mimetype) || other.mimetype == _this.mimetype)&&(identical(other.filetype, _this.filetype) || other.filetype == _this.filetype)&&(identical(other.downloads, _this.downloads) || other.downloads == _this.downloads)&&(identical(other.views, _this.views) || other.views == _this.views)&&(identical(other.revision, _this.revision) || other.revision == _this.revision)&&(identical(other.parentFolderKey, _this.parentFolderKey) || other.parentFolderKey == _this.parentFolderKey)&&(identical(other.ready, _this.ready) || other.ready == _this.ready)&&(identical(other.passwordProtected, _this.passwordProtected) || other.passwordProtected == _this.passwordProtected)&&(identical(other.deleteDate, _this.deleteDate) || other.deleteDate == _this.deleteDate)&&(identical(other.links, _this.links) || other.links == _this.links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireFileDto;
  return Object.hash(runtimeType,_this.quickkey,_this.filename,_this.hash,_this.description,_this.size,_this.privacy,_this.created,_this.createdUtc,_this.mimetype,_this.filetype,_this.downloads,_this.views,_this.revision,_this.parentFolderKey,_this.ready,_this.passwordProtected,_this.deleteDate,_this.links);
}

@override
String toString() {
  final _this = this as MediaFireFileDto;
  return 'MediaFireFileDto(quickkey: ${_this.quickkey}, filename: ${_this.filename}, hash: ${_this.hash}, description: ${_this.description}, size: ${_this.size}, privacy: ${_this.privacy}, created: ${_this.created}, createdUtc: ${_this.createdUtc}, mimetype: ${_this.mimetype}, filetype: ${_this.filetype}, downloads: ${_this.downloads}, views: ${_this.views}, revision: ${_this.revision}, parentFolderKey: ${_this.parentFolderKey}, ready: ${_this.ready}, passwordProtected: ${_this.passwordProtected}, deleteDate: ${_this.deleteDate}, links: ${_this.links})';
}


}

/// @nodoc
abstract mixin class $MediaFireFileDtoCopyWith<$Res>  {
  factory $MediaFireFileDtoCopyWith(MediaFireFileDto value, $Res Function(MediaFireFileDto) _then) = _$MediaFireFileDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? quickkey,@LenientStringConverter() String? filename,@LenientStringConverter() String? hash,@LenientStringConverter() String? description,@LenientIntConverter() int? size,@LenientStringConverter() String? privacy,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'created_utc')@LenientDateTimeConverter() DateTime? createdUtc,@LenientStringConverter() String? mimetype,@LenientStringConverter() String? filetype,@LenientIntConverter() int? downloads,@LenientIntConverter() int? views,@LenientStringConverter() String? revision,@JsonKey(name: 'parent_folderkey')@LenientStringConverter() String? parentFolderKey,@LenientBoolConverter() bool? ready,@JsonKey(name: 'password_protected')@LenientBoolConverter() bool? passwordProtected,@JsonKey(name: 'delete_date')@LenientDateTimeConverter() DateTime? deleteDate,@JsonKey(fromJson: _readLinks) MediaFireLinksDto? links
});


$MediaFireLinksDtoCopyWith<$Res>? get links;

}
/// @nodoc
class _$MediaFireFileDtoCopyWithImpl<$Res>
    implements $MediaFireFileDtoCopyWith<$Res> {
  _$MediaFireFileDtoCopyWithImpl(this._self, this._then);

  final MediaFireFileDto _self;
  final $Res Function(MediaFireFileDto) _then;

/// Create a copy of MediaFireFileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quickkey = freezed,Object? filename = freezed,Object? hash = freezed,Object? description = freezed,Object? size = freezed,Object? privacy = freezed,Object? created = freezed,Object? createdUtc = freezed,Object? mimetype = freezed,Object? filetype = freezed,Object? downloads = freezed,Object? views = freezed,Object? revision = freezed,Object? parentFolderKey = freezed,Object? ready = freezed,Object? passwordProtected = freezed,Object? deleteDate = freezed,Object? links = freezed,}) {
  return _then(MediaFireFileDto(
quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,privacy: freezed == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as String?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,createdUtc: freezed == createdUtc ? _self.createdUtc : createdUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,mimetype: freezed == mimetype ? _self.mimetype : mimetype // ignore: cast_nullable_to_non_nullable
as String?,filetype: freezed == filetype ? _self.filetype : filetype // ignore: cast_nullable_to_non_nullable
as String?,downloads: freezed == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int?,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as String?,parentFolderKey: freezed == parentFolderKey ? _self.parentFolderKey : parentFolderKey // ignore: cast_nullable_to_non_nullable
as String?,ready: freezed == ready ? _self.ready : ready // ignore: cast_nullable_to_non_nullable
as bool?,passwordProtected: freezed == passwordProtected ? _self.passwordProtected : passwordProtected // ignore: cast_nullable_to_non_nullable
as bool?,deleteDate: freezed == deleteDate ? _self.deleteDate : deleteDate // ignore: cast_nullable_to_non_nullable
as DateTime?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as MediaFireLinksDto?,
  ));
}
/// Create a copy of MediaFireFileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaFireLinksDtoCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $MediaFireLinksDtoCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}
}


/// Adds pattern-matching-related methods to [MediaFireFileDto].
extension MediaFireFileDtoPatterns on MediaFireFileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireFileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireFileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireFileDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireFileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireFileDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireFileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientStringConverter()  String? hash, @LenientStringConverter()  String? description, @LenientIntConverter()  int? size, @LenientStringConverter()  String? privacy, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter()  DateTime? createdUtc, @LenientStringConverter()  String? mimetype, @LenientStringConverter()  String? filetype, @LenientIntConverter()  int? downloads, @LenientIntConverter()  int? views, @LenientStringConverter()  String? revision, @JsonKey(name: 'parent_folderkey')@LenientStringConverter()  String? parentFolderKey, @LenientBoolConverter()  bool? ready, @JsonKey(name: 'password_protected')@LenientBoolConverter()  bool? passwordProtected, @JsonKey(name: 'delete_date')@LenientDateTimeConverter()  DateTime? deleteDate, @JsonKey(fromJson: _readLinks)  MediaFireLinksDto? links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireFileDto() when $default != null:
return $default(_that.quickkey,_that.filename,_that.hash,_that.description,_that.size,_that.privacy,_that.created,_that.createdUtc,_that.mimetype,_that.filetype,_that.downloads,_that.views,_that.revision,_that.parentFolderKey,_that.ready,_that.passwordProtected,_that.deleteDate,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientStringConverter()  String? hash, @LenientStringConverter()  String? description, @LenientIntConverter()  int? size, @LenientStringConverter()  String? privacy, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter()  DateTime? createdUtc, @LenientStringConverter()  String? mimetype, @LenientStringConverter()  String? filetype, @LenientIntConverter()  int? downloads, @LenientIntConverter()  int? views, @LenientStringConverter()  String? revision, @JsonKey(name: 'parent_folderkey')@LenientStringConverter()  String? parentFolderKey, @LenientBoolConverter()  bool? ready, @JsonKey(name: 'password_protected')@LenientBoolConverter()  bool? passwordProtected, @JsonKey(name: 'delete_date')@LenientDateTimeConverter()  DateTime? deleteDate, @JsonKey(fromJson: _readLinks)  MediaFireLinksDto? links)  $default,) {final _that = this;
switch (_that) {
case _MediaFireFileDto():
return $default(_that.quickkey,_that.filename,_that.hash,_that.description,_that.size,_that.privacy,_that.created,_that.createdUtc,_that.mimetype,_that.filetype,_that.downloads,_that.views,_that.revision,_that.parentFolderKey,_that.ready,_that.passwordProtected,_that.deleteDate,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientStringConverter()  String? hash, @LenientStringConverter()  String? description, @LenientIntConverter()  int? size, @LenientStringConverter()  String? privacy, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter()  DateTime? createdUtc, @LenientStringConverter()  String? mimetype, @LenientStringConverter()  String? filetype, @LenientIntConverter()  int? downloads, @LenientIntConverter()  int? views, @LenientStringConverter()  String? revision, @JsonKey(name: 'parent_folderkey')@LenientStringConverter()  String? parentFolderKey, @LenientBoolConverter()  bool? ready, @JsonKey(name: 'password_protected')@LenientBoolConverter()  bool? passwordProtected, @JsonKey(name: 'delete_date')@LenientDateTimeConverter()  DateTime? deleteDate, @JsonKey(fromJson: _readLinks)  MediaFireLinksDto? links)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireFileDto() when $default != null:
return $default(_that.quickkey,_that.filename,_that.hash,_that.description,_that.size,_that.privacy,_that.created,_that.createdUtc,_that.mimetype,_that.filetype,_that.downloads,_that.views,_that.revision,_that.parentFolderKey,_that.ready,_that.passwordProtected,_that.deleteDate,_that.links);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireFileDto implements MediaFireFileDto {
  const _MediaFireFileDto({@LenientStringConverter() this.quickkey, @LenientStringConverter() this.filename, @LenientStringConverter() this.hash, @LenientStringConverter() this.description, @LenientIntConverter() this.size, @LenientStringConverter() this.privacy, @LenientDateTimeConverter() this.created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter() this.createdUtc, @LenientStringConverter() this.mimetype, @LenientStringConverter() this.filetype, @LenientIntConverter() this.downloads, @LenientIntConverter() this.views, @LenientStringConverter() this.revision, @JsonKey(name: 'parent_folderkey')@LenientStringConverter() this.parentFolderKey, @LenientBoolConverter() this.ready, @JsonKey(name: 'password_protected')@LenientBoolConverter() this.passwordProtected, @JsonKey(name: 'delete_date')@LenientDateTimeConverter() this.deleteDate, @JsonKey(fromJson: _readLinks) this.links});
  factory _MediaFireFileDto.fromJson(Map<String, dynamic> json) => _$MediaFireFileDtoFromJson(json);

@override@LenientStringConverter() final  String? quickkey;
@override@LenientStringConverter() final  String? filename;
@override@LenientStringConverter() final  String? hash;
@override@LenientStringConverter() final  String? description;
@override@LenientIntConverter() final  int? size;
@override@LenientStringConverter() final  String? privacy;
@override@LenientDateTimeConverter() final  DateTime? created;
@override@JsonKey(name: 'created_utc')@LenientDateTimeConverter() final  DateTime? createdUtc;
@override@LenientStringConverter() final  String? mimetype;
@override@LenientStringConverter() final  String? filetype;
@override@LenientIntConverter() final  int? downloads;
@override@LenientIntConverter() final  int? views;
@override@LenientStringConverter() final  String? revision;
@override@JsonKey(name: 'parent_folderkey')@LenientStringConverter() final  String? parentFolderKey;
@override@LenientBoolConverter() final  bool? ready;
@override@JsonKey(name: 'password_protected')@LenientBoolConverter() final  bool? passwordProtected;
@override@JsonKey(name: 'delete_date')@LenientDateTimeConverter() final  DateTime? deleteDate;
@override@JsonKey(fromJson: _readLinks) final  MediaFireLinksDto? links;

/// Create a copy of MediaFireFileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireFileDtoCopyWith<_MediaFireFileDto> get copyWith => __$MediaFireFileDtoCopyWithImpl<_MediaFireFileDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireFileDto&&(identical(other.quickkey, quickkey) || other.quickkey == quickkey)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.description, description) || other.description == description)&&(identical(other.size, size) || other.size == size)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&(identical(other.created, created) || other.created == created)&&(identical(other.createdUtc, createdUtc) || other.createdUtc == createdUtc)&&(identical(other.mimetype, mimetype) || other.mimetype == mimetype)&&(identical(other.filetype, filetype) || other.filetype == filetype)&&(identical(other.downloads, downloads) || other.downloads == downloads)&&(identical(other.views, views) || other.views == views)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.parentFolderKey, parentFolderKey) || other.parentFolderKey == parentFolderKey)&&(identical(other.ready, ready) || other.ready == ready)&&(identical(other.passwordProtected, passwordProtected) || other.passwordProtected == passwordProtected)&&(identical(other.deleteDate, deleteDate) || other.deleteDate == deleteDate)&&(identical(other.links, links) || other.links == links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,quickkey,filename,hash,description,size,privacy,created,createdUtc,mimetype,filetype,downloads,views,revision,parentFolderKey,ready,passwordProtected,deleteDate,links);
}

@override
String toString() {
    return 'MediaFireFileDto(quickkey: $quickkey, filename: $filename, hash: $hash, description: $description, size: $size, privacy: $privacy, created: $created, createdUtc: $createdUtc, mimetype: $mimetype, filetype: $filetype, downloads: $downloads, views: $views, revision: $revision, parentFolderKey: $parentFolderKey, ready: $ready, passwordProtected: $passwordProtected, deleteDate: $deleteDate, links: $links)';
}


}

/// @nodoc
abstract mixin class _$MediaFireFileDtoCopyWith<$Res> implements $MediaFireFileDtoCopyWith<$Res> {
  factory _$MediaFireFileDtoCopyWith(_MediaFireFileDto value, $Res Function(_MediaFireFileDto) _then) = __$MediaFireFileDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? quickkey,@LenientStringConverter() String? filename,@LenientStringConverter() String? hash,@LenientStringConverter() String? description,@LenientIntConverter() int? size,@LenientStringConverter() String? privacy,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'created_utc')@LenientDateTimeConverter() DateTime? createdUtc,@LenientStringConverter() String? mimetype,@LenientStringConverter() String? filetype,@LenientIntConverter() int? downloads,@LenientIntConverter() int? views,@LenientStringConverter() String? revision,@JsonKey(name: 'parent_folderkey')@LenientStringConverter() String? parentFolderKey,@LenientBoolConverter() bool? ready,@JsonKey(name: 'password_protected')@LenientBoolConverter() bool? passwordProtected,@JsonKey(name: 'delete_date')@LenientDateTimeConverter() DateTime? deleteDate,@JsonKey(fromJson: _readLinks) MediaFireLinksDto? links
});


@override $MediaFireLinksDtoCopyWith<$Res>? get links;

}
/// @nodoc
class __$MediaFireFileDtoCopyWithImpl<$Res>
    implements _$MediaFireFileDtoCopyWith<$Res> {
  __$MediaFireFileDtoCopyWithImpl(this._self, this._then);

  final _MediaFireFileDto _self;
  final $Res Function(_MediaFireFileDto) _then;

/// Create a copy of MediaFireFileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quickkey = freezed,Object? filename = freezed,Object? hash = freezed,Object? description = freezed,Object? size = freezed,Object? privacy = freezed,Object? created = freezed,Object? createdUtc = freezed,Object? mimetype = freezed,Object? filetype = freezed,Object? downloads = freezed,Object? views = freezed,Object? revision = freezed,Object? parentFolderKey = freezed,Object? ready = freezed,Object? passwordProtected = freezed,Object? deleteDate = freezed,Object? links = freezed,}) {
  return _then(_MediaFireFileDto(
quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,privacy: freezed == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as String?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,createdUtc: freezed == createdUtc ? _self.createdUtc : createdUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,mimetype: freezed == mimetype ? _self.mimetype : mimetype // ignore: cast_nullable_to_non_nullable
as String?,filetype: freezed == filetype ? _self.filetype : filetype // ignore: cast_nullable_to_non_nullable
as String?,downloads: freezed == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as int?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int?,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as String?,parentFolderKey: freezed == parentFolderKey ? _self.parentFolderKey : parentFolderKey // ignore: cast_nullable_to_non_nullable
as String?,ready: freezed == ready ? _self.ready : ready // ignore: cast_nullable_to_non_nullable
as bool?,passwordProtected: freezed == passwordProtected ? _self.passwordProtected : passwordProtected // ignore: cast_nullable_to_non_nullable
as bool?,deleteDate: freezed == deleteDate ? _self.deleteDate : deleteDate // ignore: cast_nullable_to_non_nullable
as DateTime?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as MediaFireLinksDto?,
  ));
}

/// Create a copy of MediaFireFileDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaFireLinksDtoCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $MediaFireLinksDtoCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}
}


/// @nodoc
mixin _$MediaFireLinksDto {

@LenientStringConverter() String? get quickkey;@LenientUriConverter() Uri? get view;@LenientUriConverter() Uri? get watch;@LenientUriConverter() Uri? get listen;@JsonKey(name: 'normal_download')@LenientUriConverter() Uri? get normalDownload;@JsonKey(name: 'direct_download')@LenientUriConverter() Uri? get directDownload;@JsonKey(name: 'direct_download_error')@LenientIntConverter() int? get directDownloadError;@JsonKey(name: 'direct_download_error_message')@LenientStringConverter() String? get directDownloadErrorMessage;/// Set when the session user cannot access the file.
@LenientStringConverter() String? get error;
/// Create a copy of MediaFireLinksDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireLinksDtoCopyWith<MediaFireLinksDto> get copyWith => _$MediaFireLinksDtoCopyWithImpl<MediaFireLinksDto>(this as MediaFireLinksDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireLinksDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireLinksDto&&(identical(other.quickkey, _this.quickkey) || other.quickkey == _this.quickkey)&&(identical(other.view, _this.view) || other.view == _this.view)&&(identical(other.watch, _this.watch) || other.watch == _this.watch)&&(identical(other.listen, _this.listen) || other.listen == _this.listen)&&(identical(other.normalDownload, _this.normalDownload) || other.normalDownload == _this.normalDownload)&&(identical(other.directDownload, _this.directDownload) || other.directDownload == _this.directDownload)&&(identical(other.directDownloadError, _this.directDownloadError) || other.directDownloadError == _this.directDownloadError)&&(identical(other.directDownloadErrorMessage, _this.directDownloadErrorMessage) || other.directDownloadErrorMessage == _this.directDownloadErrorMessage)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireLinksDto;
  return Object.hash(runtimeType,_this.quickkey,_this.view,_this.watch,_this.listen,_this.normalDownload,_this.directDownload,_this.directDownloadError,_this.directDownloadErrorMessage,_this.error);
}

@override
String toString() {
  final _this = this as MediaFireLinksDto;
  return 'MediaFireLinksDto(quickkey: ${_this.quickkey}, view: ${_this.view}, watch: ${_this.watch}, listen: ${_this.listen}, normalDownload: ${_this.normalDownload}, directDownload: ${_this.directDownload}, directDownloadError: ${_this.directDownloadError}, directDownloadErrorMessage: ${_this.directDownloadErrorMessage}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $MediaFireLinksDtoCopyWith<$Res>  {
  factory $MediaFireLinksDtoCopyWith(MediaFireLinksDto value, $Res Function(MediaFireLinksDto) _then) = _$MediaFireLinksDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? quickkey,@LenientUriConverter() Uri? view,@LenientUriConverter() Uri? watch,@LenientUriConverter() Uri? listen,@JsonKey(name: 'normal_download')@LenientUriConverter() Uri? normalDownload,@JsonKey(name: 'direct_download')@LenientUriConverter() Uri? directDownload,@JsonKey(name: 'direct_download_error')@LenientIntConverter() int? directDownloadError,@JsonKey(name: 'direct_download_error_message')@LenientStringConverter() String? directDownloadErrorMessage,@LenientStringConverter() String? error
});




}
/// @nodoc
class _$MediaFireLinksDtoCopyWithImpl<$Res>
    implements $MediaFireLinksDtoCopyWith<$Res> {
  _$MediaFireLinksDtoCopyWithImpl(this._self, this._then);

  final MediaFireLinksDto _self;
  final $Res Function(MediaFireLinksDto) _then;

/// Create a copy of MediaFireLinksDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quickkey = freezed,Object? view = freezed,Object? watch = freezed,Object? listen = freezed,Object? normalDownload = freezed,Object? directDownload = freezed,Object? directDownloadError = freezed,Object? directDownloadErrorMessage = freezed,Object? error = freezed,}) {
  return _then(MediaFireLinksDto(
quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,view: freezed == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as Uri?,watch: freezed == watch ? _self.watch : watch // ignore: cast_nullable_to_non_nullable
as Uri?,listen: freezed == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as Uri?,normalDownload: freezed == normalDownload ? _self.normalDownload : normalDownload // ignore: cast_nullable_to_non_nullable
as Uri?,directDownload: freezed == directDownload ? _self.directDownload : directDownload // ignore: cast_nullable_to_non_nullable
as Uri?,directDownloadError: freezed == directDownloadError ? _self.directDownloadError : directDownloadError // ignore: cast_nullable_to_non_nullable
as int?,directDownloadErrorMessage: freezed == directDownloadErrorMessage ? _self.directDownloadErrorMessage : directDownloadErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaFireLinksDto].
extension MediaFireLinksDtoPatterns on MediaFireLinksDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireLinksDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireLinksDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireLinksDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireLinksDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireLinksDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireLinksDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? quickkey, @LenientUriConverter()  Uri? view, @LenientUriConverter()  Uri? watch, @LenientUriConverter()  Uri? listen, @JsonKey(name: 'normal_download')@LenientUriConverter()  Uri? normalDownload, @JsonKey(name: 'direct_download')@LenientUriConverter()  Uri? directDownload, @JsonKey(name: 'direct_download_error')@LenientIntConverter()  int? directDownloadError, @JsonKey(name: 'direct_download_error_message')@LenientStringConverter()  String? directDownloadErrorMessage, @LenientStringConverter()  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireLinksDto() when $default != null:
return $default(_that.quickkey,_that.view,_that.watch,_that.listen,_that.normalDownload,_that.directDownload,_that.directDownloadError,_that.directDownloadErrorMessage,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? quickkey, @LenientUriConverter()  Uri? view, @LenientUriConverter()  Uri? watch, @LenientUriConverter()  Uri? listen, @JsonKey(name: 'normal_download')@LenientUriConverter()  Uri? normalDownload, @JsonKey(name: 'direct_download')@LenientUriConverter()  Uri? directDownload, @JsonKey(name: 'direct_download_error')@LenientIntConverter()  int? directDownloadError, @JsonKey(name: 'direct_download_error_message')@LenientStringConverter()  String? directDownloadErrorMessage, @LenientStringConverter()  String? error)  $default,) {final _that = this;
switch (_that) {
case _MediaFireLinksDto():
return $default(_that.quickkey,_that.view,_that.watch,_that.listen,_that.normalDownload,_that.directDownload,_that.directDownloadError,_that.directDownloadErrorMessage,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? quickkey, @LenientUriConverter()  Uri? view, @LenientUriConverter()  Uri? watch, @LenientUriConverter()  Uri? listen, @JsonKey(name: 'normal_download')@LenientUriConverter()  Uri? normalDownload, @JsonKey(name: 'direct_download')@LenientUriConverter()  Uri? directDownload, @JsonKey(name: 'direct_download_error')@LenientIntConverter()  int? directDownloadError, @JsonKey(name: 'direct_download_error_message')@LenientStringConverter()  String? directDownloadErrorMessage, @LenientStringConverter()  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireLinksDto() when $default != null:
return $default(_that.quickkey,_that.view,_that.watch,_that.listen,_that.normalDownload,_that.directDownload,_that.directDownloadError,_that.directDownloadErrorMessage,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireLinksDto implements MediaFireLinksDto {
  const _MediaFireLinksDto({@LenientStringConverter() this.quickkey, @LenientUriConverter() this.view, @LenientUriConverter() this.watch, @LenientUriConverter() this.listen, @JsonKey(name: 'normal_download')@LenientUriConverter() this.normalDownload, @JsonKey(name: 'direct_download')@LenientUriConverter() this.directDownload, @JsonKey(name: 'direct_download_error')@LenientIntConverter() this.directDownloadError, @JsonKey(name: 'direct_download_error_message')@LenientStringConverter() this.directDownloadErrorMessage, @LenientStringConverter() this.error});
  factory _MediaFireLinksDto.fromJson(Map<String, dynamic> json) => _$MediaFireLinksDtoFromJson(json);

@override@LenientStringConverter() final  String? quickkey;
@override@LenientUriConverter() final  Uri? view;
@override@LenientUriConverter() final  Uri? watch;
@override@LenientUriConverter() final  Uri? listen;
@override@JsonKey(name: 'normal_download')@LenientUriConverter() final  Uri? normalDownload;
@override@JsonKey(name: 'direct_download')@LenientUriConverter() final  Uri? directDownload;
@override@JsonKey(name: 'direct_download_error')@LenientIntConverter() final  int? directDownloadError;
@override@JsonKey(name: 'direct_download_error_message')@LenientStringConverter() final  String? directDownloadErrorMessage;
/// Set when the session user cannot access the file.
@override@LenientStringConverter() final  String? error;

/// Create a copy of MediaFireLinksDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireLinksDtoCopyWith<_MediaFireLinksDto> get copyWith => __$MediaFireLinksDtoCopyWithImpl<_MediaFireLinksDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireLinksDto&&(identical(other.quickkey, quickkey) || other.quickkey == quickkey)&&(identical(other.view, view) || other.view == view)&&(identical(other.watch, watch) || other.watch == watch)&&(identical(other.listen, listen) || other.listen == listen)&&(identical(other.normalDownload, normalDownload) || other.normalDownload == normalDownload)&&(identical(other.directDownload, directDownload) || other.directDownload == directDownload)&&(identical(other.directDownloadError, directDownloadError) || other.directDownloadError == directDownloadError)&&(identical(other.directDownloadErrorMessage, directDownloadErrorMessage) || other.directDownloadErrorMessage == directDownloadErrorMessage)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,quickkey,view,watch,listen,normalDownload,directDownload,directDownloadError,directDownloadErrorMessage,error);
}

@override
String toString() {
    return 'MediaFireLinksDto(quickkey: $quickkey, view: $view, watch: $watch, listen: $listen, normalDownload: $normalDownload, directDownload: $directDownload, directDownloadError: $directDownloadError, directDownloadErrorMessage: $directDownloadErrorMessage, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MediaFireLinksDtoCopyWith<$Res> implements $MediaFireLinksDtoCopyWith<$Res> {
  factory _$MediaFireLinksDtoCopyWith(_MediaFireLinksDto value, $Res Function(_MediaFireLinksDto) _then) = __$MediaFireLinksDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? quickkey,@LenientUriConverter() Uri? view,@LenientUriConverter() Uri? watch,@LenientUriConverter() Uri? listen,@JsonKey(name: 'normal_download')@LenientUriConverter() Uri? normalDownload,@JsonKey(name: 'direct_download')@LenientUriConverter() Uri? directDownload,@JsonKey(name: 'direct_download_error')@LenientIntConverter() int? directDownloadError,@JsonKey(name: 'direct_download_error_message')@LenientStringConverter() String? directDownloadErrorMessage,@LenientStringConverter() String? error
});




}
/// @nodoc
class __$MediaFireLinksDtoCopyWithImpl<$Res>
    implements _$MediaFireLinksDtoCopyWith<$Res> {
  __$MediaFireLinksDtoCopyWithImpl(this._self, this._then);

  final _MediaFireLinksDto _self;
  final $Res Function(_MediaFireLinksDto) _then;

/// Create a copy of MediaFireLinksDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quickkey = freezed,Object? view = freezed,Object? watch = freezed,Object? listen = freezed,Object? normalDownload = freezed,Object? directDownload = freezed,Object? directDownloadError = freezed,Object? directDownloadErrorMessage = freezed,Object? error = freezed,}) {
  return _then(_MediaFireLinksDto(
quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,view: freezed == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as Uri?,watch: freezed == watch ? _self.watch : watch // ignore: cast_nullable_to_non_nullable
as Uri?,listen: freezed == listen ? _self.listen : listen // ignore: cast_nullable_to_non_nullable
as Uri?,normalDownload: freezed == normalDownload ? _self.normalDownload : normalDownload // ignore: cast_nullable_to_non_nullable
as Uri?,directDownload: freezed == directDownload ? _self.directDownload : directDownload // ignore: cast_nullable_to_non_nullable
as Uri?,directDownloadError: freezed == directDownloadError ? _self.directDownloadError : directDownloadError // ignore: cast_nullable_to_non_nullable
as int?,directDownloadErrorMessage: freezed == directDownloadErrorMessage ? _self.directDownloadErrorMessage : directDownloadErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MediaFireFolderDto {

@JsonKey(readValue: _readFolderKey)@LenientStringConverter() String? get folderkey;@LenientStringConverter() String? get name;@LenientStringConverter() String? get description;@LenientStringConverter() String? get privacy;@LenientDateTimeConverter() DateTime? get created;@JsonKey(name: 'created_utc')@LenientDateTimeConverter() DateTime? get createdUtc;@JsonKey(name: 'file_count')@LenientIntConverter() int? get fileCount;@JsonKey(name: 'folder_count')@LenientIntConverter() int? get folderCount;@JsonKey(name: 'parent_folderkey')@LenientStringConverter() String? get parentFolderKey;@LenientStringConverter() String? get revision;
/// Create a copy of MediaFireFolderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireFolderDtoCopyWith<MediaFireFolderDto> get copyWith => _$MediaFireFolderDtoCopyWithImpl<MediaFireFolderDto>(this as MediaFireFolderDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireFolderDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireFolderDto&&(identical(other.folderkey, _this.folderkey) || other.folderkey == _this.folderkey)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.privacy, _this.privacy) || other.privacy == _this.privacy)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.createdUtc, _this.createdUtc) || other.createdUtc == _this.createdUtc)&&(identical(other.fileCount, _this.fileCount) || other.fileCount == _this.fileCount)&&(identical(other.folderCount, _this.folderCount) || other.folderCount == _this.folderCount)&&(identical(other.parentFolderKey, _this.parentFolderKey) || other.parentFolderKey == _this.parentFolderKey)&&(identical(other.revision, _this.revision) || other.revision == _this.revision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireFolderDto;
  return Object.hash(runtimeType,_this.folderkey,_this.name,_this.description,_this.privacy,_this.created,_this.createdUtc,_this.fileCount,_this.folderCount,_this.parentFolderKey,_this.revision);
}

@override
String toString() {
  final _this = this as MediaFireFolderDto;
  return 'MediaFireFolderDto(folderkey: ${_this.folderkey}, name: ${_this.name}, description: ${_this.description}, privacy: ${_this.privacy}, created: ${_this.created}, createdUtc: ${_this.createdUtc}, fileCount: ${_this.fileCount}, folderCount: ${_this.folderCount}, parentFolderKey: ${_this.parentFolderKey}, revision: ${_this.revision})';
}


}

/// @nodoc
abstract mixin class $MediaFireFolderDtoCopyWith<$Res>  {
  factory $MediaFireFolderDtoCopyWith(MediaFireFolderDto value, $Res Function(MediaFireFolderDto) _then) = _$MediaFireFolderDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readFolderKey)@LenientStringConverter() String? folderkey,@LenientStringConverter() String? name,@LenientStringConverter() String? description,@LenientStringConverter() String? privacy,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'created_utc')@LenientDateTimeConverter() DateTime? createdUtc,@JsonKey(name: 'file_count')@LenientIntConverter() int? fileCount,@JsonKey(name: 'folder_count')@LenientIntConverter() int? folderCount,@JsonKey(name: 'parent_folderkey')@LenientStringConverter() String? parentFolderKey,@LenientStringConverter() String? revision
});




}
/// @nodoc
class _$MediaFireFolderDtoCopyWithImpl<$Res>
    implements $MediaFireFolderDtoCopyWith<$Res> {
  _$MediaFireFolderDtoCopyWithImpl(this._self, this._then);

  final MediaFireFolderDto _self;
  final $Res Function(MediaFireFolderDto) _then;

/// Create a copy of MediaFireFolderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folderkey = freezed,Object? name = freezed,Object? description = freezed,Object? privacy = freezed,Object? created = freezed,Object? createdUtc = freezed,Object? fileCount = freezed,Object? folderCount = freezed,Object? parentFolderKey = freezed,Object? revision = freezed,}) {
  return _then(MediaFireFolderDto(
folderkey: freezed == folderkey ? _self.folderkey : folderkey // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,privacy: freezed == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as String?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,createdUtc: freezed == createdUtc ? _self.createdUtc : createdUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,fileCount: freezed == fileCount ? _self.fileCount : fileCount // ignore: cast_nullable_to_non_nullable
as int?,folderCount: freezed == folderCount ? _self.folderCount : folderCount // ignore: cast_nullable_to_non_nullable
as int?,parentFolderKey: freezed == parentFolderKey ? _self.parentFolderKey : parentFolderKey // ignore: cast_nullable_to_non_nullable
as String?,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaFireFolderDto].
extension MediaFireFolderDtoPatterns on MediaFireFolderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireFolderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireFolderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireFolderDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireFolderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireFolderDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireFolderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFolderKey)@LenientStringConverter()  String? folderkey, @LenientStringConverter()  String? name, @LenientStringConverter()  String? description, @LenientStringConverter()  String? privacy, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter()  DateTime? createdUtc, @JsonKey(name: 'file_count')@LenientIntConverter()  int? fileCount, @JsonKey(name: 'folder_count')@LenientIntConverter()  int? folderCount, @JsonKey(name: 'parent_folderkey')@LenientStringConverter()  String? parentFolderKey, @LenientStringConverter()  String? revision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireFolderDto() when $default != null:
return $default(_that.folderkey,_that.name,_that.description,_that.privacy,_that.created,_that.createdUtc,_that.fileCount,_that.folderCount,_that.parentFolderKey,_that.revision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readFolderKey)@LenientStringConverter()  String? folderkey, @LenientStringConverter()  String? name, @LenientStringConverter()  String? description, @LenientStringConverter()  String? privacy, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter()  DateTime? createdUtc, @JsonKey(name: 'file_count')@LenientIntConverter()  int? fileCount, @JsonKey(name: 'folder_count')@LenientIntConverter()  int? folderCount, @JsonKey(name: 'parent_folderkey')@LenientStringConverter()  String? parentFolderKey, @LenientStringConverter()  String? revision)  $default,) {final _that = this;
switch (_that) {
case _MediaFireFolderDto():
return $default(_that.folderkey,_that.name,_that.description,_that.privacy,_that.created,_that.createdUtc,_that.fileCount,_that.folderCount,_that.parentFolderKey,_that.revision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readFolderKey)@LenientStringConverter()  String? folderkey, @LenientStringConverter()  String? name, @LenientStringConverter()  String? description, @LenientStringConverter()  String? privacy, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter()  DateTime? createdUtc, @JsonKey(name: 'file_count')@LenientIntConverter()  int? fileCount, @JsonKey(name: 'folder_count')@LenientIntConverter()  int? folderCount, @JsonKey(name: 'parent_folderkey')@LenientStringConverter()  String? parentFolderKey, @LenientStringConverter()  String? revision)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireFolderDto() when $default != null:
return $default(_that.folderkey,_that.name,_that.description,_that.privacy,_that.created,_that.createdUtc,_that.fileCount,_that.folderCount,_that.parentFolderKey,_that.revision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireFolderDto implements MediaFireFolderDto {
  const _MediaFireFolderDto({@JsonKey(readValue: _readFolderKey)@LenientStringConverter() this.folderkey, @LenientStringConverter() this.name, @LenientStringConverter() this.description, @LenientStringConverter() this.privacy, @LenientDateTimeConverter() this.created, @JsonKey(name: 'created_utc')@LenientDateTimeConverter() this.createdUtc, @JsonKey(name: 'file_count')@LenientIntConverter() this.fileCount, @JsonKey(name: 'folder_count')@LenientIntConverter() this.folderCount, @JsonKey(name: 'parent_folderkey')@LenientStringConverter() this.parentFolderKey, @LenientStringConverter() this.revision});
  factory _MediaFireFolderDto.fromJson(Map<String, dynamic> json) => _$MediaFireFolderDtoFromJson(json);

@override@JsonKey(readValue: _readFolderKey)@LenientStringConverter() final  String? folderkey;
@override@LenientStringConverter() final  String? name;
@override@LenientStringConverter() final  String? description;
@override@LenientStringConverter() final  String? privacy;
@override@LenientDateTimeConverter() final  DateTime? created;
@override@JsonKey(name: 'created_utc')@LenientDateTimeConverter() final  DateTime? createdUtc;
@override@JsonKey(name: 'file_count')@LenientIntConverter() final  int? fileCount;
@override@JsonKey(name: 'folder_count')@LenientIntConverter() final  int? folderCount;
@override@JsonKey(name: 'parent_folderkey')@LenientStringConverter() final  String? parentFolderKey;
@override@LenientStringConverter() final  String? revision;

/// Create a copy of MediaFireFolderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireFolderDtoCopyWith<_MediaFireFolderDto> get copyWith => __$MediaFireFolderDtoCopyWithImpl<_MediaFireFolderDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireFolderDto&&(identical(other.folderkey, folderkey) || other.folderkey == folderkey)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&(identical(other.created, created) || other.created == created)&&(identical(other.createdUtc, createdUtc) || other.createdUtc == createdUtc)&&(identical(other.fileCount, fileCount) || other.fileCount == fileCount)&&(identical(other.folderCount, folderCount) || other.folderCount == folderCount)&&(identical(other.parentFolderKey, parentFolderKey) || other.parentFolderKey == parentFolderKey)&&(identical(other.revision, revision) || other.revision == revision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,folderkey,name,description,privacy,created,createdUtc,fileCount,folderCount,parentFolderKey,revision);
}

@override
String toString() {
    return 'MediaFireFolderDto(folderkey: $folderkey, name: $name, description: $description, privacy: $privacy, created: $created, createdUtc: $createdUtc, fileCount: $fileCount, folderCount: $folderCount, parentFolderKey: $parentFolderKey, revision: $revision)';
}


}

/// @nodoc
abstract mixin class _$MediaFireFolderDtoCopyWith<$Res> implements $MediaFireFolderDtoCopyWith<$Res> {
  factory _$MediaFireFolderDtoCopyWith(_MediaFireFolderDto value, $Res Function(_MediaFireFolderDto) _then) = __$MediaFireFolderDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readFolderKey)@LenientStringConverter() String? folderkey,@LenientStringConverter() String? name,@LenientStringConverter() String? description,@LenientStringConverter() String? privacy,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'created_utc')@LenientDateTimeConverter() DateTime? createdUtc,@JsonKey(name: 'file_count')@LenientIntConverter() int? fileCount,@JsonKey(name: 'folder_count')@LenientIntConverter() int? folderCount,@JsonKey(name: 'parent_folderkey')@LenientStringConverter() String? parentFolderKey,@LenientStringConverter() String? revision
});




}
/// @nodoc
class __$MediaFireFolderDtoCopyWithImpl<$Res>
    implements _$MediaFireFolderDtoCopyWith<$Res> {
  __$MediaFireFolderDtoCopyWithImpl(this._self, this._then);

  final _MediaFireFolderDto _self;
  final $Res Function(_MediaFireFolderDto) _then;

/// Create a copy of MediaFireFolderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folderkey = freezed,Object? name = freezed,Object? description = freezed,Object? privacy = freezed,Object? created = freezed,Object? createdUtc = freezed,Object? fileCount = freezed,Object? folderCount = freezed,Object? parentFolderKey = freezed,Object? revision = freezed,}) {
  return _then(_MediaFireFolderDto(
folderkey: freezed == folderkey ? _self.folderkey : folderkey // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,privacy: freezed == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as String?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,createdUtc: freezed == createdUtc ? _self.createdUtc : createdUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,fileCount: freezed == fileCount ? _self.fileCount : fileCount // ignore: cast_nullable_to_non_nullable
as int?,folderCount: freezed == folderCount ? _self.folderCount : folderCount // ignore: cast_nullable_to_non_nullable
as int?,parentFolderKey: freezed == parentFolderKey ? _self.parentFolderKey : parentFolderKey // ignore: cast_nullable_to_non_nullable
as String?,revision: freezed == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MediaFireFolderContentDto {

@JsonKey(name: 'chunk_size')@LenientIntConverter() int? get chunkSize;@JsonKey(name: 'chunk_number')@LenientIntConverter() int? get chunkNumber;@JsonKey(name: 'content_type')@LenientStringConverter() String? get contentType;@JsonKey(name: 'more_chunks')@LenientBoolConverter() bool? get moreChunks;@JsonKey(fromJson: _readFolders) List<MediaFireFolderDto> get folders;@JsonKey(fromJson: _readFiles) List<MediaFireFileDto> get files;
/// Create a copy of MediaFireFolderContentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireFolderContentDtoCopyWith<MediaFireFolderContentDto> get copyWith => _$MediaFireFolderContentDtoCopyWithImpl<MediaFireFolderContentDto>(this as MediaFireFolderContentDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireFolderContentDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireFolderContentDto&&(identical(other.chunkSize, _this.chunkSize) || other.chunkSize == _this.chunkSize)&&(identical(other.chunkNumber, _this.chunkNumber) || other.chunkNumber == _this.chunkNumber)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType)&&(identical(other.moreChunks, _this.moreChunks) || other.moreChunks == _this.moreChunks)&&const DeepCollectionEquality().equals(other.folders, _this.folders)&&const DeepCollectionEquality().equals(other.files, _this.files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireFolderContentDto;
  return Object.hash(runtimeType,_this.chunkSize,_this.chunkNumber,_this.contentType,_this.moreChunks,const DeepCollectionEquality().hash(_this.folders),const DeepCollectionEquality().hash(_this.files));
}

@override
String toString() {
  final _this = this as MediaFireFolderContentDto;
  return 'MediaFireFolderContentDto(chunkSize: ${_this.chunkSize}, chunkNumber: ${_this.chunkNumber}, contentType: ${_this.contentType}, moreChunks: ${_this.moreChunks}, folders: ${_this.folders}, files: ${_this.files})';
}


}

/// @nodoc
abstract mixin class $MediaFireFolderContentDtoCopyWith<$Res>  {
  factory $MediaFireFolderContentDtoCopyWith(MediaFireFolderContentDto value, $Res Function(MediaFireFolderContentDto) _then) = _$MediaFireFolderContentDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'chunk_size')@LenientIntConverter() int? chunkSize,@JsonKey(name: 'chunk_number')@LenientIntConverter() int? chunkNumber,@JsonKey(name: 'content_type')@LenientStringConverter() String? contentType,@JsonKey(name: 'more_chunks')@LenientBoolConverter() bool? moreChunks,@JsonKey(fromJson: _readFolders) List<MediaFireFolderDto> folders,@JsonKey(fromJson: _readFiles) List<MediaFireFileDto> files
});




}
/// @nodoc
class _$MediaFireFolderContentDtoCopyWithImpl<$Res>
    implements $MediaFireFolderContentDtoCopyWith<$Res> {
  _$MediaFireFolderContentDtoCopyWithImpl(this._self, this._then);

  final MediaFireFolderContentDto _self;
  final $Res Function(MediaFireFolderContentDto) _then;

/// Create a copy of MediaFireFolderContentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chunkSize = freezed,Object? chunkNumber = freezed,Object? contentType = freezed,Object? moreChunks = freezed,Object? folders = null,Object? files = null,}) {
  return _then(MediaFireFolderContentDto(
chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,chunkNumber: freezed == chunkNumber ? _self.chunkNumber : chunkNumber // ignore: cast_nullable_to_non_nullable
as int?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,moreChunks: freezed == moreChunks ? _self.moreChunks : moreChunks // ignore: cast_nullable_to_non_nullable
as bool?,folders: null == folders ? _self.folders : folders // ignore: cast_nullable_to_non_nullable
as List<MediaFireFolderDto>,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<MediaFireFileDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaFireFolderContentDto].
extension MediaFireFolderContentDtoPatterns on MediaFireFolderContentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireFolderContentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireFolderContentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireFolderContentDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireFolderContentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireFolderContentDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireFolderContentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'chunk_size')@LenientIntConverter()  int? chunkSize, @JsonKey(name: 'chunk_number')@LenientIntConverter()  int? chunkNumber, @JsonKey(name: 'content_type')@LenientStringConverter()  String? contentType, @JsonKey(name: 'more_chunks')@LenientBoolConverter()  bool? moreChunks, @JsonKey(fromJson: _readFolders)  List<MediaFireFolderDto> folders, @JsonKey(fromJson: _readFiles)  List<MediaFireFileDto> files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireFolderContentDto() when $default != null:
return $default(_that.chunkSize,_that.chunkNumber,_that.contentType,_that.moreChunks,_that.folders,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'chunk_size')@LenientIntConverter()  int? chunkSize, @JsonKey(name: 'chunk_number')@LenientIntConverter()  int? chunkNumber, @JsonKey(name: 'content_type')@LenientStringConverter()  String? contentType, @JsonKey(name: 'more_chunks')@LenientBoolConverter()  bool? moreChunks, @JsonKey(fromJson: _readFolders)  List<MediaFireFolderDto> folders, @JsonKey(fromJson: _readFiles)  List<MediaFireFileDto> files)  $default,) {final _that = this;
switch (_that) {
case _MediaFireFolderContentDto():
return $default(_that.chunkSize,_that.chunkNumber,_that.contentType,_that.moreChunks,_that.folders,_that.files);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'chunk_size')@LenientIntConverter()  int? chunkSize, @JsonKey(name: 'chunk_number')@LenientIntConverter()  int? chunkNumber, @JsonKey(name: 'content_type')@LenientStringConverter()  String? contentType, @JsonKey(name: 'more_chunks')@LenientBoolConverter()  bool? moreChunks, @JsonKey(fromJson: _readFolders)  List<MediaFireFolderDto> folders, @JsonKey(fromJson: _readFiles)  List<MediaFireFileDto> files)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireFolderContentDto() when $default != null:
return $default(_that.chunkSize,_that.chunkNumber,_that.contentType,_that.moreChunks,_that.folders,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireFolderContentDto implements MediaFireFolderContentDto {
  const _MediaFireFolderContentDto({@JsonKey(name: 'chunk_size')@LenientIntConverter() this.chunkSize, @JsonKey(name: 'chunk_number')@LenientIntConverter() this.chunkNumber, @JsonKey(name: 'content_type')@LenientStringConverter() this.contentType, @JsonKey(name: 'more_chunks')@LenientBoolConverter() this.moreChunks, @JsonKey(fromJson: _readFolders)  List<MediaFireFolderDto> folders = const <MediaFireFolderDto>[], @JsonKey(fromJson: _readFiles)  List<MediaFireFileDto> files = const <MediaFireFileDto>[]}): _folders = folders,_files = files;
  factory _MediaFireFolderContentDto.fromJson(Map<String, dynamic> json) => _$MediaFireFolderContentDtoFromJson(json);

@override@JsonKey(name: 'chunk_size')@LenientIntConverter() final  int? chunkSize;
@override@JsonKey(name: 'chunk_number')@LenientIntConverter() final  int? chunkNumber;
@override@JsonKey(name: 'content_type')@LenientStringConverter() final  String? contentType;
@override@JsonKey(name: 'more_chunks')@LenientBoolConverter() final  bool? moreChunks;
 final  List<MediaFireFolderDto> _folders;
@override@JsonKey(fromJson: _readFolders) List<MediaFireFolderDto> get folders {
  if (_folders is EqualUnmodifiableListView) return _folders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_folders);
}

 final  List<MediaFireFileDto> _files;
@override@JsonKey(fromJson: _readFiles) List<MediaFireFileDto> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of MediaFireFolderContentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireFolderContentDtoCopyWith<_MediaFireFolderContentDto> get copyWith => __$MediaFireFolderContentDtoCopyWithImpl<_MediaFireFolderContentDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireFolderContentDto&&(identical(other.chunkSize, chunkSize) || other.chunkSize == chunkSize)&&(identical(other.chunkNumber, chunkNumber) || other.chunkNumber == chunkNumber)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.moreChunks, moreChunks) || other.moreChunks == moreChunks)&&const DeepCollectionEquality().equals(other.folders, _folders)&&const DeepCollectionEquality().equals(other.files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,chunkSize,chunkNumber,contentType,moreChunks,const DeepCollectionEquality().hash(_folders),const DeepCollectionEquality().hash(_files));
}

@override
String toString() {
    return 'MediaFireFolderContentDto(chunkSize: $chunkSize, chunkNumber: $chunkNumber, contentType: $contentType, moreChunks: $moreChunks, folders: $folders, files: $files)';
}


}

/// @nodoc
abstract mixin class _$MediaFireFolderContentDtoCopyWith<$Res> implements $MediaFireFolderContentDtoCopyWith<$Res> {
  factory _$MediaFireFolderContentDtoCopyWith(_MediaFireFolderContentDto value, $Res Function(_MediaFireFolderContentDto) _then) = __$MediaFireFolderContentDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'chunk_size')@LenientIntConverter() int? chunkSize,@JsonKey(name: 'chunk_number')@LenientIntConverter() int? chunkNumber,@JsonKey(name: 'content_type')@LenientStringConverter() String? contentType,@JsonKey(name: 'more_chunks')@LenientBoolConverter() bool? moreChunks,@JsonKey(fromJson: _readFolders) List<MediaFireFolderDto> folders,@JsonKey(fromJson: _readFiles) List<MediaFireFileDto> files
});




}
/// @nodoc
class __$MediaFireFolderContentDtoCopyWithImpl<$Res>
    implements _$MediaFireFolderContentDtoCopyWith<$Res> {
  __$MediaFireFolderContentDtoCopyWithImpl(this._self, this._then);

  final _MediaFireFolderContentDto _self;
  final $Res Function(_MediaFireFolderContentDto) _then;

/// Create a copy of MediaFireFolderContentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chunkSize = freezed,Object? chunkNumber = freezed,Object? contentType = freezed,Object? moreChunks = freezed,Object? folders = null,Object? files = null,}) {
  return _then(_MediaFireFolderContentDto(
chunkSize: freezed == chunkSize ? _self.chunkSize : chunkSize // ignore: cast_nullable_to_non_nullable
as int?,chunkNumber: freezed == chunkNumber ? _self.chunkNumber : chunkNumber // ignore: cast_nullable_to_non_nullable
as int?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,moreChunks: freezed == moreChunks ? _self.moreChunks : moreChunks // ignore: cast_nullable_to_non_nullable
as bool?,folders: null == folders ? _self._folders : folders // ignore: cast_nullable_to_non_nullable
as List<MediaFireFolderDto>,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<MediaFireFileDto>,
  ));
}


}


/// @nodoc
mixin _$MediaFireUserInfoDto {

@LenientStringConverter() String? get email;@JsonKey(name: 'first_name')@LenientStringConverter() String? get firstName;@JsonKey(name: 'last_name')@LenientStringConverter() String? get lastName;@JsonKey(name: 'display_name')@LenientStringConverter() String? get displayName;@LenientBoolConverter() bool? get premium;@LenientBoolConverter() bool? get validated;@LenientIntConverter() int? get bandwidth;@LenientDateTimeConverter() DateTime? get created;@JsonKey(name: 'used_storage_size')@LenientIntConverter() int? get usedStorageSize;@JsonKey(name: 'base_storage')@LenientIntConverter() int? get baseStorage;@JsonKey(name: 'bonus_storage')@LenientIntConverter() int? get bonusStorage;@JsonKey(name: 'storage_limit')@LenientIntConverter() int? get storageLimit;@JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter() bool? get storageLimitExceeded;
/// Create a copy of MediaFireUserInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireUserInfoDtoCopyWith<MediaFireUserInfoDto> get copyWith => _$MediaFireUserInfoDtoCopyWithImpl<MediaFireUserInfoDto>(this as MediaFireUserInfoDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireUserInfoDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireUserInfoDto&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.premium, _this.premium) || other.premium == _this.premium)&&(identical(other.validated, _this.validated) || other.validated == _this.validated)&&(identical(other.bandwidth, _this.bandwidth) || other.bandwidth == _this.bandwidth)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.usedStorageSize, _this.usedStorageSize) || other.usedStorageSize == _this.usedStorageSize)&&(identical(other.baseStorage, _this.baseStorage) || other.baseStorage == _this.baseStorage)&&(identical(other.bonusStorage, _this.bonusStorage) || other.bonusStorage == _this.bonusStorage)&&(identical(other.storageLimit, _this.storageLimit) || other.storageLimit == _this.storageLimit)&&(identical(other.storageLimitExceeded, _this.storageLimitExceeded) || other.storageLimitExceeded == _this.storageLimitExceeded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireUserInfoDto;
  return Object.hash(runtimeType,_this.email,_this.firstName,_this.lastName,_this.displayName,_this.premium,_this.validated,_this.bandwidth,_this.created,_this.usedStorageSize,_this.baseStorage,_this.bonusStorage,_this.storageLimit,_this.storageLimitExceeded);
}

@override
String toString() {
  final _this = this as MediaFireUserInfoDto;
  return 'MediaFireUserInfoDto(email: ${_this.email}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, displayName: ${_this.displayName}, premium: ${_this.premium}, validated: ${_this.validated}, bandwidth: ${_this.bandwidth}, created: ${_this.created}, usedStorageSize: ${_this.usedStorageSize}, baseStorage: ${_this.baseStorage}, bonusStorage: ${_this.bonusStorage}, storageLimit: ${_this.storageLimit}, storageLimitExceeded: ${_this.storageLimitExceeded})';
}


}

/// @nodoc
abstract mixin class $MediaFireUserInfoDtoCopyWith<$Res>  {
  factory $MediaFireUserInfoDtoCopyWith(MediaFireUserInfoDto value, $Res Function(MediaFireUserInfoDto) _then) = _$MediaFireUserInfoDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? email,@JsonKey(name: 'first_name')@LenientStringConverter() String? firstName,@JsonKey(name: 'last_name')@LenientStringConverter() String? lastName,@JsonKey(name: 'display_name')@LenientStringConverter() String? displayName,@LenientBoolConverter() bool? premium,@LenientBoolConverter() bool? validated,@LenientIntConverter() int? bandwidth,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'used_storage_size')@LenientIntConverter() int? usedStorageSize,@JsonKey(name: 'base_storage')@LenientIntConverter() int? baseStorage,@JsonKey(name: 'bonus_storage')@LenientIntConverter() int? bonusStorage,@JsonKey(name: 'storage_limit')@LenientIntConverter() int? storageLimit,@JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter() bool? storageLimitExceeded
});




}
/// @nodoc
class _$MediaFireUserInfoDtoCopyWithImpl<$Res>
    implements $MediaFireUserInfoDtoCopyWith<$Res> {
  _$MediaFireUserInfoDtoCopyWithImpl(this._self, this._then);

  final MediaFireUserInfoDto _self;
  final $Res Function(MediaFireUserInfoDto) _then;

/// Create a copy of MediaFireUserInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? displayName = freezed,Object? premium = freezed,Object? validated = freezed,Object? bandwidth = freezed,Object? created = freezed,Object? usedStorageSize = freezed,Object? baseStorage = freezed,Object? bonusStorage = freezed,Object? storageLimit = freezed,Object? storageLimitExceeded = freezed,}) {
  return _then(MediaFireUserInfoDto(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,premium: freezed == premium ? _self.premium : premium // ignore: cast_nullable_to_non_nullable
as bool?,validated: freezed == validated ? _self.validated : validated // ignore: cast_nullable_to_non_nullable
as bool?,bandwidth: freezed == bandwidth ? _self.bandwidth : bandwidth // ignore: cast_nullable_to_non_nullable
as int?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,usedStorageSize: freezed == usedStorageSize ? _self.usedStorageSize : usedStorageSize // ignore: cast_nullable_to_non_nullable
as int?,baseStorage: freezed == baseStorage ? _self.baseStorage : baseStorage // ignore: cast_nullable_to_non_nullable
as int?,bonusStorage: freezed == bonusStorage ? _self.bonusStorage : bonusStorage // ignore: cast_nullable_to_non_nullable
as int?,storageLimit: freezed == storageLimit ? _self.storageLimit : storageLimit // ignore: cast_nullable_to_non_nullable
as int?,storageLimitExceeded: freezed == storageLimitExceeded ? _self.storageLimitExceeded : storageLimitExceeded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaFireUserInfoDto].
extension MediaFireUserInfoDtoPatterns on MediaFireUserInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireUserInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireUserInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireUserInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireUserInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireUserInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireUserInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? email, @JsonKey(name: 'first_name')@LenientStringConverter()  String? firstName, @JsonKey(name: 'last_name')@LenientStringConverter()  String? lastName, @JsonKey(name: 'display_name')@LenientStringConverter()  String? displayName, @LenientBoolConverter()  bool? premium, @LenientBoolConverter()  bool? validated, @LenientIntConverter()  int? bandwidth, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'used_storage_size')@LenientIntConverter()  int? usedStorageSize, @JsonKey(name: 'base_storage')@LenientIntConverter()  int? baseStorage, @JsonKey(name: 'bonus_storage')@LenientIntConverter()  int? bonusStorage, @JsonKey(name: 'storage_limit')@LenientIntConverter()  int? storageLimit, @JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter()  bool? storageLimitExceeded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireUserInfoDto() when $default != null:
return $default(_that.email,_that.firstName,_that.lastName,_that.displayName,_that.premium,_that.validated,_that.bandwidth,_that.created,_that.usedStorageSize,_that.baseStorage,_that.bonusStorage,_that.storageLimit,_that.storageLimitExceeded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? email, @JsonKey(name: 'first_name')@LenientStringConverter()  String? firstName, @JsonKey(name: 'last_name')@LenientStringConverter()  String? lastName, @JsonKey(name: 'display_name')@LenientStringConverter()  String? displayName, @LenientBoolConverter()  bool? premium, @LenientBoolConverter()  bool? validated, @LenientIntConverter()  int? bandwidth, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'used_storage_size')@LenientIntConverter()  int? usedStorageSize, @JsonKey(name: 'base_storage')@LenientIntConverter()  int? baseStorage, @JsonKey(name: 'bonus_storage')@LenientIntConverter()  int? bonusStorage, @JsonKey(name: 'storage_limit')@LenientIntConverter()  int? storageLimit, @JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter()  bool? storageLimitExceeded)  $default,) {final _that = this;
switch (_that) {
case _MediaFireUserInfoDto():
return $default(_that.email,_that.firstName,_that.lastName,_that.displayName,_that.premium,_that.validated,_that.bandwidth,_that.created,_that.usedStorageSize,_that.baseStorage,_that.bonusStorage,_that.storageLimit,_that.storageLimitExceeded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? email, @JsonKey(name: 'first_name')@LenientStringConverter()  String? firstName, @JsonKey(name: 'last_name')@LenientStringConverter()  String? lastName, @JsonKey(name: 'display_name')@LenientStringConverter()  String? displayName, @LenientBoolConverter()  bool? premium, @LenientBoolConverter()  bool? validated, @LenientIntConverter()  int? bandwidth, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'used_storage_size')@LenientIntConverter()  int? usedStorageSize, @JsonKey(name: 'base_storage')@LenientIntConverter()  int? baseStorage, @JsonKey(name: 'bonus_storage')@LenientIntConverter()  int? bonusStorage, @JsonKey(name: 'storage_limit')@LenientIntConverter()  int? storageLimit, @JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter()  bool? storageLimitExceeded)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireUserInfoDto() when $default != null:
return $default(_that.email,_that.firstName,_that.lastName,_that.displayName,_that.premium,_that.validated,_that.bandwidth,_that.created,_that.usedStorageSize,_that.baseStorage,_that.bonusStorage,_that.storageLimit,_that.storageLimitExceeded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireUserInfoDto implements MediaFireUserInfoDto {
  const _MediaFireUserInfoDto({@LenientStringConverter() this.email, @JsonKey(name: 'first_name')@LenientStringConverter() this.firstName, @JsonKey(name: 'last_name')@LenientStringConverter() this.lastName, @JsonKey(name: 'display_name')@LenientStringConverter() this.displayName, @LenientBoolConverter() this.premium, @LenientBoolConverter() this.validated, @LenientIntConverter() this.bandwidth, @LenientDateTimeConverter() this.created, @JsonKey(name: 'used_storage_size')@LenientIntConverter() this.usedStorageSize, @JsonKey(name: 'base_storage')@LenientIntConverter() this.baseStorage, @JsonKey(name: 'bonus_storage')@LenientIntConverter() this.bonusStorage, @JsonKey(name: 'storage_limit')@LenientIntConverter() this.storageLimit, @JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter() this.storageLimitExceeded});
  factory _MediaFireUserInfoDto.fromJson(Map<String, dynamic> json) => _$MediaFireUserInfoDtoFromJson(json);

@override@LenientStringConverter() final  String? email;
@override@JsonKey(name: 'first_name')@LenientStringConverter() final  String? firstName;
@override@JsonKey(name: 'last_name')@LenientStringConverter() final  String? lastName;
@override@JsonKey(name: 'display_name')@LenientStringConverter() final  String? displayName;
@override@LenientBoolConverter() final  bool? premium;
@override@LenientBoolConverter() final  bool? validated;
@override@LenientIntConverter() final  int? bandwidth;
@override@LenientDateTimeConverter() final  DateTime? created;
@override@JsonKey(name: 'used_storage_size')@LenientIntConverter() final  int? usedStorageSize;
@override@JsonKey(name: 'base_storage')@LenientIntConverter() final  int? baseStorage;
@override@JsonKey(name: 'bonus_storage')@LenientIntConverter() final  int? bonusStorage;
@override@JsonKey(name: 'storage_limit')@LenientIntConverter() final  int? storageLimit;
@override@JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter() final  bool? storageLimitExceeded;

/// Create a copy of MediaFireUserInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireUserInfoDtoCopyWith<_MediaFireUserInfoDto> get copyWith => __$MediaFireUserInfoDtoCopyWithImpl<_MediaFireUserInfoDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireUserInfoDto&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.premium, premium) || other.premium == premium)&&(identical(other.validated, validated) || other.validated == validated)&&(identical(other.bandwidth, bandwidth) || other.bandwidth == bandwidth)&&(identical(other.created, created) || other.created == created)&&(identical(other.usedStorageSize, usedStorageSize) || other.usedStorageSize == usedStorageSize)&&(identical(other.baseStorage, baseStorage) || other.baseStorage == baseStorage)&&(identical(other.bonusStorage, bonusStorage) || other.bonusStorage == bonusStorage)&&(identical(other.storageLimit, storageLimit) || other.storageLimit == storageLimit)&&(identical(other.storageLimitExceeded, storageLimitExceeded) || other.storageLimitExceeded == storageLimitExceeded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,firstName,lastName,displayName,premium,validated,bandwidth,created,usedStorageSize,baseStorage,bonusStorage,storageLimit,storageLimitExceeded);
}

@override
String toString() {
    return 'MediaFireUserInfoDto(email: $email, firstName: $firstName, lastName: $lastName, displayName: $displayName, premium: $premium, validated: $validated, bandwidth: $bandwidth, created: $created, usedStorageSize: $usedStorageSize, baseStorage: $baseStorage, bonusStorage: $bonusStorage, storageLimit: $storageLimit, storageLimitExceeded: $storageLimitExceeded)';
}


}

/// @nodoc
abstract mixin class _$MediaFireUserInfoDtoCopyWith<$Res> implements $MediaFireUserInfoDtoCopyWith<$Res> {
  factory _$MediaFireUserInfoDtoCopyWith(_MediaFireUserInfoDto value, $Res Function(_MediaFireUserInfoDto) _then) = __$MediaFireUserInfoDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? email,@JsonKey(name: 'first_name')@LenientStringConverter() String? firstName,@JsonKey(name: 'last_name')@LenientStringConverter() String? lastName,@JsonKey(name: 'display_name')@LenientStringConverter() String? displayName,@LenientBoolConverter() bool? premium,@LenientBoolConverter() bool? validated,@LenientIntConverter() int? bandwidth,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'used_storage_size')@LenientIntConverter() int? usedStorageSize,@JsonKey(name: 'base_storage')@LenientIntConverter() int? baseStorage,@JsonKey(name: 'bonus_storage')@LenientIntConverter() int? bonusStorage,@JsonKey(name: 'storage_limit')@LenientIntConverter() int? storageLimit,@JsonKey(name: 'storage_limit_exceeded')@LenientBoolConverter() bool? storageLimitExceeded
});




}
/// @nodoc
class __$MediaFireUserInfoDtoCopyWithImpl<$Res>
    implements _$MediaFireUserInfoDtoCopyWith<$Res> {
  __$MediaFireUserInfoDtoCopyWithImpl(this._self, this._then);

  final _MediaFireUserInfoDto _self;
  final $Res Function(_MediaFireUserInfoDto) _then;

/// Create a copy of MediaFireUserInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? displayName = freezed,Object? premium = freezed,Object? validated = freezed,Object? bandwidth = freezed,Object? created = freezed,Object? usedStorageSize = freezed,Object? baseStorage = freezed,Object? bonusStorage = freezed,Object? storageLimit = freezed,Object? storageLimitExceeded = freezed,}) {
  return _then(_MediaFireUserInfoDto(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,premium: freezed == premium ? _self.premium : premium // ignore: cast_nullable_to_non_nullable
as bool?,validated: freezed == validated ? _self.validated : validated // ignore: cast_nullable_to_non_nullable
as bool?,bandwidth: freezed == bandwidth ? _self.bandwidth : bandwidth // ignore: cast_nullable_to_non_nullable
as int?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,usedStorageSize: freezed == usedStorageSize ? _self.usedStorageSize : usedStorageSize // ignore: cast_nullable_to_non_nullable
as int?,baseStorage: freezed == baseStorage ? _self.baseStorage : baseStorage // ignore: cast_nullable_to_non_nullable
as int?,bonusStorage: freezed == bonusStorage ? _self.bonusStorage : bonusStorage // ignore: cast_nullable_to_non_nullable
as int?,storageLimit: freezed == storageLimit ? _self.storageLimit : storageLimit // ignore: cast_nullable_to_non_nullable
as int?,storageLimitExceeded: freezed == storageLimitExceeded ? _self.storageLimitExceeded : storageLimitExceeded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$MediaFireWebUploadDto {

@LenientStringConverter() String? get uploadkey;@LenientBoolConverter() bool? get active;@LenientStringConverter() String? get quickkey;@LenientStringConverter() String? get filename;@LenientDateTimeConverter() DateTime? get created;@JsonKey(name: 'status_code')@LenientIntConverter() int? get statusCode;@LenientStringConverter() String? get status;@JsonKey(name: 'error_status')@LenientIntConverter() int? get errorStatus;@LenientUriConverter() Uri? get url;@LenientStringConverter() String? get eta;@LenientIntConverter() int? get size;@LenientIntConverter() int? get percentage;
/// Create a copy of MediaFireWebUploadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireWebUploadDtoCopyWith<MediaFireWebUploadDto> get copyWith => _$MediaFireWebUploadDtoCopyWithImpl<MediaFireWebUploadDto>(this as MediaFireWebUploadDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireWebUploadDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireWebUploadDto&&(identical(other.uploadkey, _this.uploadkey) || other.uploadkey == _this.uploadkey)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.quickkey, _this.quickkey) || other.quickkey == _this.quickkey)&&(identical(other.filename, _this.filename) || other.filename == _this.filename)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorStatus, _this.errorStatus) || other.errorStatus == _this.errorStatus)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.eta, _this.eta) || other.eta == _this.eta)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.percentage, _this.percentage) || other.percentage == _this.percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireWebUploadDto;
  return Object.hash(runtimeType,_this.uploadkey,_this.active,_this.quickkey,_this.filename,_this.created,_this.statusCode,_this.status,_this.errorStatus,_this.url,_this.eta,_this.size,_this.percentage);
}

@override
String toString() {
  final _this = this as MediaFireWebUploadDto;
  return 'MediaFireWebUploadDto(uploadkey: ${_this.uploadkey}, active: ${_this.active}, quickkey: ${_this.quickkey}, filename: ${_this.filename}, created: ${_this.created}, statusCode: ${_this.statusCode}, status: ${_this.status}, errorStatus: ${_this.errorStatus}, url: ${_this.url}, eta: ${_this.eta}, size: ${_this.size}, percentage: ${_this.percentage})';
}


}

/// @nodoc
abstract mixin class $MediaFireWebUploadDtoCopyWith<$Res>  {
  factory $MediaFireWebUploadDtoCopyWith(MediaFireWebUploadDto value, $Res Function(MediaFireWebUploadDto) _then) = _$MediaFireWebUploadDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? uploadkey,@LenientBoolConverter() bool? active,@LenientStringConverter() String? quickkey,@LenientStringConverter() String? filename,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'status_code')@LenientIntConverter() int? statusCode,@LenientStringConverter() String? status,@JsonKey(name: 'error_status')@LenientIntConverter() int? errorStatus,@LenientUriConverter() Uri? url,@LenientStringConverter() String? eta,@LenientIntConverter() int? size,@LenientIntConverter() int? percentage
});




}
/// @nodoc
class _$MediaFireWebUploadDtoCopyWithImpl<$Res>
    implements $MediaFireWebUploadDtoCopyWith<$Res> {
  _$MediaFireWebUploadDtoCopyWithImpl(this._self, this._then);

  final MediaFireWebUploadDto _self;
  final $Res Function(MediaFireWebUploadDto) _then;

/// Create a copy of MediaFireWebUploadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadkey = freezed,Object? active = freezed,Object? quickkey = freezed,Object? filename = freezed,Object? created = freezed,Object? statusCode = freezed,Object? status = freezed,Object? errorStatus = freezed,Object? url = freezed,Object? eta = freezed,Object? size = freezed,Object? percentage = freezed,}) {
  return _then(MediaFireWebUploadDto(
uploadkey: freezed == uploadkey ? _self.uploadkey : uploadkey // ignore: cast_nullable_to_non_nullable
as String?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,errorStatus: freezed == errorStatus ? _self.errorStatus : errorStatus // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri?,eta: freezed == eta ? _self.eta : eta // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaFireWebUploadDto].
extension MediaFireWebUploadDtoPatterns on MediaFireWebUploadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireWebUploadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireWebUploadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireWebUploadDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireWebUploadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireWebUploadDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireWebUploadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? uploadkey, @LenientBoolConverter()  bool? active, @LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'status_code')@LenientIntConverter()  int? statusCode, @LenientStringConverter()  String? status, @JsonKey(name: 'error_status')@LenientIntConverter()  int? errorStatus, @LenientUriConverter()  Uri? url, @LenientStringConverter()  String? eta, @LenientIntConverter()  int? size, @LenientIntConverter()  int? percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireWebUploadDto() when $default != null:
return $default(_that.uploadkey,_that.active,_that.quickkey,_that.filename,_that.created,_that.statusCode,_that.status,_that.errorStatus,_that.url,_that.eta,_that.size,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? uploadkey, @LenientBoolConverter()  bool? active, @LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'status_code')@LenientIntConverter()  int? statusCode, @LenientStringConverter()  String? status, @JsonKey(name: 'error_status')@LenientIntConverter()  int? errorStatus, @LenientUriConverter()  Uri? url, @LenientStringConverter()  String? eta, @LenientIntConverter()  int? size, @LenientIntConverter()  int? percentage)  $default,) {final _that = this;
switch (_that) {
case _MediaFireWebUploadDto():
return $default(_that.uploadkey,_that.active,_that.quickkey,_that.filename,_that.created,_that.statusCode,_that.status,_that.errorStatus,_that.url,_that.eta,_that.size,_that.percentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? uploadkey, @LenientBoolConverter()  bool? active, @LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientDateTimeConverter()  DateTime? created, @JsonKey(name: 'status_code')@LenientIntConverter()  int? statusCode, @LenientStringConverter()  String? status, @JsonKey(name: 'error_status')@LenientIntConverter()  int? errorStatus, @LenientUriConverter()  Uri? url, @LenientStringConverter()  String? eta, @LenientIntConverter()  int? size, @LenientIntConverter()  int? percentage)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireWebUploadDto() when $default != null:
return $default(_that.uploadkey,_that.active,_that.quickkey,_that.filename,_that.created,_that.statusCode,_that.status,_that.errorStatus,_that.url,_that.eta,_that.size,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireWebUploadDto implements MediaFireWebUploadDto {
  const _MediaFireWebUploadDto({@LenientStringConverter() this.uploadkey, @LenientBoolConverter() this.active, @LenientStringConverter() this.quickkey, @LenientStringConverter() this.filename, @LenientDateTimeConverter() this.created, @JsonKey(name: 'status_code')@LenientIntConverter() this.statusCode, @LenientStringConverter() this.status, @JsonKey(name: 'error_status')@LenientIntConverter() this.errorStatus, @LenientUriConverter() this.url, @LenientStringConverter() this.eta, @LenientIntConverter() this.size, @LenientIntConverter() this.percentage});
  factory _MediaFireWebUploadDto.fromJson(Map<String, dynamic> json) => _$MediaFireWebUploadDtoFromJson(json);

@override@LenientStringConverter() final  String? uploadkey;
@override@LenientBoolConverter() final  bool? active;
@override@LenientStringConverter() final  String? quickkey;
@override@LenientStringConverter() final  String? filename;
@override@LenientDateTimeConverter() final  DateTime? created;
@override@JsonKey(name: 'status_code')@LenientIntConverter() final  int? statusCode;
@override@LenientStringConverter() final  String? status;
@override@JsonKey(name: 'error_status')@LenientIntConverter() final  int? errorStatus;
@override@LenientUriConverter() final  Uri? url;
@override@LenientStringConverter() final  String? eta;
@override@LenientIntConverter() final  int? size;
@override@LenientIntConverter() final  int? percentage;

/// Create a copy of MediaFireWebUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireWebUploadDtoCopyWith<_MediaFireWebUploadDto> get copyWith => __$MediaFireWebUploadDtoCopyWithImpl<_MediaFireWebUploadDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireWebUploadDto&&(identical(other.uploadkey, uploadkey) || other.uploadkey == uploadkey)&&(identical(other.active, active) || other.active == active)&&(identical(other.quickkey, quickkey) || other.quickkey == quickkey)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.created, created) || other.created == created)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorStatus, errorStatus) || other.errorStatus == errorStatus)&&(identical(other.url, url) || other.url == url)&&(identical(other.eta, eta) || other.eta == eta)&&(identical(other.size, size) || other.size == size)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uploadkey,active,quickkey,filename,created,statusCode,status,errorStatus,url,eta,size,percentage);
}

@override
String toString() {
    return 'MediaFireWebUploadDto(uploadkey: $uploadkey, active: $active, quickkey: $quickkey, filename: $filename, created: $created, statusCode: $statusCode, status: $status, errorStatus: $errorStatus, url: $url, eta: $eta, size: $size, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$MediaFireWebUploadDtoCopyWith<$Res> implements $MediaFireWebUploadDtoCopyWith<$Res> {
  factory _$MediaFireWebUploadDtoCopyWith(_MediaFireWebUploadDto value, $Res Function(_MediaFireWebUploadDto) _then) = __$MediaFireWebUploadDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? uploadkey,@LenientBoolConverter() bool? active,@LenientStringConverter() String? quickkey,@LenientStringConverter() String? filename,@LenientDateTimeConverter() DateTime? created,@JsonKey(name: 'status_code')@LenientIntConverter() int? statusCode,@LenientStringConverter() String? status,@JsonKey(name: 'error_status')@LenientIntConverter() int? errorStatus,@LenientUriConverter() Uri? url,@LenientStringConverter() String? eta,@LenientIntConverter() int? size,@LenientIntConverter() int? percentage
});




}
/// @nodoc
class __$MediaFireWebUploadDtoCopyWithImpl<$Res>
    implements _$MediaFireWebUploadDtoCopyWith<$Res> {
  __$MediaFireWebUploadDtoCopyWithImpl(this._self, this._then);

  final _MediaFireWebUploadDto _self;
  final $Res Function(_MediaFireWebUploadDto) _then;

/// Create a copy of MediaFireWebUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadkey = freezed,Object? active = freezed,Object? quickkey = freezed,Object? filename = freezed,Object? created = freezed,Object? statusCode = freezed,Object? status = freezed,Object? errorStatus = freezed,Object? url = freezed,Object? eta = freezed,Object? size = freezed,Object? percentage = freezed,}) {
  return _then(_MediaFireWebUploadDto(
uploadkey: freezed == uploadkey ? _self.uploadkey : uploadkey // ignore: cast_nullable_to_non_nullable
as String?,active: freezed == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool?,quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime?,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,errorStatus: freezed == errorStatus ? _self.errorStatus : errorStatus // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri?,eta: freezed == eta ? _self.eta : eta // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,percentage: freezed == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$MediaFireDoUploadDto {

/// Upload key to pass to `upload/poll_upload`.
@LenientStringConverter() String? get key;/// `0` on success, a negative code otherwise.
@LenientIntConverter() int? get result;/// Processing status; `99` means finished.
@LenientIntConverter() int? get status;@LenientStringConverter() String? get description;/// Non zero when the file was rejected (`15` = storage full, ...).
@LenientIntConverter() int? get fileerror;@LenientStringConverter() String? get quickkey;@LenientStringConverter() String? get filename;@LenientIntConverter() int? get size;
/// Create a copy of MediaFireDoUploadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaFireDoUploadDtoCopyWith<MediaFireDoUploadDto> get copyWith => _$MediaFireDoUploadDtoCopyWithImpl<MediaFireDoUploadDto>(this as MediaFireDoUploadDto, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MediaFireDoUploadDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaFireDoUploadDto&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.fileerror, _this.fileerror) || other.fileerror == _this.fileerror)&&(identical(other.quickkey, _this.quickkey) || other.quickkey == _this.quickkey)&&(identical(other.filename, _this.filename) || other.filename == _this.filename)&&(identical(other.size, _this.size) || other.size == _this.size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MediaFireDoUploadDto;
  return Object.hash(runtimeType,_this.key,_this.result,_this.status,_this.description,_this.fileerror,_this.quickkey,_this.filename,_this.size);
}

@override
String toString() {
  final _this = this as MediaFireDoUploadDto;
  return 'MediaFireDoUploadDto(key: ${_this.key}, result: ${_this.result}, status: ${_this.status}, description: ${_this.description}, fileerror: ${_this.fileerror}, quickkey: ${_this.quickkey}, filename: ${_this.filename}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $MediaFireDoUploadDtoCopyWith<$Res>  {
  factory $MediaFireDoUploadDtoCopyWith(MediaFireDoUploadDto value, $Res Function(MediaFireDoUploadDto) _then) = _$MediaFireDoUploadDtoCopyWithImpl;
@useResult
$Res call({
@LenientStringConverter() String? key,@LenientIntConverter() int? result,@LenientIntConverter() int? status,@LenientStringConverter() String? description,@LenientIntConverter() int? fileerror,@LenientStringConverter() String? quickkey,@LenientStringConverter() String? filename,@LenientIntConverter() int? size
});




}
/// @nodoc
class _$MediaFireDoUploadDtoCopyWithImpl<$Res>
    implements $MediaFireDoUploadDtoCopyWith<$Res> {
  _$MediaFireDoUploadDtoCopyWithImpl(this._self, this._then);

  final MediaFireDoUploadDto _self;
  final $Res Function(MediaFireDoUploadDto) _then;

/// Create a copy of MediaFireDoUploadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = freezed,Object? result = freezed,Object? status = freezed,Object? description = freezed,Object? fileerror = freezed,Object? quickkey = freezed,Object? filename = freezed,Object? size = freezed,}) {
  return _then(MediaFireDoUploadDto(
key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileerror: freezed == fileerror ? _self.fileerror : fileerror // ignore: cast_nullable_to_non_nullable
as int?,quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaFireDoUploadDto].
extension MediaFireDoUploadDtoPatterns on MediaFireDoUploadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaFireDoUploadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaFireDoUploadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaFireDoUploadDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaFireDoUploadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaFireDoUploadDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaFireDoUploadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? key, @LenientIntConverter()  int? result, @LenientIntConverter()  int? status, @LenientStringConverter()  String? description, @LenientIntConverter()  int? fileerror, @LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientIntConverter()  int? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaFireDoUploadDto() when $default != null:
return $default(_that.key,_that.result,_that.status,_that.description,_that.fileerror,_that.quickkey,_that.filename,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@LenientStringConverter()  String? key, @LenientIntConverter()  int? result, @LenientIntConverter()  int? status, @LenientStringConverter()  String? description, @LenientIntConverter()  int? fileerror, @LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientIntConverter()  int? size)  $default,) {final _that = this;
switch (_that) {
case _MediaFireDoUploadDto():
return $default(_that.key,_that.result,_that.status,_that.description,_that.fileerror,_that.quickkey,_that.filename,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@LenientStringConverter()  String? key, @LenientIntConverter()  int? result, @LenientIntConverter()  int? status, @LenientStringConverter()  String? description, @LenientIntConverter()  int? fileerror, @LenientStringConverter()  String? quickkey, @LenientStringConverter()  String? filename, @LenientIntConverter()  int? size)?  $default,) {final _that = this;
switch (_that) {
case _MediaFireDoUploadDto() when $default != null:
return $default(_that.key,_that.result,_that.status,_that.description,_that.fileerror,_that.quickkey,_that.filename,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MediaFireDoUploadDto implements MediaFireDoUploadDto {
  const _MediaFireDoUploadDto({@LenientStringConverter() this.key, @LenientIntConverter() this.result, @LenientIntConverter() this.status, @LenientStringConverter() this.description, @LenientIntConverter() this.fileerror, @LenientStringConverter() this.quickkey, @LenientStringConverter() this.filename, @LenientIntConverter() this.size});
  factory _MediaFireDoUploadDto.fromJson(Map<String, dynamic> json) => _$MediaFireDoUploadDtoFromJson(json);

/// Upload key to pass to `upload/poll_upload`.
@override@LenientStringConverter() final  String? key;
/// `0` on success, a negative code otherwise.
@override@LenientIntConverter() final  int? result;
/// Processing status; `99` means finished.
@override@LenientIntConverter() final  int? status;
@override@LenientStringConverter() final  String? description;
/// Non zero when the file was rejected (`15` = storage full, ...).
@override@LenientIntConverter() final  int? fileerror;
@override@LenientStringConverter() final  String? quickkey;
@override@LenientStringConverter() final  String? filename;
@override@LenientIntConverter() final  int? size;

/// Create a copy of MediaFireDoUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaFireDoUploadDtoCopyWith<_MediaFireDoUploadDto> get copyWith => __$MediaFireDoUploadDtoCopyWithImpl<_MediaFireDoUploadDto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaFireDoUploadDto&&(identical(other.key, key) || other.key == key)&&(identical(other.result, result) || other.result == result)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.fileerror, fileerror) || other.fileerror == fileerror)&&(identical(other.quickkey, quickkey) || other.quickkey == quickkey)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,result,status,description,fileerror,quickkey,filename,size);
}

@override
String toString() {
    return 'MediaFireDoUploadDto(key: $key, result: $result, status: $status, description: $description, fileerror: $fileerror, quickkey: $quickkey, filename: $filename, size: $size)';
}


}

/// @nodoc
abstract mixin class _$MediaFireDoUploadDtoCopyWith<$Res> implements $MediaFireDoUploadDtoCopyWith<$Res> {
  factory _$MediaFireDoUploadDtoCopyWith(_MediaFireDoUploadDto value, $Res Function(_MediaFireDoUploadDto) _then) = __$MediaFireDoUploadDtoCopyWithImpl;
@override @useResult
$Res call({
@LenientStringConverter() String? key,@LenientIntConverter() int? result,@LenientIntConverter() int? status,@LenientStringConverter() String? description,@LenientIntConverter() int? fileerror,@LenientStringConverter() String? quickkey,@LenientStringConverter() String? filename,@LenientIntConverter() int? size
});




}
/// @nodoc
class __$MediaFireDoUploadDtoCopyWithImpl<$Res>
    implements _$MediaFireDoUploadDtoCopyWith<$Res> {
  __$MediaFireDoUploadDtoCopyWithImpl(this._self, this._then);

  final _MediaFireDoUploadDto _self;
  final $Res Function(_MediaFireDoUploadDto) _then;

/// Create a copy of MediaFireDoUploadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = freezed,Object? result = freezed,Object? status = freezed,Object? description = freezed,Object? fileerror = freezed,Object? quickkey = freezed,Object? filename = freezed,Object? size = freezed,}) {
  return _then(_MediaFireDoUploadDto(
key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileerror: freezed == fileerror ? _self.fileerror : fileerror // ignore: cast_nullable_to_non_nullable
as int?,quickkey: freezed == quickkey ? _self.quickkey : quickkey // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
