import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leeeeeoy_portfolio/config/firebase_config.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppConfig {
  static Future<void> initConfig() async {
    await initializeFirebase();
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_API_KEY'] ?? '',
      debug: false,
    );

    await Hive.initFlutter();
    await Hive.openBox<bool>(AppDatabase.themeBoxKey);
  }
}

Future<void> catchError(dynamic error, StackTrace? stack) async {
  if (kIsWeb) {
    return;
  }

  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
}
