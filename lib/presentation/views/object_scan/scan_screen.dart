import 'dart:async';
import 'package:camera/camera.dart';
import 'package:conquest/core/services/object_detection_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/views/object_scan/widgets/scan_frame_painter.dart';
import 'package:conquest/presentation/views/object_scan/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final QuestObjectModel object;

  const ScanScreen({super.key, required this.object});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _cameraController;
  final _detectionService = ObjectDetectionService();

  bool _isProcessing = false;
  bool _detected = false;
  bool _cameraReady = false;
  String? _error;

  DateTime _lastFrameTime = DateTime.now();
  List<DetectionResult> _currentDetections = [];

  int _sensorOrientation = 90;
  bool _isFrontCamera = false;

  double _lastLuma = 0.0;
  bool _isCameraStable = false;
  DateTime _lastLumaCheck = DateTime.now();

  int _missCount = 0;
  double _confidenceAccumulator = 0.0;
  static const _maxMisses = 3;
  static const _confirmationThreshold = 1.5;

  static const _holdDuration = Duration(seconds: 1);
  Timer? _holdTimer;
  double _holdProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _error = 'Camera permission denied.');
      return;
    }

    await _detectionService.initialize();

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _error = 'No camera found.');
      return;
    }

    final camera = cameras.first;
    _sensorOrientation = camera.sensorOrientation;
    _isFrontCamera = camera.lensDirection == CameraLensDirection.front;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    _cameraController!.startImageStream(_onFrame);
    setState(() => _cameraReady = true);
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
    if (_detected) return;

    final now = DateTime.now();

    if (now.difference(_lastLumaCheck).inMilliseconds >= 100) {
      _lastLumaCheck = now;

      final luma = _calculateLuma(image);
      final lumaDiff = (luma - _lastLuma).abs();
      _lastLuma = luma;
      final stable = lumaDiff < 1.5;

      if (mounted && stable != _isCameraStable) {
        setState(() => _isCameraStable = stable);
      }

      if (!stable) {
        _missCount = 0;
        _confidenceAccumulator = 0.0;
        _cancelHoldTimer();
        return;
      }
    } else if (!_isCameraStable) {
      return;
    }

    if (_isProcessing) return;
    if (now.difference(_lastFrameTime) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastFrameTime = now;
    _isProcessing = true;

    final results = await _detectionService.detect(
      image,
      sensorOrientation: _sensorOrientation,
      isFrontCamera: _isFrontCamera,
    );

    if (mounted) {
      setState(() => _currentDetections = results);
    }

    final targetLabel = widget.object.label.toLowerCase();
    final targetResults = results.where((r) => r.label == targetLabel).toList();

    if (targetResults.isNotEmpty) {
      _missCount = 0;
      _confidenceAccumulator += targetResults.first.confidence;
      _startHoldTimer();

      if (_confidenceAccumulator >= _confirmationThreshold) {
        _isProcessing = false;
        _onObjectConfirmed();
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
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _holdProgress += 1 / steps);
      if (_holdProgress >= 1.0) {
        timer.cancel();
        _onObjectConfirmed();
      }
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (mounted && _holdProgress > 0) {
      setState(() => _holdProgress = 0.0);
    }
  }

  Future<void> _onObjectConfirmed() async {
    if (_detected) return;
    setState(() => _detected = true);

    if (_cameraController?.value.isStreamingImages == true) {
      await _cameraController?.stopImageStream();
    }

    await ref
        .read(questProvider.notifier)
        .markObjectCompleted(widget.object.id);

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    if (_cameraController?.value.isStreamingImages == true) {
      _cameraController?.stopImageStream();
    }
    _cameraController?.dispose();
    _detectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final label =
        widget.object.label[0].toUpperCase() +
        widget.object.label.substring(1).toLowerCase();

    double cameraScale = 1.0;
    if (_cameraReady &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      final screenSize = MediaQuery.of(context).size;
      final cameraAspectRatio = 1 / _cameraController!.value.aspectRatio;
      cameraScale = screenSize.aspectRatio / cameraAspectRatio;
      if (cameraScale < 1.0) cameraScale = 1.0 / cameraScale;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraReady && _cameraController != null)
            ClipRect(
              child: Transform.scale(
                scale: cameraScale,
                child: Center(child: CameraPreview(_cameraController!)),
              ),
            ),

          if (_error != null)
            Center(
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            ),

          Positioned.fill(
            child: CustomPaint(
              painter: ScanBoxesPainter(
                detections: _currentDetections,
                targetLabel: widget.object.label.toLowerCase(),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sw * 0.03,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: EdgeInsets.all(sw * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    Text(
                      'Find: $label',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.05,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(blurRadius: 8, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: sh * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: _detected
                  ? StatusChip(
                      label: '$label found! ✓',
                      color: AppColors.greenish_3,
                    )
                  : !_isCameraStable
                  ? StatusChip(
                      label: 'Hold camera still...',
                      color: Colors.black54,
                    )
                  : _holdProgress > 0
                  ? StatusChip(
                      label: 'Hold still...',
                      color: AppColors.greenish_2,
                    )
                  : StatusChip(
                      label: 'Point camera at $label',
                      color: Colors.black54,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
