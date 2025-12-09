import 'dart:async';

import 'package:fastapp/domain/usecase/user/login_usecase.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  Future<Map<String, dynamic>?> getUserInfo();

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;
}
