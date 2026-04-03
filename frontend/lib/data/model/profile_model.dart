import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/profile_model.freezed.dart';
part 'generated/profile_model.g.dart';

@freezed
abstract class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required int id,
    required String name,
    required String title,
    String? region,
    String? email,
    String? githubUrl,
    String? blogUrl,
    String? bio,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
}
