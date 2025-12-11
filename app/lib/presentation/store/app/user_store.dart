import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:fastapp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:fastapp/domain/usecase/user/get_user_info_usecase.dart';
import 'package:fastapp/domain/usecase/user/logout_usecase.dart';
import 'package:fastapp/domain/usecase/user/refresh_token_usecase.dart';
import 'package:fastapp/core/exceptions/verify_again_exception.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:mobx/mobx.dart';

import 'package:fastapp/domain/entity/user/user.dart';
import 'package:fastapp/domain/usecase/user/login_usecase.dart';

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  // constructor:---------------------------------------------------------------
  _UserStore(
    this._isLoggedInUseCase,
    this._saveLoginStatusUseCase,
    this._loginUseCase,
    this._getUserInfoUseCase,
    this._logoutUseCase,
    this._refreshTokenUseCase,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    _isLoggedInUseCase.call(params: null).then((value) async {
      setIsLoggedIn(value);
      if (value) await getUserInfo();
    });
  }

  // use cases:-----------------------------------------------------------------
  final IsLoggedInUseCase _isLoggedInUseCase;
  final SaveLoginStatusUseCase _saveLoginStatusUseCase;
  final LoginUseCase _loginUseCase;
  final GetUserInfoUseCase _getUserInfoUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  // stores:--------------------------------------------------------------------
  // for handling form errors
  final FormErrorStore formErrorStore;

  // store for handling error messages
  final ErrorStore errorStore;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<User?> emptyLoginResponse =
      ObservableFuture.value(null);
  static ObservableFuture<User?> emptyUserInfoResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  @observable
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  User? currentUser;

  @observable
  ObservableFuture<User?> loginFuture = emptyLoginResponse;

  @observable
  ObservableFuture<User?> userInfoFuture = emptyUserInfoResponse;

  @observable
  String? verifyAgainType; // 'google2fa_code'、'email_code' 或 'mobile_code'
  
  @observable
  String? verifyAgainEmail; // 邮箱地址（部分隐藏，仅用于显示）
  
  @observable
  String? verifyAgainMobile; // 手机号（部分隐藏，仅用于显示）
  
  @observable
  String? verifyAgainCode; // 手机区号（如 "86"）
  
  @observable
  String? verifyAgainDeviceId; // 设备唯一标识

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  @computed
  bool get isUserInfoLoading => userInfoFuture.status == FutureStatus.pending;

  @computed
  bool get needsVerifyAgain => verifyAgainType != null;

  @action
  Future login({
    required int type,
    String? username,
    String? password,
    String? mobile,
    String? email,
    String? code,
    String? vcode,
    String? scene,
    int? google2faCode,
    String? deviceId,
  }) async {
    final loginParams = LoginParams(
      type: type,
      username: username,
      password: password,
      mobile: mobile,
      email: email,
      code: code,
      vcode: vcode,
      scene: scene,
      google2faCode: google2faCode,
      deviceId: deviceId,
    );
    
    final future = _loginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    try {
      await future;
      // 登录成功（无异常），使用统一方法处理状态同步
      await handleLoginSuccess();
    } on VerifyAgainException catch (e) {
      // 需要二次验证
      verifyAgainType = e.verifyType;
      verifyAgainEmail = e.email;
      verifyAgainMobile = e.mobile;
      verifyAgainCode = e.code;
      verifyAgainDeviceId = e.deviceId;
      isLoggedIn = false;
      success = false;
      // 不设置错误消息，让UI显示二次验证输入框
    } catch (e) {
      isLoggedIn = false;
      success = false;
      // 如果已经在二次验证状态，保持状态不变，不切换回密码输入框
      // 不清除 verifyAgainType，让它保持原值
      errorStore.setErrorMessage(e.toString());
      rethrow;
    }
  }

  @action
  void clearVerifyAgain() {
    _clearVerifyAgainState();
  }

  @action
  void setIsLoggedIn(bool value) {
    isLoggedIn = value;
  }

  /// 处理登录/注册成功后的状态同步（统一方法）
  @action
  Future<void> handleLoginSuccess() async {
    await _saveLoginStatusUseCase.call(params: true);
    isLoggedIn = true;
    success = true;
    _clearVerifyAgainState();
    await getUserInfo();
  }

  /// 清除二次验证状态（内部方法）
  void _clearVerifyAgainState() {
    verifyAgainType = null;
    verifyAgainEmail = null;
    verifyAgainMobile = null;
    verifyAgainCode = null;
    verifyAgainDeviceId = null;
  }

  @action
  Future getUserInfo() async {
    // 如果已经有正在进行的请求，直接返回该请求的结果，避免重复请求
    if (userInfoFuture.status == FutureStatus.pending) {
      try {
        return await userInfoFuture;
      } catch (e) {
        // 如果之前的请求失败，继续发起新请求
      }
    }

    final future = _getUserInfoUseCase.call(params: null);
    userInfoFuture = ObservableFuture(future);

    try {
      final user = await future;
      currentUser = user;
      return user;
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
      rethrow;
    }
  }

  @action
  Future<void> logout() async {
    try {
      await _logoutUseCase.call(params: null);
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
      // API 调用失败不影响本地状态清除
    } finally {
      // 无论 API 调用成功与否，都清除本地状态
      _clearUserState();
      await _saveLoginStatusUseCase.call(params: false);
    }
  }

  /// 清除所有用户缓存数据（包括设备ID等）
  @action
  Future<void> clearAllUserCache() async {
    // 先执行 logout 清除 token 和登录状态
    await logout();
    
    // 清除设备ID
    try {
      await _clearDeviceId();
    } catch (e) {
      // 清除设备ID失败不影响其他操作
      if (kDebugMode) {
        print('清除设备ID失败: $e');
      }
    }
  }

  /// 清除设备ID
  Future<void> _clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_id');
    } catch (e) {
      // 忽略错误
    }
  }

  /// 清除用户状态
  void _clearUserState() {
    isLoggedIn = false;
    currentUser = null;
    _clearVerifyAgainState();
  }

  @action
  Future<void> refreshToken() async {
    try {
      await _refreshTokenUseCase.call(params: null);
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
      rethrow;
    }
  }

  /// 更新昵称
  @action
  Future<void> updateNickname(String nickname) async {
    try {
      final userApi = getIt<UserApi>();
      await userApi.updateProfile(nickname: nickname);
      // 更新成功后立即刷新用户信息，确保界面同步
      await getUserInfo();
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
      rethrow;
    }
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
