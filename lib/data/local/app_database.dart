import 'package:hive_flutter/hive_flutter.dart';

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  static const themeBoxKey = 'theme';
  static const themeModeKey = 'themeMode';

  bool isDarkMode() => Hive.box<bool>(themeBoxKey).get(themeModeKey) ?? true;

  Future<void> setThemeMode(bool isDark) => Hive.box<bool>(themeBoxKey).put(themeModeKey, isDark);
}
