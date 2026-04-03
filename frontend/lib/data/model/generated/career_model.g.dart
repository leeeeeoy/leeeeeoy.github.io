// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../career_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CareerDetailModel _$CareerDetailModelFromJson(
  Map<String, dynamic> json,
) => _CareerDetailModel(
  id: (json['id'] as num).toInt(),
  careerId: (json['career_id'] as num).toInt(),
  title: json['title'] as String,
  appDescription: json['app_description'] as String?,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String?,
  iconUrl: json['icon_url'] as String?,
  screenshots:
      (json['screenshots'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  skills:
      (json['skills'] as List<dynamic>?)
          ?.map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  tasks:
      (json['tasks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  issues:
      (json['issues'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  downloadCount: (json['download_count'] as num?)?.toInt() ?? 0,
  userCount: (json['user_count'] as num?)?.toInt() ?? 0,
  playstoreUrl: json['playstore_url'] as String?,
  appstoreUrl: json['appstore_url'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CareerDetailModelToJson(_CareerDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'career_id': instance.careerId,
      'title': instance.title,
      'app_description': instance.appDescription,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'icon_url': instance.iconUrl,
      'screenshots': instance.screenshots,
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'features': instance.features,
      'tasks': instance.tasks,
      'issues': instance.issues,
      'download_count': instance.downloadCount,
      'user_count': instance.userCount,
      'playstore_url': instance.playstoreUrl,
      'appstore_url': instance.appstoreUrl,
      'sort_order': instance.sortOrder,
    };

_CareerModel _$CareerModelFromJson(Map<String, dynamic> json) => _CareerModel(
  id: (json['id'] as num).toInt(),
  company: json['company'] as String,
  logoUrl: json['logo_url'] as String?,
  role: json['role'] as String?,
  description: json['description'] as String?,
  joinDate: json['join_date'] as String,
  endDate: json['end_date'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  details:
      (json['details'] as List<dynamic>?)
          ?.map((e) => CareerDetailModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CareerModelToJson(_CareerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company,
      'logo_url': instance.logoUrl,
      'role': instance.role,
      'description': instance.description,
      'join_date': instance.joinDate,
      'end_date': instance.endDate,
      'sort_order': instance.sortOrder,
      'details': instance.details.map((e) => e.toJson()).toList(),
    };
