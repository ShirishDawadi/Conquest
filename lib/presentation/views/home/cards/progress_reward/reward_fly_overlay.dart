import 'dart:math' as math;
import 'package:conquest/presentation/viewmodels/reward_fly_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _iconSize = 10.0;
const _flightMs = 800;
const _staggerMs = 45;
const _maxIcons = 15;

class _FlyIcon {
  final bool isXp;
  final int value;
  final Offset from;
  final Offset to;
  final int delayMs;
  final double sway;
  bool landed = false;

  _FlyIcon({
    required this.isXp,
    required this.value,
    required this.from,
    required this.to,
    required this.delayMs,
    required this.sway,
  });
}

class RewardFlyOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const RewardFlyOverlay({super.key, required this.child});

  @override
  ConsumerState<RewardFlyOverlay> createState() => _RewardFlyOverlayState();
}

class _RewardFlyOverlayState extends ConsumerState<RewardFlyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  final _rnd = math.Random();

  RewardFlyEvent? _event;
  List<_FlyIcon> _icons = const [];
  int _totalMs = _flightMs;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
  }

  @override
  void activate() {
    super.activate();
    _active = true;
  }

  @override
  void deactivate() {
    _active = false;
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context);
    if (_active) _schedule();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _schedule() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());

  Offset? _center(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    final me = context.findRenderObject() as RenderBox;
    return me.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
  }

  List<_FlyIcon> _make(int amount, bool isXp, Offset from, Offset to) {
    if (amount <= 0) return const [];
    final n = math.min(amount, _maxIcons);
    final base = amount ~/ n;
    final extra = amount % n;
    return List.generate(
      n,
      (i) => _FlyIcon(
        isXp: isXp,
        value: base + (i < extra ? 1 : 0),
        from: from + Offset((_rnd.nextDouble() - 0.5) * 30, (_rnd.nextDouble() - 0.5) * 30),
        to: to,
        delayMs: i * _staggerMs,
        sway: (_rnd.nextDouble() - 0.5) * 80,
      ),
    );
  }

  void _maybeStart() {
    if (!mounted || !_active || _event != null) return;
    final queue = ref.read(rewardFlyProvider).queue;
    if (queue.isEmpty) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    final e = queue.first;
    final size = context.size ?? Size.zero;
    final from = _center(e.source) ?? Offset(size.width / 2, size.height * 0.7);
    final fallbackTo = Offset(size.width / 2, 80);
    final xpTo =
        _center(e.offline ? RewardFlyKeys.pending : RewardFlyKeys.xp) ??
        fallbackTo;
    final ptTo =
        _center(e.offline ? RewardFlyKeys.pending : RewardFlyKeys.points) ??
        fallbackTo;

    final xpIcons = _make(e.xp, true, from, xpTo);
    final ptIcons = _make(e.points, false, from, ptTo);
    final count = math.max(xpIcons.length, ptIcons.length);

    if (count == 0) {
      ref.read(rewardFlyProvider.notifier).done();
      return;
    }

    setState(() {
      _event = e;
      _icons = [...xpIcons, ...ptIcons];
      _totalMs = _flightMs + _staggerMs * (count - 1);
    });
    _c.duration = Duration(milliseconds: _totalMs);
    _c.forward(from: 0);
  }

  void _onTick() {
    if (_event == null) return;
    final elapsed = _c.value * _totalMs;
    for (final i in _icons) {
      if (!i.landed && elapsed >= i.delayMs + _flightMs) {
        i.landed = true;
        ref
            .read(rewardFlyProvider.notifier)
            .release(i.isXp ? i.value : 0, i.isXp ? 0 : i.value);
      }
    }
  }

  void _finish() {
    if (!mounted) return;
    final notifier = ref.read(rewardFlyProvider.notifier);
    for (final i in _icons) {
      if (!i.landed) {
        i.landed = true;
        notifier.release(i.isXp ? i.value : 0, i.isXp ? 0 : i.value);
      }
    }
    notifier.done();
    setState(() {
      _event = null;
      _icons = const [];
    });
    _schedule();
  }

  Widget _iconWidget(_FlyIcon i, double t) {
    if (t <= 0 || t >= 1) return const SizedBox.shrink();
    final e = Curves.easeInOut.transform(t);
    final bump = math.sin(math.pi * e);
    final pos =
        Offset.lerp(i.from, i.to, e)! + Offset(i.sway * bump, -50 * bump);

    return Positioned(
      left: pos.dx - _iconSize / 2,
      top: pos.dy - _iconSize / 2,
      child: Transform.scale(
        scale: 1 - 0.3 * e,
        child: SvgPicture.asset(
          i.isXp ? 'assets/icons/xp.svg' : 'assets/icons/weekly_point.svg',
          width: _iconSize,
          height: _iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rewardFlyProvider.select((s) => s.queue.length), (_, _) {
      if (_active) _schedule();
    });

    return Stack(
      children: [
        widget.child,
        if (_event != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) {
                  final elapsed = _c.value * _totalMs;
                  return Stack(
                    children: [
                      for (final i in _icons)
                        _iconWidget(i, (elapsed - i.delayMs) / _flightMs),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}