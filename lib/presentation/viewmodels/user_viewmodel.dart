import 'dart:io';
import 'package:conquest/data/models/user_model.dart';
import 'package:conquest/data/sources/remote/user_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserViewModel extends AsyncNotifier<UserModel> {
  final _source = UserRemoteSource();
  bool isSaving = false;

  @override
  Future<UserModel> build() async => _source.getMe();

  Future<String?> updateProfile({
    String? username,
    String? fullName,
    String? profilePhoto,
  }) async {
    isSaving = true;
    ref.notifyListeners();
    
    try {
      final updated = await _source.updateProfile(
        username: username,
        fullName: fullName,
        profilePhoto: profilePhoto,
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
    } finally {
      isSaving = false;
      ref.notifyListeners();
    }
  }

  Future<String?> updateAvatar(File imageFile) async {
    ref.notifyListeners();
    try {
      final updated = await _source.updateAvatar(imageFile);
      state = AsyncData(updated);
      ref.notifyListeners();
      return null;
    } catch (e) {
      ref.notifyListeners();
      final msg = e.toString().toLowerCase();
      if (msg.contains('large')) return 'Image too large, max 5MB';
      if (msg.contains('valid image')) return 'File is not a valid image';
      return 'Failed to upload image';
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
