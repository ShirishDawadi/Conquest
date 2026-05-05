import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetCard extends ConsumerWidget {
  const ResetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppColors.greenish_1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Set your daily step goal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'You haven\'t been active for a while. Choose a step goal to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black54),
          ),
          SizedBox(height: screenHeight * 0.02),
          Wrap(
            spacing: screenWidth * 0.03,
            runSpacing: screenHeight * 0.01,
            children: [2000, 5000, 7500, 10000].map((goal) {
              return GestureDetector(
                onTap: () => ref.read(questProvider.notifier).setupQuest(goal),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenish_3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$goal steps',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}