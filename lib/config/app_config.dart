import 'package:hive_flutter/hive_flutter.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';

abstract class AppConfig {
  static Future<void> initConfig() async {
    await Hive.initFlutter();
    await Hive.openBox<bool>(AppDatabase.themeBoxKey);
  }
}
