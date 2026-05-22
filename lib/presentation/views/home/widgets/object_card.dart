import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/presentation/views/object_scan/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ObjectCard extends StatelessWidget {
  final QuestObjectModel object;
  final bool completed;

  const ObjectCard({super.key, required this.object, required this.completed});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final difficultyXP = object.difficulty == 'easy'
        ? 10
        : object.difficulty == 'medium'
            ? 15
            : 20;
    final iconColor = Theme.of(context).iconTheme.color!;

    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(width: sw * 0.01),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  object.label[0].toUpperCase() +
                      object.label.substring(1).toLowerCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: sw * 0.035,
                  ),
                ),
                Text(
                  '$difficultyXP XP',
                  style: TextStyle(
                    fontSize: sw * 0.025,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.02),
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: completed
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ScanScreen(object: object),
                          ),
                        );
                      },
                child: SvgPicture.asset(
                  'assets/icons/scan.svg',
                  width: sw * 0.08,
                  height: sw * 0.08,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              if (completed)
                SvgPicture.asset(
                  'assets/icons/check.svg',
                  width: sw * 0.025,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
            ],
          ),
        ],
      ),
    );
  }
}