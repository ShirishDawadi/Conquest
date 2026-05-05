import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:flutter/material.dart';

class ObjectCard extends StatelessWidget {
  final QuestObjectModel object;
  final bool completed;

  const ObjectCard({
    super.key,
    required this.object,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final difficultyColor = object.difficulty == 'easy'
        ? AppColors.greenish_3
        : object.difficulty == 'medium'
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: difficultyColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.crop_free, size: screenWidth * 0.05, color: Colors.black54),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  object.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                Text(
                  '10 XP',
                  style: TextStyle(fontSize: screenWidth * 0.025, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.greenish_3 : Colors.black,
            ),
            child: completed
                ? Icon(Icons.check, color: Colors.white, size: screenWidth * 0.03)
                : null,
          ),
        ],
      ),
    );
  }
}