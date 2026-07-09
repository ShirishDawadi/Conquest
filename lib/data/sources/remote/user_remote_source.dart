import 'dart:developer';
import 'dart:io';
import 'package:conquest/core/network/api_client.dart';
import 'package:conquest/data/models/user_model.dart';
import 'package:dio/dio.dart';

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

  Future<UserModel> getUserById(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserModel.fromJson(response.data);
    } catch (e) {
      log('Error fetching user: $e', name: 'UserRemoteSource');
      rethrow;
    }
  }

  Future<UserModel> updateProfile({
    String? username,
    String? fullName,
    String? profilePhoto,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/me',
        data: {
          if (username != null) 'username': username,
          if (fullName != null) 'full_name': fullName,
          if (profilePhoto != null) 'profile_photo': profilePhoto,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];

      if (detail is List && detail.isNotEmpty) {
        throw detail.first['msg'] as String;
      }

      if (detail is String) throw detail;

      log('Error updating profile: $e', name: 'UserRemoteSource');
      rethrow;
    }
  }

  Future<UserModel> updateAvatar(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
          ? 'image/webp'
          : 'image/jpeg';

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'avatar.$ext',
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final sw = Stopwatch()..start();
      final response = await _dio.patch('/users/me/avatar', data: formData);
      log(
        'Client upload time: ${sw.elapsedMilliseconds}ms',
        name: 'UserRemoteSource',
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      if (detail is String) throw detail;
      log('Error updating avatar: $e', name: 'UserRemoteSource');
      rethrow;
    }
  }
}
