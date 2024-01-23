import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:leeeeeoy_portfolio/feature/home/home_screen.dart';
import 'package:leeeeeoy_portfolio/feature/main/main_screen.dart';
import 'package:leeeeeoy_portfolio/feature/profile/profile_screen.dart';

part 'app_route_state.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance, nameExtractor: (rs) => rs.name),
  ],
  routes: [
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) => MainScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/${AppRouteState.home.path}',
              name: AppRouteState.home.name,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
          observers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance, nameExtractor: (rs) => rs.name),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/${AppRouteState.profile.path}',
              name: AppRouteState.profile.name,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
          observers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance, nameExtractor: (rs) => rs.name),
          ],
        ),
      ],
    ),
  ],
);
