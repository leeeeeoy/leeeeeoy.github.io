import 'package:go_router/go_router.dart';
import 'package:leeeeeoy_portfolio/feature/home/home_page.dart';

final router = GoRouter(
  initialLocation: '/${HomePage.routePath}',
  routes: [
    GoRoute(
      path: '/${HomePage.routePath}',
      name: HomePage.routeName,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
