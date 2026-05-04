import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/jwt_utils.dart';
import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/views/leaderboard/widgets/leaderboard_podium.dart';
import 'package:conquest/presentation/views/leaderboard/widgets/leaderboard_tabs.dart';
import 'package:conquest/presentation/views/leaderboard/widgets/leaderboard_tile.dart';
// import 'package:conquest/presentation/views/leaderboard/widgets/profile_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardType _selectedType = LeaderboardType.weekly;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    JwtUtils.getUserId().then((id) {
      if (mounted) setState(() => currentUserId = id);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardProvider.notifier).load(LeaderboardType.weekly);
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'leader board',
              style: TextStyle(
                fontFamily: 'Vertigo',
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            LeaderboardTabs(
              selectedType: _selectedType,
              onTabChanged: (type) {
                setState(() => _selectedType = type);
                ref.read(leaderboardProvider.notifier).load(type);
              },
              onTabReloaded: (type) {
                ref.read(leaderboardProvider.notifier).reload(type);
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: leaderboardState.when(
                loading: () => const Center(
                  child: CupertinoActivityIndicator(
                    color: AppColors.greenish_3,
                    radius: 20,
                  ),
                ),
                error: (e, _) {
                  if (e is DioException && e.response?.statusCode == 403) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'You\'re in the waiting room',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Gpkn',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'ll be assigned to a group on Monday',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Gpkn',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('Failed to load'));
                },
                data: (entries) => _buildList(entries),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<LeaderboardEntry> entries) {
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return Column(
      children: [
        LeaderboardPodium(top3: top3),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: _selectedType == LeaderboardType.weekly
                    ? 0
                    : AppConstants.navBarBottomPadding(context),
              ),
              itemCount: rest.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => LeaderboardTile(
                entry: rest[i],
                isCurrentUser: rest[i].userId == (currentUserId ?? -1),
              ),
            ),
          ),
        ),
        if (_selectedType == LeaderboardType.weekly) ...[
          const SizedBox(height: 8),
          Container(
            margin: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              AppConstants.navBarBottomPadding(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.greenish_4,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LeaderboardTile(
              entry: entries.firstWhere(
                (e) => e.userId == (currentUserId ?? -1),
                orElse: () => LeaderboardEntry(
                  rank: 0,
                  userId: currentUserId ?? -1,
                  username: 'You',
                  points: 0,
                ),
              ),
              isCurrentUser: true,
            ),
          ),
        ],
      ],
    );
  }
}