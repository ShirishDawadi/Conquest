import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/views/leaderboard/profile_dialog.dart';
import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
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
          color: isCurrentUser ? AppColors.greenish_4 : AppColors.greenish_1,
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
                    : const AssetImage('assets/images/default-avatar.png') as ImageProvider,
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