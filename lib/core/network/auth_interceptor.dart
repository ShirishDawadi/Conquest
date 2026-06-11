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
      log(
        '401 received for ${err.requestOptions.path}',
        name: 'AuthInterceptor',
      );
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        log('Refresh token: $refreshToken', name: 'AuthInterceptor');
        if (refreshToken == null) {
          log('No refresh token found, logging out', name: 'AuthInterceptor');
          handler.next(err);
          return;
        }

        log('Attempting token refresh...', name: 'AuthInterceptor');
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
        log('LOGOUT: refresh failed: $e', name: 'AuthInterceptor');
        await _storage.deleteAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
