import 'package:conquest/core/theme/league_theme.dart';
import 'package:conquest/presentation/views/shared_widgets/level_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final String? fullName;
  final String? profilePhoto;
  final int level;
  final String league;
  final int allTimeXp;
  final int xpToNextLevel;
  final int totalSteps;
  final int weeklyPoints;
  final int currentStreak;
  final int longestStreak;
  final bool isOwnProfile;
  final VoidCallback? onEdit;

  const ProfileCard({
    super.key,
    required this.username,
    this.fullName,
    this.profilePhoto,
    required this.level,
    required this.league,
    required this.allTimeXp,
    required this.xpToNextLevel,
    required this.totalSteps,
    required this.weeklyPoints,
    required this.currentStreak,
    required this.longestStreak,
    this.isOwnProfile = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final leagueEnum = leagueFromString(league);
    final theme = leagueThemes[leagueEnum]!;
    final prevLeague = leagueEnum.index > 0
        ? League.values[leagueEnum.index - 1]
        : null;
    final nextLeague = leagueEnum.index < League.values.length - 1
        ? League.values[leagueEnum.index + 1]
        : null;


    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.light,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isOwnProfile)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onEdit,
                  child: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            if (!isOwnProfile)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.black, size: 20),
                ),
              ),
            Row(
              children: [
                CircleAvatar(
                  radius: (screenWidth / 8),
                  backgroundColor: theme.dark,
                  backgroundImage: profilePhoto != null
                      ? NetworkImage(profilePhoto!)
                      : const AssetImage('assets/images/default-avatar.png')
                            as ImageProvider,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          fullName ?? 'Username',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '@$username',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.dark,
                            child: Text(
                              '$level',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Level $level',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '$xpToNextLevel XP to next level',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Column(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/streak.svg',
                                width: 15,
                                height: 15,
                              ),
                              Text(
                                '$currentStreak',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LevelBar(
                        level: level,
                        theme: theme,
                        allTimeXp: allTimeXp,
                        xpToNextLevel: xpToNextLevel,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                prevLeague != null
                    ? _leagueBadge(
                        prevLeague,
                        size: screenWidth / 8,
                        opacity: 0.5,
                      )
                    : SizedBox(width: screenWidth / 8),
                const SizedBox(width: 10),
                _leagueBadge(leagueEnum, size: screenWidth / 4, opacity: 1),
                const SizedBox(width: 10),
                nextLeague != null
                    ? _leagueBadge(
                        nextLeague,
                        size: screenWidth / 8,
                        opacity: 0.5,
                      )
                    : SizedBox(width: screenWidth / 8),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                league.toLowerCase(),
                style: TextStyle(
                  color: theme.dark,
                  fontFamily: 'Vertigo',
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.dark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(_formatNumber(totalSteps), 'Total Steps'),
                  _stat(_formatNumber(weeklyPoints), 'Weekly Points'),
                  _stat('$longestStreak', 'Highest Streak'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leagueBadge(
    League league, {
    required double size,
    required double opacity,
  }) {
    return Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        'assets/images/league/${league.name}.svg',
        width: size,
        height: size,
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (label == 'Highest Streak')
              SvgPicture.asset(
                'assets/icons/streak.svg',
                width: 15,
                height: 15,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
