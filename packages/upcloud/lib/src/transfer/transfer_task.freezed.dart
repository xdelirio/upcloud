// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransferState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TransferState()';
}


}

/// @nodoc
class $TransferStateCopyWith<$Res>  {
$TransferStateCopyWith(TransferState _, $Res Function(TransferState) __);
}


/// Adds pattern-matching-related methods to [TransferState].
extension TransferStatePatterns on TransferState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TransferQueued value)?  queued,TResult Function( TransferRunning value)?  running,TResult Function( TransferCompleted value)?  completed,TResult Function( TransferFailed value)?  failed,TResult Function( TransferCancelled value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TransferQueued() when queued != null:
return queued(_that);case TransferRunning() when running != null:
return running(_that);case TransferCompleted() when completed != null:
return completed(_that);case TransferFailed() when failed != null:
return failed(_that);case TransferCancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TransferQueued value)  queued,required TResult Function( TransferRunning value)  running,required TResult Function( TransferCompleted value)  completed,required TResult Function( TransferFailed value)  failed,required TResult Function( TransferCancelled value)  cancelled,}){
final _that = this;
switch (_that) {
case TransferQueued():
return queued(_that);case TransferRunning():
return running(_that);case TransferCompleted():
return completed(_that);case TransferFailed():
return failed(_that);case TransferCancelled():
return cancelled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TransferQueued value)?  queued,TResult? Function( TransferRunning value)?  running,TResult? Function( TransferCompleted value)?  completed,TResult? Function( TransferFailed value)?  failed,TResult? Function( TransferCancelled value)?  cancelled,}){
final _that = this;
switch (_that) {
case TransferQueued() when queued != null:
return queued(_that);case TransferRunning() when running != null:
return running(_that);case TransferCompleted() when completed != null:
return completed(_that);case TransferFailed() when failed != null:
return failed(_that);case TransferCancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  queued,TResult Function( TransferProgress progress)?  running,TResult Function()?  completed,TResult Function( UpCloudException error)?  failed,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TransferQueued() when queued != null:
return queued();case TransferRunning() when running != null:
return running(_that.progress);case TransferCompleted() when completed != null:
return completed();case TransferFailed() when failed != null:
return failed(_that.error);case TransferCancelled() when cancelled != null:
return cancelled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  queued,required TResult Function( TransferProgress progress)  running,required TResult Function()  completed,required TResult Function( UpCloudException error)  failed,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case TransferQueued():
return queued();case TransferRunning():
return running(_that.progress);case TransferCompleted():
return completed();case TransferFailed():
return failed(_that.error);case TransferCancelled():
return cancelled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  queued,TResult? Function( TransferProgress progress)?  running,TResult? Function()?  completed,TResult? Function( UpCloudException error)?  failed,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case TransferQueued() when queued != null:
return queued();case TransferRunning() when running != null:
return running(_that.progress);case TransferCompleted() when completed != null:
return completed();case TransferFailed() when failed != null:
return failed(_that.error);case TransferCancelled() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc


class TransferQueued extends TransferState {
  const TransferQueued(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferQueued);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TransferState.queued()';
}


}




/// @nodoc


class TransferRunning extends TransferState {
  const TransferRunning(this.progress): super._();
  

 final  TransferProgress progress;

/// Create a copy of TransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferRunningCopyWith<TransferRunning> get copyWith => _$TransferRunningCopyWithImpl<TransferRunning>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferRunning&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode {
    return Object.hash(runtimeType,progress);
}

@override
String toString() {
    return 'TransferState.running(progress: $progress)';
}


}

/// @nodoc
abstract mixin class $TransferRunningCopyWith<$Res> implements $TransferStateCopyWith<$Res> {
  factory $TransferRunningCopyWith(TransferRunning value, $Res Function(TransferRunning) _then) = _$TransferRunningCopyWithImpl;
@useResult
$Res call({
 TransferProgress progress
});


$TransferProgressCopyWith<$Res> get progress;

}
/// @nodoc
class _$TransferRunningCopyWithImpl<$Res>
    implements $TransferRunningCopyWith<$Res> {
  _$TransferRunningCopyWithImpl(this._self, this._then);

  final TransferRunning _self;
  final $Res Function(TransferRunning) _then;

/// Create a copy of TransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? progress = null,}) {
  return _then(TransferRunning(
null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as TransferProgress,
  ));
}

/// Create a copy of TransferState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransferProgressCopyWith<$Res> get progress {
  
  return $TransferProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

/// @nodoc


class TransferCompleted extends TransferState {
  const TransferCompleted(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TransferState.completed()';
}


}




/// @nodoc


class TransferFailed extends TransferState {
  const TransferFailed(this.error): super._();
  

 final  UpCloudException error;

/// Create a copy of TransferState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferFailedCopyWith<TransferFailed> get copyWith => _$TransferFailedCopyWithImpl<TransferFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error);
}

@override
String toString() {
    return 'TransferState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $TransferFailedCopyWith<$Res> implements $TransferStateCopyWith<$Res> {
  factory $TransferFailedCopyWith(TransferFailed value, $Res Function(TransferFailed) _then) = _$TransferFailedCopyWithImpl;
@useResult
$Res call({
 UpCloudException error
});




}
/// @nodoc
class _$TransferFailedCopyWithImpl<$Res>
    implements $TransferFailedCopyWith<$Res> {
  _$TransferFailedCopyWithImpl(this._self, this._then);

  final TransferFailed _self;
  final $Res Function(TransferFailed) _then;

/// Create a copy of TransferState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(TransferFailed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UpCloudException,
  ));
}


}

/// @nodoc


class TransferCancelled extends TransferState {
  const TransferCancelled(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'TransferState.cancelled()';
}


}




// dart format on
