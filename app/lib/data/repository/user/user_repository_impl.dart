import 'package:dio/dio.dart';
import 'package:fastapp/domain/repository/user/user_repository.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/utils/error_handler.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

class UserRepositoryImpl extends UserRepository {
  final SharedPreferenceHelper _sharedPrefsHelper;
  final UserApi _userApi;

  UserRepositoryImpl(this._sharedPrefsHelper, this._userApi);

  @override
  Future<User?> login(LoginParams params) async {
    try {
      // 响应拦截器已处理响应格式，response 直接是 token 数据
      final response = await _userApi.login(
        type: params.type,
        username: params.username,
        password: params.password,
        mobile: params.mobile,
        code: params.code,
        scene: params.scene,
      );

      // 提取并保存 token
      final accessToken = response['access_token'] as String?;
      final refreshToken = response['refresh_token'] as String?;
      final expireAt = response['expire_at'] as int?;

      if (accessToken == null) {
        throw Exception('登录失败：未获取到访问令牌');
      }

      await _sharedPrefsHelper.saveAuthToken(accessToken);
      if (refreshToken != null) {
        await _sharedPrefsHelper.saveRefreshToken(refreshToken);
      }
      if (expireAt != null) {
        await _sharedPrefsHelper.saveExpireAt(expireAt);
      }

      // 登录 API 只返回 token，用户信息需通过 getUserInfo() 获取
      return null;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '登录失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      // 响应拦截器已处理响应格式，response 直接是用户数据
      final response = await _userApi.getUserInfo();
      
      // 如果响应是 Map，直接返回（响应拦截器已提取 data）
      if (response is Map<String, dynamic>) {
        return response;
      }
      
      throw Exception('获取用户信息失败：响应格式错误');
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
}
