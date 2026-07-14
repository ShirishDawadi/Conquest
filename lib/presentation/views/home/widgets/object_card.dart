import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/presentation/views/object_scan/scan_screen.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ObjectCard extends StatelessWidget {
  final QuestObjectModel object;
  final bool completed;

  const ObjectCard({super.key, required this.object, required this.completed});

  @override
  Widget build(BuildContext context) {
    final difficultyXP = object.difficulty == 'easy'
        ? 10
        : object.difficulty == 'medium'
        ? 15
        : 20;
    final iconColor = Theme.of(context).iconTheme.color!;

    return IconButton(
      onPressed: completed
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ScanScreen(object: object)),
              );
            },
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    object.label[0].toUpperCase() +
                        object.label.substring(1).toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  QuestReward(
                    amount: '$difficultyXP',
                    isXp: true,
                    isWeekly: true,
                    width: 9,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/scan.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                if (completed)
                  SvgPicture.asset(
                    'assets/icons/check.svg',
                    width:10,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
