import 'dart:math' as math;
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _leagues = [
  'bronze',
  'silver',
  'gold',
  'platinum',
  'diamond',
  'master',
  'legend',
];

class ProgressCelebration {
  static bool _showing = false;

  static Future<void> show(BuildContext context, ProgressEvent e) async {
    if (_showing) return;
    _showing = true;
    try {
      if (e.type == ProgressEventType.leagueUp) {
        await _leagueBelt(context, e);
      } else {
        await _levelUp(context, e);
      }
    } finally {
      _showing = false;
    }
  }

  static Future<void> _leagueBelt(BuildContext context, ProgressEvent e) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => _LeagueBelt(event: e),
      transitionBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  static Future<void> _levelUp(BuildContext context, ProgressEvent e) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => _LevelUp(event: e),
      transitionBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}

List<_Particle> _makeParticles({int count = 90}) {
  final rnd = math.Random();
  const colors = [
    AppColors.gold_light,
    AppColors.master_mid,
    AppColors.legend_light,
    AppColors.diamond_dark,
    AppColors.bronze_dark,
    AppColors.platinum_light,
  ];
  return List.generate(count, (i) {
    final left = i.isEven;
    final spread = (rnd.nextDouble() - 0.5) * math.pi * 0.35;
    final base = left ? -math.pi * 0.36 : -math.pi * 0.64;
    return _Particle(
      fromLeft: left,
      angle: base + spread,
      speed: 0.55 + rnd.nextDouble() * 0.6,
      size: 6 + rnd.nextDouble() * 6,
      spin: rnd.nextDouble() * 10,
      color: colors[rnd.nextInt(colors.length)],
    );
  });
}

class _LevelUp extends StatefulWidget {
  final ProgressEvent event;
  const _LevelUp({required this.event});

  @override
  State<_LevelUp> createState() => _LevelUpState();
}

class _LevelUpState extends State<_LevelUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final List<_Particle> _particles = _makeParticles();

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = _c.value;
          final pop = Curves.elasticOut.transform((t / 0.4).clamp(0.0, 1.0));
          final fade = t > 0.85 ? ((1 - t) / 0.15).clamp(0.0, 1.0) : 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Opacity(
                  opacity: fade,
                  child: Transform.scale(
                    scale: pop,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            fontFamily: 'Vertigo',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.event.level}',
                          style: const TextStyle(
                            fontFamily: 'Vertigo',
                            fontSize: 64,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(painter: _ConfettiPainter(_particles, t)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LeagueBelt extends StatefulWidget {
  final ProgressEvent event;
  const _LeagueBelt({required this.event});

  @override
  State<_LeagueBelt> createState() => _LeagueBeltState();
}

class _LeagueBeltState extends State<_LeagueBelt>
    with SingleTickerProviderStateMixin {
  static const _slideStart = 0.20;
  static const _slideEnd = 0.65;

  static const _beltWidth = 400.0;
  static const _beltHeight = 200.0;
  static const _spacing = 150.0;
  static const _bigSize = 200.0;
  static const _smallSize = 50.0;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );
  late final List<_Particle> _particles = _makeParticles();

  late final int _newIdx;
  late final int _oldIdx;

  @override
  void initState() {
    super.initState();
    final idx = _leagues.indexOf(widget.event.league.toLowerCase());
    _newIdx = idx < 0 ? 0 : idx;
    _oldIdx = math.max(0, _newIdx - 1);

    _c.forward().whenComplete(() {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = _c.value;
          final slideT = Curves.easeInOutCubic.transform(
            ((t - _slideStart) / (_slideEnd - _slideStart)).clamp(0.0, 1.0),
          );
          final current = _oldIdx + (_newIdx - _oldIdx) * slideT;
          final confettiT = ((t - _slideEnd) / (1 - _slideEnd)).clamp(0.0, 1.0);
          final arrived = slideT >= 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: _beltWidth,
                      height: _beltHeight,
                      child: _belt(current),
                    ),
                    const SizedBox(height: 24),
                    AnimatedOpacity(
                      opacity: arrived ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          Text(
                            'Promoted to ${_title(widget.event.league)}!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Vertigo',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You reached level ${widget.event.level}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (confettiT > 0)
                IgnorePointer(
                  child: CustomPaint(
                    painter: _ConfettiPainter(_particles, confettiT),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _belt(double current) {
    const centerX = _beltWidth / 2;
    const centerY = _beltHeight / 2;

    final badges = <_Badge>[];
    for (var i = 0; i < _leagues.length; i++) {
      final d = i - current;
      final focus = (1 - d.abs()).clamp(0.0, 1.0);
      final size = _smallSize + (_bigSize - _smallSize) * focus;

      badges.add(
        _Badge(
          name: _leagues[i],
          x: centerX + d * _spacing,
          size: size,
          opacity: 0.4 + 0.6 * focus,
          dist: d.abs(),
        ),
      );
    }
    badges.sort((a, b) => b.dist.compareTo(a.dist));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final b in badges)
          Positioned(
            left: b.x - b.size / 2,
            top: centerY - b.size / 2,
            child: Opacity(
              opacity: b.opacity,
              child: SvgPicture.asset(
                'assets/images/league/${b.name}.svg',
                width: b.size,
                height: b.size,
              ),
            ),
          ),
      ],
    );
  }

  String _title(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _Badge {
  final String name;
  final double x, size, opacity, dist;
  _Badge({
    required this.name,
    required this.x,
    required this.size,
    required this.opacity,
    required this.dist,
  });
}

class _Particle {
  final bool fromLeft;
  final double angle, speed, size, spin;
  final Color color;
  _Particle({
    required this.fromLeft,
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in particles) {
      final origin = Offset(p.fromLeft ? 0 : size.width, size.height);
      final dist = p.speed * size.height * 0.9 * Curves.easeOut.transform(t);
      final gravity = 0.7 * size.height * t * t;
      final pos = Offset(
        origin.dx + math.cos(p.angle) * dist,
        origin.dy + math.sin(p.angle) * dist + gravity,
      );

      paint.color = p.color.withValues(alpha: (1 - t * t).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t * 6);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
