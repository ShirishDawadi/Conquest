import 'package:camera/camera.dart';
import 'package:conquest/core/services/object_detection_service.dart';
import 'package:conquest/presentation/views/object_scan/widgets/scan_frame_painter.dart';
import 'package:flutter/material.dart';

class ScanCameraView extends StatefulWidget {
  final CameraController controller;
  final bool showBoxes;
  final List<DetectionResult> detections;
  final String targetLabel;
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<Offset> onTapToFocus;

  const ScanCameraView({
    super.key,
    required this.controller,
    required this.showBoxes,
    required this.detections,
    required this.targetLabel,
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.onZoomChanged,
    required this.onTapToFocus,
  });

  @override
  State<ScanCameraView> createState() => _ScanCameraViewState();
}

class _ScanCameraViewState extends State<ScanCameraView> {
  double _baseZoom = 1.0;
  Offset? _focusPoint;

  void _showFocusRing(Offset point) {
    setState(() => _focusPoint = point);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraAspectRatio = 1 / widget.controller.value.aspectRatio;
    double scale = 1.0 / cameraAspectRatio;
    if (scale < 1.0) scale = 1.0 / scale;

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onScaleStart: (_) => _baseZoom = widget.currentZoom,
        onScaleUpdate: (details) {
          if (details.scale == 1.0) return; 
          widget.onZoomChanged(_baseZoom * details.scale);
        },
        onTapUp: (details) {
          final box = context.findRenderObject() as RenderBox;
          final localPos = box.globalToLocal(details.globalPosition);
          final normalized = Offset(
            (localPos.dx / box.size.width).clamp(0.0, 1.0),
            (localPos.dy / box.size.height).clamp(0.0, 1.0),
          );
          widget.onTapToFocus(normalized);
          _showFocusRing(localPos);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRect(
              child: Transform.scale(
                scale: scale,
                child: Center(child: CameraPreview(widget.controller)),
              ),
            ),
            if (widget.showBoxes)
              Positioned.fill(
                child: CustomPaint(
                  painter: ScanBoxesPainter(
                    detections: widget.detections,
                    targetLabel: widget.targetLabel,
                  ),
                ),
              ),
            if (_focusPoint != null)
              Positioned(
                left: _focusPoint!.dx - 30,
                top: _focusPoint!.dy - 30,
                child: IgnorePointer(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}