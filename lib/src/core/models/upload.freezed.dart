// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadFileInfo {

/// File name sent to the provider.
 String get name;/// Size in bytes, `null` when unknown.
 int? get size;
/// Create a copy of UploadFileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadFileInfoCopyWith<UploadFileInfo> get copyWith => _$UploadFileInfoCopyWithImpl<UploadFileInfo>(this as UploadFileInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UploadFileInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadFileInfo&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.size, _this.size) || other.size == _this.size));
}


@override
int get hashCode {
  final _this = this as UploadFileInfo;
  return Object.hash(runtimeType,_this.name,_this.size);
}

@override
String toString() {
  final _this = this as UploadFileInfo;
  return 'UploadFileInfo(name: ${_this.name}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $UploadFileInfoCopyWith<$Res>  {
  factory $UploadFileInfoCopyWith(UploadFileInfo value, $Res Function(UploadFileInfo) _then) = _$UploadFileInfoCopyWithImpl;
@useResult
$Res call({
 String name, int? size
});




}
/// @nodoc
class _$UploadFileInfoCopyWithImpl<$Res>
    implements $UploadFileInfoCopyWith<$Res> {
  _$UploadFileInfoCopyWithImpl(this._self, this._then);

  final UploadFileInfo _self;
  final $Res Function(UploadFileInfo) _then;

/// Create a copy of UploadFileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? size = freezed,}) {
  return _then(UploadFileInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadFileInfo].
extension UploadFileInfoPatterns on UploadFileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadFileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadFileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadFileInfo value)  $default,){
final _that = this;
switch (_that) {
case _UploadFileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadFileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UploadFileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadFileInfo() when $default != null:
return $default(_that.name,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int? size)  $default,) {final _that = this;
switch (_that) {
case _UploadFileInfo():
return $default(_that.name,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int? size)?  $default,) {final _that = this;
switch (_that) {
case _UploadFileInfo() when $default != null:
return $default(_that.name,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _UploadFileInfo extends UploadFileInfo {
  const _UploadFileInfo({required this.name, this.size}): super._();
  

/// File name sent to the provider.
@override final  String name;
/// Size in bytes, `null` when unknown.
@override final  int? size;

/// Create a copy of UploadFileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadFileInfoCopyWith<_UploadFileInfo> get copyWith => __$UploadFileInfoCopyWithImpl<_UploadFileInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadFileInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,size);
}

@override
String toString() {
    return 'UploadFileInfo(name: $name, size: $size)';
}


}

/// @nodoc
abstract mixin class _$UploadFileInfoCopyWith<$Res> implements $UploadFileInfoCopyWith<$Res> {
  factory _$UploadFileInfoCopyWith(_UploadFileInfo value, $Res Function(_UploadFileInfo) _then) = __$UploadFileInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, int? size
});




}
/// @nodoc
class __$UploadFileInfoCopyWithImpl<$Res>
    implements _$UploadFileInfoCopyWith<$Res> {
  __$UploadFileInfoCopyWithImpl(this._self, this._then);

  final _UploadFileInfo _self;
  final $Res Function(_UploadFileInfo) _then;

/// Create a copy of UploadFileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? size = freezed,}) {
  return _then(_UploadFileInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$UploadOptions {

/// Destination folder, `null` for the root folder.
 FolderId? get folderId;/// Title shown by the provider. Defaults to the file name.
 String? get title; String? get description;/// Visibility of the file. When `null`, the visibility given to the
/// upload or the default one of the upload settings applies (which may
/// keep the provider default).
 bool? get isPublic; bool? get isAdult; List<String> get tags;/// Extra provider specific form fields, sent as-is.
 Map<String, String> get fields;
/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadOptionsCopyWith<UploadOptions> get copyWith => _$UploadOptionsCopyWithImpl<UploadOptions>(this as UploadOptions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UploadOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadOptions&&(identical(other.folderId, _this.folderId) || other.folderId == _this.folderId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.isPublic, _this.isPublic) || other.isPublic == _this.isPublic)&&(identical(other.isAdult, _this.isAdult) || other.isAdult == _this.isAdult)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&const DeepCollectionEquality().equals(other.fields, _this.fields));
}


@override
int get hashCode {
  final _this = this as UploadOptions;
  return Object.hash(runtimeType,_this.folderId,_this.title,_this.description,_this.isPublic,_this.isAdult,const DeepCollectionEquality().hash(_this.tags),const DeepCollectionEquality().hash(_this.fields));
}

@override
String toString() {
  final _this = this as UploadOptions;
  return 'UploadOptions(folderId: ${_this.folderId}, title: ${_this.title}, description: ${_this.description}, isPublic: ${_this.isPublic}, isAdult: ${_this.isAdult}, tags: ${_this.tags}, fields: ${_this.fields})';
}


}

/// @nodoc
abstract mixin class $UploadOptionsCopyWith<$Res>  {
  factory $UploadOptionsCopyWith(UploadOptions value, $Res Function(UploadOptions) _then) = _$UploadOptionsCopyWithImpl;
@useResult
$Res call({
 FolderId? folderId, String? title, String? description, bool? isPublic, bool? isAdult, List<String> tags, Map<String, String> fields
});




}
/// @nodoc
class _$UploadOptionsCopyWithImpl<$Res>
    implements $UploadOptionsCopyWith<$Res> {
  _$UploadOptionsCopyWithImpl(this._self, this._then);

  final UploadOptions _self;
  final $Res Function(UploadOptions) _then;

/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folderId = freezed,Object? title = freezed,Object? description = freezed,Object? isPublic = freezed,Object? isAdult = freezed,Object? tags = null,Object? fields = null,}) {
  return _then(UploadOptions(
folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as FolderId?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,isAdult: freezed == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadOptions].
extension UploadOptionsPatterns on UploadOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadOptions value)  $default,){
final _that = this;
switch (_that) {
case _UploadOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadOptions value)?  $default,){
final _that = this;
switch (_that) {
case _UploadOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FolderId? folderId,  String? title,  String? description,  bool? isPublic,  bool? isAdult,  List<String> tags,  Map<String, String> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadOptions() when $default != null:
return $default(_that.folderId,_that.title,_that.description,_that.isPublic,_that.isAdult,_that.tags,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FolderId? folderId,  String? title,  String? description,  bool? isPublic,  bool? isAdult,  List<String> tags,  Map<String, String> fields)  $default,) {final _that = this;
switch (_that) {
case _UploadOptions():
return $default(_that.folderId,_that.title,_that.description,_that.isPublic,_that.isAdult,_that.tags,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FolderId? folderId,  String? title,  String? description,  bool? isPublic,  bool? isAdult,  List<String> tags,  Map<String, String> fields)?  $default,) {final _that = this;
switch (_that) {
case _UploadOptions() when $default != null:
return $default(_that.folderId,_that.title,_that.description,_that.isPublic,_that.isAdult,_that.tags,_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _UploadOptions implements UploadOptions {
  const _UploadOptions({this.folderId, this.title, this.description, this.isPublic, this.isAdult,  List<String> tags = const <String>[],  Map<String, String> fields = const <String, String>{}}): _tags = tags,_fields = fields;
  

/// Destination folder, `null` for the root folder.
@override final  FolderId? folderId;
/// Title shown by the provider. Defaults to the file name.
@override final  String? title;
@override final  String? description;
/// Visibility of the file. When `null`, the visibility given to the
/// upload or the default one of the upload settings applies (which may
/// keep the provider default).
@override final  bool? isPublic;
@override final  bool? isAdult;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Extra provider specific form fields, sent as-is.
 final  Map<String, String> _fields;
/// Extra provider specific form fields, sent as-is.
@override@JsonKey() Map<String, String> get fields {
  if (_fields is EqualUnmodifiableMapView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fields);
}


/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadOptionsCopyWith<_UploadOptions> get copyWith => __$UploadOptionsCopyWithImpl<_UploadOptions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadOptions&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isAdult, isAdult) || other.isAdult == isAdult)&&const DeepCollectionEquality().equals(other.tags, _tags)&&const DeepCollectionEquality().equals(other.fields, _fields));
}


@override
int get hashCode {
    return Object.hash(runtimeType,folderId,title,description,isPublic,isAdult,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_fields));
}

@override
String toString() {
    return 'UploadOptions(folderId: $folderId, title: $title, description: $description, isPublic: $isPublic, isAdult: $isAdult, tags: $tags, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$UploadOptionsCopyWith<$Res> implements $UploadOptionsCopyWith<$Res> {
  factory _$UploadOptionsCopyWith(_UploadOptions value, $Res Function(_UploadOptions) _then) = __$UploadOptionsCopyWithImpl;
@override @useResult
$Res call({
 FolderId? folderId, String? title, String? description, bool? isPublic, bool? isAdult, List<String> tags, Map<String, String> fields
});




}
/// @nodoc
class __$UploadOptionsCopyWithImpl<$Res>
    implements _$UploadOptionsCopyWith<$Res> {
  __$UploadOptionsCopyWithImpl(this._self, this._then);

  final _UploadOptions _self;
  final $Res Function(_UploadOptions) _then;

/// Create a copy of UploadOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folderId = freezed,Object? title = freezed,Object? description = freezed,Object? isPublic = freezed,Object? isAdult = freezed,Object? tags = null,Object? fields = null,}) {
  return _then(_UploadOptions(
folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as FolderId?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPublic: freezed == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool?,isAdult: freezed == isAdult ? _self.isAdult : isAdult // ignore: cast_nullable_to_non_nullable
as bool?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$TransferProgress {

 int get transferred;/// Total bytes, `null` when unknown.
 int? get total;
/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferProgressCopyWith<TransferProgress> get copyWith => _$TransferProgressCopyWithImpl<TransferProgress>(this as TransferProgress, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransferProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferProgress&&(identical(other.transferred, _this.transferred) || other.transferred == _this.transferred)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as TransferProgress;
  return Object.hash(runtimeType,_this.transferred,_this.total);
}

@override
String toString() {
  final _this = this as TransferProgress;
  return 'TransferProgress(transferred: ${_this.transferred}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $TransferProgressCopyWith<$Res>  {
  factory $TransferProgressCopyWith(TransferProgress value, $Res Function(TransferProgress) _then) = _$TransferProgressCopyWithImpl;
@useResult
$Res call({
 int transferred, int? total
});




}
/// @nodoc
class _$TransferProgressCopyWithImpl<$Res>
    implements $TransferProgressCopyWith<$Res> {
  _$TransferProgressCopyWithImpl(this._self, this._then);

  final TransferProgress _self;
  final $Res Function(TransferProgress) _then;

/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transferred = null,Object? total = freezed,}) {
  return _then(TransferProgress(
transferred: null == transferred ? _self.transferred : transferred // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferProgress].
extension TransferProgressPatterns on TransferProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferProgress value)  $default,){
final _that = this;
switch (_that) {
case _TransferProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferProgress value)?  $default,){
final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int transferred,  int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
return $default(_that.transferred,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int transferred,  int? total)  $default,) {final _that = this;
switch (_that) {
case _TransferProgress():
return $default(_that.transferred,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int transferred,  int? total)?  $default,) {final _that = this;
switch (_that) {
case _TransferProgress() when $default != null:
return $default(_that.transferred,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _TransferProgress extends TransferProgress {
  const _TransferProgress({required this.transferred, this.total}): super._();
  

@override final  int transferred;
/// Total bytes, `null` when unknown.
@override final  int? total;

/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferProgressCopyWith<_TransferProgress> get copyWith => __$TransferProgressCopyWithImpl<_TransferProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferProgress&&(identical(other.transferred, transferred) || other.transferred == transferred)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,transferred,total);
}

@override
String toString() {
    return 'TransferProgress(transferred: $transferred, total: $total)';
}


}

/// @nodoc
abstract mixin class _$TransferProgressCopyWith<$Res> implements $TransferProgressCopyWith<$Res> {
  factory _$TransferProgressCopyWith(_TransferProgress value, $Res Function(_TransferProgress) _then) = __$TransferProgressCopyWithImpl;
@override @useResult
$Res call({
 int transferred, int? total
});




}
/// @nodoc
class __$TransferProgressCopyWithImpl<$Res>
    implements _$TransferProgressCopyWith<$Res> {
  __$TransferProgressCopyWithImpl(this._self, this._then);

  final _TransferProgress _self;
  final $Res Function(_TransferProgress) _then;

/// Create a copy of TransferProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transferred = null,Object? total = freezed,}) {
  return _then(_TransferProgress(
transferred: null == transferred ? _self.transferred : transferred // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
