import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/widgets/profile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: AppConstants.navBarBottomPadding(context),
          ),

          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'profile',
                style: TextStyle(
                  fontFamily: 'Vertigo',
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              userState.when(
                loading: () => const Center(
                  child: CupertinoActivityIndicator(
                    color: AppColors.greenish_3,
                    radius: 20,
                  ),
                ),
                error: (e, _) => const Center(child: Text('Failed to load')),
                data: (user) => ProfileCard(
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
                  isOwnProfile: true,
                  onEdit: () {},
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/landing');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenish_4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
