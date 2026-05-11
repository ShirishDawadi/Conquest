import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/views/home/widgets/background_tracking_dialog.dart';
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

    final sw = MediaQuery.of(context).size.width;
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
      margin: EdgeInsets.only(bottom: sw * 0.04),
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: BoxBorder.all(
          color: iconColor.withValues(alpha: 0.4)
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: sw * 0.005),
            child: Icon(
              Icons.warning_rounded,
              color: iconColor,
              size: sw * 0.06,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: sw * 0.01),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    color: Colors.black.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: sw * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _dismissed = true),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.03,
                          vertical: sw * 0.015,
                        ),
                        child: Text(
                          'Remind Me Later',
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (isPedometer) ...[
                      SizedBox(width: sw * 0.02),
                      GestureDetector(
                        onTap: () => BackgroundTrackingDialog.show(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.05,
                            vertical: sw * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(sw * 0.035),
                          ),
                          child: Text(
                            'Setup',
                            style: TextStyle(
                              fontSize: sw * 0.033,
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