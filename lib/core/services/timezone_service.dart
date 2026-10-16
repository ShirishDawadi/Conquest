import 'dart:developer';
import 'package:conquest/core/network/api_client.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneService {
  static Future<String?> current() async {
    try {
      final dynamic tz = await FlutterTimezone.getLocalTimezone();
      return tz is String ? tz : tz.identifier as String;
    } catch (e) {
      log('Timezone read failed: $e', name: 'TimezoneService');
      return null;
    }
  }

  static Future<void> sync() async {
    try {
      final name = await current();
      if (name == null) return;
      await ApiClient.instance.put(
        '/users/me/timezone',
        data: {'timezone': name},
      );
    } catch (e) {
      log('Timezone sync failed: $e', name: 'TimezoneService');
    }
  }
}