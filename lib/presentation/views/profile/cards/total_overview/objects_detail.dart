import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/summary_model.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class ObjectsDetail extends StatelessWidget {
  final DaySummaryModel summary;
  final Color mutedColor;
  final Color borderColor;

  const ObjectsDetail({
    super.key,
    required this.summary,
    required this.mutedColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final objectRewards = summary.objectRewards;

    int? xpForIndex(int index) {
      if (objectRewards.length > index) {
        return objectRewards[index].xpEarned;
      }
      return null;
    }

    final rawObjects = [
      (
        name: summary.object1.label,
        found: summary.object1Completed,
        imageUrl: summary.object1.imageUrl,
        xp: summary.object1Completed ? xpForIndex(0) : null,
      ),
      (
        name: summary.object2.label,
        found: summary.object2Completed,
        imageUrl: summary.object2.imageUrl,
        xp: summary.object2Completed
            ? xpForIndex(objectRewards.length > 1 ? 1 : 0)
            : null,
      ),
    ];

    // an object slot with no label means no quest object was assigned for it
    final objects = rawObjects.where((o) => o.name.isNotEmpty).toList();

    final foundCount = objects.where((o) => o.found).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/scan.svg',
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  AppColors.bronze_mid,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Objects',
                    style: TextStyle(fontSize: 10, color: mutedColor),
                  ),
                  if (objects.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          '$foundCount/${objects.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Found',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (objects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  'No quests found',
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ),
            )
          else
            ...List.generate(objects.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Divider(color: borderColor),
                );
              }
              final o = objects[i ~/ 2];
              return _ObjectRow(
                name: _capitalize(o.name),
                found: o.found,
                imageUrl: o.imageUrl,
                xp: o.xp,
                borderColor: borderColor,
                mutedColor: mutedColor,
              );
            }),
        ],
      ),
    );
  }
}

class _ObjectRow extends StatelessWidget {
  final String name;
  final bool found;
  final String? imageUrl;
  final int? xp;
  final Color borderColor;
  final Color mutedColor;

  const _ObjectRow({
    required this.name,
    required this.found,
    required this.imageUrl,
    required this.xp,
    required this.borderColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (found)
                  QuestReward(
                    amount: '${xp ?? 0}',
                    isXp: true,
                    isWeekly: true,
                    width: 10,
                  ),
              ],
            ),
          ),
          if (found)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    )
                  : null,
            )
          else
            Text(
              'Not Found',
              style: TextStyle(fontSize: 11, color: mutedColor),
            ),
        ],
      ),
    );
  }
}