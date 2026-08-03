import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/home/cards/tracking/background_tracking_dialog.dart';
import 'package:flutter/material.dart';

class TrackingBanner extends StatefulWidget {
  final StepTrackingMode mode;

  const TrackingBanner({super.key, required this.mode});

  @override
  State<TrackingBanner> createState() => _TrackingBannerState();
}

class _TrackingBannerState extends State<TrackingBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.mode == StepTrackingMode.health || _dismissed) {
      return const SizedBox.shrink();
    }

    final isPedometer = widget.mode == StepTrackingMode.pedometer;

    final bgColor = isPedometer
        ? AppColors.greenish_1
        : Colors.red.withValues(alpha: 0.08);
    final iconColor = isPedometer ? AppColors.greenish_3 : Colors.red;
    final title = isPedometer
        ? 'Background Step Tracking'
        : 'Step Tracking Unavailable';
    final body = isPedometer
        ? 'Steps only count while the app is open. To count steps while app is closed, setup background step tracking.'
        : 'Step tracking is unavailable. Please grant activity recognition permission in Settings.';

    return Container(
      margin: EdgeInsets.only(bottom: 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(
          color: iconColor.withValues(alpha: 0.4)
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_rounded,
            color: iconColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black.withValues(alpha: 0.5),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _dismissed = true),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          'Remind Me Later',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (isPedometer) ...[
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => BackgroundTrackingDialog.show(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Setup',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}