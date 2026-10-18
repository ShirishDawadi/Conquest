import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/local/activity_local_source.dart';
import 'package:conquest/data/sources/local/summary_local_source.dart';
import 'package:conquest/data/sources/remote/quest_remote_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestViewModel extends AsyncNotifier<QuestModel> {
  final _source = QuestRemoteSource();
  final _local = SummaryLocalSource();

  @override
  Future<QuestModel> build() => _load();

  Future<QuestModel> _load() async {
    try {
      final quest = await _source.getTodayQuest();
      await _cache(quest);
      return quest;
    } on DioException catch (e) {
      if (e.response == null) {
        final cached = await _readCached();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  void refresh() => ref.invalidateSelf();

  Future<void> reload() async {
    if (!state.hasValue) state = const AsyncLoading();
    final result = await AsyncValue.guard(_load);
    if (result.hasError && state.hasValue) return;
    state = result;
  }

  Future<void> setupQuest(int stepGoal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final quest = await _source.setupQuest(stepGoal);
      await _cache(quest);
      return quest;
    });
  }

  String _dayKey() =>
      'quest_meta_${DateTime.now().toIso8601String().substring(0, 10)}';

  Future<void> _cache(QuestModel quest) async {
    final o1 = quest.object1;
    final o2 = quest.object2;
    if (quest.needsReset || o1 == null || o2 == null) return;

    final now = DateTime.now();
    final existing = await _local.getQuest(now);

    final localDone1 =
        existing?['object1_id'] == o1.id && existing?['object1_completed'] == 1;
    final localDone2 =
        existing?['object2_id'] == o2.id && existing?['object2_completed'] == 1;

    await _local.upsertQuest(
      date: now,
      object1: o1,
      object2: o2,
      object1Completed: (quest.object1Completed ?? false) || localDone1,
      object2Completed: (quest.object2Completed ?? false) || localDone2,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dayKey(),
      '${quest.id ?? ''}|${quest.stepGoal ?? ''}',
    );
  }

  Future<QuestModel?> _readCached() async {
    final now = DateTime.now();
    final row = await _local.getQuest(now);
    if (row == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final parts = (prefs.getString(_dayKey()) ?? '|').split('|');
    final id = int.tryParse(parts[0]);
    final savedGoal = parts.length > 1 ? int.tryParse(parts[1]) : null;

    final logGoal = (await ActivityLocalSource().getLog(now))?['steps_goal'];
    return QuestModel.fromLocal(
      row,
      id: id,
      stepGoal: savedGoal ?? ((logGoal is int && logGoal > 0) ? logGoal : null),
    );
  }
}

final questProvider = AsyncNotifierProvider<QuestViewModel, QuestModel>(
  QuestViewModel.new,
);
