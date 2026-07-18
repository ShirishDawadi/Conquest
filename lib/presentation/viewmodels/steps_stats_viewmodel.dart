import 'package:conquest/data/models/activity_model.dart';
import 'package:conquest/data/sources/remote/activity_remote_source.dart';
import 'package:conquest/presentation/views/profile/cards/steps_overview/tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _startOfWeek(DateTime date) =>
    date.subtract(Duration(days: date.weekday % 7));

DateTime _endOfWeek(DateTime date) =>
    _startOfWeek(date).add(const Duration(days: 6));

DateTime _startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

DateTime _endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

class StepsStatsLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final stepsStatsLoadingProvider =
    NotifierProvider<StepsStatsLoadingNotifier, bool>(
  StepsStatsLoadingNotifier.new,
);

class StepsStatsViewModel extends AsyncNotifier<StepsStatsResponse> {
  final _source = ActivityRemoteSource();

  StatsPeriod _period = StatsPeriod.weekly;
  int _offset = 0;

  StatsPeriod get period => _period;
  int get offset => _offset;
  bool get canGoNext => _offset < 0;
  ({DateTime start, DateTime end}) get currentRange => _rangeFor(_period, _offset);

  @override
  Future<StepsStatsResponse> build() => _fetch();

  ({DateTime start, DateTime end}) _rangeFor(StatsPeriod period, int offset) {
    final now = DateTime.now();
    if (period == StatsPeriod.weekly) {
      final anchor = now.add(Duration(days: 7 * offset));
      return (start: _startOfWeek(anchor), end: _endOfWeek(anchor));
    } else {
      final anchor = DateTime(now.year, now.month + offset, 1);
      return (start: _startOfMonth(anchor), end: _endOfMonth(anchor));
    }
  }

  Future<StepsStatsResponse> _fetch() {
    final range = _rangeFor(_period, _offset);
    return _source.getStepsStats(startDate: range.start, endDate: range.end);
  }

  Future<void> _reload() async {
    ref.read(stepsStatsLoadingProvider.notifier).set(true);
    final result = await AsyncValue.guard(_fetch);
    ref.read(stepsStatsLoadingProvider.notifier).set(false);

    if (result.hasValue || !state.hasValue) {
      state = result;
    }
  }

  Future<void> load(StatsPeriod period) async {
    _period = period;
    _offset = 0;
    await _reload();
  }

  Future<void> refresh() => _reload();

  Future<void> previous() async {
    _offset -= 1;
    await _reload();
  }

  Future<void> next() async {
    if (!canGoNext) return;
    _offset += 1;
    await _reload();
  }
}

final stepsStatsProvider =
    AsyncNotifierProvider<StepsStatsViewModel, StepsStatsResponse>(
  StepsStatsViewModel.new,
);