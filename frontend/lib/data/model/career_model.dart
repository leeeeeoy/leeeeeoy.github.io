import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leeeeeoy_portfolio/data/model/skill_model.dart';

part 'generated/career_model.freezed.dart';
part 'generated/career_model.g.dart';

@freezed
abstract class CareerDetailModel with _$CareerDetailModel {
  const factory CareerDetailModel({
    required int id,
    required int careerId,
    required String title,
    String? appDescription,
    required String startDate,
    String? endDate,
    String? iconUrl,
    @Default([]) List<String> screenshots,
    @Default([]) List<SkillModel> skills,
    @Default([]) List<String> features,
    @Default([]) List<String> tasks,
    @Default([]) List<String> issues,
    @Default(0) int downloadCount,
    @Default(0) int userCount,
    String? playstoreUrl,
    String? appstoreUrl,
    @Default(0) int sortOrder,
  }) = _CareerDetailModel;

  factory CareerDetailModel.fromJson(Map<String, dynamic> json) => _$CareerDetailModelFromJson(json);
}

@freezed
abstract class CareerModel with _$CareerModel {
  const factory CareerModel({
    required int id,
    required String company,
    String? logoUrl,
    String? role,
    String? description,
    required String joinDate,
    String? endDate,
    @Default(0) int sortOrder,
    @Default([]) List<CareerDetailModel> details,
  }) = _CareerModel;

  factory CareerModel.fromJson(Map<String, dynamic> json) => _$CareerModelFromJson(json);
}
