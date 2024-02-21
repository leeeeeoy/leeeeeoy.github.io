part of 'resource.dart';

abstract class AppTheme {
  static ThemeData light = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff7BF787),
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(centerTitle: true),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(textStyle: MaterialStatePropertyAll(AppStlye.egBodyM)),
    ),
  );

  static ThemeData dark = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xff7BF787),
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(centerTitle: true),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(textStyle: MaterialStatePropertyAll(AppStlye.egBodyM)),
    ),
  );
}
