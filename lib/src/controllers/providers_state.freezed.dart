// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'providers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProvidersState {

/// Every provider config, including disabled and invalid ones.
 List<ProviderConfig> get configs;/// Entries that could not be used and why.
 List<RegistryIssue> get issues;/// Ids of providers added by the user.
 Set<String> get customIds;/// Ids of providers edited (or added) by the user.
 Set<String> get modifiedIds;/// Whether saved registry data is being loaded.
 bool get isLoading;/// Whether the remote registry is being checked.
 bool get isRefreshing;/// Whether a change is being saved.
 bool get isSaving;/// Result of the last check for updates.
 RegistryRefreshResult? get lastRefresh;/// When the remote registry was last checked.
 DateTime? get lastFetchedAt;/// Error of the last failed operation, usually an [UpCloudException]
/// (an [InvalidProviderConfigException] for invalid configs).
 Object? get error;
/// Create a copy of ProvidersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProvidersStateCopyWith<ProvidersState> get copyWith => _$ProvidersStateCopyWithImpl<ProvidersState>(this as ProvidersState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProvidersState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProvidersState&&const DeepCollectionEquality().equals(other.configs, _this.configs)&&const DeepCollectionEquality().equals(other.issues, _this.issues)&&const DeepCollectionEquality().equals(other.customIds, _this.customIds)&&const DeepCollectionEquality().equals(other.modifiedIds, _this.modifiedIds)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.lastRefresh, _this.lastRefresh) || other.lastRefresh == _this.lastRefresh)&&(identical(other.lastFetchedAt, _this.lastFetchedAt) || other.lastFetchedAt == _this.lastFetchedAt)&&const DeepCollectionEquality().equals(other.error, _this.error));
}


@override
int get hashCode {
  final _this = this as ProvidersState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.configs),const DeepCollectionEquality().hash(_this.issues),const DeepCollectionEquality().hash(_this.customIds),const DeepCollectionEquality().hash(_this.modifiedIds),_this.isLoading,_this.isRefreshing,_this.isSaving,_this.lastRefresh,_this.lastFetchedAt,const DeepCollectionEquality().hash(_this.error));
}

@override
String toString() {
  final _this = this as ProvidersState;
  return 'ProvidersState(configs: ${_this.configs}, issues: ${_this.issues}, customIds: ${_this.customIds}, modifiedIds: ${_this.modifiedIds}, isLoading: ${_this.isLoading}, isRefreshing: ${_this.isRefreshing}, isSaving: ${_this.isSaving}, lastRefresh: ${_this.lastRefresh}, lastFetchedAt: ${_this.lastFetchedAt}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ProvidersStateCopyWith<$Res>  {
  factory $ProvidersStateCopyWith(ProvidersState value, $Res Function(ProvidersState) _then) = _$ProvidersStateCopyWithImpl;
@useResult
$Res call({
 List<ProviderConfig> configs, List<RegistryIssue> issues, Set<String> customIds, Set<String> modifiedIds, bool isLoading, bool isRefreshing, bool isSaving, RegistryRefreshResult? lastRefresh, DateTime? lastFetchedAt, Object? error
});




}
/// @nodoc
class _$ProvidersStateCopyWithImpl<$Res>
    implements $ProvidersStateCopyWith<$Res> {
  _$ProvidersStateCopyWithImpl(this._self, this._then);

  final ProvidersState _self;
  final $Res Function(ProvidersState) _then;

/// Create a copy of ProvidersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configs = null,Object? issues = null,Object? customIds = null,Object? modifiedIds = null,Object? isLoading = null,Object? isRefreshing = null,Object? isSaving = null,Object? lastRefresh = freezed,Object? lastFetchedAt = freezed,Object? error = freezed,}) {
  return _then(ProvidersState(
configs: null == configs ? _self.configs : configs // ignore: cast_nullable_to_non_nullable
as List<ProviderConfig>,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<RegistryIssue>,customIds: null == customIds ? _self.customIds : customIds // ignore: cast_nullable_to_non_nullable
as Set<String>,modifiedIds: null == modifiedIds ? _self.modifiedIds : modifiedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,lastRefresh: freezed == lastRefresh ? _self.lastRefresh : lastRefresh // ignore: cast_nullable_to_non_nullable
as RegistryRefreshResult?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error ,
  ));
}

}


/// Adds pattern-matching-related methods to [ProvidersState].
extension ProvidersStatePatterns on ProvidersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProvidersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProvidersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProvidersState value)  $default,){
final _that = this;
switch (_that) {
case _ProvidersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProvidersState value)?  $default,){
final _that = this;
switch (_that) {
case _ProvidersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProviderConfig> configs,  List<RegistryIssue> issues,  Set<String> customIds,  Set<String> modifiedIds,  bool isLoading,  bool isRefreshing,  bool isSaving,  RegistryRefreshResult? lastRefresh,  DateTime? lastFetchedAt,  Object? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProvidersState() when $default != null:
return $default(_that.configs,_that.issues,_that.customIds,_that.modifiedIds,_that.isLoading,_that.isRefreshing,_that.isSaving,_that.lastRefresh,_that.lastFetchedAt,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProviderConfig> configs,  List<RegistryIssue> issues,  Set<String> customIds,  Set<String> modifiedIds,  bool isLoading,  bool isRefreshing,  bool isSaving,  RegistryRefreshResult? lastRefresh,  DateTime? lastFetchedAt,  Object? error)  $default,) {final _that = this;
switch (_that) {
case _ProvidersState():
return $default(_that.configs,_that.issues,_that.customIds,_that.modifiedIds,_that.isLoading,_that.isRefreshing,_that.isSaving,_that.lastRefresh,_that.lastFetchedAt,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProviderConfig> configs,  List<RegistryIssue> issues,  Set<String> customIds,  Set<String> modifiedIds,  bool isLoading,  bool isRefreshing,  bool isSaving,  RegistryRefreshResult? lastRefresh,  DateTime? lastFetchedAt,  Object? error)?  $default,) {final _that = this;
switch (_that) {
case _ProvidersState() when $default != null:
return $default(_that.configs,_that.issues,_that.customIds,_that.modifiedIds,_that.isLoading,_that.isRefreshing,_that.isSaving,_that.lastRefresh,_that.lastFetchedAt,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ProvidersState extends ProvidersState {
  const _ProvidersState({ List<ProviderConfig> configs = const <ProviderConfig>[],  List<RegistryIssue> issues = const <RegistryIssue>[],  Set<String> customIds = const <String>{},  Set<String> modifiedIds = const <String>{}, this.isLoading = false, this.isRefreshing = false, this.isSaving = false, this.lastRefresh, this.lastFetchedAt, this.error}): _configs = configs,_issues = issues,_customIds = customIds,_modifiedIds = modifiedIds,super._();
  

/// Every provider config, including disabled and invalid ones.
 final  List<ProviderConfig> _configs;
/// Every provider config, including disabled and invalid ones.
@override@JsonKey() List<ProviderConfig> get configs {
  if (_configs is EqualUnmodifiableListView) return _configs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_configs);
}

/// Entries that could not be used and why.
 final  List<RegistryIssue> _issues;
/// Entries that could not be used and why.
@override@JsonKey() List<RegistryIssue> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}

/// Ids of providers added by the user.
 final  Set<String> _customIds;
/// Ids of providers added by the user.
@override@JsonKey() Set<String> get customIds {
  if (_customIds is EqualUnmodifiableSetView) return _customIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_customIds);
}

/// Ids of providers edited (or added) by the user.
 final  Set<String> _modifiedIds;
/// Ids of providers edited (or added) by the user.
@override@JsonKey() Set<String> get modifiedIds {
  if (_modifiedIds is EqualUnmodifiableSetView) return _modifiedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_modifiedIds);
}

/// Whether saved registry data is being loaded.
@override@JsonKey() final  bool isLoading;
/// Whether the remote registry is being checked.
@override@JsonKey() final  bool isRefreshing;
/// Whether a change is being saved.
@override@JsonKey() final  bool isSaving;
/// Result of the last check for updates.
@override final  RegistryRefreshResult? lastRefresh;
/// When the remote registry was last checked.
@override final  DateTime? lastFetchedAt;
/// Error of the last failed operation, usually an [UpCloudException]
/// (an [InvalidProviderConfigException] for invalid configs).
@override final  Object? error;

/// Create a copy of ProvidersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProvidersStateCopyWith<_ProvidersState> get copyWith => __$ProvidersStateCopyWithImpl<_ProvidersState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProvidersState&&const DeepCollectionEquality().equals(other.configs, _configs)&&const DeepCollectionEquality().equals(other.issues, _issues)&&const DeepCollectionEquality().equals(other.customIds, _customIds)&&const DeepCollectionEquality().equals(other.modifiedIds, _modifiedIds)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.lastRefresh, lastRefresh) || other.lastRefresh == lastRefresh)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_configs),const DeepCollectionEquality().hash(_issues),const DeepCollectionEquality().hash(_customIds),const DeepCollectionEquality().hash(_modifiedIds),isLoading,isRefreshing,isSaving,lastRefresh,lastFetchedAt,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'ProvidersState(configs: $configs, issues: $issues, customIds: $customIds, modifiedIds: $modifiedIds, isLoading: $isLoading, isRefreshing: $isRefreshing, isSaving: $isSaving, lastRefresh: $lastRefresh, lastFetchedAt: $lastFetchedAt, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ProvidersStateCopyWith<$Res> implements $ProvidersStateCopyWith<$Res> {
  factory _$ProvidersStateCopyWith(_ProvidersState value, $Res Function(_ProvidersState) _then) = __$ProvidersStateCopyWithImpl;
@override @useResult
$Res call({
 List<ProviderConfig> configs, List<RegistryIssue> issues, Set<String> customIds, Set<String> modifiedIds, bool isLoading, bool isRefreshing, bool isSaving, RegistryRefreshResult? lastRefresh, DateTime? lastFetchedAt, Object? error
});




}
/// @nodoc
class __$ProvidersStateCopyWithImpl<$Res>
    implements _$ProvidersStateCopyWith<$Res> {
  __$ProvidersStateCopyWithImpl(this._self, this._then);

  final _ProvidersState _self;
  final $Res Function(_ProvidersState) _then;

/// Create a copy of ProvidersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configs = null,Object? issues = null,Object? customIds = null,Object? modifiedIds = null,Object? isLoading = null,Object? isRefreshing = null,Object? isSaving = null,Object? lastRefresh = freezed,Object? lastFetchedAt = freezed,Object? error = freezed,}) {
  return _then(_ProvidersState(
configs: null == configs ? _self._configs : configs // ignore: cast_nullable_to_non_nullable
as List<ProviderConfig>,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<RegistryIssue>,customIds: null == customIds ? _self._customIds : customIds // ignore: cast_nullable_to_non_nullable
as Set<String>,modifiedIds: null == modifiedIds ? _self._modifiedIds : modifiedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,lastRefresh: freezed == lastRefresh ? _self.lastRefresh : lastRefresh // ignore: cast_nullable_to_non_nullable
as RegistryRefreshResult?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error ,
  ));
}


}

// dart format on
