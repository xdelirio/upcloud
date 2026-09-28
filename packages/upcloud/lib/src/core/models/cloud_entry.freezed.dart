// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CloudEntry {

 Object? get id; String get name; DateTime? get createdAt;/// Provider specific data not covered by the common fields.
 Map<String, Object?> get extra;
/// Create a copy of CloudEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudEntryCopyWith<CloudEntry> get copyWith => _$CloudEntryCopyWithImpl<CloudEntry>(this as CloudEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CloudEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudEntry&&const DeepCollectionEquality().equals(other.id, _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.extra, _this.extra));
}


@override
int get hashCode {
  final _this = this as CloudEntry;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.id),_this.name,_this.createdAt,const DeepCollectionEquality().hash(_this.extra));
}

@override
String toString() {
  final _this = this as CloudEntry;
  return 'CloudEntry(id: ${_this.id}, name: ${_this.name}, createdAt: ${_this.createdAt}, extra: ${_this.extra})';
}


}

/// @nodoc
abstract mixin class $CloudEntryCopyWith<$Res>  {
  factory $CloudEntryCopyWith(CloudEntry value, $Res Function(CloudEntry) _then) = _$CloudEntryCopyWithImpl;
@useResult
$Res call({
 String name, DateTime? createdAt, Map<String, Object?> extra
});




}
/// @nodoc
class _$CloudEntryCopyWithImpl<$Res>
    implements $CloudEntryCopyWith<$Res> {
  _$CloudEntryCopyWithImpl(this._self, this._then);

  final CloudEntry _self;
  final $Res Function(CloudEntry) _then;

/// Create a copy of CloudEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? createdAt = freezed,Object? extra = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,extra: null == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CloudEntry].
extension CloudEntryPatterns on CloudEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CloudFile value)?  file,TResult Function( CloudFolder value)?  folder,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CloudFile() when file != null:
return file(_that);case CloudFolder() when folder != null:
return folder(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CloudFile value)  file,required TResult Function( CloudFolder value)  folder,}){
final _that = this;
switch (_that) {
case CloudFile():
return file(_that);case CloudFolder():
return folder(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CloudFile value)?  file,TResult? Function( CloudFolder value)?  folder,}){
final _that = this;
switch (_that) {
case CloudFile() when file != null:
return file(_that);case CloudFolder() when folder != null:
return folder(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( FileId id,  String name,  FolderId? folderId,  DataSize? size,  DateTime? createdAt,  Uri? thumbnailUrl,  Uri? pageUrl,  Duration? duration,  int? views,  bool? isPublic,  bool? isReady,  Map<String, Object?> extra)?  file,TResult Function( FolderId id,  String name,  FolderId? parentId,  DateTime? createdAt,  int? fileCount,  Map<String, Object?> extra)?  folder,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CloudFile() when file != null:
return file(_that.id,_that.name,_that.folderId,_that.size,_that.createdAt,_that.thumbnailUrl,_that.pageUrl,_that.duration,_that.views,_that.isPublic,_that.isReady,_that.extra);case CloudFolder() when folder != null:
return folder(_that.id,_that.name,_that.parentId,_that.createdAt,_that.fileCount,_that.extra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( FileId id,  String name,  FolderId? folderId,  DataSize? size,  DateTime? createdAt,  Uri? thumbnailUrl,  Uri? pageUrl,  Duration? duration,  int? views,  bool? isPublic,  bool? isReady,  Map<String, Object?> extra)  file,required TResult Function( FolderId id,  String name,  FolderId? parentId,  DateTime? createdAt,  int? fileCount,  Map<String, Object?> extra)  folder,}) {final _that = this;
switch (_that) {
case CloudFile():
return file(_that.id,_that.name,_that.folderId,_that.size,_that.createdAt,_that.thumbnailUrl,_that.pageUrl,_that.duration,_that.views,_that.isPublic,_that.isReady,_that.extra);case CloudFolder():
return folder(_that.id,_that.name,_that.parentId,_that.createdAt,_that.fileCount,_that.extra);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( FileId id,  String name,  FolderId? folderId,  DataSize? size,  DateTime? createdAt,  Uri? thumbnailUrl,  Uri? pageUrl,  Duration? duration,  int? views,  bool? isPublic,  bool? isReady,  Map<String, Object?> extra)?  file,TResult? Function( FolderId id,  String name,  FolderId? parentId,  DateTime? createdAt,  int? fileCount,  Map<String, Object?> extra)?  folder,}) {final _that = this;
switch (_that) {
case CloudFile() when file != null:
return file(_that.id,_that.name,_that.folderId,_that.size,_that.createdAt,_that.thumbnailUrl,_that.pageUrl,_that.duration,_that.views,_that.isPublic,_that.isReady,_that.extra);case CloudFolder() when folder != null:
return folder(_that.id,_that.name,_that.parentId,_that.createdAt,_that.fileCount,_that.extra);case _:
  return null;

}
}

}

/// @nodoc


class CloudFile implements CloudEntry {
  const CloudFile({required this.id, required this.name, this.folderId, this.size, this.createdAt, this.thumbnailUrl, this.pageUrl, this.duration, this.views, this.isPublic, this.isReady,  Map<String, Object?> extra = const <String, Object?>{}}): _extra = extra;
  

@override final  FileId id;
@override final  String name;
/// Folder that contains the file, `null` for the root folder.
 final  FolderId? folderId;
 final  DataSize? size;
@override final  DateTime? createdAt;
/// Preview image, when the provider generates one.
 final  Uri? thumbnailUrl;
/// Link to share the file: its public watch/download page.
 final  Uri? pageUrl;
/// Playback length for video/audio files.
 final  Duration? duration;
 final  int? views;
 final  bool? isPublic;
/// Whether the file finished processing and can be played/downloaded.
 final  bool? isReady;
/// Provider specific data not covered by the common fields.
 final  Map<String, Object?> _extra;
/// Provider specific data not covered by the common fields.
@override@JsonKey() Map<String, Object?> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}


/// Create a copy of CloudEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudFileCopyWith<CloudFile> get copyWith => _$CloudFileCopyWithImpl<CloudFile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.size, size) || other.size == size)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.pageUrl, pageUrl) || other.pageUrl == pageUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.views, views) || other.views == views)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&const DeepCollectionEquality().equals(other.extra, _extra));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,folderId,size,createdAt,thumbnailUrl,pageUrl,duration,views,isPublic,isReady,const DeepCollectionEquality().hash(_extra));
}

@override
String toString() {
    return 'CloudEntry.file(id: $id, name: $name, folderId: $folderId, size: $size, createdAt: $createdAt, thumbnailUrl: $thumbnailUrl, pageUrl: $pageUrl, duration: $duration, views: $views, isPublic: $isPublic, isReady: $isReady, extra: $extra)';
}


}

/// @nodoc
abstract mixin class $CloudFileCopyWith<$Res> implements $CloudEntryCopyWith<$Res> {
  factory $CloudFileCopyWith(CloudFile value, $Res Function(CloudFile) _then) = _$CloudFileCopyWithImpl;
@override @useResult
$Res call({
 FileId id, String name, FolderId? folderId, DataSize? size, DateTime? createdAt, Uri? thumbnailUrl, Uri? pageUrl, Duration? duration, int? views, bool? isPublic, bool? isReady, Map<String, Object?> extra
});




}
/// @nodoc
class _$CloudFileCopyWithImpl<$Res>
    implements $CloudFileCopyWith<$Res> {
  _$CloudFileCopyWithImpl(this._self, this._then);

  final CloudFile _self;
  final $Res Function(CloudFile) _then;

/// Create a copy of CloudEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? folderId = freezed,Object? size = freezed,Object? createdAt = freezed,Object? thumbnailUrl = freezed,Object? pageUrl = freezed,Object? duration = freezed,Object? views = freezed,Object? isPublic = freezed,Object? isReady = freezed,Object? extra = null,}) {
  return _then(CloudFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FileId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as FolderId?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as DataSize?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as Uri?,pageUrl: freezed == pageUrl ? _self.pageUrl : pageUrl // ignore: cast_nullable_to_non_nullable
as Uri?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,views: freezed == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,isReady: freezed == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool?,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

/// @nodoc


class CloudFolder implements CloudEntry {
  const CloudFolder({required this.id, required this.name, this.parentId, this.createdAt, this.fileCount,  Map<String, Object?> extra = const <String, Object?>{}}): _extra = extra;
  

@override final  FolderId id;
@override final  String name;
/// Parent folder, `null` for the root folder.
 final  FolderId? parentId;
@override final  DateTime? createdAt;
/// Number of files inside, when the provider reports it.
 final  int? fileCount;
/// Provider specific data not covered by the common fields.
 final  Map<String, Object?> _extra;
/// Provider specific data not covered by the common fields.
@override@JsonKey() Map<String, Object?> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}


/// Create a copy of CloudEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudFolderCopyWith<CloudFolder> get copyWith => _$CloudFolderCopyWithImpl<CloudFolder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.fileCount, fileCount) || other.fileCount == fileCount)&&const DeepCollectionEquality().equals(other.extra, _extra));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,parentId,createdAt,fileCount,const DeepCollectionEquality().hash(_extra));
}

@override
String toString() {
    return 'CloudEntry.folder(id: $id, name: $name, parentId: $parentId, createdAt: $createdAt, fileCount: $fileCount, extra: $extra)';
}


}

/// @nodoc
abstract mixin class $CloudFolderCopyWith<$Res> implements $CloudEntryCopyWith<$Res> {
  factory $CloudFolderCopyWith(CloudFolder value, $Res Function(CloudFolder) _then) = _$CloudFolderCopyWithImpl;
@override @useResult
$Res call({
 FolderId id, String name, FolderId? parentId, DateTime? createdAt, int? fileCount, Map<String, Object?> extra
});




}
/// @nodoc
class _$CloudFolderCopyWithImpl<$Res>
    implements $CloudFolderCopyWith<$Res> {
  _$CloudFolderCopyWithImpl(this._self, this._then);

  final CloudFolder _self;
  final $Res Function(CloudFolder) _then;

/// Create a copy of CloudEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? parentId = freezed,Object? createdAt = freezed,Object? fileCount = freezed,Object? extra = null,}) {
  return _then(CloudFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FolderId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as FolderId?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fileCount: freezed == fileCount ? _self.fileCount : fileCount // ignore: cast_nullable_to_non_nullable
as int?,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
