import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/steps_stats_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/summary_viewmodel.dart';
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
  bool _tapArmed = false;

  final List<GlobalKey> _pageKeys = List.generate(4, (_) => GlobalKey());
  final List<ScrollController> _scrollControllers = List.generate(
    4,
    (_) => ScrollController(),
  );

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      _tapArmed = false;
      setState(() => _currentIndex = index);
      return;
    }

    final controller = _scrollControllers[index];
    final position = controller.positions.isEmpty
        ? null
        : controller.positions.first;
    final isScrolled = position != null && position.pixels > 1;

    if (isScrolled) {
      position.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      _tapArmed = true;
    } else if (_tapArmed) {
      _tapArmed = false;
      _refreshCurrentPage(index);
    } else {
      _tapArmed = true;
    }
  }

  void _refreshCurrentPage(int index) {
    switch (index) {
      case 0:
        ref.read(userProvider.notifier).refresh();
        ref.read(questProvider.notifier).refresh();
        ref.read(stepProvider.notifier).refresh();
        ref.read(mapProvider.notifier).refresh();
        break;
      case 1:
        ref.read(mapProvider.notifier).refresh();
        break;
      case 2:
        ref.read(leaderboardProvider.notifier).refresh();
        break;
      case 3:
        ref.read(userProvider.notifier).refresh();
        ref.read(stepsStatsProvider.notifier).refresh();
        final today = DateTime.now();
        ref.invalidate(
          daySummaryProvider(DateTime(today.year, today.month, today.day)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(mapProvider).isTracking;

    final pages = <Widget>[
      HomeScreen(key: _pageKeys[0]),
      MapScreen(key: _pageKeys[1]),
      LeaderboardScreen(key: _pageKeys[2]),
      ProfileScreen(key: _pageKeys[3]),
    ];

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
                for (var i = 0; i < pages.length; i++)
                  PrimaryScrollController(
                    controller: _scrollControllers[i],
                    child: pages[i],
                  ),
              ],
            ),

            Positioned(
              bottom: MediaQuery.of(context).viewPadding.bottom + 15,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
