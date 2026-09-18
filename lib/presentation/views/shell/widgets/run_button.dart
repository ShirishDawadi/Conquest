import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunButton extends ConsumerStatefulWidget {
  const RunButton({super.key});

  @override
  ConsumerState<RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends ConsumerState<RunButton> {
  static const _snapDuration = Duration(milliseconds: 300);

  double _dragProgress = 0.0;
  bool _isBusy = false;
  bool _busyIsStarting = false;
  bool _showBusyText = false;

  Future<void> _handleSwipeComplete(bool isTracking) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _busyIsStarting = !isTracking;
      _showBusyText = false;
    });

    await Future.delayed(_snapDuration);

    if (!mounted) return;

    setState(() {
      _showBusyText = true;
    });

    Object? error;

    try {
      final notifier = ref.read(mapProvider.notifier);

      if (!isTracking) {
        await notifier.startTracking();
      } else {
        await notifier.stopTracking();
      }
    } catch (e, st) {
      error = e;

      debugPrint('RunButton tracking operation failed: $e\n$st');
    } finally {
      if (!mounted) return;

      setState(() {
        _isBusy = false;
        _showBusyText = false;
        _busyIsStarting = false;
      });
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _dragProgress = 0.0;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Could not change tracking state. Please try again.',
              style: TextStyle(fontFamily: 'Gpkn'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    await Future.delayed(_snapDuration);

    if (!mounted) return;

    setState(() {
      _dragProgress = 0.0;
    });
  }

  Future<void> _handleTap() async {
    if (_isBusy) return;

    final isTracking = ref.read(mapProvider).isTracking;

    HapticFeedback.mediumImpact();

    await _handleSwipeComplete(isTracking);
  }

  void _handleDragUpdate(DragUpdateDetails details, bool isTracking) {
    if (_isBusy) return;

    setState(() {
      if (!isTracking) {
        _dragProgress = (_dragProgress + details.delta.dx / 60).clamp(0.0, 1.0);
      } else {
        _dragProgress = (_dragProgress - details.delta.dx / 60).clamp(0.0, 1.0);
      }
    });

    if (_dragProgress >= 1.0) {
      HapticFeedback.mediumImpact();
      _handleSwipeComplete(isTracking);
    }
  }

  void _handleDragEnd() {
    if (_isBusy) return;

    setState(() {
      _dragProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(mapProvider).isTracking;

    final buttonWidth = 105.0;
    final buttonHeight = 35.0;
    final thumbSize = buttonHeight;
    final baseThumbWidth = thumbSize * 1.6;
    final thumbTravel = buttonWidth - baseThumbWidth;

    final thumbWidth = baseThumbWidth + (_dragProgress * thumbTravel);

    final thumbLeft = isTracking ? thumbTravel * (1 - _dragProgress) : 0.0;

    return Semantics(
      button: true,
      enabled: !_isBusy,
      label: isTracking ? 'Stop tracking' : 'Start tracking',
      hint: _isBusy
          ? (_busyIsStarting ? 'Starting tracking' : 'Stopping tracking')
          : (isTracking
                ? 'Swipe left to stop tracking'
                : 'Swipe right to start tracking'),
      onTap: _isBusy ? null : _handleTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onHorizontalDragUpdate: _isBusy
            ? null
            : (details) {
                _handleDragUpdate(details, isTracking);
              },

        onHorizontalDragEnd: _isBusy ? null : (_) => _handleDragEnd(),

        child: AnimatedContainer(
          duration: _snapDuration,
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
              if (!_isBusy && _dragProgress == 0.0)
                Positioned(
                  left: isTracking ? buttonWidth * 0.1 : null,
                  right: isTracking ? null : buttonWidth * 0.1,
                  child: Text(
                    isTracking ? 'Stop' : 'Start',
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Gpkn',
                      fontSize: 12,
                    ),
                  ),
                ),

              AnimatedPositioned(
                duration: _dragProgress > 0 && !_isBusy
                    ? Duration.zero
                    : _snapDuration,
                left: thumbLeft,
                child: AnimatedContainer(
                  duration: _dragProgress > 0 && !_isBusy
                      ? Duration.zero
                      : _snapDuration,
                  curve: Curves.easeInOut,
                  width: thumbWidth,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: isTracking
                        ? AppColors.master_dark
                        : AppColors.greenish_3,
                    borderRadius: BorderRadius.circular(thumbSize / 2),
                  ),
                  child: _showBusyText
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: _busyIsStarting
                              ? [
                                  const Text(
                                    'Starting',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gpkn',
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: thumbSize * 0.45,
                                  ),
                                ]
                              : [
                                  Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: thumbSize * 0.45,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Stopping',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gpkn',
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                        )
                      : Center(
                          child: Icon(
                            isTracking ? Icons.arrow_back : Icons.arrow_forward,
                            color: Colors.white,
                            size: thumbSize * 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
