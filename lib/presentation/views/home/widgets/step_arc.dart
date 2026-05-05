import 'package:conquest/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StepArc extends StatelessWidget {
  final int steps;
  final int goal;
  final int walkFrame;

  const StepArc({
    super.key,
    required this.steps,
    required this.goal,
    required this.walkFrame,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progress = (steps / goal).clamp(0.0, 1.0);
    final arcSize = screenWidth * 0.75;

    return SizedBox(
      height: arcSize * 0.65,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(arcSize, arcSize),
            painter: _ArcPainter(progress: progress),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/character/walk_$walkFrame.png',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
                Text(
                  '$steps steps',
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Gpkn',
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${(steps * 0.00067).toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${(steps * 0.04).toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;

  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 24.0;

    final bgPaint = Paint()
      ..color = AppColors.silver_light
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [AppColors.greenish_2, AppColors.greenish_5,],
            begin: Alignment.bottomLeft,
            stops: [0.4,1.0],
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi * 0.8;
    const sweepAngle = math.pi * 1.4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
