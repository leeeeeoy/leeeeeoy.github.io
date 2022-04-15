import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leeeeeoy_portfolio/app.dart';
import 'package:leeeeeoy_portfolio/app_config.dart';
import 'package:leeeeeoy_portfolio/bloc/theme_bloc.dart';
import 'package:leeeeeoy_portfolio/data/local/app_database.dart';
import 'package:leeeeeoy_portfolio/data/repository/app_repository.dart';
import 'package:leeeeeoy_portfolio/util/logger/app_bloc_observer.dart';

void main() async {
  await AppConfig.initConfig();
  WidgetsFlutterBinding.ensureInitialized();
  BlocOverrides.runZoned(
    () => runApp(
      BlocProvider(
        create: (context) => ThemeBloc(
          appRepository: AppRepository(),
          isDark: AppDatabase().isDarkMode(),
        ),
        child: const App(),
      ),
    ),
    blocObserver: CustomBlocObserver(),
  );
}
