import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/profile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDialog extends ConsumerWidget {
  final int userId;
  const ProfileDialog({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(otherUserProvider(userId));

    return userState.when(
      loading: () => const Center(
        child: CupertinoActivityIndicator(
          color: AppColors.greenish_3,
          radius: 20,
        ),
      ),
      error: (e, _) => const Center(child: Text('Failed to load')),
      data: (user) => IntrinsicHeight(
        child: ProfileCard(
          username: user.username,
          fullName: user.fullName,
          profilePhoto: user.profilePhoto,
          level: user.level,
          league: user.league,
          allTimeXp: user.allTimeXp,
          xpToNextLevel: user.xpToNextLevel,
          totalSteps: user.totalSteps,
          weeklyPoints: user.weeklyPoints,
          currentStreak: user.currentStreak,
          longestStreak: user.longestStreak,
          isOwnProfile: false,
        ),
      ),
    );
  }
}