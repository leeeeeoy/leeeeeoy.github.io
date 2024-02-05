part of 'resource.dart';

///
/// const Color(0xff0064FF): 토스 컬러
///
///
abstract class AppTheme {
  static ThemeData light = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff7BF787),
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(centerTitle: true),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(GoogleFonts.dancingScript()),
      ),
    ),
  );

  static ThemeData dark = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xff7BF787),
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(centerTitle: true),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(GoogleFonts.dancingScript()),
      ),
    ),
  );
}
