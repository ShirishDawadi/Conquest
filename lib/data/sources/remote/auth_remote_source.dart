import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/auth_model.dart';

class AuthRemoteSource {
  final _dio = ApiClient.instance;

  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      log('Login success: ${response.statusCode}');
      return AuthModel.fromJson(response.data);
    } catch (e) {
      log('Login error: $e', name: 'AuthRemoteSource');
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      log('Register success', name: 'AuthRemoteSource');
    } catch (e) {
      log('Register error: $e', name: 'AuthRemoteSource');
      rethrow;
    }
  }
}
