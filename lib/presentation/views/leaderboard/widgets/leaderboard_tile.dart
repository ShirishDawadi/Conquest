import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/views/leaderboard/profile_dialog.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:conquest/presentation/views/shared_widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final LeaderboardType leaderboardType;

  const LeaderboardTile({
    super.key,
    required this.entry,
    required this.isCurrentUser,
    required this.leaderboardType,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color mutedColor = textColor.withValues(alpha: 0.50);
    final child = Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(
            '${entry.rank}.',
            style: TextStyle(
              color: isCurrentUser ? Colors.white : textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          ProfileAvatar(radius: 18, photoUrl: entry.profilePhoto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser
                      ? '${entry.fullName} (YOU)'
                      : entry.fullName,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : textColor,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${entry.username}',
                  style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white.withValues(alpha: 0.50)
                        : mutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (leaderboardType == LeaderboardType.weekly)
                SvgPicture.asset('assets/icons/weekly_point.svg', width: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${entry.points}',
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (leaderboardType == LeaderboardType.allTime)
                SvgPicture.asset('assets/icons/xp.svg', width: 10),
            ],
          ),
        ],
      ),
    );

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
      child: isCurrentUser
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.greenish_4,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            )
          : GlassContainer(borderRadius: 16, child: child),
    );
  }
}
