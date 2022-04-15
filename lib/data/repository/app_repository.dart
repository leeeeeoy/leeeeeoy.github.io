import 'package:leeeeeoy_portfolio/data/local/app_database.dart';

class AppRepository {
  bool getThemeMode() => AppDatabase().isDarkMode();

  Future<void> setThmeMode(bool isDark) => AppDatabase().setThemeMode(isDark);
}
