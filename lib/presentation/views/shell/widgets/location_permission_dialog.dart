import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/map_state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionDialog extends StatelessWidget {
  final LocationPermissionStatus status;

  const LocationPermissionDialog({super.key, required this.status});

  static Future<void> show(BuildContext context, LocationPermissionStatus status) {
    return showDialog(
      context: context,
      builder: (_) => LocationPermissionDialog(status: status),
    );
  }

  @override
  Widget build(BuildContext context) {

    String message;
    String actionLabel;
    VoidCallback onAction;

    switch (status) {
      case LocationPermissionStatus.serviceDisabled:
        message = 'Location services are turned off. Turn them on to start tracking.';
        actionLabel = 'Open Settings';
        onAction = () => Geolocator.openLocationSettings();
        break;
      case LocationPermissionStatus.deniedForever:
        message = 'Location permission was denied. Enable it in app settings to start tracking.';
        actionLabel = 'Open Settings';
        onAction = () => Geolocator.openAppSettings();
        break;
      case LocationPermissionStatus.denied:
      default:
        message = 'Location permission is required to track your route.';
        actionLabel = 'OK';
        onAction = () {};
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20,20,20,10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location needed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAction();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.greenish_3,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}