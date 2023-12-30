part of 'app_router.dart';

enum AppRouteState {
  home(''),
  profile('profile');

  final String path;

  const AppRouteState(this.path);
}
