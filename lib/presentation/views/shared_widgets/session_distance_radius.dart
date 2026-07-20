import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SessionDistanceRadius extends StatelessWidget {
  final int circle;
  final double size;
  const SessionDistanceRadius({
    super.key,
    required this.circle,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circle >= 3 ? AppColors.greenish_3 : null,
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 0.5,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: (size*2)/3,
            height: (size*2)/3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circle >= 2 ? AppColors.greenish_2 : null,
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: size/3,
                  height: size/3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circle >= 1 ? AppColors.greenish_1 : null,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
