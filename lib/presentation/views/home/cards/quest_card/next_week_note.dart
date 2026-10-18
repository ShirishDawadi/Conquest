import 'package:conquest/core/utils/week_utils.dart';
import 'package:flutter/material.dart';

class NextWeekNote extends StatelessWidget {
  const NextWeekNote({super.key});

  @override
  Widget build(BuildContext context) {
    if (!WeekUtils.isAheadOfBoard()) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              "Points you earn now count toward next week's leaderboard",
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
