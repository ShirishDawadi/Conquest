import 'package:flutter/material.dart';

class CharacterAvatar extends StatefulWidget {
  final bool isActive;
  final double size;

  const CharacterAvatar({
    super.key,
    required this.isActive,
    this.size = 44,
  });

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frame = (_controller.value * 4).floor().clamp(0, 3);
        return Image.asset(
          'assets/images/character/${widget.isActive ? 'walk' : 'stand'}_$frame.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        );
      },
    );
  }
}