import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conquest/core/services/object_detection_service.dart';

enum ScanMode { live, capture }

class DetectionCapabilityUtil {
  static const _cacheKey = 'recommended_scan_mode';
  static const _slowThresholdMs = 150;

  static Future<ScanMode?> getCachedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return null;
    return cached == 'capture' ? ScanMode.capture : ScanMode.live;
  }

  static Future<ScanMode> benchmarkAndCache(ObjectDetectionService service) async {
    final ms = await service.benchmarkInferenceMs();
    final mode = ms > _slowThresholdMs ? ScanMode.capture : ScanMode.live;

    log('Benchmark: ${ms}ms -> recommended $mode', name: 'CAPABILITY');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, mode == ScanMode.capture ? 'capture' : 'live');
    return mode;
  }
}