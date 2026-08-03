import 'package:conquest/presentation/views/shared_widgets/character_avatar.dart';
import 'package:flutter/material.dart';

class SessionAvatarCard extends StatelessWidget {
  final bool isSessionActive;
  final double currentDistanceKm;
  final double? bestSessionKm;

  const SessionAvatarCard({
    super.key,
    required this.isSessionActive,
    required this.currentDistanceKm,
    required this.bestSessionKm,
  });

  double _nextGoalKm(double distanceKm) {
    if (distanceKm < 0.5) return 0.5;
    if (distanceKm < 1.0) return 1.0;
    return 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.10);

    final goalKm = _nextGoalKm(currentDistanceKm);
    final percent = ((currentDistanceKm / goalKm) * 100).clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CharacterAvatar(isActive: isSessionActive, size: 48),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSessionActive) ...[
                  Text(
                    '${currentDistanceKm.toStringAsFixed(1)}km',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  Text(
                    currentDistanceKm >= 2.0
                        ? '100% completed'
                        : '$percent% to ${goalKm == 0.5 ? '500m' : '${goalKm.toStringAsFixed(0)}km'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text('Current Session', style: TextStyle(fontSize: 12)),
                ] else ...[
                  Text(
                    'No Active\nSession',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bestSessionKm != null
                ? '-- Best: ${bestSessionKm!.toStringAsFixed(1)}km'
                : '-- Best: 0.0km',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
