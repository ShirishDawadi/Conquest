import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:conquest/core/services/object_detection_service.dart';
import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:conquest/core/utils/detection_capability_utils.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/local/object_image_local_source.dart';
import 'package:conquest/data/sources/remote/object_image_remote_source.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CapturedFrame {
  final Uint8List bytes;
  final List<DetectionResult> results;
  final int width;
  final int height;

  CapturedFrame({
    required this.bytes,
    required this.results,
    required this.width,
    required this.height,
  });
}

class ScanViewModel extends ChangeNotifier {
  final QuestObjectModel object;
  final WidgetRef ref;

  ScanViewModel({required this.object, required this.ref});

  final detectionService = ObjectDetectionService();
  final _objectImageSource = ObjectImageRemoteSource();
  final _captureLocalSource = ObjectImageLocalSource();

  CameraController? cameraController;

  ScanMode mode = ScanMode.live;
  bool modeReady = false;
  bool cameraReady = false;
  bool modelReady = false;
  String? error;

  List<DetectionResult> currentDetections = [];
  bool isCameraStable = false;
  double holdProgress = 0.0;
  bool capturing = false;

  CapturedFrame? reviewFrame;
  bool? reviewFound;

  bool get reviewing => reviewFrame != null;

  String get targetLabel => object.label.toLowerCase();
  String get displayLabel =>
      object.label[0].toUpperCase() + object.label.substring(1).toLowerCase();

  bool _disposed = false;

  DateTime _lastFrameTime = DateTime.now();
  int _sensorOrientation = 90;
  bool _isFrontCamera = false;

  double _lastLuma = 0.0;
  DateTime _lastLumaCheck = DateTime.now();

  bool _isProcessing = false;
  int _missCount = 0;
  double _confidenceAccumulator = 0.0;
  static const _maxMisses = 3;
  static const _confirmationThreshold = 1.5;

  static const _captureConfidenceThreshold = 0.35;

  static const _holdDuration = Duration(seconds: 1);
  Timer? _holdTimer;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get currentZoom => _currentZoom;

  FlashMode _flashMode = FlashMode.off;
  FlashMode get flashMode => _flashMode;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      error = 'Camera permission denied.';
      _notify();
      return;
    }

    final cachedMode = await DetectionCapabilityUtil.getCachedMode();

    if (cachedMode != null && !_disposed) {
      mode = cachedMode;
      modeReady = true;
      _notify();
    }

    final cameraFuture = _initCamera();
    final modelFuture = _initModel(needsBenchmark: cachedMode == null);

    await Future.wait([cameraFuture, modelFuture]);

    if (!_disposed &&
        mode == ScanMode.live &&
        cameraController != null &&
        cameraController!.value.isInitialized &&
        !cameraController!.value.isStreamingImages) {
      cameraController!.startImageStream(_onFrame);
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (_disposed) return;

    if (cameras.isEmpty) {
      error = 'No camera found.';
      _notify();
      return;
    }

    final camera = cameras.first;
    _sensorOrientation = camera.sensorOrientation;
    _isFrontCamera = camera.lensDirection == CameraLensDirection.front;

    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await cameraController!.initialize();
    if (_disposed) return;

    _minZoom = await cameraController!.getMinZoomLevel();
    _maxZoom = await cameraController!.getMaxZoomLevel();
    _currentZoom = _minZoom;

    cameraReady = true;
    _notify();
  }

  Future<void> _initModel({required bool needsBenchmark}) async {
    await detectionService.initialize();
    if (_disposed) return;

    modelReady = true;

    if (needsBenchmark) {
      final recommended = await DetectionCapabilityUtil.benchmarkAndCache(detectionService);
      if (_disposed) return;
      mode = recommended;
      modeReady = true;
    }

    _notify();
  }

  Future<void> setZoom(double zoom) async {
    if (cameraController == null || _disposed) return;
    final clamped = zoom.clamp(_minZoom, _maxZoom);
    if (clamped == _currentZoom) return;
    _currentZoom = clamped;
    try {
      await cameraController!.setZoomLevel(_currentZoom);
    } catch (e) {
      log('Zoom failed: $e', name: 'ScanViewModel');
    }
    _notify();
  }

  Future<void> setFocusAndExposurePoint(Offset normalizedOffset) async {
    if (cameraController == null || _disposed) return;
    try {
      await cameraController!.setFocusPoint(normalizedOffset);
      await cameraController!.setExposurePoint(normalizedOffset);
    } catch (e) {
      log('Focus/exposure set failed: $e', name: 'ScanViewModel');
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || _disposed) return;
    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await cameraController!.setFlashMode(_flashMode);
    } catch (e) {
      log('Flash toggle failed: $e', name: 'ScanViewModel');
    }
    _notify();
  }

  Future<void> toggleMode() async {
    if (reviewing) return;
    if (mode == ScanMode.capture) {
      mode = ScanMode.live;
      if (cameraController?.value.isStreamingImages == false) {
        await cameraController?.startImageStream(_onFrame);
      }
    } else {
      if (cameraController?.value.isStreamingImages == true) {
        await cameraController?.stopImageStream();
      }
      mode = ScanMode.capture;
      currentDetections = [];
      isCameraStable = false;
      _missCount = 0;
      _confidenceAccumulator = 0.0;
      _cancelHoldTimer();
    }
    _notify();
  }

  double _calculateLuma(CameraImage image) {
    final yPlane = image.planes[0].bytes;
    int sum = 0;
    for (int i = 0; i < yPlane.length; i += 20) {
      sum += yPlane[i];
    }
    return sum / (yPlane.length / 20);
  }

  void _onFrame(CameraImage image) async {
    if (_disposed || reviewing || mode != ScanMode.live) return;
    if (!modelReady) return;

    final now = DateTime.now();

    if (now.difference(_lastLumaCheck).inMilliseconds >= 100) {
      _lastLumaCheck = now;

      final luma = _calculateLuma(image);
      final lumaDiff = (luma - _lastLuma).abs();
      _lastLuma = luma;
      final stable = lumaDiff < 1.5;

      if (stable != isCameraStable) {
        isCameraStable = stable;
        _notify();
      }

      if (!stable) {
        _missCount = 0;
        _confidenceAccumulator = 0.0;
        _cancelHoldTimer();
        return;
      }
    } else if (!isCameraStable) {
      return;
    }

    if (_isProcessing) return;
    if (now.difference(_lastFrameTime) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastFrameTime = now;
    _isProcessing = true;

    final results = await detectionService.detect(
      image,
      sensorOrientation: _sensorOrientation,
      isFrontCamera: _isFrontCamera,
    );

    if (_disposed) return;
    currentDetections = results;
    _notify();

    final targetResults = results.where((r) => r.label == targetLabel).toList();

    if (targetResults.isNotEmpty) {
      _missCount = 0;
      _confidenceAccumulator += targetResults.first.confidence;
      _startHoldTimer();

      if (_confidenceAccumulator >= _confirmationThreshold) {
        _isProcessing = false;
        _onLiveObjectConfirmed();
        return;
      }
    } else {
      _missCount++;
      if (_missCount >= _maxMisses) {
        _missCount = 0;
        _confidenceAccumulator = 0.0;
        _cancelHoldTimer();
      }
    }

    _isProcessing = false;
  }

  void _startHoldTimer() {
    if (_holdTimer != null) return;
    const interval = Duration(milliseconds: 100);
    final steps = _holdDuration.inMilliseconds / interval.inMilliseconds;

    _holdTimer = Timer.periodic(interval, (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      holdProgress += 1 / steps;
      _notify();
      if (holdProgress >= 1.0) {
        timer.cancel();
        _onLiveObjectConfirmed();
      }
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (holdProgress > 0) {
      holdProgress = 0.0;
      _notify();
    }
  }

  img.Image _cropToSquare(img.Image source) {
    final size = source.width < source.height ? source.width : source.height;
    final x = ((source.width - size) / 2).round();
    final y = ((source.height - size) / 2).round();
    return img.copyCrop(source, x: x, y: y, width: size, height: size);
  }

  Future<CapturedFrame?> _takeAndAnalyze() async {
    if (cameraController == null) return null;

    final file = await cameraController!.takePicture();
    final bytes = await File(file.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    var oriented = img.bakeOrientation(decoded);
    oriented = _cropToSquare(oriented);

    final squareBytes = Uint8List.fromList(img.encodeJpg(oriented, quality: 90));
    final results = await detectionService.detectStatic(oriented);

    return CapturedFrame(
      bytes: squareBytes,
      results: results,
      width: oriented.width,
      height: oriented.height,
    );
  }

  double _targetConfidenceIn(CapturedFrame frame) {
    var best = 0.0;
    for (final r in frame.results) {
      if (r.label == targetLabel && r.confidence > best) {
        best = r.confidence;
      }
    }
    return best;
  }

  Future<String> _saveImageLocally(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final captureDir = Directory('${dir.path}/object_images');
    if (!await captureDir.exists()) {
      await captureDir.create(recursive: true);
    }
    final path =
        '${captureDir.path}/obj_${object.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(bytes);
    return path;
  }
  
  Future<void> _handleFoundObject(CapturedFrame frame) async {
    final questId = ref.read(questProvider).value?.id;

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      position = null;
    }

    final online = await ConnectivityUtils.isOnline();

    if (online) {
      try {
        await _objectImageSource.uploadObjectImage(
          questId: questId!,
          objectId: object.id,
          latitude: position?.latitude,
          longitude: position?.longitude,
          imageBytes: frame.bytes,
        );
        ref.invalidate(questProvider);
        return;
      } catch (e) {
        log('Upload failed despite being online, queuing: $e', name: 'ScanViewModel');
      }
    }

    final imagePath = await _saveImageLocally(frame.bytes);
    await _captureLocalSource.insertPending(
      questId: questId,
      objectId: object.id,
      imagePath: imagePath,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );
  }

  Future<void> _onLiveObjectConfirmed() async {
    if (reviewing) return;

    if (cameraController?.value.isStreamingImages == true) {
      await cameraController?.stopImageStream();
    }

    final frame = await _takeAndAnalyze();
    if (frame == null || _disposed) return;

    await _handleFoundObject(frame);
    if (_disposed) return;

    reviewFrame = frame;
    reviewFound = true;
    _notify();
  }

  Future<void> onCaptureTap() async {
    if (capturing || cameraController == null) return;
    if (!modelReady) return;

    capturing = true;
    _notify();

    CapturedFrame? frame;
    try {
      frame = await _takeAndAnalyze();
    } catch (e) {
      log('Capture failed: $e', name: 'ScanViewModel');
    } finally {
      if (!_disposed) {
        capturing = false;
        _notify();
      }
    }

    if (_disposed) return;

    if (frame == null) {
      log('Capture produced no frame — camera or decode issue', name: 'ScanViewModel');
      return;
    }

    final found = _targetConfidenceIn(frame) >= _captureConfidenceThreshold;

    if (found) {
      await _handleFoundObject(frame);
      if (_disposed) return;
    }

    reviewFrame = frame;
    reviewFound = found;
    _notify();
  }

  Future<void> onRetry() async {
    reviewFrame = null;
    reviewFound = null;
    currentDetections = [];
    isCameraStable = false;
    _missCount = 0;
    _confidenceAccumulator = 0.0;
    _notify();

    if (mode == ScanMode.live &&
        modelReady &&
        cameraController?.value.isStreamingImages == false) {
      await cameraController?.startImageStream(_onFrame);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _holdTimer?.cancel();
    if (cameraController?.value.isStreamingImages == true) {
      cameraController?.stopImageStream();
    }
    cameraController?.dispose();
    detectionService.dispose();
    super.dispose();
  }
}