// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) =>
    _ProfileModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      title: json['title'] as String,
      region: json['region'] as String?,
      email: json['email'] as String?,
      githubUrl: json['github_url'] as String?,
      blogUrl: json['blog_url'] as String?,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$ProfileModelToJson(_ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'region': instance.region,
      'email': instance.email,
      'github_url': instance.githubUrl,
      'blog_url': instance.blogUrl,
      'bio': instance.bio,
    };
