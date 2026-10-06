import 'package:conquest/data/models/leaderboard_model.dart';
import 'package:conquest/data/sources/remote/leaderboard_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardViewModel extends AsyncNotifier<List<LeaderboardEntry>> {
  final _source = LeaderboardRemoteSource();
  final _cache = <LeaderboardType, List<LeaderboardEntry>>{};
  LeaderboardType? _lastType;

  @override
  Future<List<LeaderboardEntry>> build() async {
    _cache.clear();
    _lastType = LeaderboardType.weekly;
    return _fetch(LeaderboardType.weekly);
  }

  Future<List<LeaderboardEntry>> _fetch(LeaderboardType type) async {
    final data = switch (type) {
      LeaderboardType.weekly => await _source.getWeekly(),
      LeaderboardType.steps => await _source.getHallOfFameSteps(),
      LeaderboardType.allTime => await _source.getHallOfFameXp(),
    };
    _cache[type] = data;
    return data;
  }

  Future<void> refresh() {
    _cache.clear();
    if (_lastType != null) return load(_lastType!);
    return load(LeaderboardType.weekly);
  }

  Future<void> load(LeaderboardType type) async {
    _lastType = type;
    if (_cache.containsKey(type)) {
      state = AsyncData(_cache[type]!);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(type));
  }

  Future<void> reload(LeaderboardType type) async {
    _cache.remove(type);
    _lastType = type;
    if (!state.hasValue) state = const AsyncLoading();

    final result = await AsyncValue.guard(() => _fetch(type));
    if (result.hasError && state.hasValue) return;

    state = result;
  }
}

enum LeaderboardType { weekly, steps, allTime }

final leaderboardProvider =
    AsyncNotifierProvider<LeaderboardViewModel, List<LeaderboardEntry>>(
      LeaderboardViewModel.new,
    );
