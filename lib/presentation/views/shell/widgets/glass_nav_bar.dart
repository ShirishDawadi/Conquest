import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
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

    return GlassContainer(
      borderRadius: 30,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: _navItem(
                context,
                0,
                'assets/icons/home.svg',
                'assets/icons/home-filled.svg',
              ),
            ),
            Expanded(
              child: _navItem(
                context,
                1,
                'assets/icons/map.svg',
                'assets/icons/map-filled.svg',
              ),
            ),
            Expanded(
              child: _navItem(
                context,
                2,
                'assets/icons/leaderboard.svg',
                'assets/icons/leaderboard-filled.svg',
              ),
            ),
            Expanded(
              child: _navItem(
                context,
                3,
                'assets/icons/profile.svg',
                'assets/icons/profile-filled.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    String icon,
    String selectedIcon,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SvgPicture.asset(
        isSelected ? selectedIcon : icon,
        colorFilter: ColorFilter.mode(
          isSelected
              ? AppColors.greenish_3
              : Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
        width: 24,
        height: 24,
      ),
    );
  }
}
