import 'package:dio/dio.dart';
import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/utils/error_handler.dart';
import 'package:fastapp/core/exceptions/verify_again_exception.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

class UserRepositoryImpl extends UserRepository {
  final SharedPreferenceHelper _sharedPrefsHelper;
  final UserApi _userApi;

  UserRepositoryImpl(this._sharedPrefsHelper, this._userApi);

  @override
  Future<User?> login(LoginParams params) async {
    try {
      // 响应拦截器已处理响应格式，response 直接是 token 数据或 verify_again 数据
      final response = await _userApi.login(
        type: params.type,
        username: params.username,
        password: params.password,
        mobile: params.mobile,
        email: params.email,
        code: params.code,
        vcode: params.vcode,
        scene: params.scene,
        google2faCode: params.google2faCode,
      );

      // 检查是否需要二次验证
      final verifyAgain = response['verify_again'] as String?;
      if (verifyAgain != null) {
        final email = response['email'] as String?;
        throw VerifyAgainException(verifyAgain, email: email);
      }

      // 保存 token
      await _saveTokens(response, errorMessage: '登录失败：未获取到访问令牌');

      // 登录 API 只返回 token，用户信息需通过 getUserInfo() 获取
      return null;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '登录失败'));
    } catch (e) {
      if (e is VerifyAgainException) rethrow;
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      // 响应拦截器已处理响应格式，response 直接是用户数据
      final response = await _userApi.getUserInfo();
      
      // 响应拦截器已提取 data，直接返回
      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取用户信息失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  @override
  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;

  @override
  Future<void> logout() async {
    try {
      await _userApi.logout();
    } catch (e) {
      // API 调用失败不影响本地清除
    }
    await _clearTokens();
  }

  @override
  Future<void> refreshToken() async {
    final refreshTokenValue = await _sharedPrefsHelper.refreshToken;
    if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
      throw Exception('刷新token失败：未找到refresh_token');
    }
    
    try {
      final response = await _userApi.refreshToken(refreshTokenValue);
      await _saveTokens(response, errorMessage: '刷新token失败：未获取到访问令牌');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '刷新token失败'));
    }
  }

  /// 保存 token 到本地存储
  Future<void> _saveTokens(Map<String, dynamic> response, {required String errorMessage}) async {
    final accessToken = response['access_token'] as String?;
    if (accessToken == null) {
      throw Exception(errorMessage);
    }

    final futures = <Future>[
      _sharedPrefsHelper.saveAuthToken(accessToken),
    ];
    
    final refreshToken = response['refresh_token'] as String?;
    if (refreshToken != null) {
      futures.add(_sharedPrefsHelper.saveRefreshToken(refreshToken));
    }
    
    final expireAt = response['expire_at'] as int?;
    if (expireAt != null) {
      futures.add(_sharedPrefsHelper.saveExpireAt(expireAt));
    }
    
    await Future.wait(futures);
  }

  /// 清除所有 token 和登录状态
  Future<void> _clearTokens() async {
    await _sharedPrefsHelper.clearAllTokens();
    await _sharedPrefsHelper.saveIsLoggedIn(false);
  }

  @override
  Future<Map<String, dynamic>> getGoogle2faQrcode() async {
    try {
      final response = await _userApi.getGoogle2faQrcode();
      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取二维码失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> bindGoogle2fa({required String secret, required String code}) async {
    try {
      await _userApi.bindGoogle2fa(secret: secret, code: code);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '绑定失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> unbindGoogle2fa({required String code}) async {
    try {
      await _userApi.unbindGoogle2fa(code: code);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '解绑失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
