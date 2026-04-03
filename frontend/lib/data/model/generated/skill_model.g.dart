// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../skill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SkillModel _$SkillModelFromJson(Map<String, dynamic> json) => _SkillModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  iconUrl: json['icon_url'] as String?,
  category: json['category'] as String,
  proficiency: (json['proficiency'] as num?)?.toInt(),
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SkillModelToJson(_SkillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'category': instance.category,
      'proficiency': instance.proficiency,
      'sort_order': instance.sortOrder,
    };

_SkillsModel _$SkillsModelFromJson(Map<String, dynamic> json) => _SkillsModel(
  language: (json['language'] as List<dynamic>)
      .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  tool: (json['tool'] as List<dynamic>)
      .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  platform: (json['platform'] as List<dynamic>)
      .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SkillsModelToJson(_SkillsModel instance) =>
    <String, dynamic>{
      'language': instance.language.map((e) => e.toJson()).toList(),
      'tool': instance.tool.map((e) => e.toJson()).toList(),
      'platform': instance.platform.map((e) => e.toJson()).toList(),
    };
