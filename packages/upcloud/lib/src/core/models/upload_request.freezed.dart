// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadRequest {

/// Where the file is sent, including any query parameter.
 Uri get url;/// HTTP method.
 String get method;/// How the file is sent.
 UploadEncoding get encoding;/// Name of the multipart part that carries the file.
 String get fileField;/// Form fields sent before the file (multipart only).
 Map<String, String> get fields;/// HTTP headers.
 Map<String, String> get headers;/// Opaque data of the provider, needed by
/// `FileUploading.completeUpload`. Executors must not send it.
 Map<String, String> get context;
/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadRequestCopyWith<UploadRequest> get copyWith => _$UploadRequestCopyWithImpl<UploadRequest>(this as UploadRequest, _$identity);

  /// Serializes this UploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadRequest&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding)&&(identical(other.fileField, _this.fileField) || other.fileField == _this.fileField)&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&const DeepCollectionEquality().equals(other.headers, _this.headers)&&const DeepCollectionEquality().equals(other.context, _this.context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadRequest;
  return Object.hash(runtimeType,_this.url,_this.method,_this.encoding,_this.fileField,const DeepCollectionEquality().hash(_this.fields),const DeepCollectionEquality().hash(_this.headers),const DeepCollectionEquality().hash(_this.context));
}

@override
String toString() {
  final _this = this as UploadRequest;
  return 'UploadRequest(url: ${_this.url}, method: ${_this.method}, encoding: ${_this.encoding}, fileField: ${_this.fileField}, fields: ${_this.fields}, headers: ${_this.headers}, context: ${_this.context})';
}


}

/// @nodoc
abstract mixin class $UploadRequestCopyWith<$Res>  {
  factory $UploadRequestCopyWith(UploadRequest value, $Res Function(UploadRequest) _then) = _$UploadRequestCopyWithImpl;
@useResult
$Res call({
 Uri url, String method, UploadEncoding encoding, String fileField, Map<String, String> fields, Map<String, String> headers, Map<String, String> context
});




}
/// @nodoc
class _$UploadRequestCopyWithImpl<$Res>
    implements $UploadRequestCopyWith<$Res> {
  _$UploadRequestCopyWithImpl(this._self, this._then);

  final UploadRequest _self;
  final $Res Function(UploadRequest) _then;

/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? method = null,Object? encoding = null,Object? fileField = null,Object? fields = null,Object? headers = null,Object? context = null,}) {
  return _then(UploadRequest(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,encoding: null == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as UploadEncoding,fileField: null == fileField ? _self.fileField : fileField // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadRequest].
extension UploadRequestPatterns on UploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _UploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri url,  String method,  UploadEncoding encoding,  String fileField,  Map<String, String> fields,  Map<String, String> headers,  Map<String, String> context)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
return $default(_that.url,_that.method,_that.encoding,_that.fileField,_that.fields,_that.headers,_that.context);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri url,  String method,  UploadEncoding encoding,  String fileField,  Map<String, String> fields,  Map<String, String> headers,  Map<String, String> context)  $default,) {final _that = this;
switch (_that) {
case _UploadRequest():
return $default(_that.url,_that.method,_that.encoding,_that.fileField,_that.fields,_that.headers,_that.context);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri url,  String method,  UploadEncoding encoding,  String fileField,  Map<String, String> fields,  Map<String, String> headers,  Map<String, String> context)?  $default,) {final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
return $default(_that.url,_that.method,_that.encoding,_that.fileField,_that.fields,_that.headers,_that.context);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadRequest implements UploadRequest {
  const _UploadRequest({required this.url, this.method = 'POST', this.encoding = UploadEncoding.multipart, this.fileField = 'file',  Map<String, String> fields = const <String, String>{},  Map<String, String> headers = const <String, String>{},  Map<String, String> context = const <String, String>{}}): _fields = fields,_headers = headers,_context = context;
  factory _UploadRequest.fromJson(Map<String, dynamic> json) => _$UploadRequestFromJson(json);

/// Where the file is sent, including any query parameter.
@override final  Uri url;
/// HTTP method.
@override@JsonKey() final  String method;
/// How the file is sent.
@override@JsonKey() final  UploadEncoding encoding;
/// Name of the multipart part that carries the file.
@override@JsonKey() final  String fileField;
/// Form fields sent before the file (multipart only).
 final  Map<String, String> _fields;
/// Form fields sent before the file (multipart only).
@override@JsonKey() Map<String, String> get fields {
  if (_fields is EqualUnmodifiableMapView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fields);
}

/// HTTP headers.
 final  Map<String, String> _headers;
/// HTTP headers.
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

/// Opaque data of the provider, needed by
/// `FileUploading.completeUpload`. Executors must not send it.
 final  Map<String, String> _context;
/// Opaque data of the provider, needed by
/// `FileUploading.completeUpload`. Executors must not send it.
@override@JsonKey() Map<String, String> get context {
  if (_context is EqualUnmodifiableMapView) return _context;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_context);
}


/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadRequestCopyWith<_UploadRequest> get copyWith => __$UploadRequestCopyWithImpl<_UploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadRequest&&(identical(other.url, url) || other.url == url)&&(identical(other.method, method) || other.method == method)&&(identical(other.encoding, encoding) || other.encoding == encoding)&&(identical(other.fileField, fileField) || other.fileField == fileField)&&const DeepCollectionEquality().equals(other.fields, _fields)&&const DeepCollectionEquality().equals(other.headers, _headers)&&const DeepCollectionEquality().equals(other.context, _context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,method,encoding,fileField,const DeepCollectionEquality().hash(_fields),const DeepCollectionEquality().hash(_headers),const DeepCollectionEquality().hash(_context));
}

@override
String toString() {
    return 'UploadRequest(url: $url, method: $method, encoding: $encoding, fileField: $fileField, fields: $fields, headers: $headers, context: $context)';
}


}

/// @nodoc
abstract mixin class _$UploadRequestCopyWith<$Res> implements $UploadRequestCopyWith<$Res> {
  factory _$UploadRequestCopyWith(_UploadRequest value, $Res Function(_UploadRequest) _then) = __$UploadRequestCopyWithImpl;
@override @useResult
$Res call({
 Uri url, String method, UploadEncoding encoding, String fileField, Map<String, String> fields, Map<String, String> headers, Map<String, String> context
});




}
/// @nodoc
class __$UploadRequestCopyWithImpl<$Res>
    implements _$UploadRequestCopyWith<$Res> {
  __$UploadRequestCopyWithImpl(this._self, this._then);

  final _UploadRequest _self;
  final $Res Function(_UploadRequest) _then;

/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? method = null,Object? encoding = null,Object? fileField = null,Object? fields = null,Object? headers = null,Object? context = null,}) {
  return _then(_UploadRequest(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,encoding: null == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as UploadEncoding,fileField: null == fileField ? _self.fileField : fileField // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,context: null == context ? _self._context : context // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$UploadResponse {

/// HTTP status code.
 int get statusCode;/// Body decoded as text (usually JSON).
 String get body;/// Response headers.
 Map<String, String> get headers;
/// Create a copy of UploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadResponseCopyWith<UploadResponse> get copyWith => _$UploadResponseCopyWithImpl<UploadResponse>(this as UploadResponse, _$identity);

  /// Serializes this UploadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadResponse&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.body, _this.body) || other.body == _this.body)&&const DeepCollectionEquality().equals(other.headers, _this.headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadResponse;
  return Object.hash(runtimeType,_this.statusCode,_this.body,const DeepCollectionEquality().hash(_this.headers));
}

@override
String toString() {
  final _this = this as UploadResponse;
  return 'UploadResponse(statusCode: ${_this.statusCode}, body: ${_this.body}, headers: ${_this.headers})';
}


}

/// @nodoc
abstract mixin class $UploadResponseCopyWith<$Res>  {
  factory $UploadResponseCopyWith(UploadResponse value, $Res Function(UploadResponse) _then) = _$UploadResponseCopyWithImpl;
@useResult
$Res call({
 int statusCode, String body, Map<String, String> headers
});




}
/// @nodoc
class _$UploadResponseCopyWithImpl<$Res>
    implements $UploadResponseCopyWith<$Res> {
  _$UploadResponseCopyWithImpl(this._self, this._then);

  final UploadResponse _self;
  final $Res Function(UploadResponse) _then;

/// Create a copy of UploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? body = null,Object? headers = null,}) {
  return _then(UploadResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadResponse].
extension UploadResponsePatterns on UploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _UploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int statusCode,  String body,  Map<String, String> headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadResponse() when $default != null:
return $default(_that.statusCode,_that.body,_that.headers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int statusCode,  String body,  Map<String, String> headers)  $default,) {final _that = this;
switch (_that) {
case _UploadResponse():
return $default(_that.statusCode,_that.body,_that.headers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int statusCode,  String body,  Map<String, String> headers)?  $default,) {final _that = this;
switch (_that) {
case _UploadResponse() when $default != null:
return $default(_that.statusCode,_that.body,_that.headers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadResponse extends UploadResponse {
  const _UploadResponse({required this.statusCode, required this.body,  Map<String, String> headers = const <String, String>{}}): _headers = headers,super._();
  factory _UploadResponse.fromJson(Map<String, dynamic> json) => _$UploadResponseFromJson(json);

/// HTTP status code.
@override final  int statusCode;
/// Body decoded as text (usually JSON).
@override final  String body;
/// Response headers.
 final  Map<String, String> _headers;
/// Response headers.
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}


/// Create a copy of UploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadResponseCopyWith<_UploadResponse> get copyWith => __$UploadResponseCopyWithImpl<_UploadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,body,const DeepCollectionEquality().hash(_headers));
}

@override
String toString() {
    return 'UploadResponse(statusCode: $statusCode, body: $body, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$UploadResponseCopyWith<$Res> implements $UploadResponseCopyWith<$Res> {
  factory _$UploadResponseCopyWith(_UploadResponse value, $Res Function(_UploadResponse) _then) = __$UploadResponseCopyWithImpl;
@override @useResult
$Res call({
 int statusCode, String body, Map<String, String> headers
});




}
/// @nodoc
class __$UploadResponseCopyWithImpl<$Res>
    implements _$UploadResponseCopyWith<$Res> {
  __$UploadResponseCopyWithImpl(this._self, this._then);

  final _UploadResponse _self;
  final $Res Function(_UploadResponse) _then;

/// Create a copy of UploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? body = null,Object? headers = null,}) {
  return _then(_UploadResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
