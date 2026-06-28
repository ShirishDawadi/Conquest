import 'dart:developer';
import 'package:conquest/core/config.dart';
import 'package:conquest/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  static const _storage = FlutterSecureStorage();
  static Future<String?>? _refreshFuture;

  static final _refreshDio = Dio(BaseOptions(
    baseUrl: Config.baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
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

      _refreshFuture ??= _doRefresh(refreshToken).whenComplete(() {
        _refreshFuture = null;
      });

      final newToken = await _refreshFuture;

      if (newToken == null) {
        await _storage.deleteAll();
        handler.next(err);
        return;
      }

      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await ApiClient.instance.fetch(err.requestOptions);
      handler.resolve(retryResponse);

    } catch (e) {
      _refreshFuture = null;
      await _storage.deleteAll();
      handler.next(err);
    }
  }

  static Future<String?> _doRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final newToken = response.data['access_token'] as String;
      await _storage.write(key: 'access_token', value: newToken);
      log('Token refreshed', name: 'AuthInterceptor');
      return newToken;
    } catch (e) {
      log('Refresh failed: $e', name: 'AuthInterceptor');
      return null;
    }
  }
}