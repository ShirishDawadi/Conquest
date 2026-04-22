import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtUtils {
  static const _storage = FlutterSecureStorage();

  static Future<int?> getUserId() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    final jwt = JWT.decode(token);
    return int.tryParse(jwt.payload['sub'].toString());
  }
}