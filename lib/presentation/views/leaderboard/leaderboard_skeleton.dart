import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase(context),
      highlightColor: AppColors.shimmerHighlight(context),
      child: Column(
        children: [
          _podiumSkeleton(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => _tileSkeleton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _podiumSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isCenter = i == 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: isCenter ? 25 : 20,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 75,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _tileSkeleton() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
