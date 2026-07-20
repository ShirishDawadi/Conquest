import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/profile/cards/total_overview/objects_detail.dart';
import 'package:conquest/presentation/views/profile/cards/total_overview/sessions.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TotalOverviewExpanded extends StatelessWidget {
  final Color mutedColor;
  final Color borderColor;

  const TotalOverviewExpanded({
    super.key,
    required this.mutedColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepsCaloriesRow(mutedColor: mutedColor, borderColor: borderColor),
        const SizedBox(height: 12),
        ObjectsDetail(mutedColor: mutedColor, borderColor: borderColor),
        const SizedBox(height: 12),
        Sessions(mutedColor: mutedColor, borderColor: borderColor),
      ],
    );
  }
}

class _StepsCaloriesRow extends StatelessWidget {
  final Color mutedColor;
  final Color borderColor;

  const _StepsCaloriesRow({
    required this.mutedColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/steps.svg',
                        width: 30,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                          AppColors.greenish_3,
                          BlendMode.srcIn,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Steps',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mutedColor,
                                  ),
                                ),
                                QuestReward(
                                  amount: '10',
                                  isXp: true,
                                  isWeekly: true,
                                  width: 10,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '5605',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '/5000',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mutedColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '100%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 5,
                      backgroundColor: borderColor,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.greenish_3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/kcal.svg',
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calories',
                            style: TextStyle(fontSize: 10, color: mutedColor),
                          ),
                          Text(
                            '300 kcal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
