import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class BackgroundTrackingDialog extends ConsumerStatefulWidget {
  const BackgroundTrackingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const BackgroundTrackingDialog(),
    );
  }

  @override
  ConsumerState<BackgroundTrackingDialog> createState() =>
      _BackgroundTrackingDialogState();
}

class _BackgroundTrackingDialogState
    extends ConsumerState<BackgroundTrackingDialog> {
  bool _hasHealthConnect = false;
  bool _hasGoogleFit = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    final healthConnect = await StepService().isHealthConnectAvailable;
    final googleFit = await canLaunchUrl(
      Uri.parse('android-app://com.google.android.apps.fitness'),
    );
    if (mounted) {
      setState(() {
        _hasHealthConnect = healthConnect;
        _hasGoogleFit = googleFit;
        _loading = false;
      });
    }
  }

  Future<void> _openPlayStore(String packageName) async {
    final uri = Uri.parse('market://details?id=$packageName');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _openHealthConnect() async {
    final uri = Uri.parse('android-app://com.google.android.apps.healthdata');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openGoogleFit() async {
    final uri = Uri.parse('android-app://com.google.android.apps.fitness');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onDone() async {
    await ref.read(stepProvider.notifier).retryHealthConnect();
    if (mounted) Navigator.of(context).pop();
  }

  int _stepNumber({required bool isConnectStep}) {
    int n = 1;
    if (!_hasHealthConnect) n++;
    if (!_hasGoogleFit) n++;
    if (isConnectStep) return n;
    return n + 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: _loading
            ? SizedBox(
                height: screenWidth * 0.3,
                child: const Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Background Step Tracking',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    'Complete the steps below to count steps even when the app is closed.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  if (!_hasHealthConnect)
                    _StepTile(
                      number: 1,
                      title: 'Install Health Connect',
                      description: 'Required to sync step data with your app.',
                      buttonLabel: 'Open Play Store',
                      onTap: () => _openPlayStore(
                        'com.google.android.apps.healthdata',
                      ),
                      screenWidth: screenWidth,
                    ),
                  if (!_hasGoogleFit)
                    _StepTile(
                      number: !_hasHealthConnect ? 2 : 1,
                      title: 'Install Google Fit',
                      description:
                          'Counts your steps and writes them to Health Connect.',
                      buttonLabel: 'Open Play Store',
                      onTap: () => _openPlayStore(
                        'com.google.android.apps.fitness',
                      ),
                      screenWidth: screenWidth,
                    ),
                  _StepTile(
                    number: _stepNumber(isConnectStep: true),
                    title: 'Connect Google Fit to Health Connect',
                    description:
                        'Open Google Fit → Profile → Settings → Health Connect → Enable sync.',
                    buttonLabel: 'Open Google Fit',
                    onTap: _openGoogleFit,
                    screenWidth: screenWidth,
                  ),
                  _StepTile(
                    number: _stepNumber(isConnectStep: false),
                    title: 'Allow Conquest to read steps',
                    description:
                        'Open Health Connect → App permissions → Conquest → Allow Steps.',
                    buttonLabel: 'Open Health Connect',
                    onTap: _openHealthConnect,
                    screenWidth: screenWidth,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      FilledButton(
                        onPressed: _onDone,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.greenish_3,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenWidth * 0.03,
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;
  final double screenWidth;

  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.035,
            backgroundColor: AppColors.greenish_3,
            child: Text(
              '$number',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                SizedBox(height: screenWidth * 0.005),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: screenWidth * 0.015),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    '$buttonLabel →',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: AppColors.greenish_3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}