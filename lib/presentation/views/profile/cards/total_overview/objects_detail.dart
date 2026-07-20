import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ObjectsDetail extends StatelessWidget {
  final Color mutedColor;
  final Color borderColor;

  const ObjectsDetail({
    super.key,
    required this.mutedColor,
    required this.borderColor,
  });

  static const _objects = [
    (name: 'Potted Plant', found: true, rewardXp: 10),
    (name: 'Chair', found: false, rewardXp: null),
  ];

  @override
  Widget build(BuildContext context) {
    final foundCount = _objects.where((o) => o.found).length;

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
                  Row(
                    children: [
                      Text(
                        '$foundCount/${_objects.length}',
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
          ...List.generate(_objects.length * 2 - 1, (i) {
            if (i.isOdd) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(color: borderColor),
              );
            }
            final o = _objects[i ~/ 2];
            return _ObjectRow(
              name: o.name,
              found: o.found,
              rewardXp: o.rewardXp,
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
  final int? rewardXp;
  final Color borderColor;
  final Color mutedColor;

  const _ObjectRow({
    required this.name,
    required this.found,
    required this.rewardXp,
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
                if (found && rewardXp != null)
                  QuestReward(
                    amount: '10',
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
