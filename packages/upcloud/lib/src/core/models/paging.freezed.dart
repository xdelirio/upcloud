// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paging.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PageRequest {

 int get page; int get perPage;
/// Create a copy of PageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageRequestCopyWith<PageRequest> get copyWith => _$PageRequestCopyWithImpl<PageRequest>(this as PageRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PageRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageRequest&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.perPage, _this.perPage) || other.perPage == _this.perPage));
}


@override
int get hashCode {
  final _this = this as PageRequest;
  return Object.hash(runtimeType,_this.page,_this.perPage);
}

@override
String toString() {
  final _this = this as PageRequest;
  return 'PageRequest(page: ${_this.page}, perPage: ${_this.perPage})';
}


}

/// @nodoc
abstract mixin class $PageRequestCopyWith<$Res>  {
  factory $PageRequestCopyWith(PageRequest value, $Res Function(PageRequest) _then) = _$PageRequestCopyWithImpl;
@useResult
$Res call({
 int page, int perPage
});




}
/// @nodoc
class _$PageRequestCopyWithImpl<$Res>
    implements $PageRequestCopyWith<$Res> {
  _$PageRequestCopyWithImpl(this._self, this._then);

  final PageRequest _self;
  final $Res Function(PageRequest) _then;

/// Create a copy of PageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? perPage = null,}) {
  return _then(PageRequest(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PageRequest].
extension PageRequestPatterns on PageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageRequest value)  $default,){
final _that = this;
switch (_that) {
case _PageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  int perPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageRequest() when $default != null:
return $default(_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  int perPage)  $default,) {final _that = this;
switch (_that) {
case _PageRequest():
return $default(_that.page,_that.perPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  int perPage)?  $default,) {final _that = this;
switch (_that) {
case _PageRequest() when $default != null:
return $default(_that.page,_that.perPage);case _:
  return null;

}
}

}

/// @nodoc


class _PageRequest extends PageRequest {
  const _PageRequest({this.page = 1, this.perPage = 50}): super._();
  

@override@JsonKey() final  int page;
@override@JsonKey() final  int perPage;

/// Create a copy of PageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageRequestCopyWith<_PageRequest> get copyWith => __$PageRequestCopyWithImpl<_PageRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageRequest&&(identical(other.page, page) || other.page == page)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,page,perPage);
}

@override
String toString() {
    return 'PageRequest(page: $page, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$PageRequestCopyWith<$Res> implements $PageRequestCopyWith<$Res> {
  factory _$PageRequestCopyWith(_PageRequest value, $Res Function(_PageRequest) _then) = __$PageRequestCopyWithImpl;
@override @useResult
$Res call({
 int page, int perPage
});




}
/// @nodoc
class __$PageRequestCopyWithImpl<$Res>
    implements _$PageRequestCopyWith<$Res> {
  __$PageRequestCopyWithImpl(this._self, this._then);

  final _PageRequest _self;
  final $Res Function(_PageRequest) _then;

/// Create a copy of PageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? perPage = null,}) {
  return _then(_PageRequest(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PagedResult<T> {

 List<T> get items; PageRequest get request;/// Total number of items across all pages, if known.
 int? get totalItems;/// Total number of pages, if known.
 int? get totalPages;/// Explicit flag from the provider. When `null` it is inferred from
/// [totalPages] or from the page being full.
 bool? get hasMoreHint;
/// Create a copy of PagedResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedResultCopyWith<T, PagedResult<T>> get copyWith => _$PagedResultCopyWithImpl<T, PagedResult<T>>(this as PagedResult<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PagedResult<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedResult<T>&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.request, _this.request) || other.request == _this.request)&&(identical(other.totalItems, _this.totalItems) || other.totalItems == _this.totalItems)&&(identical(other.totalPages, _this.totalPages) || other.totalPages == _this.totalPages)&&(identical(other.hasMoreHint, _this.hasMoreHint) || other.hasMoreHint == _this.hasMoreHint));
}


@override
int get hashCode {
  final _this = this as PagedResult<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.request,_this.totalItems,_this.totalPages,_this.hasMoreHint);
}

@override
String toString() {
  final _this = this as PagedResult<T>;
  return 'PagedResult<$T>(items: ${_this.items}, request: ${_this.request}, totalItems: ${_this.totalItems}, totalPages: ${_this.totalPages}, hasMoreHint: ${_this.hasMoreHint})';
}


}

/// @nodoc
abstract mixin class $PagedResultCopyWith<T,$Res>  {
  factory $PagedResultCopyWith(PagedResult<T> value, $Res Function(PagedResult<T>) _then) = _$PagedResultCopyWithImpl;
@useResult
$Res call({
 List<T> items, PageRequest request, int? totalItems, int? totalPages, bool? hasMoreHint
});


$PageRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$PagedResultCopyWithImpl<T,$Res>
    implements $PagedResultCopyWith<T, $Res> {
  _$PagedResultCopyWithImpl(this._self, this._then);

  final PagedResult<T> _self;
  final $Res Function(PagedResult<T>) _then;

/// Create a copy of PagedResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? request = null,Object? totalItems = freezed,Object? totalPages = freezed,Object? hasMoreHint = freezed,}) {
  return _then(PagedResult(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PageRequest,totalItems: freezed == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int?,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,hasMoreHint: freezed == hasMoreHint ? _self.hasMoreHint : hasMoreHint // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of PagedResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageRequestCopyWith<$Res> get request {
  
  return $PageRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}


/// Adds pattern-matching-related methods to [PagedResult].
extension PagedResultPatterns<T> on PagedResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedResult<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedResult<T> value)  $default,){
final _that = this;
switch (_that) {
case _PagedResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedResult<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PagedResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  PageRequest request,  int? totalItems,  int? totalPages,  bool? hasMoreHint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedResult() when $default != null:
return $default(_that.items,_that.request,_that.totalItems,_that.totalPages,_that.hasMoreHint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  PageRequest request,  int? totalItems,  int? totalPages,  bool? hasMoreHint)  $default,) {final _that = this;
switch (_that) {
case _PagedResult():
return $default(_that.items,_that.request,_that.totalItems,_that.totalPages,_that.hasMoreHint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  PageRequest request,  int? totalItems,  int? totalPages,  bool? hasMoreHint)?  $default,) {final _that = this;
switch (_that) {
case _PagedResult() when $default != null:
return $default(_that.items,_that.request,_that.totalItems,_that.totalPages,_that.hasMoreHint);case _:
  return null;

}
}

}

/// @nodoc


class _PagedResult<T> extends PagedResult<T> {
  const _PagedResult({required  List<T> items, required this.request, this.totalItems, this.totalPages, this.hasMoreHint}): _items = items,super._();
  

 final  List<T> _items;
@override List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  PageRequest request;
/// Total number of items across all pages, if known.
@override final  int? totalItems;
/// Total number of pages, if known.
@override final  int? totalPages;
/// Explicit flag from the provider. When `null` it is inferred from
/// [totalPages] or from the page being full.
@override final  bool? hasMoreHint;

/// Create a copy of PagedResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedResultCopyWith<T, _PagedResult<T>> get copyWith => __$PagedResultCopyWithImpl<T, _PagedResult<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedResult<T>&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.request, request) || other.request == request)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasMoreHint, hasMoreHint) || other.hasMoreHint == hasMoreHint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),request,totalItems,totalPages,hasMoreHint);
}

@override
String toString() {
    return 'PagedResult<$T>(items: $items, request: $request, totalItems: $totalItems, totalPages: $totalPages, hasMoreHint: $hasMoreHint)';
}


}

/// @nodoc
abstract mixin class _$PagedResultCopyWith<T,$Res> implements $PagedResultCopyWith<T, $Res> {
  factory _$PagedResultCopyWith(_PagedResult<T> value, $Res Function(_PagedResult<T>) _then) = __$PagedResultCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, PageRequest request, int? totalItems, int? totalPages, bool? hasMoreHint
});


@override $PageRequestCopyWith<$Res> get request;

}
/// @nodoc
class __$PagedResultCopyWithImpl<T,$Res>
    implements _$PagedResultCopyWith<T, $Res> {
  __$PagedResultCopyWithImpl(this._self, this._then);

  final _PagedResult<T> _self;
  final $Res Function(_PagedResult<T>) _then;

/// Create a copy of PagedResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? request = null,Object? totalItems = freezed,Object? totalPages = freezed,Object? hasMoreHint = freezed,}) {
  return _then(_PagedResult<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as PageRequest,totalItems: freezed == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int?,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,hasMoreHint: freezed == hasMoreHint ? _self.hasMoreHint : hasMoreHint // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of PagedResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageRequestCopyWith<$Res> get request {
  
  return $PageRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

// dart format on
