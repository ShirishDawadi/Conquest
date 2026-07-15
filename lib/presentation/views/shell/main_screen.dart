import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:conquest/presentation/views/home/home_screen.dart';
import 'package:conquest/presentation/views/leaderboard/leaderboard_screen.dart';
import 'package:conquest/presentation/views/map/map_screen.dart';
import 'package:conquest/presentation/views/profile/profile_screen.dart';
import 'package:conquest/presentation/views/shell/widgets/glass_nav_bar.dart';
import 'package:conquest/presentation/views/shell/widgets/lazy_indexed_stack.dart';
import 'package:conquest/presentation/views/shell/widgets/run_button.dart';
import 'package:conquest/presentation/views/shell/widgets/tracking_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<GlobalKey> _pageKeys = List.generate(4, (_) => GlobalKey());

  void _onNavTap(int index) {
    if (index == _currentIndex) {
      _refreshCurrentPage(index);
    }
    setState(() => _currentIndex = index);
  }

  void _refreshCurrentPage(int index) {
    switch (index) {
      case 0:
        ref.read(userProvider.notifier).refresh();
        ref.read(questProvider.notifier).refresh();
        ref.read(stepProvider.notifier).refresh();
        break;
      case 1:
        ref.read(mapProvider.notifier).refresh();
        break;
      case 2:
        ref.read(leaderboardProvider.notifier).refresh();
        break;
      case 3:
        ref.read(userProvider.notifier).refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(mapProvider).isTracking;

    return Theme(
      data: _currentIndex == 1 ? ThemeData.light() : Theme.of(context),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            LazyIndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(key: _pageKeys[0]),
                MapScreen(key: _pageKeys[1]),
                LeaderboardScreen(key: _pageKeys[2]),
                ProfileScreen(key: _pageKeys[3]),
              ],
            ),

            Positioned(
              bottom: MediaQuery.of(context).viewPadding.bottom +15,
              // bottom:0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  0
                ),
                child: Column(
                  children: [
                    if (isTracking) const TrackingBar(),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: GlassNavBar(
                            currentIndex: _currentIndex,
                            onTap: _onNavTap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const RunButton(),
                      ],
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
}
