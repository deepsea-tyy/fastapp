import 'dart:async';

import 'package:fastapp/domain/usecase/user/login_usecase.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  Future<Map<String, dynamic>?> getUserInfo();

  /// 获取用户基本信息
  Future<Map<String, dynamic>> getUserBaseInfo({required int userId});

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;

  Future<void> logout();

  Future<void> refreshToken();

  /// 获取Google2FA二维码和密钥
  Future<Map<String, dynamic>> getGoogle2faQrcode();

  /// 绑定Google2FA
  Future<void> bindGoogle2fa({required String secret, required String code});

  /// 解绑Google2FA
  Future<void> unbindGoogle2fa({required String code});
}
