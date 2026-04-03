// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../skill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SkillModel {

 int get id; String get name; String? get iconUrl; String get category; int? get proficiency; int get sortOrder;
/// Create a copy of SkillModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillModelCopyWith<SkillModel> get copyWith => _$SkillModelCopyWithImpl<SkillModel>(this as SkillModel, _$identity);

  /// Serializes this SkillModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.proficiency, proficiency) || other.proficiency == proficiency)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,category,proficiency,sortOrder);

@override
String toString() {
  return 'SkillModel(id: $id, name: $name, iconUrl: $iconUrl, category: $category, proficiency: $proficiency, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $SkillModelCopyWith<$Res>  {
  factory $SkillModelCopyWith(SkillModel value, $Res Function(SkillModel) _then) = _$SkillModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? iconUrl, String category, int? proficiency, int sortOrder
});




}
/// @nodoc
class _$SkillModelCopyWithImpl<$Res>
    implements $SkillModelCopyWith<$Res> {
  _$SkillModelCopyWithImpl(this._self, this._then);

  final SkillModel _self;
  final $Res Function(SkillModel) _then;

/// Create a copy of SkillModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,Object? category = null,Object? proficiency = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,proficiency: freezed == proficiency ? _self.proficiency : proficiency // ignore: cast_nullable_to_non_nullable
as int?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _SkillModel implements SkillModel {
  const _SkillModel({required this.id, required this.name, this.iconUrl, required this.category, this.proficiency, this.sortOrder = 0});
  factory _SkillModel.fromJson(Map<String, dynamic> json) => _$SkillModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? iconUrl;
@override final  String category;
@override final  int? proficiency;
@override@JsonKey() final  int sortOrder;

/// Create a copy of SkillModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkillModelCopyWith<_SkillModel> get copyWith => __$SkillModelCopyWithImpl<_SkillModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkillModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkillModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.proficiency, proficiency) || other.proficiency == proficiency)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,category,proficiency,sortOrder);

@override
String toString() {
  return 'SkillModel(id: $id, name: $name, iconUrl: $iconUrl, category: $category, proficiency: $proficiency, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$SkillModelCopyWith<$Res> implements $SkillModelCopyWith<$Res> {
  factory _$SkillModelCopyWith(_SkillModel value, $Res Function(_SkillModel) _then) = __$SkillModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? iconUrl, String category, int? proficiency, int sortOrder
});




}
/// @nodoc
class __$SkillModelCopyWithImpl<$Res>
    implements _$SkillModelCopyWith<$Res> {
  __$SkillModelCopyWithImpl(this._self, this._then);

  final _SkillModel _self;
  final $Res Function(_SkillModel) _then;

/// Create a copy of SkillModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,Object? category = null,Object? proficiency = freezed,Object? sortOrder = null,}) {
  return _then(_SkillModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,proficiency: freezed == proficiency ? _self.proficiency : proficiency // ignore: cast_nullable_to_non_nullable
as int?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SkillsModel {

 List<SkillModel> get language; List<SkillModel> get tool; List<SkillModel> get platform;
/// Create a copy of SkillsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkillsModelCopyWith<SkillsModel> get copyWith => _$SkillsModelCopyWithImpl<SkillsModel>(this as SkillsModel, _$identity);

  /// Serializes this SkillsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkillsModel&&const DeepCollectionEquality().equals(other.language, language)&&const DeepCollectionEquality().equals(other.tool, tool)&&const DeepCollectionEquality().equals(other.platform, platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(language),const DeepCollectionEquality().hash(tool),const DeepCollectionEquality().hash(platform));

@override
String toString() {
  return 'SkillsModel(language: $language, tool: $tool, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $SkillsModelCopyWith<$Res>  {
  factory $SkillsModelCopyWith(SkillsModel value, $Res Function(SkillsModel) _then) = _$SkillsModelCopyWithImpl;
@useResult
$Res call({
 List<SkillModel> language, List<SkillModel> tool, List<SkillModel> platform
});




}
/// @nodoc
class _$SkillsModelCopyWithImpl<$Res>
    implements $SkillsModelCopyWith<$Res> {
  _$SkillsModelCopyWithImpl(this._self, this._then);

  final SkillsModel _self;
  final $Res Function(SkillsModel) _then;

/// Create a copy of SkillsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? tool = null,Object? platform = null,}) {
  return _then(_self.copyWith(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _SkillsModel extends SkillsModel {
  const _SkillsModel({required final  List<SkillModel> language, required final  List<SkillModel> tool, required final  List<SkillModel> platform}): _language = language,_tool = tool,_platform = platform,super._();
  factory _SkillsModel.fromJson(Map<String, dynamic> json) => _$SkillsModelFromJson(json);

 final  List<SkillModel> _language;
@override List<SkillModel> get language {
  if (_language is EqualUnmodifiableListView) return _language;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_language);
}

 final  List<SkillModel> _tool;
@override List<SkillModel> get tool {
  if (_tool is EqualUnmodifiableListView) return _tool;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tool);
}

 final  List<SkillModel> _platform;
@override List<SkillModel> get platform {
  if (_platform is EqualUnmodifiableListView) return _platform;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platform);
}


/// Create a copy of SkillsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkillsModelCopyWith<_SkillsModel> get copyWith => __$SkillsModelCopyWithImpl<_SkillsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkillsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkillsModel&&const DeepCollectionEquality().equals(other._language, _language)&&const DeepCollectionEquality().equals(other._tool, _tool)&&const DeepCollectionEquality().equals(other._platform, _platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_language),const DeepCollectionEquality().hash(_tool),const DeepCollectionEquality().hash(_platform));

@override
String toString() {
  return 'SkillsModel(language: $language, tool: $tool, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$SkillsModelCopyWith<$Res> implements $SkillsModelCopyWith<$Res> {
  factory _$SkillsModelCopyWith(_SkillsModel value, $Res Function(_SkillsModel) _then) = __$SkillsModelCopyWithImpl;
@override @useResult
$Res call({
 List<SkillModel> language, List<SkillModel> tool, List<SkillModel> platform
});




}
/// @nodoc
class __$SkillsModelCopyWithImpl<$Res>
    implements _$SkillsModelCopyWith<$Res> {
  __$SkillsModelCopyWithImpl(this._self, this._then);

  final _SkillsModel _self;
  final $Res Function(_SkillsModel) _then;

/// Create a copy of SkillsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? tool = null,Object? platform = null,}) {
  return _then(_SkillsModel(
language: null == language ? _self._language : language // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,tool: null == tool ? _self._tool : tool // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,platform: null == platform ? _self._platform : platform // ignore: cast_nullable_to_non_nullable
as List<SkillModel>,
  ));
}


}

// dart format on
