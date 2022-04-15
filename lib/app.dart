import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:leeeeeoy_portfolio/bloc/theme_bloc.dart';
import 'package:leeeeeoy_portfolio/feature/home/home_page.dart';
import 'package:leeeeeoy_portfolio/resource/resource.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: (state is ThemeDarkChecked) ? ThemeMode.dark : ThemeMode.light,
          scrollBehavior: AppScrollBehavior(),
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
