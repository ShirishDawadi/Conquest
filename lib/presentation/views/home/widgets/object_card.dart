import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ObjectCard extends StatelessWidget {
  final QuestObjectModel object;
  final bool completed;

  const ObjectCard({super.key, required this.object, required this.completed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final difficultyXP = object.difficulty == 'easy'
        ? 10
        : object.difficulty == 'medium'
        ? 15
        : 20;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.greenish_2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth * 0.01),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  object.label[0].toUpperCase() +
                      object.label.substring(1).toLowerCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                Text(
                  '$difficultyXP XP',
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: screenWidth * 0.02),

          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/scan.svg',
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
              ),

              if (completed)
                SvgPicture.asset(
                  'assets/icons/check.svg',
                  width: screenWidth * 0.025,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
