import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/jwt_utils.dart';
import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/views/widgets/profile_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

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
            _buildTabs(),
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

  Widget _buildTabs() {
    final tabs = ['Weekly', 'Steps', 'All time'];
    final types = [
      LeaderboardType.weekly,
      LeaderboardType.steps,
      LeaderboardType.allTime,
    ];
    final selectedIndex = types.indexOf(_selectedType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = (constraints.maxWidth - 50) / 3;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: AppColors.greenish_1,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: selectedIndex * tabWidth,
                child: Container(
                  width: tabWidth,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.greenish_4,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Row(
                children: List.generate(tabs.length, (i) {
                  final isSelected = _selectedType == types[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_selectedType == types[i]) {
                        ref
                            .read(leaderboardProvider.notifier)
                            .reload(_selectedType);
                      } else {
                        setState(() => _selectedType = types[i]);
                        ref.read(leaderboardProvider.notifier).load(types[i]);
                      }
                    },
                    child: SizedBox(
                      width: tabWidth,
                      height: 36,
                      child: Center(
                        child: Text(
                          tabs[i],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<LeaderboardEntry> entries) {
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return Column(
      children: [
        _buildPodium(top3),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: _selectedType==LeaderboardType.weekly? 0: AppConstants.navBarBottomPadding(context),
              ),
              itemCount: rest.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) =>
                  _buildTile(rest[i], rest[i].userId == (currentUserId ?? -1)),
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
            child: _buildTile(
              entries.firstWhere(
                (e) => e.userId == (currentUserId ?? -1),
                orElse: () => LeaderboardEntry(
                  rank: 0,
                  userId: currentUserId ?? -1,
                  username: 'You',
                  points: 0,
                ),
              ),
              true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    if (top3.isEmpty) return const SizedBox();
    final order = top3.length >= 3 ? [top3[1], top3[0], top3[2]] : top3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: order.map((e) {
        final isFirst = e.rank == 1;
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(0),
                child: ProfileDialog(userId: e.userId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                if (isFirst)
                  SvgPicture.asset(
                    'assets/icons/crown.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.amber,
                      BlendMode.srcIn,
                    ),
                  ),
                CircleAvatar(
                  radius: isFirst ? 36 : 28,
                  backgroundImage: e.profilePhoto != null
                      ? NetworkImage(e.profilePhoto!)
                      : const AssetImage('assets/images/default-avatar.png')
                            as ImageProvider,
                ),
                const SizedBox(height: 4),
                Text(e.username, style: const TextStyle(fontSize: 12)),
                Text(
                  '${e.points} points',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTile(LeaderboardEntry entry, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(0),
            child: ProfileDialog(userId: entry.userId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: isCurrentUser? AppColors.greenish_4: AppColors.greenish_1,
            borderRadius: BorderRadius.circular(16),
          ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                '${entry.rank}.',
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundImage: entry.profilePhoto != null
                    ? NetworkImage(entry.profilePhoto!)
                    : const AssetImage('assets/images/default-avatar.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCurrentUser ? '${entry.username} (YOU)' : entry.username,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Text(
                '${entry.points}',
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
