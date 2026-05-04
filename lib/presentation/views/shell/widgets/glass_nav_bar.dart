import 'dart:ui';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    final navHeight = MediaQuery.of(context).size.height * 0.065;

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(context, 0, 'assets/icons/home.svg', 'assets/icons/home-filled.svg', iconSize),
                _navItem(context, 1, 'assets/icons/map.svg', 'assets/icons/map-filled.svg', iconSize),
                _navItem(context, 2, 'assets/icons/leaderboard.svg', 'assets/icons/leaderboard-filled.svg', iconSize),
                _navItem(context, 3, 'assets/icons/profile.svg', 'assets/icons/profile-filled.svg', iconSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, String icon, String selectedIcon, double size) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SvgPicture.asset(
        isSelected ? selectedIcon : icon,
        colorFilter: ColorFilter.mode(
          isSelected ? AppColors.greenish_3 : Colors.black,
          BlendMode.srcIn,
        ),
        width: size,
        height: size,
      ),
    );
  }
}