import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:leeeeeoy_portfolio/firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
  }

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(kReleaseMode);

  await FirebasePerformance.instance.setPerformanceCollectionEnabled(kReleaseMode);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}
