import 'package:conquest/core/theme/app_colors.dart';
// import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:flutter/material.dart';

class LeaderboardTabs extends StatelessWidget {
  final LeaderboardType selectedType;
  final ValueChanged<LeaderboardType> onTabChanged;
  final ValueChanged<LeaderboardType> onTabReloaded;

  const LeaderboardTabs({
    super.key,
    required this.selectedType,
    required this.onTabChanged,
    required this.onTabReloaded,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Weekly', 'Steps', 'All time'];
    final types = [
      LeaderboardType.weekly,
      LeaderboardType.steps,
      LeaderboardType.allTime,
    ];
    final selectedIndex = types.indexOf(selectedType);

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
                  final isSelected = selectedType == types[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (selectedType == types[i]) {
                        onTabReloaded(types[i]);
                      } else {
                        onTabChanged(types[i]);
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
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
}