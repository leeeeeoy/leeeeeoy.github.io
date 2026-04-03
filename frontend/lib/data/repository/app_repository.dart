import 'package:injectable/injectable.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';

@LazySingleton()
final class AppRepository {
  const AppRepository({required this.appDatabase});

  final AppDatabase appDatabase;

  bool getThemeMode() => appDatabase.isDarkMode();

  Future<void> setThemeMode(bool isDark) => appDatabase.setThemeMode(isDark);
}
