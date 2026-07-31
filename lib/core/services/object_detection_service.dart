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

  static const _confidenceThreshold = 0.35;
  static const _iouThreshold = 0.45;

  static const Map<String, double> _classConfidenceOverrides = {
    'person': 0.5,
  };

  static const _inputSize = 192;
  static const _maxDetections = 756;

  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter; // runs inference off the UI thread
  List<String> _labels = [];

  bool _isInitialized = false;
  bool _isRunning = false;
  bool _disposed = false;

  DateTime _lastRun = DateTime.now();

  late final List _inputTensor;
  late final List<List<List<double>>> _outputBuffer;

  List<DetectionResult> latestDetections = [];
  double _padX = 0.0;
  double _padY = 0.0;
  double _scaledW = 1.0;
  double _scaledH = 1.0;

  bool get isInitialized => _isInitialized;

  double _thresholdFor(String label) =>
      _classConfidenceOverrides[label] ?? _confidenceThreshold;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final options = InterpreterOptions()..threads = 4;
    try {
      options.useNnApiForAndroid = true;
    } catch (e) {
      log('NNAPI not available: $e', name: 'OD');
    }

    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    // Wraps the interpreter so .run() calls happen on a background isolate
    // instead of blocking Dart's UI thread. Without this, native inference
    // freezes any running animation (like your spinner) for its duration.
    _isolateInterpreter = await IsolateInterpreter.create(
      address: _interpreter!.address,
    );

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
    _labels = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<List<DetectionResult>> detect(
    CameraImage image, {
    int sensorOrientation = 90,
    bool isFrontCamera = false,
  }) async {
    if (!_isInitialized || _isolateInterpreter == null || _disposed) return [];

    final now = DateTime.now();
    if (now.difference(_lastRun).inMilliseconds < 300) return [];
    _lastRun = now;

    if (_isRunning) return [];
    _isRunning = true;

    try {
      final rotationAngle = isFrontCamera ? -sensorOrientation : sensorOrientation;
      final ok = _preprocess(image, rotationAngle: rotationAngle);
      if (!ok) return [];

      await _isolateInterpreter!.runForMultipleInputs([_inputTensor], {0: _outputBuffer});
      final detections = _postprocess(_outputBuffer[0]);
      latestDetections = detections;
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
      img.Image? frame;
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

      final rotated = img.copyRotate(frame, angle: rotationAngle);
      _letterboxIntoTensor(rotated);
      return true;
    } catch (e) {
      log("Preprocess error: $e", name: "OD");
      return false;
    }
  }

  void _letterboxIntoTensor(img.Image source) {
    final origW = source.width;
    final origH = source.height;

    final scale = (_inputSize / origW < _inputSize / origH)
        ? _inputSize / origW
        : _inputSize / origH;

    final scaledW = (origW * scale).round().clamp(1, _inputSize);
    final scaledH = (origH * scale).round().clamp(1, _inputSize);

    final padX = ((_inputSize - scaledW) / 2).floorToDouble();
    final padY = ((_inputSize - scaledH) / 2).floorToDouble();

    _padX = padX;
    _padY = padY;
    _scaledW = scaledW.toDouble();
    _scaledH = scaledH.toDouble();

    final resized = img.copyResize(
      source,
      width: scaledW,
      height: scaledH,
      interpolation: img.Interpolation.average,
    );

    final tensor = _inputTensor[0];
    const padValue = 114 / 255.0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        tensor[y][x][0] = padValue;
        tensor[y][x][1] = padValue;
        tensor[y][x][2] = padValue;
      }
    }

    final offsetX = padX.round();
    final offsetY = padY.round();

    for (int y = 0; y < scaledH; y++) {
      final ty = y + offsetY;
      if (ty < 0 || ty >= _inputSize) continue;
      for (int x = 0; x < scaledW; x++) {
        final tx = x + offsetX;
        if (tx < 0 || tx >= _inputSize) continue;

        final p = resized.getPixel(x, y);
        tensor[ty][tx][0] = p.r / 255.0;
        tensor[ty][tx][1] = p.g / 255.0;
        tensor[ty][tx][2] = p.b / 255.0;
      }
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

      if (bestClass < 0 || bestClass >= _labels.length) continue;
      final label = _labels[bestClass].toLowerCase();
      if (bestClassScore < _thresholdFor(label)) continue;

      final boxCx = cx * _inputSize;
      final boxCy = cy * _inputSize;
      final boxW = w * _inputSize;
      final boxH = h * _inputSize;

      final x1 = ((boxCx - boxW / 2 - _padX) / _scaledW).clamp(0.0, 1.0);
      final y1 = ((boxCy - boxH / 2 - _padY) / _scaledH).clamp(0.0, 1.0);
      final x2 = ((boxCx + boxW / 2 - _padX) / _scaledW).clamp(0.0, 1.0);
      final y2 = ((boxCy + boxH / 2 - _padY) / _scaledH).clamp(0.0, 1.0);

      detections.add(DetectionResult(label: label, confidence: bestClassScore, bbox: [y1, x1, y2, x2]));
    }

    return _crossClassSuppress(_nms(detections));
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

  List<DetectionResult> _crossClassSuppress(List<DetectionResult> dets) {
    if (dets.isEmpty) return [];
    final sorted = [...dets]..sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <DetectionResult>[];

    for (final d in sorted) {
      bool suppressed = false;
      for (final k in kept) {
        if (k.label == d.label) continue;
        if (_iou(d.bbox, k.bbox) > 0.6 && k.confidence > d.confidence + 0.15) {
          suppressed = true;
          break;
        }
      }
      if (!suppressed) kept.add(d);
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

  Future<int> benchmarkInferenceMs() async {
    if (!_isInitialized || _isolateInterpreter == null) return 999;
    final sw = Stopwatch()..start();
    await _isolateInterpreter!.runForMultipleInputs([_inputTensor], {0: _outputBuffer});
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  Future<List<DetectionResult>> detectStatic(img.Image image) async {
    if (!_isInitialized || _isolateInterpreter == null || _disposed) return [];
    try {
      _letterboxIntoTensor(image);
      await _isolateInterpreter!.runForMultipleInputs([_inputTensor], {0: _outputBuffer});
      return _postprocess(_outputBuffer[0]);
    } catch (e) {
      log("Static detection failed: $e", name: "OD");
      return [];
    }
  }

  void dispose() {
    _disposed = true;
    _isolateInterpreter?.close();
    _interpreter?.close();
    _interpreter = null;
    _isolateInterpreter = null;
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
      final g = (yy - 0.344136 * (uu - 128) - 0.714136 * (vv - 128)).clamp(0, 255).toInt();
      final b = (yy + 1.772 * (uu - 128)).clamp(0, 255).toInt();

      out.setPixelRgb(x0, y0, r, g, b);
    }
  }

  return out;
}