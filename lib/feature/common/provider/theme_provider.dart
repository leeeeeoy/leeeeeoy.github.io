import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leeeeeoy_portfolio/data/repository/repository_provider.dart';

final themeProvider = StateProvider<bool>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);

  return appRepository.getThemeMode();
});
