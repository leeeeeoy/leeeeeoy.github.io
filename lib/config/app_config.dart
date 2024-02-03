import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:leeeeeoy_portfolio/config/firebase_config.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';
import 'package:leeeeeoy_portfolio/di/di.dart';

abstract class AppConfig {
  static Future<void> initConfig() async {
    configureDependencies();

    await initializeFirebase();

    await getIt<AppDatabase>().initDatabase();
  }
}

Future<void> catchError(dynamic error, StackTrace? stack) async {
  if (kIsWeb) {
    return;
  }

  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
}
