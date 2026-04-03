import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leeeeeoy_portfolio/data/model/skill_model.dart';

part 'generated/project_model.freezed.dart';
part 'generated/project_model.g.dart';

@freezed
abstract class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    required int id,
    required String title,
    String? subtitle,
    String? description,
    String? iconUrl,
    String? mainScreenshot,
    @Default([]) List<String> screenshots,
    @Default([]) List<SkillModel> skills,
    @Default([]) List<String> features,
    @Default([]) List<String> tasks,
    @Default(0) int downloadCount,
    @Default(0) int userCount,
    String? githubUrl,
    String? playstoreUrl,
    String? appstoreUrl,
    @Default(0) int sortOrder,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
}
