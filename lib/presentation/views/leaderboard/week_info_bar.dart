import 'dart:async';
import 'package:conquest/core/utils/week_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WeekInfoBar extends StatefulWidget {
  const WeekInfoBar({super.key});

  @override
  State<WeekInfoBar> createState() => _WeekInfoBarState();
}

class _WeekInfoBarState extends State<WeekInfoBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration r) {
    final d = r.inDays;
    final h = r.inHours % 24;
    final m = r.inMinutes % 60;
    final s = r.inSeconds % 60;

    if (d > 0) return '${d}d ${h}h';
    if (r.inHours > 0) return '${h}h ${m}m';
    if (r.inMinutes > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final switchAt = WeekUtils.boardMonday().add(
      const Duration(days: 7, hours: WeekUtils.switchHourUtc),
    );
    var remaining = switchAt.difference(nowUtc);
    if (remaining.isNegative) remaining = Duration.zero;

    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            'assets/icons/time.svg',
            width: 12,
            colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(
            'Season ends in ${_format(remaining)}',
            style: TextStyle(fontSize: 10, color: muted),
          ),
        ],
      ),
    );
  }
}
