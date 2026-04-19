import 'package:conquest/core/config.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = Config.baseUrl;

  static Dio get instance {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    return dio;
  }
}