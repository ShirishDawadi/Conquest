import 'package:conquest/data/models/user_model.dart';
import 'package:conquest/data/sources/remote/user_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserViewModel extends AsyncNotifier<UserModel> {
  final _source = UserRemoteSource();

  @override
  Future<UserModel> build() async => _source.getMe();

  Future<String?> updateProfile({String? username, String? fullName}) async {
    try {
      final updated = await _source.updateProfile(
        username: username,
        fullName: fullName,
      );
      state = AsyncData(updated);
      return null;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('spaces')) return 'Username cannot contain spaces';
      if (msg.contains('3 characters')) {
        return 'Username must be at least 3 characters';
      }
      if (msg.contains('already taken')) return 'Username already taken';
      return 'Something went wrong';
    }
  }

  void refresh() => ref.invalidateSelf();
}

final userProvider = AsyncNotifierProvider<UserViewModel, UserModel>(
  UserViewModel.new,
);

final otherUserProvider = FutureProvider.autoDispose.family<UserModel, int>((
  ref,
  userId,
) {
  return UserRemoteSource().getUserById(userId);
});
