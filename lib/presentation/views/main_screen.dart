import 'package:conquest/presentation/views/home_screen.dart';
import 'package:conquest/presentation/views/leaderboard_screen.dart';
import 'package:conquest/presentation/views/map_screen.dart';
import 'package:conquest/presentation/views/profile_screen.dart';
import 'package:conquest/presentation/views/widgets/navigation/glass_nav_bar.dart';
import 'package:conquest/presentation/views/widgets/navigation/lazy_indexed_stack.dart';
import 'package:conquest/presentation/views/widgets/navigation/run_button.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          LazyIndexedStack(
            index: _currentIndex,
            children: const [
              HomeScreen(),
              MapScreen(),
              LeaderboardScreen(),
              ProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).padding.bottom + 25,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GlassNavBar(
                      currentIndex: _currentIndex,
                      onTap: (index) => setState(() => _currentIndex = index),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const RunButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}