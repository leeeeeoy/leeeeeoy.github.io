import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/skill_model.freezed.dart';
part 'generated/skill_model.g.dart';

@freezed
abstract class SkillModel with _$SkillModel {
  const factory SkillModel({
    required int id,
    required String name,
    String? iconUrl,
    required String category,
    int? proficiency,
    @Default(0) int sortOrder,
  }) = _SkillModel;

  factory SkillModel.fromJson(Map<String, dynamic> json) => _$SkillModelFromJson(json);
}

@freezed
abstract class SkillsModel with _$SkillsModel {
  const SkillsModel._();

  const factory SkillsModel({
    required List<SkillModel> language,
    required List<SkillModel> tool,
    required List<SkillModel> platform,
  }) = _SkillsModel;

  factory SkillsModel.fromJson(Map<String, dynamic> json) => _$SkillsModelFromJson(json);

  List<SkillModel> get all => [...language, ...tool, ...platform];
}
