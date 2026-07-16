import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/activity_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class StepsBarChart extends StatefulWidget {
  final List<StepsStatsDay> days;
  final bool isLoading;
  final ValueChanged<StepsStatsDay>? onBarTap;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const StepsBarChart({
    super.key,
    required this.days,
    this.isLoading = false,
    this.onBarTap,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  State<StepsBarChart> createState() => _StepsBarChartState();
}

class _StepsBarChartState extends State<StepsBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _growth;

  static const double _swipeVelocityThreshold = 200.0;
  static const double _axisLabelWidth = 28.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _growth = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (!widget.isLoading && widget.days.isNotEmpty) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant StepsBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final justFinishedLoading = oldWidget.isLoading && !widget.isLoading;
    final dataChanged = !listEquals(oldWidget.days, widget.days);
    if (!widget.isLoading && (justFinishedLoading || dataChanged)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = widget.days
        .map((d) => d.steps > d.goal ? d.steps : d.goal)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final axisMax = maxValue == 0
        ? 1000
        : ((maxValue / 1000).ceil() * 1000).clamp(1000, 1 << 30);

    return LayoutBuilder(
      builder: (context, constraints) {
        final plotWidth = constraints.maxWidth - _axisLabelWidth;
        final barSlotWidth = widget.days.isEmpty
            ? 0.0
            : plotWidth / widget.days.length;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.onBarTap == null || widget.days.isEmpty
              ? null
              : (details) {
                  final localX = details.localPosition.dx - _axisLabelWidth;
                  if (localX < 0) return;
                  final index = (localX / barSlotWidth).floor();
                  if (index < 0 || index >= widget.days.length) return;
                  widget.onBarTap!(widget.days[index]);
                },
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity <= -_swipeVelocityThreshold) {
              widget.onSwipeLeft?.call();
            } else if (velocity >= _swipeVelocityThreshold) {
              widget.onSwipeRight?.call();
            }
          },
          child: Column(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _growth,
                  builder: (context, _) => CustomPaint(
                    painter: _StepsBarChartPainter(
                      days: widget.days,
                      axisMax: axisMax.toDouble(),
                      growth: widget.isLoading ? 0 : _growth.value,
                      completeColor: AppColors.greenish_3,
                      incompleteColor: AppColors.master_mid,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.greenish_3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  Text(
                    'Complete Goal',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.40),
                      fontSize: 10,
                    ),
                  ),
              
                  const SizedBox(width: 8,),
              
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.master_mid,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  Text(
                    'Incomplete Goal',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.40),
                      fontSize: 10,
                    ),
                  ),
              
                  const SizedBox(width: 8,),
              
                  _DashedBox(color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 2,),
                  Text(
                    'Goal',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.40),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepsBarChartPainter extends CustomPainter {
  final List<StepsStatsDay> days;
  final double axisMax;
  final double growth;
  final Color completeColor;
  final Color incompleteColor;
  final Color foregroundColor;

  static const double _chartBottomPadding = 32.0;
  static const double _chartTopPadding = 8.0;
  static const double _axisLabelWidth = 28.0;
  static const double _minBarGap = 2.0;
  static const double _goalLineInset = 1.5;

  _StepsBarChartPainter({
    required this.days,
    required this.axisMax,
    required this.growth,
    required this.completeColor,
    required this.incompleteColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final plotHeight = size.height - _chartBottomPadding - _chartTopPadding;
    final plotLeft = _axisLabelWidth;
    final plotWidth = size.width - plotLeft;

    _drawGridAndAxis(canvas, size, plotLeft, plotWidth, plotHeight);

    if (days.isEmpty) return;

    final barSlotWidth = plotWidth / days.length;
    final barWidth = (barSlotWidth - _minBarGap).clamp(2.0, 22.0);

    final showLabelEvery = days.length <= 7
        ? 1
        : (days.length / 6).ceil().clamp(1, 10);

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final slotLeft = plotLeft + i * barSlotWidth;
      final barLeft = slotLeft + (barSlotWidth - barWidth) / 2;

      final date = DateTime.parse(day.date);
      final shouldLabel =
          days.length <= 7 || date.day % showLabelEvery == 0 || date.day == 1;
      if (shouldLabel) {
        final label = days.length <= 7
            ? DateFormat('E').format(date)
            : '${date.day}';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: days.length <= 7 ? 10 : 8,
              color: foregroundColor.withValues(alpha: 0.40),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            slotLeft + (barSlotWidth - tp.width) / 2,
            size.height - _chartBottomPadding + 10,
          ),
        );
      }

      if (growth <= 0) continue;

      final stepsRatio = axisMax == 0
          ? 0.0
          : (day.steps / axisMax).clamp(0.0, 1.0) * growth;
      final goalRatio = axisMax == 0
          ? 0.0
          : (day.goal / axisMax).clamp(0.0, 1.0) * growth;

      final barTop = _chartTopPadding + plotHeight * (1 - stepsRatio);
      final barBottom = _chartTopPadding + plotHeight;

      final isComplete = day.goal > 0 && day.steps >= day.goal;
      final barColor = day.steps == 0
          ? completeColor.withValues(alpha: 0.15)
          : (isComplete ? completeColor : incompleteColor);

      final cornerRadius = Radius.circular(barWidth < 8 ? 2 : 6);
      final barRRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(barLeft, barTop, barLeft + barWidth, barBottom),
        topLeft: cornerRadius,
        topRight: cornerRadius,
      );
      canvas.drawRRect(barRRect, Paint()..color = barColor);

      if (day.goal > 0) {
        final goalTop = _chartTopPadding + plotHeight * (1 - goalRatio);
        final inset = (barWidth / 2 - 0.5).clamp(0.0, _goalLineInset);
        final goalRect = Rect.fromLTRB(
          barLeft + inset,
          goalTop,
          barLeft + barWidth - inset,
          barBottom,
        );
        _drawDashedRect(canvas, goalRect, foregroundColor);
      }
    }
  }

  void _drawGridAndAxis(
    Canvas canvas,
    Size size,
    double plotLeft,
    double plotWidth,
    double plotHeight,
  ) {
    const gridLines = 4;
    final gridPaint = Paint()
      ..color = foregroundColor.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    for (var i = 0; i <= gridLines; i++) {
      final y = _chartTopPadding + plotHeight * (1 - i / gridLines);
      canvas.drawLine(Offset(plotLeft, y), Offset(size.width, y), gridPaint);

      final value = axisMax * i / gridLines;
      final label = value >= 1000
          ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k'
          : value.toInt().toString();

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 10,
            color: foregroundColor.withValues(alpha: 0.40),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plotLeft - tp.width - 6, y - tp.height / 2));
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    const dashWidth = 3.0;
    const dashSpace = 3.0;

    void dashedLine(Offset start, Offset end) {
      final totalLength = (end - start).distance;
      if (totalLength == 0) return;
      final direction = (end - start) / totalLength;
      var drawn = 0.0;
      while (drawn < totalLength) {
        final segmentEnd = (drawn + dashWidth).clamp(0.0, totalLength);
        canvas.drawLine(
          start + direction * drawn,
          start + direction * segmentEnd,
          paint,
        );
        drawn += dashWidth + dashSpace;
      }
    }

    dashedLine(rect.topLeft, rect.topRight);
    dashedLine(rect.topRight, rect.bottomRight);
    dashedLine(rect.bottomRight, rect.bottomLeft);
    dashedLine(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant _StepsBarChartPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.axisMax != axisMax ||
        oldDelegate.growth != growth;
  }
}

class _DashedBox extends StatelessWidget {
  final Color color;

  const _DashedBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: CustomPaint(painter: _DashedBoxPainter(color: color)),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  final Color color;

  _DashedBoxPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashWidth = 2.0;
    const dashSpace = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(2),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBoxPainter oldDelegate) =>
      oldDelegate.color != color;
}
