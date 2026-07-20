import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SessionsExpanded extends StatelessWidget {
  final Color mutedColor;

  const SessionsExpanded({super.key, required this.mutedColor});

  static const _sessions = [
    (speed: '1.5km/hr', distance: '2.3km', time: '01:45:36'),
    (speed: '1.5km/hr', distance: '2.3km', time: '01:45:36'),
    (speed: '1.5km/hr', distance: '2.3km', time: '01:45:36'),
    (speed: '1.5km/hr', distance: '2.3km', time: '01:45:36'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                'No.',
                style: TextStyle(fontSize: 10, color: mutedColor),
              ),
            ),
            Expanded(
              child: Text(
                'Route',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: mutedColor),
              ),
            ),
            Expanded(
              child: Text(
                'Speed',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: mutedColor),
              ),
            ),
            Expanded(
              child: Text(
                'Distance',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: mutedColor),
              ),
            ),
            Expanded(
              child: Text(
                'Time',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: mutedColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...List.generate(_sessions.length, (i) {
          final s = _sessions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: Icon(
                    Icons.timeline,
                    size: 22,
                    color: AppColors.greenish_3,
                  ),
                ),
                Expanded(
                  child: Text(
                    s.speed,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    s.distance,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    s.time,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
