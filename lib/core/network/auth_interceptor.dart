import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

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
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        handler.next(err);
        return;
      }

      _refreshFuture ??= _doRefresh(refreshToken);
      final newToken = await _refreshFuture;
      _refreshFuture = null;

      if (newToken == null) {
        await _storage.deleteAll();
        handler.next(err);
        return;
      }

      final options = Options(
        method: err.requestOptions.method,
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newToken',
        },
      );

      final response = await ApiClient.instance.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: options,
      );

      handler.resolve(response);
    } catch (e) {
      _refreshFuture = null;
      await _storage.deleteAll();
      handler.next(err);
    }
  }

  static Future<String?> _doRefresh(String refreshToken) async {
    try {
      final response = await ApiClient.instance.post(
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
