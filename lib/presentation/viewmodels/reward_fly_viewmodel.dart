import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RewardFlyKeys {
  static final xp = GlobalKey(debugLabel: 'xpTarget');
  static final points = GlobalKey(debugLabel: 'pointsTarget');
  static final pending = GlobalKey(debugLabel: 'pendingTarget');
  static final stepsQuest = GlobalKey(debugLabel: 'stepsQuest');
  static final distance = GlobalKey(debugLabel: 'distance');
  static final _objects = <int, GlobalKey>{};

  static GlobalKey object(int id) =>
      _objects.putIfAbsent(id, () => GlobalKey());

  static GlobalKey? objectOrNull(int? id) => id == null ? null : _objects[id];
}

class RewardFlyEvent {
  final int xp;
  final int points;
  final GlobalKey? source;
  final bool offline;
  const RewardFlyEvent(this.xp, this.points, this.source, this.offline);
}

class RewardFlyState {
  final List<RewardFlyEvent> queue;
  final int heldXp;
  final int heldPoints;
  const RewardFlyState({
    this.queue = const [],
    this.heldXp = 0,
    this.heldPoints = 0,
  });
}

class RewardFlyViewModel extends Notifier<RewardFlyState> {
  @override
  RewardFlyState build() => const RewardFlyState();

  void push(int xp, int points, GlobalKey? source, {required bool offline}) {
    state = RewardFlyState(
      queue: [...state.queue, RewardFlyEvent(xp, points, source, offline)],
      heldXp: state.heldXp + (offline ? 0 : xp),
      heldPoints: state.heldPoints + (offline ? 0 : points),
    );
  }

  void release(int xp, int points) {
    state = RewardFlyState(
      queue: state.queue,
      heldXp: math.max(0, state.heldXp - xp),
      heldPoints: math.max(0, state.heldPoints - points),
    );
  }

  void done() {
    if (state.queue.isEmpty) return;
    state = RewardFlyState(
      queue: state.queue.sublist(1),
      heldXp: state.heldXp,
      heldPoints: state.heldPoints,
    );
  }
}

final rewardFlyProvider = NotifierProvider<RewardFlyViewModel, RewardFlyState>(
  RewardFlyViewModel.new,
);
