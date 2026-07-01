import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConstants {
  static final trackingBarKey = GlobalKey();

  static double navBarBottomPadding(BuildContext context) {
    final isTracking = ProviderScope.containerOf(context).read(mapProvider).isTracking;

    final base = MediaQuery.of(context).padding.bottom +
        25 +
        MediaQuery.of(context).size.height * 0.065;

    if (isTracking) {
      return base + 60;
    }

    return base + 10;
  }
}