import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
final class AppDatabase {
  const AppDatabase();

  Future<void> initDatabase() async {
    await Hive.initFlutter();
    await Hive.openBox<bool>(_themeBoxKey);
  }

  static const _themeBoxKey = 'theme';
  static const _themeModeKey = 'themeMode';

  bool isDarkMode() => Hive.box<bool>(_themeBoxKey).get(_themeModeKey) ?? true;

  Future<void> setThemeMode(bool isDark) => Hive.box<bool>(_themeBoxKey).put(_themeModeKey, isDark);
}
