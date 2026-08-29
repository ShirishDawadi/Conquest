import 'package:conquest/core/database/app_database.dart';
import 'package:conquest/data/sources/remote/auth_remote_source.dart';
import 'package:conquest/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/quest_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/step_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/steps_stats_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/summary_viewmodel.dart';
import 'package:conquest/presentation/viewmodels/user_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthViewModel extends AsyncNotifier<bool> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<bool> build() async => false;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = await AuthRemoteSource().login(email, password);
      await _storage.write(key: 'access_token', value: auth.accessToken);
      await _storage.write(key: 'refresh_token', value: auth.refreshToken);
      return true;
    });
  }

  Future<void> register(String username, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await AuthRemoteSource().register(username, email, password);
      final auth = await AuthRemoteSource().login(email, password);
      await _storage.write(key: 'access_token', value: auth.accessToken);
      await _storage.write(key: 'refresh_token', value: auth.refreshToken);
      return true;
    });
  }

  Future<void> logout() async {
  await _storage.deleteAll();
  ref.invalidate(stepProvider);
  ref.invalidate(questProvider);
  ref.invalidate(userProvider);
  ref.invalidate(leaderboardProvider);
  ref.invalidate(stepsStatsProvider);
  ref.invalidate(daySummaryProvider);
  await AppDatabase().deleteDb();
  if (ref.mounted) {
    state = const AsyncData(false);
  }
}
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, bool>(
  AuthViewModel.new,
);
