import 'package:conquest/core/theme/league_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LevelBar extends StatelessWidget {
  final int level;
  final LeagueTheme theme;
  final int allTimeXp;
  final int xpToNextLevel;

  const LevelBar({
    super.key,
    required this.level,
    required this.theme,
    required this.allTimeXp,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final totalXpForLevel = allTimeXp + xpToNextLevel;
    final xpProgress = totalXpForLevel > 0 ? allTimeXp / totalXpForLevel : 0.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: xpProgress.clamp(0.0, 1.0),
            borderRadius: BorderRadius.circular(20),
            backgroundColor: theme.mid,
            valueColor: AlwaysStoppedAnimation<Color>(theme.dark),
            minHeight: 20,
          ),
        ),

        Positioned(
          left: 8,
          child: Text(
            "$level",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),

        Text(
          '${allTimeXp.toInt()} / $totalXpForLevel',
          style: TextStyle(fontSize: 8, color: Colors.white),
        ),

        Positioned(
          right: 8,
          child: Text(
            "${(level).toInt() + 1}",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
