import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:conquest/presentation/views/shared_widgets/session_distance_radius.dart';
import 'package:conquest/presentation/views/shared_widgets/sessions_expanded.dart';
import 'package:flutter/material.dart';

class Sessions extends StatelessWidget {
  final Color mutedColor;
  final Color borderColor;

  const Sessions({
    super.key,
    required this.mutedColor,
    required this.borderColor,
  });

  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SessionDistanceRadius(circle: 3, size: 30),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activities',
                      style: TextStyle(fontSize: 10, color: mutedColor),
                    ),
                    Row(
                      children: [
                        Text(
                          '4',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Sessions Found',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        const Spacer(),
                        QuestReward(amount: '20', isXp: true, isWeekly: false, width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SessionsExpanded(mutedColor: mutedColor),
        ],
      ),
    );
  }
}