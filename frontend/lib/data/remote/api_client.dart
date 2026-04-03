import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:leeeeeoy_portfolio/config/app_env.dart';

@lazySingleton
class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
  }
}
