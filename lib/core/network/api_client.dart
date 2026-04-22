import 'package:conquest/core/config.dart';
import 'package:conquest/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _instance = _createInstance();

  static Dio get instance => _instance;

  static Dio _createInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Config.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(AuthInterceptor());
    return dio;
  }
}