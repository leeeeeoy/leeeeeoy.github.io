import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:leeeeeoy_portfolio/feature/common/bloc/theme_bloc.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:flutter/material.dart';
import 'package:leeeeeoy_portfolio/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.system;

        if (state is ThemeLoaded) {
          themeMode = state.themeMode;
        }

        return MaterialApp.router(
          title: "L's Portfolio",
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko', 'KR')],
        );
      },
    );
  }
}
