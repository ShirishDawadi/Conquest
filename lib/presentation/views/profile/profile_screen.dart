import 'dart:async';
import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/steps_stats_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/summary_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/profile/cards/activity_overview/calendar_session_row.dart';
import 'package:conquest/presentation/views/profile/cards/total_overview/total_overview.dart';
import 'package:conquest/presentation/views/profile/edit_profile_screen.dart';
import 'package:conquest/presentation/views/profile/cards/steps_overview/steps_overview_card.dart';
import 'package:conquest/presentation/views/profile/profile_skeleton.dart';
import 'package:conquest/presentation/views/shared_widgets/profile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _GapDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  const _GapDelegate(this.height);

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox(height: height);

  @override
  bool shouldRebuild(covariant _GapDelegate old) => old.height != height;
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);

    unawaited(ref.read(daySummaryProvider(_selectedDate).notifier).refresh());
    ref.invalidate(stepsStatsProvider);

    try {
      await Future.wait([
        ref.read(userProvider.notifier).reload(),
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
    } catch (_) {}

    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.value;
    final showSkeleton = _refreshing || userState.isLoading;

    final summaryAsync = ref.watch(daySummaryProvider(_selectedDate));
    final sessionCount = summaryAsync.maybeWhen(
      data: (summary) => summary?.gpsSessions.length ?? 0,
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const SliverPersistentHeader(delegate: _GapDelegate(40)),
            SliverAppBar(
              floating: true,
              snap: true,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              title: const Text(
                'profile',
                style: TextStyle(fontFamily: 'Vertigo', fontSize: 24),
              ),
              // actions: [],
            ),
            CupertinoSliverRefreshControl(
              refreshTriggerPullDistance: 120,
              onRefresh: _onRefresh,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (showSkeleton)
                    const ProfileSkeleton()
                  else if (user == null)
                    const Center(child: Text('Failed to load'))
                  else ...[
                    ProfileCard(
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
                      onEdit: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const EditProfileScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                    ),
                    StepsOverviewCard(),
                    CalendarSessionRow(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                      sessions: sessionCount,
                    ),
                    const SizedBox(height: 10),
                    TotalOverview(date: _selectedDate),
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
                            await ref
                                .read(authViewModelProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/landing',
                              );
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
                  SizedBox(height: AppConstants.navBarBottomPadding(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
