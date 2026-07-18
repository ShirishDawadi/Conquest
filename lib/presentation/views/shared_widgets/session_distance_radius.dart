import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SessionDistanceRadius extends StatelessWidget {
  final int circle;
  const SessionDistanceRadius({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
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
            width: 16,
            height: 16,
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
                  width: 8,
                  height: 8,
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
