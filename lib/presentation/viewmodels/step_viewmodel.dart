import 'dart:async';
import 'package:conquest/core/services/step_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepViewModel extends AsyncNotifier<int> {
  StepService get _service => StepService();

  StreamSubscription<int>? _subscription;
  bool _initialized = false;

  @override
  Future<int> build() async {
    ref.keepAlive();

    await _subscription?.cancel();
    _subscription = null;

    if (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _service.initialize();
      _initialized = true;
    }

    _subscription = _service.stepStream.listen((steps) {
      state = AsyncData(steps);
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return _service.todaySteps;
  }

  Future<void> refresh() async {
    if (_service.mode == StepTrackingMode.unavailable) return;
    if (state is AsyncLoading) return;
    await _service.refresh();
    state = AsyncData(_service.todaySteps);
  }

  Future<void> retryHealthConnect() async {
    await _service.retryHealthConnect();
    state = AsyncData(_service.todaySteps);
  }

  StepTrackingMode get trackingMode => _service.mode;
}

final stepProvider = AsyncNotifierProvider<StepViewModel, int>(
  StepViewModel.new,
);

final trackingModeProvider = Provider<StepTrackingMode>((ref) {
  final stepAsync = ref.watch(stepProvider);
  return stepAsync.when(
    loading: () => StepTrackingMode.unavailable,
    error: (_, __) => StepTrackingMode.unavailable,
    data: (_) => ref.read(stepProvider.notifier).trackingMode,
  );
});