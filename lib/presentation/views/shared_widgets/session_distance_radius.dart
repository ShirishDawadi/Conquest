import 'dart:math' as math;
import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SessionDistanceRadius extends StatelessWidget {
  final double distanceMeters;
  final double size;
  final double highestMeter;

  const SessionDistanceRadius({
    super.key,
    required this.distanceMeters,
    this.size = 24,
    this.highestMeter = 0,
  });

  static double outerRadius(double size) => size / 2;
  static double middleRadius(double size) => size / 3;
  static double innerRadius(double size) => size / 6;

  static double _radiusForDistance(double distance, double size) {
    final d = distance.clamp(0, double.infinity);
    final inner = innerRadius(size);
    final middle = middleRadius(size);
    final outer = outerRadius(size);

    if (d < 500) {
      final t = (d / 500).clamp(0.0, 1.0);
      return inner * t;
    } else if (d < 1000) {
      final t = ((d - 500) / 500).clamp(0.0, 1.0);
      return inner + (middle - inner) * t;
    } else if (d < 2000) {
      final t = ((d - 1000) / 1000).clamp(0.0, 1.0);
      return middle + (outer - middle) * t;
    }
    return outer;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final d = distanceMeters.clamp(0, double.infinity);
    double width = (size / 24 < 2) ? size / 24 : 2;

    final bool ring1Filled = d >= 500;
    final bool ring2Filled = d >= 1000;
    final bool ring3Filled = d >= 2000;

    final double? bestRadius = highestMeter > 0
        ? _radiusForDistance(highestMeter.toDouble(), size)
        : null;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: d.toDouble()),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animatedDistance, child) {
        double? circleRadius;
        Color? circleColor;

        if (animatedDistance < 500) {
          circleRadius = _radiusForDistance(animatedDistance, size);
          circleColor = AppColors.greenish_1.withValues(alpha: 0.65);
        } else if (animatedDistance < 1000) {
          circleRadius = _radiusForDistance(animatedDistance, size);
          circleColor = AppColors.greenish_2.withValues(alpha: 0.65);
        } else if (animatedDistance < 2000) {
          circleRadius = _radiusForDistance(animatedDistance, size);
          circleColor = AppColors.greenish_3.withValues(alpha: 0.65);
        } else {
          circleRadius = null;
          circleColor = null;
        }

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (circleRadius != null)
                Container(
                  width: circleRadius * 2,
                  height: circleRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                  ),
                ),

              if (bestRadius != null)
                CustomPaint(
                  size: Size(size, size),
                  painter: _DashedCirclePainter(
                    radius: bestRadius,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),

              SizedBox(
                width: size,
                height: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ring3Filled ? AppColors.greenish_3 : null,
                    border: Border.all(
                      color: AppColors.greenish_3,
                      width: width,
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: (size * 2) / 3,
                      height: (size * 2) / 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ring2Filled ? AppColors.greenish_2 : null,
                          border: Border.all(
                            color: AppColors.greenish_2,
                            width: width,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: size / 3,
                            height: size / 3,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ring1Filled
                                    ? AppColors.greenish_1
                                    : null,
                                border: Border.all(
                                  color: AppColors.greenish_1,
                                  width: width,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final double radius;
  final Color color;

  _DashedCirclePainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    double dashLength = 5;
    double gapLength = 5;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final circumference = 2 * math.pi * radius;
    final dashAngle = (dashLength / circumference) * 2 * math.pi;
    final gapAngle = (gapLength / circumference) * 2 * math.pi;

    double currentAngle = 0;
    while (currentAngle < 2 * math.pi) {
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          dashAngle,
        );
      canvas.drawPath(path, paint);
      currentAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}
