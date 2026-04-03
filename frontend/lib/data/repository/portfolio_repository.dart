import 'package:injectable/injectable.dart';
import 'package:leeeeeoy_portfolio/data/model/career_model.dart';
import 'package:leeeeeoy_portfolio/data/model/profile_model.dart';
import 'package:leeeeeoy_portfolio/data/model/project_model.dart';
import 'package:leeeeeoy_portfolio/data/model/skill_model.dart';
import 'package:leeeeeoy_portfolio/data/remote/portfolio_data_source.dart';

@lazySingleton
class PortfolioRepository {
  final PortfolioDataSource _dataSource;

  PortfolioRepository(this._dataSource);

  Future<ProfileModel> getProfile() => _dataSource.fetchProfile();

  Future<SkillsModel> getSkills() => _dataSource.fetchSkills();

  Future<List<CareerModel>> getCareers() => _dataSource.fetchCareers();

  Future<List<ProjectModel>> getProjects() => _dataSource.fetchProjects();
}
