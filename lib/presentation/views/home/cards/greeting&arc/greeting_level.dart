import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/user_model.dart';
import 'package:conquest/presentation/viewmodels/reward_fly_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:conquest/presentation/views/shared_widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GreetingLevel extends ConsumerWidget {
  final UserModel user;
  final String greeting;

  const GreetingLevel({super.key, required this.user, required this.greeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final held = ref.watch(
      rewardFlyProvider.select((s) => (s.heldXp, s.heldPoints)),
    );

    final shownXp = (user.allTimeXp - held.$1).clamp(0, user.allTimeXp);
    final shownPoints = (user.weeklyPoints - held.$2).clamp(
      0,
      user.weeklyPoints,
    );

    final totalXpForLevel = user.allTimeXp + user.xpToNextLevel;
    final xpProgress = totalXpForLevel > 0 ? shownXp / totalXpForLevel : 0.0;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileAvatar(
                  radius: screenWidth * 0.08,
                  photoUrl: user.profilePhoto,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontFamily: 'Vertigo',
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user.fullName ?? user.username,
                          style: const TextStyle(
                            fontFamily: 'Vertigo',
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/league/${user.league.toLowerCase()}.svg',
                  width: screenWidth * 0.125,
                  height: screenWidth * 0.125,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/xp.svg', width: 20),
                    Text(
                      '${user.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Stack(
                    key: RewardFlyKeys.xp,
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: xpProgress.clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 250),
                          builder: (_, value, _) => LinearProgressIndicator(
                            value: value,
                            borderRadius: BorderRadius.circular(20),
                            backgroundColor: AppColors.progressBarBackground(
                              context,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.diamond_dark,
                            ),
                            minHeight: 18,
                          ),
                        ),
                      ),
                      Text(
                        '$shownXp / $totalXpForLevel',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  key: RewardFlyKeys.points,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/weekly_point.svg',
                      width: 20,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 24),
                      child: Text(
                        '$shownPoints',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                SvgPicture.asset('assets/icons/streak.svg', width: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 24),
                  child: Text(
                    '${user.currentStreak}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}