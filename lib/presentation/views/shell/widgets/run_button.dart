import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunButton extends ConsumerStatefulWidget {
  const RunButton({super.key});

  @override
  ConsumerState<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends ConsumerState<RunButton> {
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(mapProvider).isTracking;
    final buttonWidth = 105.0;
    final buttonHeight = 35.0;
    final thumbSize = buttonHeight;
    final thumbTravel = buttonWidth - thumbSize - 20;

    final thumbPosition = isTracking
        ? thumbTravel - (_dragProgress * thumbTravel)
        : _dragProgress * thumbTravel;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          if (!isTracking) {
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
          setState(() => _dragProgress = 0.0);
          if (!isTracking) {
            ref.read(mapProvider.notifier).startTracking();
          } else {
            ref.read(mapProvider.notifier).stopTracking();
          }
        }
      },
      onHorizontalDragEnd: (_) => setState(() => _dragProgress = 0.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: isTracking ? AppColors.master_light : AppColors.greenish_1,
          borderRadius: BorderRadius.circular(buttonHeight / 2),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              left: isTracking ? buttonWidth * 0.1 : null,
              right: isTracking ? null : buttonWidth * 0.1,
              child: Text(
                isTracking ? 'Stop' : 'Start',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Gpkn',
                  fontSize: 12
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
                  color: isTracking
                      ? AppColors.master_dark
                      : AppColors.greenish_3,
                  borderRadius: BorderRadius.circular(thumbSize / 2),
                ),
                child: Icon(
                  isTracking ? Icons.arrow_back : Icons.arrow_forward,
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
