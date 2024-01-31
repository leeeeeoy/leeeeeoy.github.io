import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leeeeeoy_portfolio/config/firebase_config.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';
import 'package:leeeeeoy_portfolio/di/di.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AppConfig {
  static Future<void> initConfig() async {
    configureDependencies();

    await initializeFirebase();
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_API_KEY'] ?? '',
      debug: false,
    );

    await getIt<AppDatabase>().initDatabase();
  }
}

Future<void> catchError(dynamic error, StackTrace? stack) async {
  if (kIsWeb) {
    return;
  }

  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
}
