import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leeeeeoy_portfolio/data/repository/app_repository.dart';

final appRepositoryProvider = Provider<AppRepository>(
  (ref) => AppRepository(),
);
