// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkCard {

 String get id; String get url; String get canonicalUrl; String get domain; DateTime get createdAt; DateTime get updatedAt; LinkPlatform get platform; CardStatus get status; MetadataStatus get metadataStatus; String? get title; String? get description; String? get imageUrl; String? get localImage; String? get faviconUrl; String? get siteName; String? get notes; String? get originalSharedText; DateTime? get metadataFetchedAt;
/// Create a copy of LinkCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkCardCopyWith<LinkCard> get copyWith => _$LinkCardCopyWithImpl<LinkCard>(this as LinkCard, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkCard&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.canonicalUrl, canonicalUrl) || other.canonicalUrl == canonicalUrl)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.status, status) || other.status == status)&&(identical(other.metadataStatus, metadataStatus) || other.metadataStatus == metadataStatus)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.localImage, localImage) || other.localImage == localImage)&&(identical(other.faviconUrl, faviconUrl) || other.faviconUrl == faviconUrl)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.originalSharedText, originalSharedText) || other.originalSharedText == originalSharedText)&&(identical(other.metadataFetchedAt, metadataFetchedAt) || other.metadataFetchedAt == metadataFetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,canonicalUrl,domain,createdAt,updatedAt,platform,status,metadataStatus,title,description,imageUrl,localImage,faviconUrl,siteName,notes,originalSharedText,metadataFetchedAt);

@override
String toString() {
  return 'LinkCard(id: $id, url: $url, canonicalUrl: $canonicalUrl, domain: $domain, createdAt: $createdAt, updatedAt: $updatedAt, platform: $platform, status: $status, metadataStatus: $metadataStatus, title: $title, description: $description, imageUrl: $imageUrl, localImage: $localImage, faviconUrl: $faviconUrl, siteName: $siteName, notes: $notes, originalSharedText: $originalSharedText, metadataFetchedAt: $metadataFetchedAt)';
}


}

/// @nodoc
abstract mixin class $LinkCardCopyWith<$Res>  {
  factory $LinkCardCopyWith(LinkCard value, $Res Function(LinkCard) _then) = _$LinkCardCopyWithImpl;
@useResult
$Res call({
 String id, String url, String canonicalUrl, String domain, DateTime createdAt, DateTime updatedAt, LinkPlatform platform, CardStatus status, MetadataStatus metadataStatus, String? title, String? description, String? imageUrl, String? localImage, String? faviconUrl, String? siteName, String? notes, String? originalSharedText, DateTime? metadataFetchedAt
});




}
/// @nodoc
class _$LinkCardCopyWithImpl<$Res>
    implements $LinkCardCopyWith<$Res> {
  _$LinkCardCopyWithImpl(this._self, this._then);

  final LinkCard _self;
  final $Res Function(LinkCard) _then;

/// Create a copy of LinkCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? canonicalUrl = null,Object? domain = null,Object? createdAt = null,Object? updatedAt = null,Object? platform = null,Object? status = null,Object? metadataStatus = null,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? localImage = freezed,Object? faviconUrl = freezed,Object? siteName = freezed,Object? notes = freezed,Object? originalSharedText = freezed,Object? metadataFetchedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,canonicalUrl: null == canonicalUrl ? _self.canonicalUrl : canonicalUrl // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as LinkPlatform,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardStatus,metadataStatus: null == metadataStatus ? _self.metadataStatus : metadataStatus // ignore: cast_nullable_to_non_nullable
as MetadataStatus,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,localImage: freezed == localImage ? _self.localImage : localImage // ignore: cast_nullable_to_non_nullable
as String?,faviconUrl: freezed == faviconUrl ? _self.faviconUrl : faviconUrl // ignore: cast_nullable_to_non_nullable
as String?,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,originalSharedText: freezed == originalSharedText ? _self.originalSharedText : originalSharedText // ignore: cast_nullable_to_non_nullable
as String?,metadataFetchedAt: freezed == metadataFetchedAt ? _self.metadataFetchedAt : metadataFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkCard].
extension LinkCardPatterns on LinkCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkCard value)  $default,){
final _that = this;
switch (_that) {
case _LinkCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkCard value)?  $default,){
final _that = this;
switch (_that) {
case _LinkCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String canonicalUrl,  String domain,  DateTime createdAt,  DateTime updatedAt,  LinkPlatform platform,  CardStatus status,  MetadataStatus metadataStatus,  String? title,  String? description,  String? imageUrl,  String? localImage,  String? faviconUrl,  String? siteName,  String? notes,  String? originalSharedText,  DateTime? metadataFetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkCard() when $default != null:
return $default(_that.id,_that.url,_that.canonicalUrl,_that.domain,_that.createdAt,_that.updatedAt,_that.platform,_that.status,_that.metadataStatus,_that.title,_that.description,_that.imageUrl,_that.localImage,_that.faviconUrl,_that.siteName,_that.notes,_that.originalSharedText,_that.metadataFetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String canonicalUrl,  String domain,  DateTime createdAt,  DateTime updatedAt,  LinkPlatform platform,  CardStatus status,  MetadataStatus metadataStatus,  String? title,  String? description,  String? imageUrl,  String? localImage,  String? faviconUrl,  String? siteName,  String? notes,  String? originalSharedText,  DateTime? metadataFetchedAt)  $default,) {final _that = this;
switch (_that) {
case _LinkCard():
return $default(_that.id,_that.url,_that.canonicalUrl,_that.domain,_that.createdAt,_that.updatedAt,_that.platform,_that.status,_that.metadataStatus,_that.title,_that.description,_that.imageUrl,_that.localImage,_that.faviconUrl,_that.siteName,_that.notes,_that.originalSharedText,_that.metadataFetchedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String canonicalUrl,  String domain,  DateTime createdAt,  DateTime updatedAt,  LinkPlatform platform,  CardStatus status,  MetadataStatus metadataStatus,  String? title,  String? description,  String? imageUrl,  String? localImage,  String? faviconUrl,  String? siteName,  String? notes,  String? originalSharedText,  DateTime? metadataFetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _LinkCard() when $default != null:
return $default(_that.id,_that.url,_that.canonicalUrl,_that.domain,_that.createdAt,_that.updatedAt,_that.platform,_that.status,_that.metadataStatus,_that.title,_that.description,_that.imageUrl,_that.localImage,_that.faviconUrl,_that.siteName,_that.notes,_that.originalSharedText,_that.metadataFetchedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LinkCard extends LinkCard {
  const _LinkCard({required this.id, required this.url, required this.canonicalUrl, required this.domain, required this.createdAt, required this.updatedAt, this.platform = LinkPlatform.other, this.status = CardStatus.pending, this.metadataStatus = MetadataStatus.pending, this.title, this.description, this.imageUrl, this.localImage, this.faviconUrl, this.siteName, this.notes, this.originalSharedText, this.metadataFetchedAt}): super._();
  

@override final  String id;
@override final  String url;
@override final  String canonicalUrl;
@override final  String domain;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  LinkPlatform platform;
@override@JsonKey() final  CardStatus status;
@override@JsonKey() final  MetadataStatus metadataStatus;
@override final  String? title;
@override final  String? description;
@override final  String? imageUrl;
@override final  String? localImage;
@override final  String? faviconUrl;
@override final  String? siteName;
@override final  String? notes;
@override final  String? originalSharedText;
@override final  DateTime? metadataFetchedAt;

/// Create a copy of LinkCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkCardCopyWith<_LinkCard> get copyWith => __$LinkCardCopyWithImpl<_LinkCard>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkCard&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.canonicalUrl, canonicalUrl) || other.canonicalUrl == canonicalUrl)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.status, status) || other.status == status)&&(identical(other.metadataStatus, metadataStatus) || other.metadataStatus == metadataStatus)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.localImage, localImage) || other.localImage == localImage)&&(identical(other.faviconUrl, faviconUrl) || other.faviconUrl == faviconUrl)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.originalSharedText, originalSharedText) || other.originalSharedText == originalSharedText)&&(identical(other.metadataFetchedAt, metadataFetchedAt) || other.metadataFetchedAt == metadataFetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,canonicalUrl,domain,createdAt,updatedAt,platform,status,metadataStatus,title,description,imageUrl,localImage,faviconUrl,siteName,notes,originalSharedText,metadataFetchedAt);

@override
String toString() {
  return 'LinkCard(id: $id, url: $url, canonicalUrl: $canonicalUrl, domain: $domain, createdAt: $createdAt, updatedAt: $updatedAt, platform: $platform, status: $status, metadataStatus: $metadataStatus, title: $title, description: $description, imageUrl: $imageUrl, localImage: $localImage, faviconUrl: $faviconUrl, siteName: $siteName, notes: $notes, originalSharedText: $originalSharedText, metadataFetchedAt: $metadataFetchedAt)';
}


}

/// @nodoc
abstract mixin class _$LinkCardCopyWith<$Res> implements $LinkCardCopyWith<$Res> {
  factory _$LinkCardCopyWith(_LinkCard value, $Res Function(_LinkCard) _then) = __$LinkCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String canonicalUrl, String domain, DateTime createdAt, DateTime updatedAt, LinkPlatform platform, CardStatus status, MetadataStatus metadataStatus, String? title, String? description, String? imageUrl, String? localImage, String? faviconUrl, String? siteName, String? notes, String? originalSharedText, DateTime? metadataFetchedAt
});




}
/// @nodoc
class __$LinkCardCopyWithImpl<$Res>
    implements _$LinkCardCopyWith<$Res> {
  __$LinkCardCopyWithImpl(this._self, this._then);

  final _LinkCard _self;
  final $Res Function(_LinkCard) _then;

/// Create a copy of LinkCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? canonicalUrl = null,Object? domain = null,Object? createdAt = null,Object? updatedAt = null,Object? platform = null,Object? status = null,Object? metadataStatus = null,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? localImage = freezed,Object? faviconUrl = freezed,Object? siteName = freezed,Object? notes = freezed,Object? originalSharedText = freezed,Object? metadataFetchedAt = freezed,}) {
  return _then(_LinkCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,canonicalUrl: null == canonicalUrl ? _self.canonicalUrl : canonicalUrl // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as LinkPlatform,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CardStatus,metadataStatus: null == metadataStatus ? _self.metadataStatus : metadataStatus // ignore: cast_nullable_to_non_nullable
as MetadataStatus,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,localImage: freezed == localImage ? _self.localImage : localImage // ignore: cast_nullable_to_non_nullable
as String?,faviconUrl: freezed == faviconUrl ? _self.faviconUrl : faviconUrl // ignore: cast_nullable_to_non_nullable
as String?,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,originalSharedText: freezed == originalSharedText ? _self.originalSharedText : originalSharedText // ignore: cast_nullable_to_non_nullable
as String?,metadataFetchedAt: freezed == metadataFetchedAt ? _self.metadataFetchedAt : metadataFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
