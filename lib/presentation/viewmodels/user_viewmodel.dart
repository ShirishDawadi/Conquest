import 'package:conquest/data/models/user_model.dart';
import 'package:conquest/data/sources/remote/user_remote_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserViewModel extends AsyncNotifier<UserModel> {
  final _source = UserRemoteSource();

  @override
  Future<UserModel> build() async => _source.getMe();
}

final userProvider = AsyncNotifierProvider<UserViewModel, UserModel>(
  UserViewModel.new,
);
