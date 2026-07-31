import 'package:conquest/data/models/quest_model.dart';
import 'package:conquest/data/sources/remote/quest_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestViewModel extends AsyncNotifier<QuestModel> {
  final _source = QuestRemoteSource();

  @override
  Future<QuestModel> build() async => _source.getTodayQuest();

  void refresh() => ref.invalidateSelf();

  Future<void> setupQuest(int stepGoal) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _source.setupQuest(stepGoal));
  }
}

final questProvider = AsyncNotifierProvider<QuestViewModel, QuestModel>(
  QuestViewModel.new,
);