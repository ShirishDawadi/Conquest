import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/remote/quest_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestViewModel extends AsyncNotifier<QuestModel> {
  final _source = QuestRemoteSource();

  @override
  Future<QuestModel> build() async => _source.getTodayQuest();

  Future<void> setupQuest(int stepGoal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _source.setupQuest(stepGoal));
  }

  Future<void> markStepsCompleted() async {
    final quest = state.value;
    if (quest == null || quest.id == null) return;
    state = await AsyncValue.guard(() async {
      await _source.markQuest(questId: quest.id!, stepsCompleted: true);
      return _source.getTodayQuest();
    });
  }

  Future<void> markObjectCompleted(int objectNumber) async {
    final quest = state.value;
    if (quest == null || quest.id == null) return;
    state = await AsyncValue.guard(() async {
      await _source.markQuest(
        questId: quest.id!,
        object1Completed: objectNumber == 1,
        object2Completed: objectNumber == 2,
      );
      return _source.getTodayQuest();
    });
  }
}

final questProvider = AsyncNotifierProvider<QuestViewModel, QuestModel>(
  QuestViewModel.new,
);