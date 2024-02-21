import 'package:freezed_annotation/freezed_annotation.dart';

part 'career_data.freezed.dart';

@freezed
class CarrerData with _$CarrerData {
  const factory CarrerData({
    required String company,
    required DateTime joinDateTime,
    required String description,
    required List<CarrerDetailData> detailDataList,
  }) = _CarrerData;
}

@freezed
class CarrerDetailData with _$CarrerDetailData {
  const factory CarrerDetailData({
    required String title,
    required DateTime startDateTime,
    DateTime? endDateTime,
    required String appDescription,
    @Default([]) List<String> screenshots,
    @Default([]) List<String> skills,
    @Default([]) List<String> features,
    @Default([]) List<String> tasks,
    @Default([]) List<String> issues,
    String? playStoreLink,
    String? appStoreLink,
    @Default(0) int downloadCount,
    @Default(0) int userCount,
  }) = _CarrerDetailData;
}
