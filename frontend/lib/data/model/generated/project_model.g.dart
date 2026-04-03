// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) =>
    _ProjectModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      mainScreenshot: json['main_screenshot'] as String?,
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
          (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tasks:
          (json['tasks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      downloadCount: (json['download_count'] as num?)?.toInt() ?? 0,
      userCount: (json['user_count'] as num?)?.toInt() ?? 0,
      githubUrl: json['github_url'] as String?,
      playstoreUrl: json['playstore_url'] as String?,
      appstoreUrl: json['appstore_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProjectModelToJson(_ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'description': instance.description,
      'icon_url': instance.iconUrl,
      'main_screenshot': instance.mainScreenshot,
      'screenshots': instance.screenshots,
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'features': instance.features,
      'tasks': instance.tasks,
      'download_count': instance.downloadCount,
      'user_count': instance.userCount,
      'github_url': instance.githubUrl,
      'playstore_url': instance.playstoreUrl,
      'appstore_url': instance.appstoreUrl,
      'sort_order': instance.sortOrder,
    };
