import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConstants {
  static final trackingBarKey = GlobalKey();

  static double navBarBottomPadding(BuildContext context) {
    final isTracking = ProviderScope.containerOf(
      context,
    ).read(mapProvider).isTracking;

    // final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    // final base = bottomInset + 15 + 52;
    final base = 15 + 52;

    if (isTracking) {
      return base + 70;
    }

    return base + 10;
  }

  static double navBarBottomPosition(BuildContext context) {
    final isTracking = ProviderScope.containerOf(
      context,
    ).read(mapProvider).isTracking;

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    final base = bottomInset + 15 + 52;

    if (isTracking) {
      return base + 70;
    }

    return base + 10;
  }
}
