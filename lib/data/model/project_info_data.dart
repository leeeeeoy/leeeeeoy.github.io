import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_info_data.freezed.dart';

@freezed
class ProjectInfoData with _$ProjectInfoData {
  const factory ProjectInfoData({
    required String title,
    required String iconPath,
    required String mainScreenshotPath,
    required String subTitle,
    required String description,
    @Default([]) List<String> screenshots,
    @Default([]) List<String> skills,
    @Default([]) List<String> features,
    String? githubLink,
    String? playStoreLink,
    String? appStoreLink,
    @Default(0) int downloadCount,
  }) = _ProjectInfoData;
}
