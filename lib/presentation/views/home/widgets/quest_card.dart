import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/presentation/views/home/widgets/object_card.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  final int steps;

  const QuestCard({super.key, required this.quest, required this.steps});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final goal = quest.stepGoal ?? 1;
    final progress = (steps / goal).clamp(0.0, 1.0);

    return GlassContainer(
      blur: 0,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Today's Quest",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    width: screenWidth * 0.06,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/steps.svg',
                        width: screenWidth * 0.075,
                        height: screenWidth * 0.075,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${quest.stepGoal} Steps Goal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                QuestReward(
                                  amount: '10',
                                  isXp: true,
                                  isWeekly: true,
                                  width: screenWidth * 0.028,
                                ),
                                Text(
                                  '${(progress * 100).toInt()}% Completed',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.028,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: AppColors.progressBarBackground(
                            context,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.greenish_3,
                          ),
                          minHeight: screenWidth * 0.04,
                        ),
                      ),

                      Text(
                        '$steps/${quest.stepGoal}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Scan the following objects:',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Row(
              children: [
                if (quest.object1 != null)
                  Expanded(
                    child: ObjectCard(
                      object: quest.object1!,
                      completed: quest.object1Completed ?? false,
                    ),
                  ),
                if (quest.object1 != null && quest.object2 != null)
                  SizedBox(width: screenWidth * 0.03),
                if (quest.object2 != null)
                  Expanded(
                    child: ObjectCard(
                      object: quest.object2!,
                      completed: quest.object2Completed ?? false,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
