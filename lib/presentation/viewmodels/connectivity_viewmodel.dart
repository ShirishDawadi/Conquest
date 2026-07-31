import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityViewModel extends StreamNotifier<bool> {
  @override
  Stream<bool> build() async* {
    yield await ConnectivityUtils.isOnline();
    yield* ConnectivityUtils.onStatusChange;
  }
}

final connectivityProvider = StreamNotifierProvider<ConnectivityViewModel, bool>(
  ConnectivityViewModel.new,
);