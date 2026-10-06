import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TotalOverviewSkeleton extends StatelessWidget {
  final bool expanded;
  const TotalOverviewSkeleton({super.key, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: expanded ? const _ExpandedShape() : const _CompactShape(),
    );
  }
}

Widget _box({double? height, double radius = 12}) => Container(
  height: height,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
  ),
);

class _CompactShape extends StatelessWidget {
  const _CompactShape();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _box(height: 60)),
            const SizedBox(width: 8),
            Expanded(child: _box(height: 60)),
            const SizedBox(width: 8),
            Expanded(child: _box(height: 60)),
          ],
        ),
        const SizedBox(height: 20),
        _box(height: 20, radius: 6),
      ],
    );
  }
}

class _ExpandedShape extends StatelessWidget {
  const _ExpandedShape();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: _box(height: 58, radius: 20)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _box(height: 58, radius: 20)),
          ],
        ),
        const SizedBox(height: 12),
        _box(height: 100, radius: 20),
        const SizedBox(height: 12),
        _box(height: 100, radius: 20),
      ],
    );
  }
}
