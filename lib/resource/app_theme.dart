part of 'resource.dart';

abstract class AppTheme {
  static ThemeData light() => ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          toolbarHeight: 56,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black,
        ),
        primaryColor: Colors.white,
        textTheme: GoogleFonts.juaTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                }
                return Colors.orange;
              },
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.all(0),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          toolbarHeight: 56,
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        primaryColor: Colors.indigo,
        textTheme: GoogleFonts.juaTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black26,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                }
                return Colors.indigo;
              },
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.all(0),
          ),
        ),
      );
}

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) =>
      child;
}
