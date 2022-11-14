import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leeeeeoy_portfolio/app.dart';
import 'package:leeeeeoy_portfolio/config/app_config.dart';
import 'package:leeeeeoy_portfolio/util/logger/provider_logger.dart';

void main() async {
  await AppConfig.initConfig();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      observers: [
        ProviderLogger(),
      ],
      child: const App(),
    ),
  );
}
