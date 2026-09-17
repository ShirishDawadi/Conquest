import 'dart:developer';
import 'dart:typed_data';
import 'package:conquest/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ObjectUploadResult {
  final String? photoUrl;
  final int xpEarned;
  final int pointsEarned;

  ObjectUploadResult({
    required this.photoUrl,
    required this.xpEarned,
    required this.pointsEarned,
  });
}

class ObjectImageRemoteSource {
  final _dio = ApiClient.instance;

  Future<ObjectUploadResult> uploadObjectImage({
    required int questId,
    required int objectId,
    double? latitude,
    double? longitude,
    required Uint8List imageBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'quest_id': questId,
        'object_id': objectId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'object.jpg',
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final response = await _dio.post('/object-images/upload', data: formData);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ObjectUploadResult(
          photoUrl: data['photo_url'] as String?,
          xpEarned: data['xp_earned'] as int? ?? 0,
          pointsEarned: data['points_earned'] as int? ?? 0,
        );
      }
      return ObjectUploadResult(photoUrl: null, xpEarned: 0, pointsEarned: 0);
    } catch (e) {
      log('Error uploading object image: $e', name: 'ObjectImageRemoteSource');
      rethrow;
    }
  }
}