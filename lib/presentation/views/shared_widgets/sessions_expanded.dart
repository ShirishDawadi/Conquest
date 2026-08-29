import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/views/shared_widgets/route_preview.dart';
import 'package:flutter/material.dart';

class SessionsExpanded extends StatelessWidget {
  final Color mutedColor;
  final List<GpsSession> sessions;

  const SessionsExpanded({
    super.key,
    required this.mutedColor,
    required this.sessions,
  });

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = two(d.inHours);
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No sessions on this day',
            style: TextStyle(fontSize: 12, color: mutedColor),
          ),
        ),
      );
    }

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
        ...List.generate(sessions.length, (i) {
          final s = sessions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: Center(
                    child: RoutePreview(
                      session: s,
                      size: 22,
                      color: AppColors.greenish_3,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${s.speedString}km/hr',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${s.distanceKm.toStringAsFixed(2)}km',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatDuration(s.duration),
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