import 'package:conquest/presentation/views/home_screen.dart';
import 'package:conquest/presentation/views/leaderboard_screen.dart';
import 'package:conquest/presentation/views/map_screen.dart';
import 'package:conquest/presentation/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:conquest/core/theme/app_colors.dart';

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
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          MapScreen(),
          LeaderboardScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == _currentIndex) {
            // reload logic later
          }
          setState(() => _currentIndex = index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/home-filled.svg',
              colorFilter: ColorFilter.mode(AppColors.greenish_3, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/map.svg',
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/map-filled.svg',
              colorFilter: ColorFilter.mode(AppColors.greenish_3, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            label: 'Map',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/leaderboard.svg',
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/leaderboard-filled.svg',
              colorFilter: ColorFilter.mode(AppColors.greenish_3, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/profile.svg',
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/profile-filled.svg',
              colorFilter: ColorFilter.mode(AppColors.greenish_3, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}