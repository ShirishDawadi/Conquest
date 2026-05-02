import 'dart:ui';
import 'package:conquest/presentation/views/home_screen.dart';
import 'package:conquest/presentation/views/leaderboard_screen.dart';
import 'package:conquest/presentation/views/map_screen.dart';
import 'package:conquest/presentation/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:conquest/core/theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isRunning = false;
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          _LazyIndexedStack(
            index: _currentIndex,
            children: const [
              HomeScreen(),
              MapScreen(),
              LeaderboardScreen(),
              ProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).padding.bottom + 25,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildGlassNav()),
                  const SizedBox(width: 10),
                  _buildRunButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNav() {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    final navHeight = MediaQuery.of(context).size.height * 0.065;

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(
                  0,
                  'assets/icons/home.svg',
                  'assets/icons/home-filled.svg',
                  iconSize,
                ),
                _navItem(
                  1,
                  'assets/icons/map.svg',
                  'assets/icons/map-filled.svg',
                  iconSize,
                ),
                _navItem(
                  2,
                  'assets/icons/leaderboard.svg',
                  'assets/icons/leaderboard-filled.svg',
                  iconSize,
                ),
                _navItem(
                  3,
                  'assets/icons/profile.svg',
                  'assets/icons/profile-filled.svg',
                  iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, String icon, String selectedIcon, double size) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: SvgPicture.asset(
        isSelected ? selectedIcon : icon,
        colorFilter: ColorFilter.mode(
          isSelected ? AppColors.greenish_3 : Colors.black,
          BlendMode.srcIn,
        ),
        width: size,
        height: size,
      ),
    );
  }

  Widget _buildRunButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.25;
    final buttonHeight = buttonWidth * 0.35;
    final thumbSize = buttonHeight;
    final thumbTravel = buttonWidth - thumbSize - 20;

    final thumbPosition = _isRunning
        ? thumbTravel - (_dragProgress * thumbTravel)
        : _dragProgress * thumbTravel;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          if (!_isRunning) {
            _dragProgress = (_dragProgress + details.delta.dx / 60).clamp(
              0.0,
              1.0,
            );
          } else {
            _dragProgress = (_dragProgress - details.delta.dx / 60).clamp(
              0.0,
              1.0,
            );
          }
        });
        if (_dragProgress >= 1.0) {
          setState(() {
            _isRunning = !_isRunning;
            _dragProgress = 0.0;
          });
        }
      },
      onHorizontalDragEnd: (_) {
        setState(() => _dragProgress = 0.0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: _isRunning ? AppColors.master_light : AppColors.greenish_1,
          borderRadius: BorderRadius.circular(buttonHeight / 2),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              left: _isRunning ? buttonWidth * 0.1 : null,
              right: _isRunning ? null : buttonWidth * 0.1,
              child: Text(
                _isRunning ? 'Stop' : 'Start',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Gpkn',
                  fontSize: buttonHeight * 0.35,
                ),
              ),
            ),
            Positioned(
              right: buttonWidth * 0.1,
              child: Text(
                'Start',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Gpkn',
                  fontSize: buttonHeight * 0.35,
                ),
              ),
            ),
            Positioned(
              left: buttonWidth * 0.1,
              child: Text(
                'Stop',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Gpkn',
                  fontSize: buttonHeight * 0.35,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: _dragProgress > 0
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              left: thumbPosition,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: thumbSize * 1.6,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: _isRunning
                      ? AppColors.master_dark
                      : AppColors.greenish_3,
                  borderRadius: BorderRadius.circular(thumbSize / 2),
                ),
                child: Icon(
                  _isRunning ? Icons.arrow_back : Icons.arrow_forward,
                  color: Colors.white,
                  size: thumbSize * 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _LazyIndexedStack({required this.index, required this.children});

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List.generate(
      widget.children.length,
      (i) => i == widget.index,
    );
  }

  @override
  void didUpdateWidget(_LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activated[widget.index] = true;
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        return _activated[i] ? widget.children[i] : const SizedBox.shrink();
      }),
    );
  }
}
