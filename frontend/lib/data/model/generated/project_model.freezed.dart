// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../project_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectModel {

 int get id; String get title; String? get subtitle; String? get description; String? get iconUrl; String? get mainScreenshot; List<String> get screenshots; List<SkillModel> get skills; List<String> get features; List<String> get tasks; int get downloadCount; int get userCount; String? get githubUrl; String? get playstoreUrl; String? get appstoreUrl; int get sortOrder;
/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectModelCopyWith<ProjectModel> get copyWith => _$ProjectModelCopyWithImpl<ProjectModel>(this as ProjectModel, _$identity);

  /// Serializes this ProjectModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.mainScreenshot, mainScreenshot) || other.mainScreenshot == mainScreenshot)&&const DeepCollectionEquality().equals(other.screenshots, screenshots)&&const DeepCollectionEquality().equals(other.skills, skills)&&const DeepCollectionEquality().equals(other.features, features)&&const DeepCollectionEquality().equals(other.tasks, tasks)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.playstoreUrl, playstoreUrl) || other.playstoreUrl == playstoreUrl)&&(identical(other.appstoreUrl, appstoreUrl) || other.appstoreUrl == appstoreUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,description,iconUrl,mainScreenshot,const DeepCollectionEquality().hash(screenshots),const DeepCollectionEquality().hash(skills),const DeepCollectionEquality().hash(features),const DeepCollectionEquality().hash(tasks),downloadCount,userCount,githubUrl,playstoreUrl,appstoreUrl,sortOrder);

@override
String toString() {
  return 'ProjectModel(id: $id, title: $title, subtitle: $subtitle, description: $description, iconUrl: $iconUrl, mainScreenshot: $mainScreenshot, screenshots: $screenshots, skills: $skills, features: $features, tasks: $tasks, downloadCount: $downloadCount, userCount: $userCount, githubUrl: $githubUrl, playstoreUrl: $playstoreUrl, appstoreUrl: $appstoreUrl, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $ProjectModelCopyWith<$Res>  {
  factory $ProjectModelCopyWith(ProjectModel value, $Res Function(ProjectModel) _then) = _$ProjectModelCopyWithImpl;
@useResult
$Res call({
 int id, String title, String? subtitle, String? description, String? iconUrl, String? mainScreenshot, List<String> screenshots, List<SkillModel> skills, List<String> features, List<String> tasks, int downloadCount, int userCount, String? githubUrl, String? playstoreUrl, String? appstoreUrl, int sortOrder
});




}
/// @nodoc
class _$ProjectModelCopyWithImpl<$Res>
    implements $ProjectModelCopyWith<$Res> {
  _$ProjectModelCopyWithImpl(this._self, this._then);

  final ProjectModel _self;
  final $Res Function(ProjectModel) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subtitle = freezed,Object? description = freezed,Object? iconUrl = freezed,Object? mainScreenshot = freezed,Object? screenshots = null,Object? skills = null,Object? features = null,Object? tasks = null,Object? downloadCount = null,Object? userCount = null,Object? githubUrl = freezed,Object? playstoreUrl = freezed,Object? appstoreUrl = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,mainScreenshot: freezed == mainScreenshot ? _self.mainScreenshot : mainScreenshot // ignore: cast_nullable_to_non_nullable
as String?,screenshots: null == screenshots ? _self.screenshots : screenshots // ignore: cast_nullable_to_non_nullable
as List<String>,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<String>,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,githubUrl: freezed == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String?,playstoreUrl: freezed == playstoreUrl ? _self.playstoreUrl : playstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,appstoreUrl: freezed == appstoreUrl ? _self.appstoreUrl : appstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _ProjectModel implements ProjectModel {
  const _ProjectModel({required this.id, required this.title, this.subtitle, this.description, this.iconUrl, this.mainScreenshot, final  List<String> screenshots = const [], final  List<SkillModel> skills = const [], final  List<String> features = const [], final  List<String> tasks = const [], this.downloadCount = 0, this.userCount = 0, this.githubUrl, this.playstoreUrl, this.appstoreUrl, this.sortOrder = 0}): _screenshots = screenshots,_skills = skills,_features = features,_tasks = tasks;
  factory _ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);

@override final  int id;
@override final  String title;
@override final  String? subtitle;
@override final  String? description;
@override final  String? iconUrl;
@override final  String? mainScreenshot;
 final  List<String> _screenshots;
@override@JsonKey() List<String> get screenshots {
  if (_screenshots is EqualUnmodifiableListView) return _screenshots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_screenshots);
}

 final  List<SkillModel> _skills;
@override@JsonKey() List<SkillModel> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}

 final  List<String> _features;
@override@JsonKey() List<String> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

 final  List<String> _tasks;
@override@JsonKey() List<String> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

@override@JsonKey() final  int downloadCount;
@override@JsonKey() final  int userCount;
@override final  String? githubUrl;
@override final  String? playstoreUrl;
@override final  String? appstoreUrl;
@override@JsonKey() final  int sortOrder;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectModelCopyWith<_ProjectModel> get copyWith => __$ProjectModelCopyWithImpl<_ProjectModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.mainScreenshot, mainScreenshot) || other.mainScreenshot == mainScreenshot)&&const DeepCollectionEquality().equals(other._screenshots, _screenshots)&&const DeepCollectionEquality().equals(other._skills, _skills)&&const DeepCollectionEquality().equals(other._features, _features)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.githubUrl, githubUrl) || other.githubUrl == githubUrl)&&(identical(other.playstoreUrl, playstoreUrl) || other.playstoreUrl == playstoreUrl)&&(identical(other.appstoreUrl, appstoreUrl) || other.appstoreUrl == appstoreUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,subtitle,description,iconUrl,mainScreenshot,const DeepCollectionEquality().hash(_screenshots),const DeepCollectionEquality().hash(_skills),const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_tasks),downloadCount,userCount,githubUrl,playstoreUrl,appstoreUrl,sortOrder);

@override
String toString() {
  return 'ProjectModel(id: $id, title: $title, subtitle: $subtitle, description: $description, iconUrl: $iconUrl, mainScreenshot: $mainScreenshot, screenshots: $screenshots, skills: $skills, features: $features, tasks: $tasks, downloadCount: $downloadCount, userCount: $userCount, githubUrl: $githubUrl, playstoreUrl: $playstoreUrl, appstoreUrl: $appstoreUrl, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ProjectModelCopyWith<$Res> implements $ProjectModelCopyWith<$Res> {
  factory _$ProjectModelCopyWith(_ProjectModel value, $Res Function(_ProjectModel) _then) = __$ProjectModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String? subtitle, String? description, String? iconUrl, String? mainScreenshot, List<String> screenshots, List<SkillModel> skills, List<String> features, List<String> tasks, int downloadCount, int userCount, String? githubUrl, String? playstoreUrl, String? appstoreUrl, int sortOrder
});




}
/// @nodoc
class __$ProjectModelCopyWithImpl<$Res>
    implements _$ProjectModelCopyWith<$Res> {
  __$ProjectModelCopyWithImpl(this._self, this._then);

  final _ProjectModel _self;
  final $Res Function(_ProjectModel) _then;

/// Create a copy of ProjectModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subtitle = freezed,Object? description = freezed,Object? iconUrl = freezed,Object? mainScreenshot = freezed,Object? screenshots = null,Object? skills = null,Object? features = null,Object? tasks = null,Object? downloadCount = null,Object? userCount = null,Object? githubUrl = freezed,Object? playstoreUrl = freezed,Object? appstoreUrl = freezed,Object? sortOrder = null,}) {
  return _then(_ProjectModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,mainScreenshot: freezed == mainScreenshot ? _self.mainScreenshot : mainScreenshot // ignore: cast_nullable_to_non_nullable
as String?,screenshots: null == screenshots ? _self._screenshots : screenshots // ignore: cast_nullable_to_non_nullable
as List<String>,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<String>,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,githubUrl: freezed == githubUrl ? _self.githubUrl : githubUrl // ignore: cast_nullable_to_non_nullable
as String?,playstoreUrl: freezed == playstoreUrl ? _self.playstoreUrl : playstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,appstoreUrl: freezed == appstoreUrl ? _self.appstoreUrl : appstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
