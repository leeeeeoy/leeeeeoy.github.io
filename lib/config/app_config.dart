import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leeeeeoy_portfolio/config/firebase_config.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';

abstract class AppConfig {
  static Future<void> initConfig() async {
    await initializeFirebase();

    await Hive.initFlutter();
    await Hive.openBox<bool>(AppDatabase.themeBoxKey);
  }
}

Future<void> catchError(dynamic error, StackTrace? stack) async {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
}
