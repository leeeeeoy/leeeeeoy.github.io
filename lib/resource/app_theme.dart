part of 'resource.dart';

abstract class AppTheme {
  static ThemeData light() => ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber,
        ),
      );

  static ThemeData dark() => ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown,
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
