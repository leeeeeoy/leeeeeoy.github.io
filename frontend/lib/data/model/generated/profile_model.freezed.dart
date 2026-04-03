// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileModel {

 int get id; String get name; String get title; String? get region; String? get email; String? get githubUrl; String? get blogUrl; String? get bio;
/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileModelCopyWith<ProfileModel> get copyWith => _$ProfileModelCopyWithImpl<ProfileModel>(this as ProfileModel, _$identity);

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.region, region) || other.region == region)&&(identical(other.email, email) || other.email == email)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.blogUrl, blogUrl) || other.blogUrl == blogUrl)&&(identical(other.bio, bio) || other.bio == bio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,region,email,githubUrl,blogUrl,bio);

@override
String toString() {
  return 'ProfileModel(id: $id, name: $name, title: $title, region: $region, email: $email, githubUrl: $githubUrl, blogUrl: $blogUrl, bio: $bio)';
}


}

/// @nodoc
abstract mixin class $ProfileModelCopyWith<$Res>  {
  factory $ProfileModelCopyWith(ProfileModel value, $Res Function(ProfileModel) _then) = _$ProfileModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String title, String? region, String? email, String? githubUrl, String? blogUrl, String? bio
});




}
/// @nodoc
class _$ProfileModelCopyWithImpl<$Res>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._self, this._then);

  final ProfileModel _self;
  final $Res Function(ProfileModel) _then;

/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? title = null,Object? region = freezed,Object? email = freezed,Object? githubUrl = freezed,Object? blogUrl = freezed,Object? bio = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,githubUrl: freezed == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String?,blogUrl: freezed == blogUrl ? _self.blogUrl : blogUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _ProfileModel implements ProfileModel {
  const _ProfileModel({required this.id, required this.name, required this.title, this.region, this.email, this.githubUrl, this.blogUrl, this.bio});
  factory _ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String title;
@override final  String? region;
@override final  String? email;
@override final  String? githubUrl;
@override final  String? blogUrl;
@override final  String? bio;

/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileModelCopyWith<_ProfileModel> get copyWith => __$ProfileModelCopyWithImpl<_ProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.region, region) || other.region == region)&&(identical(other.email, email) || other.email == email)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.blogUrl, blogUrl) || other.blogUrl == blogUrl)&&(identical(other.bio, bio) || other.bio == bio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,region,email,githubUrl,blogUrl,bio);

@override
String toString() {
  return 'ProfileModel(id: $id, name: $name, title: $title, region: $region, email: $email, githubUrl: $githubUrl, blogUrl: $blogUrl, bio: $bio)';
}


}

/// @nodoc
abstract mixin class _$ProfileModelCopyWith<$Res> implements $ProfileModelCopyWith<$Res> {
  factory _$ProfileModelCopyWith(_ProfileModel value, $Res Function(_ProfileModel) _then) = __$ProfileModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String title, String? region, String? email, String? githubUrl, String? blogUrl, String? bio
});




}
/// @nodoc
class __$ProfileModelCopyWithImpl<$Res>
    implements _$ProfileModelCopyWith<$Res> {
  __$ProfileModelCopyWithImpl(this._self, this._then);

  final _ProfileModel _self;
  final $Res Function(_ProfileModel) _then;

/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? title = null,Object? region = freezed,Object? email = freezed,Object? githubUrl = freezed,Object? blogUrl = freezed,Object? bio = freezed,}) {
  return _then(_ProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,githubUrl: freezed == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String?,blogUrl: freezed == blogUrl ? _self.blogUrl : blogUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
