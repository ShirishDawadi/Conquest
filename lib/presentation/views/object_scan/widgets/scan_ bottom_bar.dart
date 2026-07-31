import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/detection_capability_utils.dart';
import 'package:conquest/presentation/views/object_scan/widgets/status_chip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanBottomBar extends StatelessWidget {
  final bool reviewing;
  final bool? reviewFound;
  final ScanMode mode;
  final bool isCameraStable;
  final double holdProgress;
  final bool capturing;
  final String displayLabel;
  final VoidCallback onCaptureTap;
  final VoidCallback onRetryTap;

  const ScanBottomBar({
    super.key,
    required this.reviewing,
    required this.reviewFound,
    required this.mode,
    required this.isCameraStable,
    required this.holdProgress,
    required this.capturing,
    required this.displayLabel,
    required this.onCaptureTap,
    required this.onRetryTap,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusChip(),
          const SizedBox(height: 20),

          if (!reviewing && mode == ScanMode.capture)
            GestureDetector(
              onTap: capturing ? null : onCaptureTap,
              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 4),
                ),
                child: capturing
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CupertinoActivityIndicator(radius: 12,),
                      )
                    : null,
              ),
            ),

          if (reviewing && reviewFound == false)
            GestureDetector(
              onTap: onRetryTap,
              child: Container(
                width: 75,
                height:75,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color:  AppColors.border,
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.black87,
                  size: 48,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    if (reviewing) {
      return StatusChip(
        label: reviewFound == true
            ? '$displayLabel Detected'
            : '$displayLabel Not Detected',
        color: reviewFound == true
            ? AppColors.greenish_3
            : AppColors.master_mid,
      );
    }

    if (mode == ScanMode.capture) {
      return StatusChip(
        label: 'Capture to detect $displayLabel',
        color: AppColors.darkCard,
      );
    }

    if (!isCameraStable) {
      return const StatusChip(
        label: 'Hold camera still...',
        color: AppColors.darkCard,
      );
    }

    if (holdProgress > 0) {
      return const StatusChip(
        label: 'Hold still...',
        color: AppColors.greenish_2,
      );
    }

    return StatusChip(label: 'Detecting $displayLabel', color: Colors.black54);
  }
}
