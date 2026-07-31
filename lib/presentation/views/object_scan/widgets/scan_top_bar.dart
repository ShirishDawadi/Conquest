import 'package:camera/camera.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/utils/detection_capability_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScanTopBar extends StatelessWidget {
  final String displayLabel;
  final ScanMode mode;
  final bool modeReady;
  final bool showModeChip;
  final FlashMode flashMode;
  final VoidCallback onBack;
  final VoidCallback onToggleMode;
  final VoidCallback onFlashTap;

  const ScanTopBar({
    super.key,
    required this.displayLabel,
    required this.mode,
    required this.modeReady,
    required this.showModeChip,
    required this.flashMode,
    required this.onBack,
    required this.onToggleMode,
    required this.onFlashTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: SvgPicture.asset(
                'assets/icons/nav_left.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),

            Expanded(
              child: Text(
                'Detect : $displayLabel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Gpkn',
                ),
              ),
            ),

              GestureDetector(
                onTap: onFlashTap,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),

            GestureDetector(
              onTap: (modeReady && showModeChip) ? onToggleMode : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                decoration: BoxDecoration(
                  color: mode == ScanMode.live
                      ? AppColors.master_mid
                      : AppColors.greenish_3,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mode == ScanMode.live ? 'Live' : 'Capture',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}