import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RunButton extends StatefulWidget {
  const RunButton({super.key});

  @override
  State<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<RunButton> {
  bool _isRunning = false;
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
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
            _dragProgress = (_dragProgress + details.delta.dx / 60).clamp(0.0, 1.0);
          } else {
            _dragProgress = (_dragProgress - details.delta.dx / 60).clamp(0.0, 1.0);
          }
        });
        if (_dragProgress >= 1.0) {
          setState(() {
            _isRunning = !_isRunning;
            _dragProgress = 0.0;
          });
        }
      },
      onHorizontalDragEnd: (_) => setState(() => _dragProgress = 0.0),
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
            AnimatedPositioned(
              duration: _dragProgress > 0 ? Duration.zero : const Duration(milliseconds: 300),
              left: thumbPosition,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: thumbSize * 1.6,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: _isRunning ? AppColors.master_dark : AppColors.greenish_3,
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