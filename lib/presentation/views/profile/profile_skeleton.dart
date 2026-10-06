import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {

    Widget box(double height) => Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase(context),
        highlightColor: AppColors.shimmerHighlight(context),
        child: Column(
          children: [
            box(400),
            const SizedBox(height: 12),
            box(400),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: box(200)),
                const SizedBox(width: 12),
                Expanded(child: box(200)),
              ],
            ),
            const SizedBox(height: 12),
            box(500),
          ],
        ),
      ),
    );
  }
}
