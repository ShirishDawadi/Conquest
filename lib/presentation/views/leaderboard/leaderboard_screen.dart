import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/jwt_utils.dart';
import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/views/leaderboard/leaderboard_skeleton.dart';
import 'package:conquest/presentation/views/leaderboard/widgets/leaderboard_podium.dart';
import 'package:conquest/presentation/views/leaderboard/widgets/leaderboard_tabs.dart';
import 'package:conquest/presentation/views/leaderboard/widgets/leaderboard_tile.dart';
import 'package:conquest/presentation/views/shared_widgets/error_state_view.dart';
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
  bool _refreshing = false;

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

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await Future.wait([
      ref.read(leaderboardProvider.notifier).reload(_selectedType),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'leader board',
              style: TextStyle(fontFamily: 'Vertigo', fontSize: 24),
            ),
            const SizedBox(height: 15),
            LeaderboardTabs(
              selectedType: _selectedType,
              onTabChanged: (type) {
                setState(() => _selectedType = type);
                ref.read(leaderboardProvider.notifier).load(type);
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: leaderboardState.when(
                loading: () => const LeaderboardSkeleton(),
                error: (e, _) {
                  if (e is DioException && e.response?.statusCode == 403) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'You\'re in the waiting room',
                            style: TextStyle(fontFamily: 'Gpkn', fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'ll be assigned to a group on Monday',
                            style: TextStyle(fontFamily: 'Gpkn', fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  final isOffline =
                      e is DioException &&
                      e.type == DioExceptionType.connectionError;

                  return isOffline
                      ? NoInternetStateView(
                          onRetry: () => ref
                              .read(leaderboardProvider.notifier)
                              .reload(_selectedType),
                        )
                      : ErrorStateView(
                          onRetry: () => ref
                              .read(leaderboardProvider.notifier)
                              .reload(_selectedType),
                        );
                },
                data: (entries) => Stack(
                  children: [
                    _buildList(entries),

                    if (_selectedType == LeaderboardType.weekly)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: AppConstants.navBarBottomPadding(context),
                        child: IntrinsicHeight(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
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
                                  fullName: 'You',
                                  points: 0,
                                ),
                              ),
                              isCurrentUser: true,
                              leaderboardType: _selectedType,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 120,
          onRefresh: _onRefresh,
        ),
        if (_refreshing)
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const LeaderboardSkeleton(),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: LeaderboardPodium(
              top3: top3,
              leaderboardType: _selectedType,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList.separated(
              itemCount: rest.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => LeaderboardTile(
                entry: rest[i],
                isCurrentUser: rest[i].userId == (currentUserId ?? -1),
                leaderboardType: _selectedType,
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: AppConstants.navBarBottomPadding(context)),
        ),
        if (_selectedType == LeaderboardType.weekly)
          SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.navBarBottomPadding(context)),
          ),
      ],
    );
  }
}
