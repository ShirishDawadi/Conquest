import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/presentation/views/leaderboard/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntry> top3;

  const LeaderboardPodium({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox();
    final order = top3.length >= 3 ? [top3[1], top3[0], top3[2]] : top3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: order.map((e) {
        final isFirst = e.rank == 1;
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(0),
                child: ProfileDialog(userId: e.userId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                if (isFirst)
                  SvgPicture.asset(
                    'assets/icons/crown.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                  ),
                CircleAvatar(
                  radius: isFirst ? 36 : 28,
                  backgroundImage: e.profilePhoto != null
                      ? NetworkImage(e.profilePhoto!)
                      : const AssetImage('assets/images/default-avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 4),
                Text(e.username, style: const TextStyle(fontSize: 12)),
                Text(
                  '${e.points} points',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}