// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Credentials {

 Map<String, String> get values;
/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialsCopyWith<Credentials> get copyWith => _$CredentialsCopyWithImpl<Credentials>(this as Credentials, _$identity);

  /// Serializes this Credentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Credentials;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Credentials&&const DeepCollectionEquality().equals(other.values, _this.values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Credentials;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.values));
}

@override
String toString() {
  final _this = this as Credentials;
  return 'Credentials(values: ${_this.values})';
}


}

/// @nodoc
abstract mixin class $CredentialsCopyWith<$Res>  {
  factory $CredentialsCopyWith(Credentials value, $Res Function(Credentials) _then) = _$CredentialsCopyWithImpl;
@useResult
$Res call({
 Map<String, String> values
});




}
/// @nodoc
class _$CredentialsCopyWithImpl<$Res>
    implements $CredentialsCopyWith<$Res> {
  _$CredentialsCopyWithImpl(this._self, this._then);

  final Credentials _self;
  final $Res Function(Credentials) _then;

/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? values = null,}) {
  return _then(Credentials(
null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Credentials].
extension CredentialsPatterns on Credentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Credentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Credentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Credentials value)  $default,){
final _that = this;
switch (_that) {
case _Credentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Credentials value)?  $default,){
final _that = this;
switch (_that) {
case _Credentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, String> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Credentials() when $default != null:
return $default(_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, String> values)  $default,) {final _that = this;
switch (_that) {
case _Credentials():
return $default(_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, String> values)?  $default,) {final _that = this;
switch (_that) {
case _Credentials() when $default != null:
return $default(_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Credentials extends Credentials {
  const _Credentials( Map<String, String> values): _values = values,super._();
  factory _Credentials.fromJson(Map<String, dynamic> json) => _$CredentialsFromJson(json);

 final  Map<String, String> _values;
@override Map<String, String> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}


/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialsCopyWith<_Credentials> get copyWith => __$CredentialsCopyWithImpl<_Credentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Credentials&&const DeepCollectionEquality().equals(other.values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));
}

@override
String toString() {
    return 'Credentials(values: $values)';
}


}

/// @nodoc
abstract mixin class _$CredentialsCopyWith<$Res> implements $CredentialsCopyWith<$Res> {
  factory _$CredentialsCopyWith(_Credentials value, $Res Function(_Credentials) _then) = __$CredentialsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, String> values
});




}
/// @nodoc
class __$CredentialsCopyWithImpl<$Res>
    implements _$CredentialsCopyWith<$Res> {
  __$CredentialsCopyWithImpl(this._self, this._then);

  final _Credentials _self;
  final $Res Function(_Credentials) _then;

/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(_Credentials(
null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$CredentialField {

/// Key inside [Credentials.values].
 String get id;/// Label shown to the user.
 String get label; CredentialInputKind get kind; bool get isRequired;/// Short help text.
 String? get hint;/// Where the user can obtain the value (e.g. the API settings page).
 Uri? get helpUrl;/// Value used when the user leaves the field empty.
 String? get defaultValue;
/// Create a copy of CredentialField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialFieldCopyWith<CredentialField> get copyWith => _$CredentialFieldCopyWithImpl<CredentialField>(this as CredentialField, _$identity);

  /// Serializes this CredentialField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CredentialField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialField&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.isRequired, _this.isRequired) || other.isRequired == _this.isRequired)&&(identical(other.hint, _this.hint) || other.hint == _this.hint)&&(identical(other.helpUrl, _this.helpUrl) || other.helpUrl == _this.helpUrl)&&(identical(other.defaultValue, _this.defaultValue) || other.defaultValue == _this.defaultValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CredentialField;
  return Object.hash(runtimeType,_this.id,_this.label,_this.kind,_this.isRequired,_this.hint,_this.helpUrl,_this.defaultValue);
}

@override
String toString() {
  final _this = this as CredentialField;
  return 'CredentialField(id: ${_this.id}, label: ${_this.label}, kind: ${_this.kind}, isRequired: ${_this.isRequired}, hint: ${_this.hint}, helpUrl: ${_this.helpUrl}, defaultValue: ${_this.defaultValue})';
}


}

/// @nodoc
abstract mixin class $CredentialFieldCopyWith<$Res>  {
  factory $CredentialFieldCopyWith(CredentialField value, $Res Function(CredentialField) _then) = _$CredentialFieldCopyWithImpl;
@useResult
$Res call({
 String id, String label, CredentialInputKind kind, bool isRequired, String? hint, Uri? helpUrl, String? defaultValue
});




}
/// @nodoc
class _$CredentialFieldCopyWithImpl<$Res>
    implements $CredentialFieldCopyWith<$Res> {
  _$CredentialFieldCopyWithImpl(this._self, this._then);

  final CredentialField _self;
  final $Res Function(CredentialField) _then;

/// Create a copy of CredentialField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? kind = null,Object? isRequired = null,Object? hint = freezed,Object? helpUrl = freezed,Object? defaultValue = freezed,}) {
  return _then(CredentialField(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CredentialInputKind,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,helpUrl: freezed == helpUrl ? _self.helpUrl : helpUrl // ignore: cast_nullable_to_non_nullable
as Uri?,defaultValue: freezed == defaultValue ? _self.defaultValue : defaultValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CredentialField].
extension CredentialFieldPatterns on CredentialField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CredentialField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CredentialField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CredentialField value)  $default,){
final _that = this;
switch (_that) {
case _CredentialField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CredentialField value)?  $default,){
final _that = this;
switch (_that) {
case _CredentialField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  CredentialInputKind kind,  bool isRequired,  String? hint,  Uri? helpUrl,  String? defaultValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CredentialField() when $default != null:
return $default(_that.id,_that.label,_that.kind,_that.isRequired,_that.hint,_that.helpUrl,_that.defaultValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  CredentialInputKind kind,  bool isRequired,  String? hint,  Uri? helpUrl,  String? defaultValue)  $default,) {final _that = this;
switch (_that) {
case _CredentialField():
return $default(_that.id,_that.label,_that.kind,_that.isRequired,_that.hint,_that.helpUrl,_that.defaultValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  CredentialInputKind kind,  bool isRequired,  String? hint,  Uri? helpUrl,  String? defaultValue)?  $default,) {final _that = this;
switch (_that) {
case _CredentialField() when $default != null:
return $default(_that.id,_that.label,_that.kind,_that.isRequired,_that.hint,_that.helpUrl,_that.defaultValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CredentialField implements CredentialField {
  const _CredentialField({required this.id, required this.label, this.kind = CredentialInputKind.text, this.isRequired = true, this.hint, this.helpUrl, this.defaultValue});
  factory _CredentialField.fromJson(Map<String, dynamic> json) => _$CredentialFieldFromJson(json);

/// Key inside [Credentials.values].
@override final  String id;
/// Label shown to the user.
@override final  String label;
@override@JsonKey() final  CredentialInputKind kind;
@override@JsonKey() final  bool isRequired;
/// Short help text.
@override final  String? hint;
/// Where the user can obtain the value (e.g. the API settings page).
@override final  Uri? helpUrl;
/// Value used when the user leaves the field empty.
@override final  String? defaultValue;

/// Create a copy of CredentialField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialFieldCopyWith<_CredentialField> get copyWith => __$CredentialFieldCopyWithImpl<_CredentialField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialFieldToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CredentialField&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.helpUrl, helpUrl) || other.helpUrl == helpUrl)&&(identical(other.defaultValue, defaultValue) || other.defaultValue == defaultValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,kind,isRequired,hint,helpUrl,defaultValue);
}

@override
String toString() {
    return 'CredentialField(id: $id, label: $label, kind: $kind, isRequired: $isRequired, hint: $hint, helpUrl: $helpUrl, defaultValue: $defaultValue)';
}


}

/// @nodoc
abstract mixin class _$CredentialFieldCopyWith<$Res> implements $CredentialFieldCopyWith<$Res> {
  factory _$CredentialFieldCopyWith(_CredentialField value, $Res Function(_CredentialField) _then) = __$CredentialFieldCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, CredentialInputKind kind, bool isRequired, String? hint, Uri? helpUrl, String? defaultValue
});




}
/// @nodoc
class __$CredentialFieldCopyWithImpl<$Res>
    implements _$CredentialFieldCopyWith<$Res> {
  __$CredentialFieldCopyWithImpl(this._self, this._then);

  final _CredentialField _self;
  final $Res Function(_CredentialField) _then;

/// Create a copy of CredentialField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? kind = null,Object? isRequired = null,Object? hint = freezed,Object? helpUrl = freezed,Object? defaultValue = freezed,}) {
  return _then(_CredentialField(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CredentialInputKind,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,helpUrl: freezed == helpUrl ? _self.helpUrl : helpUrl // ignore: cast_nullable_to_non_nullable
as Uri?,defaultValue: freezed == defaultValue ? _self.defaultValue : defaultValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CredentialSchema {

 List<CredentialField> get fields;
/// Create a copy of CredentialSchema
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialSchemaCopyWith<CredentialSchema> get copyWith => _$CredentialSchemaCopyWithImpl<CredentialSchema>(this as CredentialSchema, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CredentialSchema;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialSchema&&const DeepCollectionEquality().equals(other.fields, _this.fields));
}


@override
int get hashCode {
  final _this = this as CredentialSchema;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.fields));
}

@override
String toString() {
  final _this = this as CredentialSchema;
  return 'CredentialSchema(fields: ${_this.fields})';
}


}

/// @nodoc
abstract mixin class $CredentialSchemaCopyWith<$Res>  {
  factory $CredentialSchemaCopyWith(CredentialSchema value, $Res Function(CredentialSchema) _then) = _$CredentialSchemaCopyWithImpl;
@useResult
$Res call({
 List<CredentialField> fields
});




}
/// @nodoc
class _$CredentialSchemaCopyWithImpl<$Res>
    implements $CredentialSchemaCopyWith<$Res> {
  _$CredentialSchemaCopyWithImpl(this._self, this._then);

  final CredentialSchema _self;
  final $Res Function(CredentialSchema) _then;

/// Create a copy of CredentialSchema
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fields = null,}) {
  return _then(CredentialSchema(
null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<CredentialField>,
  ));
}

}


/// Adds pattern-matching-related methods to [CredentialSchema].
extension CredentialSchemaPatterns on CredentialSchema {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CredentialSchema value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CredentialSchema() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CredentialSchema value)  $default,){
final _that = this;
switch (_that) {
case _CredentialSchema():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CredentialSchema value)?  $default,){
final _that = this;
switch (_that) {
case _CredentialSchema() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CredentialField> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CredentialSchema() when $default != null:
return $default(_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CredentialField> fields)  $default,) {final _that = this;
switch (_that) {
case _CredentialSchema():
return $default(_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CredentialField> fields)?  $default,) {final _that = this;
switch (_that) {
case _CredentialSchema() when $default != null:
return $default(_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _CredentialSchema extends CredentialSchema {
  const _CredentialSchema( List<CredentialField> fields): _fields = fields,super._();
  

 final  List<CredentialField> _fields;
@override List<CredentialField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of CredentialSchema
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialSchemaCopyWith<_CredentialSchema> get copyWith => __$CredentialSchemaCopyWithImpl<_CredentialSchema>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CredentialSchema&&const DeepCollectionEquality().equals(other.fields, _fields));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_fields));
}

@override
String toString() {
    return 'CredentialSchema(fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$CredentialSchemaCopyWith<$Res> implements $CredentialSchemaCopyWith<$Res> {
  factory _$CredentialSchemaCopyWith(_CredentialSchema value, $Res Function(_CredentialSchema) _then) = __$CredentialSchemaCopyWithImpl;
@override @useResult
$Res call({
 List<CredentialField> fields
});




}
/// @nodoc
class __$CredentialSchemaCopyWithImpl<$Res>
    implements _$CredentialSchemaCopyWith<$Res> {
  __$CredentialSchemaCopyWithImpl(this._self, this._then);

  final _CredentialSchema _self;
  final $Res Function(_CredentialSchema) _then;

/// Create a copy of CredentialSchema
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fields = null,}) {
  return _then(_CredentialSchema(
null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<CredentialField>,
  ));
}


}

// dart format on
