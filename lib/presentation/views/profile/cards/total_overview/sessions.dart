import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/views/shared_widgets/quest_reward.dart';
import 'package:conquest/presentation/views/shared_widgets/session_distance_radius.dart';
import 'package:conquest/presentation/views/shared_widgets/sessions_expanded.dart';
import 'package:flutter/material.dart';

class Sessions extends StatelessWidget {
  final List<GpsSession> sessions;
  final Color mutedColor;
  final Color borderColor;
  final int? distanceXp;

  const Sessions({
    super.key,
    required this.sessions,
    required this.mutedColor,
    required this.borderColor,
    this.distanceXp,
  });

  @override
  Widget build(BuildContext context) {
    final bestDistanceMeters = sessions.isEmpty
        ? 0.0
        : sessions
                .map((s) => s.furthestDistanceKm)
                .reduce((a, b) => a > b ? a : b) *
            1000;

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
              SessionDistanceRadius(
                distanceMeters: bestDistanceMeters,
                size: 30,
              ),
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
                          '${sessions.length}',
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
                        QuestReward(
                          amount: '${distanceXp ?? 0}',
                          isXp: true,
                          isWeekly: false,
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SessionsExpanded(mutedColor: mutedColor, sessions: sessions,),
        ],
      ),
    );
  }
}