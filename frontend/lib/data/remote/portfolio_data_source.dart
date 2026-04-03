import 'package:injectable/injectable.dart';
import 'package:leeeeeoy_portfolio/data/model/career_model.dart';
import 'package:leeeeeoy_portfolio/data/model/profile_model.dart';
import 'package:leeeeeoy_portfolio/data/model/project_model.dart';
import 'package:leeeeeoy_portfolio/data/model/skill_model.dart';
import 'package:leeeeeoy_portfolio/data/remote/api_client.dart';

@lazySingleton
class PortfolioDataSource {
  final ApiClient _apiClient;

  PortfolioDataSource(this._apiClient);

  Future<ProfileModel> fetchProfile() async {
    final response = await _apiClient.dio.get('/api/profile');
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SkillsModel> fetchSkills() async {
    final response = await _apiClient.dio.get('/api/skills');
    return SkillsModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<CareerModel>> fetchCareers() async {
    final response = await _apiClient.dio.get('/api/careers');
    return (response.data as List<dynamic>)
        .map((e) => CareerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProjectModel>> fetchProjects() async {
    final response = await _apiClient.dio.get('/api/projects');
    return (response.data as List<dynamic>)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
