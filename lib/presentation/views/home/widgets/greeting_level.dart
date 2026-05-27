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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: (screenWidth * 0.09),
              backgroundImage: user.profilePhoto != null
                  ? NetworkImage(user.profilePhoto!)
                  : const AssetImage('assets/images/default-avatar.png')
                        as ImageProvider,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: 'Vertigo',
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                    Text(
                      user.fullName ?? user.username,
                      style: TextStyle(
                        fontFamily: 'Vertigo',
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/images/league/${user.league.toLowerCase()}.svg',
              width: screenWidth * 0.175,
              height: screenWidth * 0.175,
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
            const SizedBox(width: 20),
            SvgPicture.asset(
              'assets/icons/weekly_point.svg',
              width: screenWidth * 0.05,
            ),
            Text(
              '${user.weeklyPoints}',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              'assets/icons/streak.svg',
              width: screenWidth * 0.05,
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
    );
  }
}
