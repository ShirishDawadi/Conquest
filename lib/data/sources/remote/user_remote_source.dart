import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/user_model.dart';

class UserRemoteSource {
  final _dio = ApiClient.instance;

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      log('Error fetching user: $e', name: 'UserRemoteSource');
      rethrow;
    }
  }
}