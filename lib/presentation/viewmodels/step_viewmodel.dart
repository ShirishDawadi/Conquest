import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/services/reward_applier.dart';
import 'package:conquest/data/models/activity_model.dart';
import 'package:conquest/data/sources/local/activity_local_source.dart';
import 'package:conquest/data/sources/remote/activity_remote_source.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/summary_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepViewModel extends AsyncNotifier<int> {
  StepService get _service => StepService();
  final _activitySource = ActivityRemoteSource();
  final _activityLocal = ActivityLocalSource();

  StreamSubscription<int>? _subscription;
  bool _initialized = false;
  DateTime? _lastSync;

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

    _updateLocalAndSync(_service.todaySteps);

    _subscription = _service.stepStream.listen((steps) {
      state = AsyncData(steps);
      _updateLocalAndSync(steps);
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return _service.todaySteps;
  }

  void _updateLocalAndSync(int steps) {
    if (steps <= 0) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _activityLocal.upsertLocalSteps(today, steps);
    ref.invalidate(daySummaryProvider(today));

    _syncToBackend(steps, now);
  }

  void _syncToBackend(int steps, DateTime now) {
    if (_lastSync != null &&
        now.difference(_lastSync!) < const Duration(minutes: 5)) {
      return;
    }
    _lastSync = now;

    final today = now.toIso8601String().substring(0, 10);

    _activitySource
        .syncActivity(ActivitySyncRequest(date: today, steps: steps))
        .then((result) async {
          ref.invalidate(questProvider);
          await RewardApplier.apply(
            date: now,
            actionType: 'steps_completed',
            xpEarned: result.xpEarned,
            pointsEarned: result.pointsEarned,
            invalidate: (d) => ref.invalidate(daySummaryProvider(d)),
          );
        })
        .onError((e, _) {
          log('Activity sync failed: $e', name: 'StepViewModel');
        });
  }

  Future<void> refresh() async {
    log('StepViewModel refresh called, mode=${_service.mode}, state=$state', name: 'StepViewModel');
    if (_service.mode == StepTrackingMode.unavailable) return;
    if (state is AsyncLoading) return;
    await _service.retryHealthConnect();
    await _service.refresh();
    state = const AsyncLoading();
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