// core/services/activity_sync_service.dart

import 'dart:async';
import 'dart:developer';
import 'package:conquest/core/services/step_service.dart';
import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:conquest/data/models/activity_model.dart';
import 'package:conquest/data/sources/local/activity_local_source.dart';
import 'package:conquest/data/sources/remote/activity_remote_source.dart';

class ActivitySyncService {
  static final ActivitySyncService _instance = ActivitySyncService._internal();
  factory ActivitySyncService() => _instance;
  ActivitySyncService._internal();

  final _local = ActivityLocalSource();
  final _remote = ActivityRemoteSource();
  final _stepService = StepService();

  StreamSubscription<int>? _stepSubscription;
  Timer? _retrySyncTimer;

  Future<void> start() async {
    await _stepService.initialize();

    _stepSubscription = _stepService.stepStream.listen((steps) {
      _handleStepUpdate(steps);
    });

    _retrySyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncUnsyncedLogs();
    });

    syncUnsyncedLogs();
  }

  Future<void> _handleStepUpdate(int steps) async {
    final today = DateTime.now();

    await _local.upsertLocalSteps(today, steps);

    await _syncDay(today, steps);
  }

  Future<void> _syncDay(DateTime date, int steps) async {
    try {
      if (!await ConnectivityUtils.isOnline()) return;

      final result = await _remote.syncActivity(
        ActivitySyncRequest(
          date: date.toIso8601String().substring(0, 10),
          steps: steps,
        ),
      );

      await _local.markSynced(date);

      log('Synced activity for ${result.date}: ${result.steps} steps', name: 'ActivitySyncService');
    } catch (e) {
      log('ActivitySyncService _syncDay failed: $e', name: 'ActivitySyncService');
    }
  }

  Future<void> syncUnsyncedLogs() async {
    try {
      if (!await ConnectivityUtils.isOnline()) return;

      final unsynced = await _local.getUnsyncedLogs();
      for (final row in unsynced) {
        final date = DateTime.parse(row['date'] as String);
        final steps = row['steps_achieved'] as int;

        try {
          await _remote.syncActivity(
            ActivitySyncRequest(
              date: row['date'] as String,
              steps: steps,
            ),
          );
          await _local.markSynced(date);
        } catch (e) {
          log('Retry sync failed for ${row['date']}: $e', name: 'ActivitySyncService');
        }
      }
    } catch (e) {
      log('ActivitySyncService syncUnsyncedLogs failed: $e', name: 'ActivitySyncService');
    }
  }

  void dispose() {
    _stepSubscription?.cancel();
    _retrySyncTimer?.cancel();
  }
}