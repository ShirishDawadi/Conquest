import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GreetingLevel extends StatelessWidget {
  final UserModel user;
  final String greeting;

  const GreetingLevel({super.key, required this.user, required this.greeting});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final totalXpForLevel = user.allTimeXp + user.xpToNextLevel;
    final xpProgress = totalXpForLevel > 0
        ? user.allTimeXp / totalXpForLevel
        : 0.0;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: (screenWidth * 0.08),
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
                      style: TextStyle(fontSize: screenWidth * 0.02),
                    ),
                  ],
                ),
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
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/xp.svg',
                  width: screenWidth * 0.05,
                ),
                Text(
                  '${user.level}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    child: LinearProgressIndicator(
                      value: xpProgress.clamp(0.0, 1.0),
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      backgroundColor: AppColors.progressBarBackground(context),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.diamond_dark),
                      minHeight: screenWidth * 0.045,
                    ),
                  ),
                  Text(
                    '${user.allTimeXp.toInt()} / $totalXpForLevel',
                    style: TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ],
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
