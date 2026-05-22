import 'package:conquest/core/services/object_detection_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ScanBoxesPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final String targetLabel;

  ScanBoxesPainter({
    required this.detections,
    required this.targetLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final det in detections) {
      final isTarget = det.label == targetLabel;

      final boxColor = isTarget ? AppColors.greenish_4 : Colors.black;
      final labelBg  = isTarget ? AppColors.greenish_4 : Colors.black;

      final boxPaint = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final yMin = det.bbox[0];
      final xMin = det.bbox[1];
      final yMax = det.bbox[2];
      final xMax = det.bbox[3];

      final rect = Rect.fromLTRB(
        xMin * size.width,
        yMin * size.height,
        xMax * size.width,
        yMax * size.height,
      );

      canvas.drawRect(rect, boxPaint);

      final label = det.label[0].toUpperCase() + det.label.substring(1);
      final textSpan = TextSpan(
        text: '  $label  ',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final tagRect = Rect.fromLTWH(
        rect.left,
        rect.top - 22,
        textPainter.width,
        22,
      );

      canvas.drawRect(
        tagRect,
        Paint()..color = labelBg,
      );

      textPainter.paint(canvas, Offset(rect.left, rect.top - 20));
    }
  }

  @override
  bool shouldRepaint(ScanBoxesPainter old) =>
      old.detections != detections || old.targetLabel != targetLabel;
}