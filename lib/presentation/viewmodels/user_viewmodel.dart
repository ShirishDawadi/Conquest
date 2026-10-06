import 'dart:io';
import 'package:conquest/core/utils/connectivity_utils.dart';
import 'package:conquest/data/models/user_model.dart';
import 'package:conquest/data/sources/local/user_local_source.dart';
import 'package:conquest/data/sources/remote/user_remote_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileError {
  final String message;
  final bool isFieldError;
  const ProfileError(this.message, {this.isFieldError = false});
}

class UserViewModel extends AsyncNotifier<UserModel> {
  final _source = UserRemoteSource();
  final _local = UserLocalSource();
  bool isSaving = false;

  @override
  Future<UserModel> build() async {
    final cached = await _local.getUser();

    if (cached != null) {
      _refreshFromServer();
      return cached;
    }

    final fresh = await _source.getMe();
    await _local.saveUser(fresh);
    return fresh;
  }

  Future<void> _refreshFromServer() async {
    try {
      final fresh = await _source.getMe();
      await _local.saveUser(fresh);
      state = AsyncData(fresh);
    } catch (_) {}
  }

  Future<bool> _isOffline(Object e) async {
    if (e is DioException && e.type == DioExceptionType.connectionError) {
      return true;
    }
    return !await ConnectivityUtils.isOnline();
  }

  Future<ProfileError?> updateProfile({
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

      await _local.saveUser(updated);
      state = AsyncData(updated);
      return null;
    } catch (e) {
      if (await _isOffline(e)) {
        return const ProfileError('No internet connection');
      }

      final msg = e.toString().toLowerCase();

      if (msg.contains('spaces')) {
        return const ProfileError(
          'Username cannot contain spaces',
          isFieldError: true,
        );
      }
      if (msg.contains('3 characters')) {
        return const ProfileError(
          'Username must be at least 3 characters',
          isFieldError: true,
        );
      }
      if (msg.contains('already taken')) {
        return const ProfileError('Username already taken', isFieldError: true);
      }

      return const ProfileError('Something went wrong');
    } finally {
      isSaving = false;
      ref.notifyListeners();
    }
  }

  Future<String?> updateAvatar(File imageFile) async {
    ref.notifyListeners();
    try {
      final updated = await _source.updateAvatar(imageFile);
      await _local.saveUser(updated);
      state = AsyncData(updated);
      ref.notifyListeners();
      return null;
    } catch (e) {
      ref.notifyListeners();
      if (await _isOffline(e)) return 'No internet connection';

      final msg = e.toString().toLowerCase();
      if (msg.contains('large')) return 'Image too large, max 5MB';
      if (msg.contains('valid image')) return 'File is not a valid image';
      return 'Failed to upload image';
    }
  }

  Future<void> reload() async {
    final fresh = await _source.getMe();
    await _local.saveUser(fresh);
    state = AsyncData(fresh);
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
