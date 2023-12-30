import 'package:go_router/go_router.dart';
import 'package:leeeeeoy_portfolio/feature/home/home_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
