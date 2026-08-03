import 'dart:math' as math;
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:conquest/presentation/views/shared_widgets/session_distance_radius.dart';
import 'package:flutter/material.dart';

const double _canvasWidth = 260;
const double _canvasHeight = 200;
const double _ringDiameter = 180;
final Offset _ringCenter = const Offset(85, 90);

class MilestoneRingGroup extends StatelessWidget {
  final double distanceMeters;
  final double highestMeter;
  final int xpPerMilestone;

  const MilestoneRingGroup({
    super.key,
    required this.distanceMeters,
    this.highestMeter = 0,
    this.xpPerMilestone = 10,
  });

  @override
  Widget build(BuildContext context) {
    final milestones = [
      _MilestoneSpec(
        label: '500m',
        angleDegrees: -90,
        labelY: 0,
        radius: SessionDistanceRadius.innerRadius(_ringDiameter),
        color: AppColors.greenish_1,
        completed: distanceMeters >= 500 || highestMeter >= 500,
      ),
      _MilestoneSpec(
        label: '1km',
        angleDegrees: 0,
        labelY: 90,
        radius: SessionDistanceRadius.middleRadius(_ringDiameter),
        color: AppColors.greenish_2,
        completed: distanceMeters >= 1000 || highestMeter >= 1000,
      ),
      _MilestoneSpec(
        label: '2km',
        angleDegrees: 90,
        labelY: 180,
        radius: SessionDistanceRadius.outerRadius(_ringDiameter),
        color: AppColors.greenish_3,
        completed: distanceMeters >= 2000 || highestMeter >= 2000,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth.isFinite
            ? (constraints.maxWidth / _canvasWidth).clamp(0.0, 1.0)
            : 1.0;

        return SizedBox(
          width: _canvasWidth * scale,
          height: _canvasHeight * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: _canvasWidth,
                  height: _canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: _ringCenter.dx - _ringDiameter / 2,
                        top: _ringCenter.dy - _ringDiameter / 2,
                        child: SessionDistanceRadius(
                          distanceMeters: distanceMeters,
                          highestMeter: highestMeter,
                          size: _ringDiameter,
                        ),
                      ),
                      CustomPaint(
                        size: const Size(_canvasWidth, _canvasHeight),
                        painter: _ConnectorPainter(milestones: milestones),
                      ),
                    ],
                  ),
                ),
              ),
              for (final m in milestones)
                Positioned(
                  left: (_labelAnchorX + 10) * scale,
                  top: (m.labelY - 15) * scale,
                  child: _MilestoneLabel(
                    label: m.label,
                    completed: m.completed,
                    xp: xpPerMilestone,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MilestoneSpec {
  final String label;
  final double angleDegrees;
  final double labelY;
  final double radius;
  final Color color;
  final bool completed;

  _MilestoneSpec({
    required this.label,
    required this.angleDegrees,
    required this.labelY,
    required this.radius,
    required this.color,
    required this.completed,
  });
}

const double _labelAnchorX = 195;

class _MilestoneLabel extends StatelessWidget {
  final String label;
  final bool completed;
  final int xp;

  const _MilestoneLabel({
    required this.label,
    required this.completed,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        if (completed) ...[
          Icon(Icons.check, size: 12, color: AppColors.greenish_2),
          const SizedBox(width: 3),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: completed ? AppColors.greenish_2 : onSurface,
              ),
            ),
            const SizedBox(width: 4),
            QuestReward(amount: '10', isXp: true, isWeekly: false, width: 10),
          ],
        ),
      ],
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final List<_MilestoneSpec> milestones;

  _ConnectorPainter({required this.milestones});

  @override
  void paint(Canvas canvas, Size size) {
    for (final m in milestones) {
      final rad = m.angleDegrees * math.pi / 180;

      final anchor = Offset(
        _ringCenter.dx + m.radius * math.cos(rad),
        _ringCenter.dy + m.radius * math.sin(rad),
      );

      final elbow = Offset(anchor.dx + 24, m.labelY);
      final labelStart = Offset(_labelAnchorX, m.labelY);

      final linePaint = Paint()
        ..color = m.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(anchor.dx, anchor.dy)
        ..lineTo(elbow.dx, elbow.dy)
        ..lineTo(labelStart.dx, labelStart.dy);

      canvas.drawPath(path, linePaint);

      final dotPaint = Paint()
        ..color = m.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(anchor, 3, dotPaint);
      canvas.drawCircle(labelStart, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) => false;
}
