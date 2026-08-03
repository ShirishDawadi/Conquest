import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/presentation/views/home/cards/quest_card/object_card.dart';
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
    final goal = quest.stepGoal ?? 1;
    final progress = (steps / goal).clamp(0.0, 1.0);

    return GlassContainer(
      blur: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Today's Quest",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: SvgPicture.asset(
                //     'assets/icons/edit.svg',
                //     width: 24,
                //     colorFilter: ColorFilter.mode(
                //       Theme.of(context).iconTheme.color!,
                //       BlendMode.srcIn,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.all(16),
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
                        width: 30,
                        height: 30,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${quest.stepGoal} Steps Goal',
                              style: TextStyle(fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                QuestReward(
                                  amount: '10',
                                  isXp: true,
                                  isWeekly: true,
                                  width: 10,
                                ),
                                Text(
                                  '${(progress * 100).toInt()}% Completed',
                                  style: TextStyle(
                                    fontSize: 10,
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
                  SizedBox(height: 5),
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
                          minHeight: 16,
                        ),
                      ),

                      Text(
                        '$steps/${quest.stepGoal}',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Scan the following objects:',
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                if (quest.object1 != null)
                  Expanded(
                    child: ObjectCard(
                      object: quest.object1!,
                      completed: quest.object1Completed ?? false,
                      questId: quest.id,
                    ),
                  ),
                if (quest.object1 != null && quest.object2 != null)
                  SizedBox(width: 10),
                if (quest.object2 != null)
                  Expanded(
                    child: ObjectCard(
                      object: quest.object2!,
                      completed: quest.object2Completed ?? false,
                      questId: quest.id,
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
