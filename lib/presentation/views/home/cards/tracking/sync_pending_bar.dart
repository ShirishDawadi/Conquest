import 'package:conquest/presentation/viewmodels/connectivity_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/pending_rewards_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SyncPendingBar extends ConsumerWidget {
  const SyncPendingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingRewardsProvider).value;
    if (pending == null || pending.isEmpty) return const SizedBox.shrink();

    final offline = ref.watch(connectivityProvider).value == false;
    final w = MediaQuery.of(context).size.width;
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);

    Widget amount(String icon, int value) => Padding(
      padding: EdgeInsets.only(left: w * 0.03),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: w * 0.035),
          SizedBox(width: w * 0.01),
          Text(
            '+$value',
            style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: w * 0.02),
      child: GlassContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: w * 0.025,
          ),
          child: Row(
            children: [
              Icon(
                offline ? Icons.wifi_off_rounded : Icons.sync_rounded,
                size: w * 0.04,
                color: muted,
              ),
              SizedBox(width: w * 0.02),
              Expanded(
                child: Text(
                  offline ? 'Get online to sync · up to' : 'Syncing · up to',
                  style: TextStyle(fontSize: w * 0.03, color: muted),
                ),
              ),
              if (pending.xp > 0) amount('assets/icons/xp.svg', pending.xp),
              if (pending.points > 0)
                amount('assets/icons/weekly_point.svg', pending.points),
            ],
          ),
        ),
      ),
    );
  }
}