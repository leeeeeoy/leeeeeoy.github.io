// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../career_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CareerDetailModel {

 int get id; int get careerId; String get title; String? get appDescription; String get startDate; String? get endDate; String? get iconUrl; List<String> get screenshots; List<SkillModel> get skills; List<String> get features; List<String> get tasks; List<String> get issues; int get downloadCount; int get userCount; String? get playstoreUrl; String? get appstoreUrl; int get sortOrder;
/// Create a copy of CareerDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CareerDetailModelCopyWith<CareerDetailModel> get copyWith => _$CareerDetailModelCopyWithImpl<CareerDetailModel>(this as CareerDetailModel, _$identity);

  /// Serializes this CareerDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CareerDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.careerId, careerId) || other.careerId == careerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.appDescription, appDescription) || other.appDescription == appDescription)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&const DeepCollectionEquality().equals(other.screenshots, screenshots)&&const DeepCollectionEquality().equals(other.skills, skills)&&const DeepCollectionEquality().equals(other.features, features)&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.issues, issues)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.playstoreUrl, playstoreUrl) || other.playstoreUrl == playstoreUrl)&&(identical(other.appstoreUrl, appstoreUrl) || other.appstoreUrl == appstoreUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,careerId,title,appDescription,startDate,endDate,iconUrl,const DeepCollectionEquality().hash(screenshots),const DeepCollectionEquality().hash(skills),const DeepCollectionEquality().hash(features),const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(issues),downloadCount,userCount,playstoreUrl,appstoreUrl,sortOrder);

@override
String toString() {
  return 'CareerDetailModel(id: $id, careerId: $careerId, title: $title, appDescription: $appDescription, startDate: $startDate, endDate: $endDate, iconUrl: $iconUrl, screenshots: $screenshots, skills: $skills, features: $features, tasks: $tasks, issues: $issues, downloadCount: $downloadCount, userCount: $userCount, playstoreUrl: $playstoreUrl, appstoreUrl: $appstoreUrl, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $CareerDetailModelCopyWith<$Res>  {
  factory $CareerDetailModelCopyWith(CareerDetailModel value, $Res Function(CareerDetailModel) _then) = _$CareerDetailModelCopyWithImpl;
@useResult
$Res call({
 int id, int careerId, String title, String? appDescription, String startDate, String? endDate, String? iconUrl, List<String> screenshots, List<SkillModel> skills, List<String> features, List<String> tasks, List<String> issues, int downloadCount, int userCount, String? playstoreUrl, String? appstoreUrl, int sortOrder
});




}
/// @nodoc
class _$CareerDetailModelCopyWithImpl<$Res>
    implements $CareerDetailModelCopyWith<$Res> {
  _$CareerDetailModelCopyWithImpl(this._self, this._then);

  final CareerDetailModel _self;
  final $Res Function(CareerDetailModel) _then;

/// Create a copy of CareerDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? careerId = null,Object? title = null,Object? appDescription = freezed,Object? startDate = null,Object? endDate = freezed,Object? iconUrl = freezed,Object? screenshots = null,Object? skills = null,Object? features = null,Object? tasks = null,Object? issues = null,Object? downloadCount = null,Object? userCount = null,Object? playstoreUrl = freezed,Object? appstoreUrl = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,careerId: null == careerId ? _self.careerId : careerId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,appDescription: freezed == appDescription ? _self.appDescription : appDescription // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,screenshots: null == screenshots ? _self.screenshots : screenshots // ignore: cast_nullable_to_non_nullable
as List<String>,skills: null == skills ? _self.skills : skills // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<String>,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<String>,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,playstoreUrl: freezed == playstoreUrl ? _self.playstoreUrl : playstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,appstoreUrl: freezed == appstoreUrl ? _self.appstoreUrl : appstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _CareerDetailModel implements CareerDetailModel {
  const _CareerDetailModel({required this.id, required this.careerId, required this.title, this.appDescription, required this.startDate, this.endDate, this.iconUrl, final  List<String> screenshots = const [], final  List<SkillModel> skills = const [], final  List<String> features = const [], final  List<String> tasks = const [], final  List<String> issues = const [], this.downloadCount = 0, this.userCount = 0, this.playstoreUrl, this.appstoreUrl, this.sortOrder = 0}): _screenshots = screenshots,_skills = skills,_features = features,_tasks = tasks,_issues = issues;
  factory _CareerDetailModel.fromJson(Map<String, dynamic> json) => _$CareerDetailModelFromJson(json);

@override final  int id;
@override final  int careerId;
@override final  String title;
@override final  String? appDescription;
@override final  String startDate;
@override final  String? endDate;
@override final  String? iconUrl;
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

 final  List<String> _issues;
@override@JsonKey() List<String> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}

@override@JsonKey() final  int downloadCount;
@override@JsonKey() final  int userCount;
@override final  String? playstoreUrl;
@override final  String? appstoreUrl;
@override@JsonKey() final  int sortOrder;

/// Create a copy of CareerDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CareerDetailModelCopyWith<_CareerDetailModel> get copyWith => __$CareerDetailModelCopyWithImpl<_CareerDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CareerDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CareerDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.careerId, careerId) || other.careerId == careerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.appDescription, appDescription) || other.appDescription == appDescription)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&const DeepCollectionEquality().equals(other._screenshots, _screenshots)&&const DeepCollectionEquality().equals(other._skills, _skills)&&const DeepCollectionEquality().equals(other._features, _features)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._issues, _issues)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.playstoreUrl, playstoreUrl) || other.playstoreUrl == playstoreUrl)&&(identical(other.appstoreUrl, appstoreUrl) || other.appstoreUrl == appstoreUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,careerId,title,appDescription,startDate,endDate,iconUrl,const DeepCollectionEquality().hash(_screenshots),const DeepCollectionEquality().hash(_skills),const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_issues),downloadCount,userCount,playstoreUrl,appstoreUrl,sortOrder);

@override
String toString() {
  return 'CareerDetailModel(id: $id, careerId: $careerId, title: $title, appDescription: $appDescription, startDate: $startDate, endDate: $endDate, iconUrl: $iconUrl, screenshots: $screenshots, skills: $skills, features: $features, tasks: $tasks, issues: $issues, downloadCount: $downloadCount, userCount: $userCount, playstoreUrl: $playstoreUrl, appstoreUrl: $appstoreUrl, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$CareerDetailModelCopyWith<$Res> implements $CareerDetailModelCopyWith<$Res> {
  factory _$CareerDetailModelCopyWith(_CareerDetailModel value, $Res Function(_CareerDetailModel) _then) = __$CareerDetailModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int careerId, String title, String? appDescription, String startDate, String? endDate, String? iconUrl, List<String> screenshots, List<SkillModel> skills, List<String> features, List<String> tasks, List<String> issues, int downloadCount, int userCount, String? playstoreUrl, String? appstoreUrl, int sortOrder
});




}
/// @nodoc
class __$CareerDetailModelCopyWithImpl<$Res>
    implements _$CareerDetailModelCopyWith<$Res> {
  __$CareerDetailModelCopyWithImpl(this._self, this._then);

  final _CareerDetailModel _self;
  final $Res Function(_CareerDetailModel) _then;

/// Create a copy of CareerDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? careerId = null,Object? title = null,Object? appDescription = freezed,Object? startDate = null,Object? endDate = freezed,Object? iconUrl = freezed,Object? screenshots = null,Object? skills = null,Object? features = null,Object? tasks = null,Object? issues = null,Object? downloadCount = null,Object? userCount = null,Object? playstoreUrl = freezed,Object? appstoreUrl = freezed,Object? sortOrder = null,}) {
  return _then(_CareerDetailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,careerId: null == careerId ? _self.careerId : careerId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,appDescription: freezed == appDescription ? _self.appDescription : appDescription // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,screenshots: null == screenshots ? _self._screenshots : screenshots // ignore: cast_nullable_to_non_nullable
as List<String>,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<String>,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<String>,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,playstoreUrl: freezed == playstoreUrl ? _self.playstoreUrl : playstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,appstoreUrl: freezed == appstoreUrl ? _self.appstoreUrl : appstoreUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CareerModel {

 int get id; String get company; String? get logoUrl; String? get role; String? get description; String get joinDate; String? get endDate; int get sortOrder; List<CareerDetailModel> get details;
/// Create a copy of CareerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CareerModelCopyWith<CareerModel> get copyWith => _$CareerModelCopyWithImpl<CareerModel>(this as CareerModel, _$identity);

  /// Serializes this CareerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CareerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.description, description) || other.description == description)&&(identical(other.joinDate, joinDate) || other.joinDate == joinDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.details, details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,company,logoUrl,role,description,joinDate,endDate,sortOrder,const DeepCollectionEquality().hash(details));

@override
String toString() {
  return 'CareerModel(id: $id, company: $company, logoUrl: $logoUrl, role: $role, description: $description, joinDate: $joinDate, endDate: $endDate, sortOrder: $sortOrder, details: $details)';
}


}

/// @nodoc
abstract mixin class $CareerModelCopyWith<$Res>  {
  factory $CareerModelCopyWith(CareerModel value, $Res Function(CareerModel) _then) = _$CareerModelCopyWithImpl;
@useResult
$Res call({
 int id, String company, String? logoUrl, String? role, String? description, String joinDate, String? endDate, int sortOrder, List<CareerDetailModel> details
});




}
/// @nodoc
class _$CareerModelCopyWithImpl<$Res>
    implements $CareerModelCopyWith<$Res> {
  _$CareerModelCopyWithImpl(this._self, this._then);

  final CareerModel _self;
  final $Res Function(CareerModel) _then;

/// Create a copy of CareerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? company = null,Object? logoUrl = freezed,Object? role = freezed,Object? description = freezed,Object? joinDate = null,Object? endDate = freezed,Object? sortOrder = null,Object? details = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,joinDate: null == joinDate ? _self.joinDate : joinDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as List<CareerDetailModel>,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _CareerModel implements CareerModel {
  const _CareerModel({required this.id, required this.company, this.logoUrl, this.role, this.description, required this.joinDate, this.endDate, this.sortOrder = 0, final  List<CareerDetailModel> details = const []}): _details = details;
  factory _CareerModel.fromJson(Map<String, dynamic> json) => _$CareerModelFromJson(json);

@override final  int id;
@override final  String company;
@override final  String? logoUrl;
@override final  String? role;
@override final  String? description;
@override final  String joinDate;
@override final  String? endDate;
@override@JsonKey() final  int sortOrder;
 final  List<CareerDetailModel> _details;
@override@JsonKey() List<CareerDetailModel> get details {
  if (_details is EqualUnmodifiableListView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_details);
}


/// Create a copy of CareerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CareerModelCopyWith<_CareerModel> get copyWith => __$CareerModelCopyWithImpl<_CareerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CareerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CareerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.description, description) || other.description == description)&&(identical(other.joinDate, joinDate) || other.joinDate == joinDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._details, _details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,company,logoUrl,role,description,joinDate,endDate,sortOrder,const DeepCollectionEquality().hash(_details));

@override
String toString() {
  return 'CareerModel(id: $id, company: $company, logoUrl: $logoUrl, role: $role, description: $description, joinDate: $joinDate, endDate: $endDate, sortOrder: $sortOrder, details: $details)';
}


}

/// @nodoc
abstract mixin class _$CareerModelCopyWith<$Res> implements $CareerModelCopyWith<$Res> {
  factory _$CareerModelCopyWith(_CareerModel value, $Res Function(_CareerModel) _then) = __$CareerModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String company, String? logoUrl, String? role, String? description, String joinDate, String? endDate, int sortOrder, List<CareerDetailModel> details
});




}
/// @nodoc
class __$CareerModelCopyWithImpl<$Res>
    implements _$CareerModelCopyWith<$Res> {
  __$CareerModelCopyWithImpl(this._self, this._then);

  final _CareerModel _self;
  final $Res Function(_CareerModel) _then;

/// Create a copy of CareerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? company = null,Object? logoUrl = freezed,Object? role = freezed,Object? description = freezed,Object? joinDate = null,Object? endDate = freezed,Object? sortOrder = null,Object? details = null,}) {
  return _then(_CareerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,joinDate: null == joinDate ? _self.joinDate : joinDate // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as List<CareerDetailModel>,
  ));
}


}

// dart format on
