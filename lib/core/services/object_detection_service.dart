import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final List<double> bbox;

  const DetectionResult({
    required this.label,
    required this.confidence,
    required this.bbox,
  });
}

class ObjectDetectionService {
  static const _modelPath = 'assets/models/yolov8n.tflite';
  static const _labelPath = 'assets/models/labelmap.txt';

  static const _confidenceThreshold = 0.1;
  static const _iouThreshold = 0.45;

  static const _inputSize = 192;
  static const _maxDetections = 756;

  Interpreter? _interpreter;
  List<String> _labels = [];

  bool _isInitialized = false;
  bool _isRunning = false;
  bool _disposed = false;

  DateTime _lastRun = DateTime.now();

  late final List _inputTensor;
  late final List<List<List<double>>> _outputBuffer;

  List<DetectionResult> latestDetections = [];

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final options = InterpreterOptions()..threads = 4;

    try {
      options.useNnApiForAndroid = true;
    } catch (e) {
      log('NNAPI not available: $e', name: 'OD');
    }

    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    await _loadLabels();

    _inputTensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(_inputSize, (_) => List.filled(3, 0.0)),
      ),
    );

    _outputBuffer = List.generate(
      1,
      (_) => List.generate(84, (_) => List.filled(_maxDetections, 0.0)),
    );

    _isInitialized = true;
  }

  Future<void> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelPath);
    _labels = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<List<DetectionResult>> detect(
    CameraImage image, {
    int sensorOrientation = 90,
    bool isFrontCamera = false,
  }) async {
    if (!_isInitialized || _interpreter == null || _disposed) return [];

    final now = DateTime.now();
    if (now.difference(_lastRun).inMilliseconds < 300) return [];
    _lastRun = now;

    if (_isRunning) return [];
    _isRunning = true;

    final totalSW = Stopwatch()..start();

    try {
      final rotationAngle = isFrontCamera
          ? -sensorOrientation
          : sensorOrientation;

      final preprocessSW = Stopwatch()..start();
      final ok = _preprocess(image, rotationAngle: rotationAngle);
      preprocessSW.stop();
      log("Preprocess: ${preprocessSW.elapsedMilliseconds} ms", name: "PERF");

      if (!ok) return [];

      final inferenceSW = Stopwatch()..start();
      _interpreter!.runForMultipleInputs([_inputTensor], {0: _outputBuffer});
      inferenceSW.stop();
      log("Inference: ${inferenceSW.elapsedMilliseconds} ms", name: "PERF");

      final postSW = Stopwatch()..start();
      final detections = _postprocess(_outputBuffer[0]);
      postSW.stop();
      log("Postprocess: ${postSW.elapsedMilliseconds} ms", name: "PERF");

      latestDetections = detections;

      totalSW.stop();
      log("TOTAL: ${totalSW.elapsedMilliseconds} ms", name: "PERF");

      return detections;
    } catch (e) {
      log("Detection failed: $e", name: "OD");
      return [];
    } finally {
      _isRunning = false;
    }
  }

  bool _preprocess(CameraImage image, {int rotationAngle = 90}) {
    try {
      final sw = Stopwatch();

      img.Image? frame;

      sw.start();

      if (image.format.group == ImageFormatGroup.yuv420) {
        frame = _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        frame = img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
          order: img.ChannelOrder.bgra,
        );
      } else {
        return false;
      }

      sw.stop();
      log("YUV->RGB: ${sw.elapsedMilliseconds} ms", name: "PERF");

      sw
        ..reset()
        ..start();

      final resized = img.copyResize(
        frame,
        width: _inputSize,
        height: _inputSize,
      );

      sw.stop();
      log("Resize: ${sw.elapsedMilliseconds} ms", name: "PERF");

      sw
        ..reset()
        ..start();

      final rotated = img.copyRotate(resized, angle: rotationAngle);

      sw.stop();
      log("Rotate: ${sw.elapsedMilliseconds} ms", name: "PERF");

      sw
        ..reset()
        ..start();

      final tensor = _inputTensor[0];

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final p = rotated.getPixel(x, y);

          tensor[y][x][0] = p.r / 255.0;
          tensor[y][x][1] = p.g / 255.0;
          tensor[y][x][2] = p.b / 255.0;
        }
      }

      sw.stop();
      log("Normalize: ${sw.elapsedMilliseconds} ms", name: "PERF");

      return true;
    } catch (e) {
      log("Preprocess error: $e", name: "OD");
      return false;
    }
  }

  List<DetectionResult> _postprocess(List<List<double>> output) {
    final detections = <DetectionResult>[];

    for (int i = 0; i < _maxDetections; i++) {
      final cx = output[0][i];
      final cy = output[1][i];
      final w = output[2][i];
      final h = output[3][i];

      double bestClassScore = 0.0;
      int bestClass = -1;

      for (int c = 4; c < 84; c++) {
        final s = output[c][i];
        if (s > bestClassScore) {
          bestClassScore = s;
          bestClass = c - 4;
        }
      }

      final confidence = bestClassScore;
      if (confidence < _confidenceThreshold) continue;
      if (bestClass < 0 || bestClass >= _labels.length) continue;

      final label = _labels[bestClass];

      final x1 = (cx - w / 2).clamp(0.0, 1.0);
      final y1 = (cy - h / 2).clamp(0.0, 1.0);
      final x2 = (cx + w / 2).clamp(0.0, 1.0);
      final y2 = (cy + h / 2).clamp(0.0, 1.0);

      detections.add(
        DetectionResult(
          label: label.toLowerCase(),
          confidence: confidence,
          bbox: [y1, x1, y2, x2],
        ),
      );
    }

    return _nms(detections);
  }

  List<DetectionResult> _nms(List<DetectionResult> dets) {
    if (dets.isEmpty) return [];
    dets.sort((a, b) => b.confidence.compareTo(a.confidence));

    final kept = <DetectionResult>[];
    for (final d in dets) {
      bool sup = false;
      for (final k in kept) {
        if (k.label != d.label) continue;
        if (_iou(d.bbox, k.bbox) > _iouThreshold) {
          sup = true;
          break;
        }
      }
      if (!sup) kept.add(d);
    }
    return kept;
  }

  double _iou(List<double> a, List<double> b) {
    final y1 = a[0] > b[0] ? a[0] : b[0];
    final x1 = a[1] > b[1] ? a[1] : b[1];
    final y2 = a[2] < b[2] ? a[2] : b[2];
    final x2 = a[3] < b[3] ? a[3] : b[3];

    final w = (x2 - x1).clamp(0.0, 1.0);
    final h = (y2 - y1).clamp(0.0, 1.0);
    final inter = w * h;

    final aArea = (a[2] - a[0]) * (a[3] - a[1]);
    final bArea = (b[2] - b[0]) * (b[3] - b[1]);
    final union = aArea + bArea - inter;

    return union <= 0 ? 0.0 : inter / union;
  }

  void dispose() {
    _disposed = true;
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    _isRunning = false;
  }
}

img.Image _convertYUV420(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final out = img.Image(width: width, height: height);

  final y = image.planes[0].bytes;
  final u = image.planes[1].bytes;
  final v = image.planes[2].bytes;

  final ys = image.planes[0].bytesPerRow;
  final us = image.planes[1].bytesPerRow;
  final usp = image.planes[1].bytesPerPixel ?? 1;

  for (int y0 = 0; y0 < height; y0++) {
    for (int x0 = 0; x0 < width; x0++) {
      final yi = y0 * ys + x0;
      final ui = (y0 ~/ 2) * us + (x0 ~/ 2) * usp;

      if (yi >= y.length || ui >= u.length || ui >= v.length) continue;

      final yy = y[yi];
      final uu = u[ui];
      final vv = v[ui];

      final r = (yy + 1.402 * (vv - 128)).clamp(0, 255).toInt();
      final g = (yy - 0.344136 * (uu - 128) - 0.714136 * (vv - 128))
          .clamp(0, 255)
          .toInt();
      final b = (yy + 1.772 * (uu - 128)).clamp(0, 255).toInt();

      out.setPixelRgb(x0, y0, r, g, b);
    }
  }

  return out;
}
