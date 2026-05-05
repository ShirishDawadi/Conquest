import 'package:conquest/core/theme/league_theme.dart';
import 'package:conquest/data/models/user_model.dart';
import 'package:conquest/presentation/views/shared_widgets/level_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GreetingLevel extends StatelessWidget {
  final UserModel user;
  final String greeting;

  const GreetingLevel({super.key, required this.user, required this.greeting});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leagueEnum = leagueFromString(user.league);
    final theme = leagueThemes[leagueEnum]!;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontFamily: 'Vertigo',
                      fontSize: screenWidth * 0.05,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    user.fullName ?? user.username,
                    style: TextStyle(
                      fontFamily: 'Vertigo',
                      fontSize: screenWidth * 0.06,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/images/league/${user.league.toLowerCase()}.svg',
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.dark,
              child: Text(
                '${user.level}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: LevelBar(
                allTimeXp: user.allTimeXp,
                level: user.level,
                theme: theme,
                xpToNextLevel: user.xpToNextLevel,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/streak.svg',
                  width: screenWidth * 0.065,
                ),
                Text(
                  '${user.currentStreak}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
