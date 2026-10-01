import 'package:conquest/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ErrorStateView extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorStateView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.report_outlined,
      title: 'Something Went Wrong',
      subtitle: 'We\'re having trouble right now. Please try again.',
      onRetry: onRetry,
    );
  }
}

class NoInternetStateView extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetStateView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.wifi_off_rounded,
      title: 'No Internet Connection',
      subtitle: 'Check your connection and try again.',
      onRetry: onRetry,
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _StateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: textColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Gpkn',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Gpkn',
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenish_4,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, size: 13, color: Colors.white),
                      const SizedBox(width: 6),
                      const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: 'Gpkn',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
