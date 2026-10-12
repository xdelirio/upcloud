// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_browser_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CloudBreadcrumb {

 FolderId? get id;/// Folder name. Empty for the root, which widgets label themselves.
 String get name;
/// Create a copy of CloudBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudBreadcrumbCopyWith<CloudBreadcrumb> get copyWith => _$CloudBreadcrumbCopyWithImpl<CloudBreadcrumb>(this as CloudBreadcrumb, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CloudBreadcrumb;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudBreadcrumb&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as CloudBreadcrumb;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as CloudBreadcrumb;
  return 'CloudBreadcrumb(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $CloudBreadcrumbCopyWith<$Res>  {
  factory $CloudBreadcrumbCopyWith(CloudBreadcrumb value, $Res Function(CloudBreadcrumb) _then) = _$CloudBreadcrumbCopyWithImpl;
@useResult
$Res call({
 FolderId? id, String name
});




}
/// @nodoc
class _$CloudBreadcrumbCopyWithImpl<$Res>
    implements $CloudBreadcrumbCopyWith<$Res> {
  _$CloudBreadcrumbCopyWithImpl(this._self, this._then);

  final CloudBreadcrumb _self;
  final $Res Function(CloudBreadcrumb) _then;

/// Create a copy of CloudBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,}) {
  return _then(CloudBreadcrumb(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FolderId?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CloudBreadcrumb].
extension CloudBreadcrumbPatterns on CloudBreadcrumb {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloudBreadcrumb value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloudBreadcrumb() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloudBreadcrumb value)  $default,){
final _that = this;
switch (_that) {
case _CloudBreadcrumb():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloudBreadcrumb value)?  $default,){
final _that = this;
switch (_that) {
case _CloudBreadcrumb() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FolderId? id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloudBreadcrumb() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FolderId? id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CloudBreadcrumb():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FolderId? id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CloudBreadcrumb() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _CloudBreadcrumb extends CloudBreadcrumb {
  const _CloudBreadcrumb({this.id, this.name = ''}): super._();
  

@override final  FolderId? id;
/// Folder name. Empty for the root, which widgets label themselves.
@override@JsonKey() final  String name;

/// Create a copy of CloudBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloudBreadcrumbCopyWith<_CloudBreadcrumb> get copyWith => __$CloudBreadcrumbCopyWithImpl<_CloudBreadcrumb>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloudBreadcrumb&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'CloudBreadcrumb(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CloudBreadcrumbCopyWith<$Res> implements $CloudBreadcrumbCopyWith<$Res> {
  factory _$CloudBreadcrumbCopyWith(_CloudBreadcrumb value, $Res Function(_CloudBreadcrumb) _then) = __$CloudBreadcrumbCopyWithImpl;
@override @useResult
$Res call({
 FolderId? id, String name
});




}
/// @nodoc
class __$CloudBreadcrumbCopyWithImpl<$Res>
    implements _$CloudBreadcrumbCopyWith<$Res> {
  __$CloudBreadcrumbCopyWithImpl(this._self, this._then);

  final _CloudBreadcrumb _self;
  final $Res Function(_CloudBreadcrumb) _then;

/// Create a copy of CloudBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,}) {
  return _then(_CloudBreadcrumb(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FolderId?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CloudBrowserState {

/// Folders from the root to the current folder (never empty).
 List<CloudBreadcrumb> get path;/// Loaded entries of the current folder or search.
 List<CloudEntry> get entries;/// Whether the first page is loading (initial load or refresh).
 bool get isLoading;/// Whether the next page is loading.
 bool get isLoadingMore;/// Whether [entries] reflect a completed load of the current listing.
 bool get hasLoaded;/// Whether another page can be loaded with `loadMore`.
 bool get hasMore;/// Why the first page could not be loaded.
 UpCloudException? get error;/// Why the last `loadMore` failed.
 UpCloudException? get loadMoreError;/// Whether an action (create, rename, delete...) is running.
 bool get isBusy;/// Error of the last failed action.
 UpCloudException? get actionError;/// Selection keys (see `CloudEntryUi.selectionKey`) of selected entries.
 Set<String> get selection;/// Active search query, `null` when browsing folders.
 String? get query;
/// Create a copy of CloudBrowserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudBrowserStateCopyWith<CloudBrowserState> get copyWith => _$CloudBrowserStateCopyWithImpl<CloudBrowserState>(this as CloudBrowserState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CloudBrowserState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudBrowserState&&const DeepCollectionEquality().equals(other.path, _this.path)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.hasLoaded, _this.hasLoaded) || other.hasLoaded == _this.hasLoaded)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.loadMoreError, _this.loadMoreError) || other.loadMoreError == _this.loadMoreError)&&(identical(other.isBusy, _this.isBusy) || other.isBusy == _this.isBusy)&&(identical(other.actionError, _this.actionError) || other.actionError == _this.actionError)&&const DeepCollectionEquality().equals(other.selection, _this.selection)&&(identical(other.query, _this.query) || other.query == _this.query));
}


@override
int get hashCode {
  final _this = this as CloudBrowserState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.path),const DeepCollectionEquality().hash(_this.entries),_this.isLoading,_this.isLoadingMore,_this.hasLoaded,_this.hasMore,_this.error,_this.loadMoreError,_this.isBusy,_this.actionError,const DeepCollectionEquality().hash(_this.selection),_this.query);
}

@override
String toString() {
  final _this = this as CloudBrowserState;
  return 'CloudBrowserState(path: ${_this.path}, entries: ${_this.entries}, isLoading: ${_this.isLoading}, isLoadingMore: ${_this.isLoadingMore}, hasLoaded: ${_this.hasLoaded}, hasMore: ${_this.hasMore}, error: ${_this.error}, loadMoreError: ${_this.loadMoreError}, isBusy: ${_this.isBusy}, actionError: ${_this.actionError}, selection: ${_this.selection}, query: ${_this.query})';
}


}

/// @nodoc
abstract mixin class $CloudBrowserStateCopyWith<$Res>  {
  factory $CloudBrowserStateCopyWith(CloudBrowserState value, $Res Function(CloudBrowserState) _then) = _$CloudBrowserStateCopyWithImpl;
@useResult
$Res call({
 List<CloudBreadcrumb> path, List<CloudEntry> entries, bool isLoading, bool isLoadingMore, bool hasLoaded, bool hasMore, UpCloudException? error, UpCloudException? loadMoreError, bool isBusy, UpCloudException? actionError, Set<String> selection, String? query
});




}
/// @nodoc
class _$CloudBrowserStateCopyWithImpl<$Res>
    implements $CloudBrowserStateCopyWith<$Res> {
  _$CloudBrowserStateCopyWithImpl(this._self, this._then);

  final CloudBrowserState _self;
  final $Res Function(CloudBrowserState) _then;

/// Create a copy of CloudBrowserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? entries = null,Object? isLoading = null,Object? isLoadingMore = null,Object? hasLoaded = null,Object? hasMore = null,Object? error = freezed,Object? loadMoreError = freezed,Object? isBusy = null,Object? actionError = freezed,Object? selection = null,Object? query = freezed,}) {
  return _then(CloudBrowserState(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as List<CloudBreadcrumb>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<CloudEntry>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasLoaded: null == hasLoaded ? _self.hasLoaded : hasLoaded // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UpCloudException?,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as UpCloudException?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as UpCloudException?,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as Set<String>,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CloudBrowserState].
extension CloudBrowserStatePatterns on CloudBrowserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloudBrowserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloudBrowserState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloudBrowserState value)  $default,){
final _that = this;
switch (_that) {
case _CloudBrowserState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloudBrowserState value)?  $default,){
final _that = this;
switch (_that) {
case _CloudBrowserState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CloudBreadcrumb> path,  List<CloudEntry> entries,  bool isLoading,  bool isLoadingMore,  bool hasLoaded,  bool hasMore,  UpCloudException? error,  UpCloudException? loadMoreError,  bool isBusy,  UpCloudException? actionError,  Set<String> selection,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloudBrowserState() when $default != null:
return $default(_that.path,_that.entries,_that.isLoading,_that.isLoadingMore,_that.hasLoaded,_that.hasMore,_that.error,_that.loadMoreError,_that.isBusy,_that.actionError,_that.selection,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CloudBreadcrumb> path,  List<CloudEntry> entries,  bool isLoading,  bool isLoadingMore,  bool hasLoaded,  bool hasMore,  UpCloudException? error,  UpCloudException? loadMoreError,  bool isBusy,  UpCloudException? actionError,  Set<String> selection,  String? query)  $default,) {final _that = this;
switch (_that) {
case _CloudBrowserState():
return $default(_that.path,_that.entries,_that.isLoading,_that.isLoadingMore,_that.hasLoaded,_that.hasMore,_that.error,_that.loadMoreError,_that.isBusy,_that.actionError,_that.selection,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CloudBreadcrumb> path,  List<CloudEntry> entries,  bool isLoading,  bool isLoadingMore,  bool hasLoaded,  bool hasMore,  UpCloudException? error,  UpCloudException? loadMoreError,  bool isBusy,  UpCloudException? actionError,  Set<String> selection,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _CloudBrowserState() when $default != null:
return $default(_that.path,_that.entries,_that.isLoading,_that.isLoadingMore,_that.hasLoaded,_that.hasMore,_that.error,_that.loadMoreError,_that.isBusy,_that.actionError,_that.selection,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _CloudBrowserState extends CloudBrowserState {
  const _CloudBrowserState({ List<CloudBreadcrumb> path = const <CloudBreadcrumb>[CloudBreadcrumb.root],  List<CloudEntry> entries = const <CloudEntry>[], this.isLoading = false, this.isLoadingMore = false, this.hasLoaded = false, this.hasMore = false, this.error, this.loadMoreError, this.isBusy = false, this.actionError,  Set<String> selection = const <String>{}, this.query}): _path = path,_entries = entries,_selection = selection,super._();
  

/// Folders from the root to the current folder (never empty).
 final  List<CloudBreadcrumb> _path;
/// Folders from the root to the current folder (never empty).
@override@JsonKey() List<CloudBreadcrumb> get path {
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_path);
}

/// Loaded entries of the current folder or search.
 final  List<CloudEntry> _entries;
/// Loaded entries of the current folder or search.
@override@JsonKey() List<CloudEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// Whether the first page is loading (initial load or refresh).
@override@JsonKey() final  bool isLoading;
/// Whether the next page is loading.
@override@JsonKey() final  bool isLoadingMore;
/// Whether [entries] reflect a completed load of the current listing.
@override@JsonKey() final  bool hasLoaded;
/// Whether another page can be loaded with `loadMore`.
@override@JsonKey() final  bool hasMore;
/// Why the first page could not be loaded.
@override final  UpCloudException? error;
/// Why the last `loadMore` failed.
@override final  UpCloudException? loadMoreError;
/// Whether an action (create, rename, delete...) is running.
@override@JsonKey() final  bool isBusy;
/// Error of the last failed action.
@override final  UpCloudException? actionError;
/// Selection keys (see `CloudEntryUi.selectionKey`) of selected entries.
 final  Set<String> _selection;
/// Selection keys (see `CloudEntryUi.selectionKey`) of selected entries.
@override@JsonKey() Set<String> get selection {
  if (_selection is EqualUnmodifiableSetView) return _selection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selection);
}

/// Active search query, `null` when browsing folders.
@override final  String? query;

/// Create a copy of CloudBrowserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloudBrowserStateCopyWith<_CloudBrowserState> get copyWith => __$CloudBrowserStateCopyWithImpl<_CloudBrowserState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloudBrowserState&&const DeepCollectionEquality().equals(other.path, _path)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasLoaded, hasLoaded) || other.hasLoaded == hasLoaded)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.actionError, actionError) || other.actionError == actionError)&&const DeepCollectionEquality().equals(other.selection, _selection)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_path),const DeepCollectionEquality().hash(_entries),isLoading,isLoadingMore,hasLoaded,hasMore,error,loadMoreError,isBusy,actionError,const DeepCollectionEquality().hash(_selection),query);
}

@override
String toString() {
    return 'CloudBrowserState(path: $path, entries: $entries, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasLoaded: $hasLoaded, hasMore: $hasMore, error: $error, loadMoreError: $loadMoreError, isBusy: $isBusy, actionError: $actionError, selection: $selection, query: $query)';
}


}

/// @nodoc
abstract mixin class _$CloudBrowserStateCopyWith<$Res> implements $CloudBrowserStateCopyWith<$Res> {
  factory _$CloudBrowserStateCopyWith(_CloudBrowserState value, $Res Function(_CloudBrowserState) _then) = __$CloudBrowserStateCopyWithImpl;
@override @useResult
$Res call({
 List<CloudBreadcrumb> path, List<CloudEntry> entries, bool isLoading, bool isLoadingMore, bool hasLoaded, bool hasMore, UpCloudException? error, UpCloudException? loadMoreError, bool isBusy, UpCloudException? actionError, Set<String> selection, String? query
});




}
/// @nodoc
class __$CloudBrowserStateCopyWithImpl<$Res>
    implements _$CloudBrowserStateCopyWith<$Res> {
  __$CloudBrowserStateCopyWithImpl(this._self, this._then);

  final _CloudBrowserState _self;
  final $Res Function(_CloudBrowserState) _then;

/// Create a copy of CloudBrowserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? entries = null,Object? isLoading = null,Object? isLoadingMore = null,Object? hasLoaded = null,Object? hasMore = null,Object? error = freezed,Object? loadMoreError = freezed,Object? isBusy = null,Object? actionError = freezed,Object? selection = null,Object? query = freezed,}) {
  return _then(_CloudBrowserState(
path: null == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<CloudBreadcrumb>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<CloudEntry>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasLoaded: null == hasLoaded ? _self.hasLoaded : hasLoaded // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UpCloudException?,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as UpCloudException?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as UpCloudException?,selection: null == selection ? _self._selection : selection // ignore: cast_nullable_to_non_nullable
as Set<String>,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
