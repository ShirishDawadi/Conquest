import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';

class LeaderboardTabs extends StatelessWidget {
  final LeaderboardType selectedType;
  final ValueChanged<LeaderboardType> onTabChanged;

  const LeaderboardTabs({
    super.key,
    required this.selectedType,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Weekly', 'Steps', 'XP'];
    final types = [LeaderboardType.weekly, LeaderboardType.steps, LeaderboardType.allTime];
    final selectedIndex = types.indexOf(selectedType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = (constraints.maxWidth - 50) / 3;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GlassContainer(
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
                    final isSelected = selectedType == types[i];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (selectedType != types[i]) onTabChanged(types[i]);
                      },
                      child: SizedBox(
                        width: tabWidth,
                        height: 36,
                        child: Center(
                          child: Text(
                            tabs[i],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
