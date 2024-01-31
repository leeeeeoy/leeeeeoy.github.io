import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:leeeeeoy_portfolio/app.dart';
import 'package:leeeeeoy_portfolio/config/app_config.dart';
import 'package:leeeeeoy_portfolio/data/repository/app_repository.dart';
import 'package:leeeeeoy_portfolio/di/di.dart';
import 'package:leeeeeoy_portfolio/feature/common/bloc/theme_bloc.dart';
import 'package:leeeeeoy_portfolio/util/logger/app_bloc_observer.dart';

void main() async {
  runZonedGuarded(
    () async {
      usePathUrlStrategy();

      WidgetsFlutterBinding.ensureInitialized();

      await AppConfig.initConfig();

      Bloc.observer = AppBlocObserver();

      runApp(
        BlocProvider(
          create: (context) => ThemeBloc(appRepository: getIt<AppRepository>()),
          child: const App(),
        ),
      );
    },
    catchError,
  );
}
