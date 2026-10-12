// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_upload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteUploadJob {

/// Identifier of the job. Many providers use the future file id.
 String get id; RemoteUploadStatus get status;/// Id of the resulting file, if already known.
 FileId? get fileId; Uri? get sourceUrl; FolderId? get folderId;/// Progress between 0 and 1, if reported.
 double? get progress; String? get error;/// Provider specific data not covered by the common fields.
 Map<String, Object?> get extra;
/// Create a copy of RemoteUploadJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteUploadJobCopyWith<RemoteUploadJob> get copyWith => _$RemoteUploadJobCopyWithImpl<RemoteUploadJob>(this as RemoteUploadJob, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RemoteUploadJob;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteUploadJob&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.fileId, _this.fileId) || other.fileId == _this.fileId)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.folderId, _this.folderId) || other.folderId == _this.folderId)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.extra, _this.extra));
}


@override
int get hashCode {
  final _this = this as RemoteUploadJob;
  return Object.hash(runtimeType,_this.id,_this.status,_this.fileId,_this.sourceUrl,_this.folderId,_this.progress,_this.error,const DeepCollectionEquality().hash(_this.extra));
}

@override
String toString() {
  final _this = this as RemoteUploadJob;
  return 'RemoteUploadJob(id: ${_this.id}, status: ${_this.status}, fileId: ${_this.fileId}, sourceUrl: ${_this.sourceUrl}, folderId: ${_this.folderId}, progress: ${_this.progress}, error: ${_this.error}, extra: ${_this.extra})';
}


}

/// @nodoc
abstract mixin class $RemoteUploadJobCopyWith<$Res>  {
  factory $RemoteUploadJobCopyWith(RemoteUploadJob value, $Res Function(RemoteUploadJob) _then) = _$RemoteUploadJobCopyWithImpl;
@useResult
$Res call({
 String id, RemoteUploadStatus status, FileId? fileId, Uri? sourceUrl, FolderId? folderId, double? progress, String? error, Map<String, Object?> extra
});




}
/// @nodoc
class _$RemoteUploadJobCopyWithImpl<$Res>
    implements $RemoteUploadJobCopyWith<$Res> {
  _$RemoteUploadJobCopyWithImpl(this._self, this._then);

  final RemoteUploadJob _self;
  final $Res Function(RemoteUploadJob) _then;

/// Create a copy of RemoteUploadJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? fileId = freezed,Object? sourceUrl = freezed,Object? folderId = freezed,Object? progress = freezed,Object? error = freezed,Object? extra = null,}) {
  return _then(RemoteUploadJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RemoteUploadStatus,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as FileId?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as Uri?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as FolderId?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,extra: null == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteUploadJob].
extension RemoteUploadJobPatterns on RemoteUploadJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteUploadJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteUploadJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteUploadJob value)  $default,){
final _that = this;
switch (_that) {
case _RemoteUploadJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteUploadJob value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteUploadJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RemoteUploadStatus status,  FileId? fileId,  Uri? sourceUrl,  FolderId? folderId,  double? progress,  String? error,  Map<String, Object?> extra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteUploadJob() when $default != null:
return $default(_that.id,_that.status,_that.fileId,_that.sourceUrl,_that.folderId,_that.progress,_that.error,_that.extra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RemoteUploadStatus status,  FileId? fileId,  Uri? sourceUrl,  FolderId? folderId,  double? progress,  String? error,  Map<String, Object?> extra)  $default,) {final _that = this;
switch (_that) {
case _RemoteUploadJob():
return $default(_that.id,_that.status,_that.fileId,_that.sourceUrl,_that.folderId,_that.progress,_that.error,_that.extra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RemoteUploadStatus status,  FileId? fileId,  Uri? sourceUrl,  FolderId? folderId,  double? progress,  String? error,  Map<String, Object?> extra)?  $default,) {final _that = this;
switch (_that) {
case _RemoteUploadJob() when $default != null:
return $default(_that.id,_that.status,_that.fileId,_that.sourceUrl,_that.folderId,_that.progress,_that.error,_that.extra);case _:
  return null;

}
}

}

/// @nodoc


class _RemoteUploadJob implements RemoteUploadJob {
  const _RemoteUploadJob({required this.id, this.status = RemoteUploadStatus.pending, this.fileId, this.sourceUrl, this.folderId, this.progress, this.error,  Map<String, Object?> extra = const <String, Object?>{}}): _extra = extra;
  

/// Identifier of the job. Many providers use the future file id.
@override final  String id;
@override@JsonKey() final  RemoteUploadStatus status;
/// Id of the resulting file, if already known.
@override final  FileId? fileId;
@override final  Uri? sourceUrl;
@override final  FolderId? folderId;
/// Progress between 0 and 1, if reported.
@override final  double? progress;
@override final  String? error;
/// Provider specific data not covered by the common fields.
 final  Map<String, Object?> _extra;
/// Provider specific data not covered by the common fields.
@override@JsonKey() Map<String, Object?> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}


/// Create a copy of RemoteUploadJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteUploadJobCopyWith<_RemoteUploadJob> get copyWith => __$RemoteUploadJobCopyWithImpl<_RemoteUploadJob>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteUploadJob&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.extra, _extra));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,status,fileId,sourceUrl,folderId,progress,error,const DeepCollectionEquality().hash(_extra));
}

@override
String toString() {
    return 'RemoteUploadJob(id: $id, status: $status, fileId: $fileId, sourceUrl: $sourceUrl, folderId: $folderId, progress: $progress, error: $error, extra: $extra)';
}


}

/// @nodoc
abstract mixin class _$RemoteUploadJobCopyWith<$Res> implements $RemoteUploadJobCopyWith<$Res> {
  factory _$RemoteUploadJobCopyWith(_RemoteUploadJob value, $Res Function(_RemoteUploadJob) _then) = __$RemoteUploadJobCopyWithImpl;
@override @useResult
$Res call({
 String id, RemoteUploadStatus status, FileId? fileId, Uri? sourceUrl, FolderId? folderId, double? progress, String? error, Map<String, Object?> extra
});




}
/// @nodoc
class __$RemoteUploadJobCopyWithImpl<$Res>
    implements _$RemoteUploadJobCopyWith<$Res> {
  __$RemoteUploadJobCopyWithImpl(this._self, this._then);

  final _RemoteUploadJob _self;
  final $Res Function(_RemoteUploadJob) _then;

/// Create a copy of RemoteUploadJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? fileId = freezed,Object? sourceUrl = freezed,Object? folderId = freezed,Object? progress = freezed,Object? error = freezed,Object? extra = null,}) {
  return _then(_RemoteUploadJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RemoteUploadStatus,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as FileId?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as Uri?,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as FolderId?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
