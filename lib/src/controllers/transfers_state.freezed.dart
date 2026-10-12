// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransferEntry {

 UploadTask get task;/// State of [task] when the snapshot was taken.
 TransferState get state;/// Recent average speed in bytes per second, while running.
 double? get bytesPerSecond;/// [UploadTask.attempt] when the snapshot was taken: `1` for the first
/// attempt, `2` for the first automatic retry...
 int get attempt;
/// Create a copy of TransferEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferEntryCopyWith<TransferEntry> get copyWith => _$TransferEntryCopyWithImpl<TransferEntry>(this as TransferEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransferEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferEntry&&(identical(other.task, _this.task) || other.task == _this.task)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.bytesPerSecond, _this.bytesPerSecond) || other.bytesPerSecond == _this.bytesPerSecond)&&(identical(other.attempt, _this.attempt) || other.attempt == _this.attempt));
}


@override
int get hashCode {
  final _this = this as TransferEntry;
  return Object.hash(runtimeType,_this.task,_this.state,_this.bytesPerSecond,_this.attempt);
}

@override
String toString() {
  final _this = this as TransferEntry;
  return 'TransferEntry(task: ${_this.task}, state: ${_this.state}, bytesPerSecond: ${_this.bytesPerSecond}, attempt: ${_this.attempt})';
}


}

/// @nodoc
abstract mixin class $TransferEntryCopyWith<$Res>  {
  factory $TransferEntryCopyWith(TransferEntry value, $Res Function(TransferEntry) _then) = _$TransferEntryCopyWithImpl;
@useResult
$Res call({
 UploadTask task, TransferState state, double? bytesPerSecond, int attempt
});


$TransferStateCopyWith<$Res> get state;

}
/// @nodoc
class _$TransferEntryCopyWithImpl<$Res>
    implements $TransferEntryCopyWith<$Res> {
  _$TransferEntryCopyWithImpl(this._self, this._then);

  final TransferEntry _self;
  final $Res Function(TransferEntry) _then;

/// Create a copy of TransferEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? task = null,Object? state = null,Object? bytesPerSecond = freezed,Object? attempt = null,}) {
  return _then(TransferEntry(
task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as UploadTask,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TransferState,bytesPerSecond: freezed == bytesPerSecond ? _self.bytesPerSecond : bytesPerSecond // ignore: cast_nullable_to_non_nullable
as double?,attempt: null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TransferEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransferStateCopyWith<$Res> get state {
  
  return $TransferStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransferEntry].
extension TransferEntryPatterns on TransferEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferEntry value)  $default,){
final _that = this;
switch (_that) {
case _TransferEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TransferEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UploadTask task,  TransferState state,  double? bytesPerSecond,  int attempt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferEntry() when $default != null:
return $default(_that.task,_that.state,_that.bytesPerSecond,_that.attempt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UploadTask task,  TransferState state,  double? bytesPerSecond,  int attempt)  $default,) {final _that = this;
switch (_that) {
case _TransferEntry():
return $default(_that.task,_that.state,_that.bytesPerSecond,_that.attempt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UploadTask task,  TransferState state,  double? bytesPerSecond,  int attempt)?  $default,) {final _that = this;
switch (_that) {
case _TransferEntry() when $default != null:
return $default(_that.task,_that.state,_that.bytesPerSecond,_that.attempt);case _:
  return null;

}
}

}

/// @nodoc


class _TransferEntry extends TransferEntry {
  const _TransferEntry({required this.task, required this.state, this.bytesPerSecond, this.attempt = 0}): super._();
  

@override final  UploadTask task;
/// State of [task] when the snapshot was taken.
@override final  TransferState state;
/// Recent average speed in bytes per second, while running.
@override final  double? bytesPerSecond;
/// [UploadTask.attempt] when the snapshot was taken: `1` for the first
/// attempt, `2` for the first automatic retry...
@override@JsonKey() final  int attempt;

/// Create a copy of TransferEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferEntryCopyWith<_TransferEntry> get copyWith => __$TransferEntryCopyWithImpl<_TransferEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferEntry&&(identical(other.task, task) || other.task == task)&&(identical(other.state, state) || other.state == state)&&(identical(other.bytesPerSecond, bytesPerSecond) || other.bytesPerSecond == bytesPerSecond)&&(identical(other.attempt, attempt) || other.attempt == attempt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,task,state,bytesPerSecond,attempt);
}

@override
String toString() {
    return 'TransferEntry(task: $task, state: $state, bytesPerSecond: $bytesPerSecond, attempt: $attempt)';
}


}

/// @nodoc
abstract mixin class _$TransferEntryCopyWith<$Res> implements $TransferEntryCopyWith<$Res> {
  factory _$TransferEntryCopyWith(_TransferEntry value, $Res Function(_TransferEntry) _then) = __$TransferEntryCopyWithImpl;
@override @useResult
$Res call({
 UploadTask task, TransferState state, double? bytesPerSecond, int attempt
});


@override $TransferStateCopyWith<$Res> get state;

}
/// @nodoc
class __$TransferEntryCopyWithImpl<$Res>
    implements _$TransferEntryCopyWith<$Res> {
  __$TransferEntryCopyWithImpl(this._self, this._then);

  final _TransferEntry _self;
  final $Res Function(_TransferEntry) _then;

/// Create a copy of TransferEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? task = null,Object? state = null,Object? bytesPerSecond = freezed,Object? attempt = null,}) {
  return _then(_TransferEntry(
task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as UploadTask,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TransferState,bytesPerSecond: freezed == bytesPerSecond ? _self.bytesPerSecond : bytesPerSecond // ignore: cast_nullable_to_non_nullable
as double?,attempt: null == attempt ? _self.attempt : attempt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TransferEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransferStateCopyWith<$Res> get state {
  
  return $TransferStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}

/// @nodoc
mixin _$TransferBatchEntry {

 String get id;/// Uploads of the batch, oldest first.
 List<TransferEntry> get entries;
/// Create a copy of TransferBatchEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferBatchEntryCopyWith<TransferBatchEntry> get copyWith => _$TransferBatchEntryCopyWithImpl<TransferBatchEntry>(this as TransferBatchEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransferBatchEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferBatchEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}


@override
int get hashCode {
  final _this = this as TransferBatchEntry;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as TransferBatchEntry;
  return 'TransferBatchEntry(id: ${_this.id}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $TransferBatchEntryCopyWith<$Res>  {
  factory $TransferBatchEntryCopyWith(TransferBatchEntry value, $Res Function(TransferBatchEntry) _then) = _$TransferBatchEntryCopyWithImpl;
@useResult
$Res call({
 String id, List<TransferEntry> entries
});




}
/// @nodoc
class _$TransferBatchEntryCopyWithImpl<$Res>
    implements $TransferBatchEntryCopyWith<$Res> {
  _$TransferBatchEntryCopyWithImpl(this._self, this._then);

  final TransferBatchEntry _self;
  final $Res Function(TransferBatchEntry) _then;

/// Create a copy of TransferBatchEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entries = null,}) {
  return _then(TransferBatchEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<TransferEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferBatchEntry].
extension TransferBatchEntryPatterns on TransferBatchEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferBatchEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferBatchEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferBatchEntry value)  $default,){
final _that = this;
switch (_that) {
case _TransferBatchEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferBatchEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TransferBatchEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<TransferEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferBatchEntry() when $default != null:
return $default(_that.id,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<TransferEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _TransferBatchEntry():
return $default(_that.id,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<TransferEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _TransferBatchEntry() when $default != null:
return $default(_that.id,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _TransferBatchEntry extends TransferBatchEntry {
  const _TransferBatchEntry({required this.id, required  List<TransferEntry> entries}): _entries = entries,super._();
  

@override final  String id;
/// Uploads of the batch, oldest first.
 final  List<TransferEntry> _entries;
/// Uploads of the batch, oldest first.
@override List<TransferEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of TransferBatchEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferBatchEntryCopyWith<_TransferBatchEntry> get copyWith => __$TransferBatchEntryCopyWithImpl<_TransferBatchEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferBatchEntry&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.entries, _entries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'TransferBatchEntry(id: $id, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$TransferBatchEntryCopyWith<$Res> implements $TransferBatchEntryCopyWith<$Res> {
  factory _$TransferBatchEntryCopyWith(_TransferBatchEntry value, $Res Function(_TransferBatchEntry) _then) = __$TransferBatchEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, List<TransferEntry> entries
});




}
/// @nodoc
class __$TransferBatchEntryCopyWithImpl<$Res>
    implements _$TransferBatchEntryCopyWith<$Res> {
  __$TransferBatchEntryCopyWithImpl(this._self, this._then);

  final _TransferBatchEntry _self;
  final $Res Function(_TransferBatchEntry) _then;

/// Create a copy of TransferBatchEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entries = null,}) {
  return _then(_TransferBatchEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<TransferEntry>,
  ));
}


}

/// @nodoc
mixin _$TransfersState {

/// Every transfer, oldest first.
 List<TransferEntry> get entries;
/// Create a copy of TransfersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransfersStateCopyWith<TransfersState> get copyWith => _$TransfersStateCopyWithImpl<TransfersState>(this as TransfersState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransfersState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransfersState&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}


@override
int get hashCode {
  final _this = this as TransfersState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as TransfersState;
  return 'TransfersState(entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $TransfersStateCopyWith<$Res>  {
  factory $TransfersStateCopyWith(TransfersState value, $Res Function(TransfersState) _then) = _$TransfersStateCopyWithImpl;
@useResult
$Res call({
 List<TransferEntry> entries
});




}
/// @nodoc
class _$TransfersStateCopyWithImpl<$Res>
    implements $TransfersStateCopyWith<$Res> {
  _$TransfersStateCopyWithImpl(this._self, this._then);

  final TransfersState _self;
  final $Res Function(TransfersState) _then;

/// Create a copy of TransfersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,}) {
  return _then(TransfersState(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<TransferEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransfersState].
extension TransfersStatePatterns on TransfersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransfersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransfersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransfersState value)  $default,){
final _that = this;
switch (_that) {
case _TransfersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransfersState value)?  $default,){
final _that = this;
switch (_that) {
case _TransfersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransferEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransfersState() when $default != null:
return $default(_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransferEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _TransfersState():
return $default(_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransferEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _TransfersState() when $default != null:
return $default(_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _TransfersState extends TransfersState {
  const _TransfersState({ List<TransferEntry> entries = const <TransferEntry>[]}): _entries = entries,super._();
  

/// Every transfer, oldest first.
 final  List<TransferEntry> _entries;
/// Every transfer, oldest first.
@override@JsonKey() List<TransferEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of TransfersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransfersStateCopyWith<_TransfersState> get copyWith => __$TransfersStateCopyWithImpl<_TransfersState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransfersState&&const DeepCollectionEquality().equals(other.entries, _entries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'TransfersState(entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$TransfersStateCopyWith<$Res> implements $TransfersStateCopyWith<$Res> {
  factory _$TransfersStateCopyWith(_TransfersState value, $Res Function(_TransfersState) _then) = __$TransfersStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransferEntry> entries
});




}
/// @nodoc
class __$TransfersStateCopyWithImpl<$Res>
    implements _$TransfersStateCopyWith<$Res> {
  __$TransfersStateCopyWithImpl(this._self, this._then);

  final _TransfersState _self;
  final $Res Function(_TransfersState) _then;

/// Create a copy of TransfersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(_TransfersState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<TransferEntry>,
  ));
}


}

// dart format on
