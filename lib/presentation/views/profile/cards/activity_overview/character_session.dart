import 'package:conquest/presentation/views/shared_widgets/session_distance_radius.dart';
import 'package:flutter/material.dart';

class CharacterSession extends StatelessWidget {
  final int sessions;

  const CharacterSession({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.10),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/character/stand_0.png',
            width: 200,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SessionDistanceRadius(circle: 3),
              const SizedBox(width: 6),
              Text(
                '$sessions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                ' Sessions',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
