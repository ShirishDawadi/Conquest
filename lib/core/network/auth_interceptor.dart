import 'dart:developer';
import 'package:conquest/core/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken == null) {
          handler.next(err);
          return;
        }

        final dio = Dio(BaseOptions(baseUrl: Config.baseUrl));
        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );
        log(
          'New access token: ${response.data['access_token']}',
          name: 'AuthInterceptor',
        );

        final newAccessToken = response.data['access_token'];
        await _storage.write(key: 'access_token', value: newAccessToken);

        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch(retryOptions);
        handler.resolve(retryResponse);
      } catch (e) {
        log('Refresh failed: $e', name: 'AuthInterceptor');
        await _storage.deleteAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
