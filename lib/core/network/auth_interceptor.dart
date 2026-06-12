import 'dart:developer';
import 'package:conquest/core/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  static const _storage = FlutterSecureStorage();

  static Future<String?>? _refreshFuture;

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
      log('401 received for ${err.requestOptions.path}', name: 'AuthInterceptor');
      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken == null) {
          log('No refresh token found, logging out', name: 'AuthInterceptor');
          handler.next(err);
          return;
        }

        _refreshFuture ??= _doRefresh();
        final newToken = await _refreshFuture;
        _refreshFuture = null;

        if (newToken == null) {
          log('LOGOUT: refresh returned null', name: 'AuthInterceptor');
          await _storage.deleteAll();
          handler.next(err);
          return;
        }

        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        final dio = Dio(BaseOptions(baseUrl: Config.baseUrl));
        final retryResponse = await dio.fetch(retryOptions);
        handler.resolve(retryResponse);
      } catch (e) {
        log('LOGOUT: refresh failed: $e', name: 'AuthInterceptor');
        _refreshFuture = null;
        await _storage.deleteAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  static Future<String?> _doRefresh() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      final dio = Dio(BaseOptions(baseUrl: Config.baseUrl));
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newToken = response.data['access_token'] as String;
      await _storage.write(key: 'access_token', value: newToken);
      log('New access token: $newToken', name: 'AuthInterceptor');
      return newToken;
    } catch (e) {
      log('_doRefresh failed: $e', name: 'AuthInterceptor');
      return null;
    }
  }
}