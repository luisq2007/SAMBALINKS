// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Category {

 String get id; String get name; DateTime get createdAt; DateTime get updatedAt; int get sortOrder;/// Hex de la paleta, p. ej. "#B9ECFA".
 String? get color;/// Clave de un catálogo propio de iconos, nunca un codePoint.
 String? get icon;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,sortOrder,color,icon);

@override
String toString() {
  return 'Category(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, sortOrder: $sortOrder, color: $color, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, int sortOrder, String? color, String? icon
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? sortOrder = null,Object? color = freezed,Object? icon = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  int sortOrder,  String? color,  String? icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.sortOrder,_that.color,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  int sortOrder,  String? color,  String? icon)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.sortOrder,_that.color,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  int sortOrder,  String? color,  String? icon)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.sortOrder,_that.color,_that.icon);case _:
  return null;

}
}

}

/// @nodoc


class _Category extends Category {
  const _Category({required this.id, required this.name, required this.createdAt, required this.updatedAt, this.sortOrder = 0, this.color, this.icon}): super._();
  

@override final  String id;
@override final  String name;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  int sortOrder;
/// Hex de la paleta, p. ej. "#B9ECFA".
@override final  String? color;
/// Clave de un catálogo propio de iconos, nunca un codePoint.
@override final  String? icon;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,sortOrder,color,icon);

@override
String toString() {
  return 'Category(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, sortOrder: $sortOrder, color: $color, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, int sortOrder, String? color, String? icon
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? sortOrder = null,Object? color = freezed,Object? icon = freezed,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CategorySummary {

 Category get category; int get linkCount;
/// Create a copy of CategorySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySummaryCopyWith<CategorySummary> get copyWith => _$CategorySummaryCopyWithImpl<CategorySummary>(this as CategorySummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySummary&&(identical(other.category, category) || other.category == category)&&(identical(other.linkCount, linkCount) || other.linkCount == linkCount));
}


@override
int get hashCode => Object.hash(runtimeType,category,linkCount);

@override
String toString() {
  return 'CategorySummary(category: $category, linkCount: $linkCount)';
}


}

/// @nodoc
abstract mixin class $CategorySummaryCopyWith<$Res>  {
  factory $CategorySummaryCopyWith(CategorySummary value, $Res Function(CategorySummary) _then) = _$CategorySummaryCopyWithImpl;
@useResult
$Res call({
 Category category, int linkCount
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$CategorySummaryCopyWithImpl<$Res>
    implements $CategorySummaryCopyWith<$Res> {
  _$CategorySummaryCopyWithImpl(this._self, this._then);

  final CategorySummary _self;
  final $Res Function(CategorySummary) _then;

/// Create a copy of CategorySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? linkCount = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,linkCount: null == linkCount ? _self.linkCount : linkCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of CategorySummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategorySummary].
extension CategorySummaryPatterns on CategorySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySummary value)  $default,){
final _that = this;
switch (_that) {
case _CategorySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySummary value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  int linkCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySummary() when $default != null:
return $default(_that.category,_that.linkCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  int linkCount)  $default,) {final _that = this;
switch (_that) {
case _CategorySummary():
return $default(_that.category,_that.linkCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  int linkCount)?  $default,) {final _that = this;
switch (_that) {
case _CategorySummary() when $default != null:
return $default(_that.category,_that.linkCount);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySummary extends CategorySummary {
  const _CategorySummary({required this.category, required this.linkCount}): super._();
  

@override final  Category category;
@override final  int linkCount;

/// Create a copy of CategorySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySummaryCopyWith<_CategorySummary> get copyWith => __$CategorySummaryCopyWithImpl<_CategorySummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySummary&&(identical(other.category, category) || other.category == category)&&(identical(other.linkCount, linkCount) || other.linkCount == linkCount));
}


@override
int get hashCode => Object.hash(runtimeType,category,linkCount);

@override
String toString() {
  return 'CategorySummary(category: $category, linkCount: $linkCount)';
}


}

/// @nodoc
abstract mixin class _$CategorySummaryCopyWith<$Res> implements $CategorySummaryCopyWith<$Res> {
  factory _$CategorySummaryCopyWith(_CategorySummary value, $Res Function(_CategorySummary) _then) = __$CategorySummaryCopyWithImpl;
@override @useResult
$Res call({
 Category category, int linkCount
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$CategorySummaryCopyWithImpl<$Res>
    implements _$CategorySummaryCopyWith<$Res> {
  __$CategorySummaryCopyWithImpl(this._self, this._then);

  final _CategorySummary _self;
  final $Res Function(_CategorySummary) _then;

/// Create a copy of CategorySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? linkCount = null,}) {
  return _then(_CategorySummary(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,linkCount: null == linkCount ? _self.linkCount : linkCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CategorySummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
