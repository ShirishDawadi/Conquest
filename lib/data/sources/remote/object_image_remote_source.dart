import 'dart:developer';
import 'dart:typed_data';
import 'package:conquest/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ObjectImageRemoteSource {
  final _dio = ApiClient.instance;

  Future<void> uploadObjectImage({
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

      await _dio.post('/object-images/upload', data: formData);
    } catch (e) {
      log('Error uploading object image: $e', name: 'ObjectImageRemoteSource');
      rethrow;
    }
  }
}