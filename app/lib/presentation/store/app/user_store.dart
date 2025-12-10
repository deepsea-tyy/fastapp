import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:fastapp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:fastapp/domain/usecase/user/get_user_info_usecase.dart';
import 'package:fastapp/domain/usecase/user/logout_usecase.dart';
import 'package:fastapp/domain/usecase/user/refresh_token_usecase.dart';
import 'package:fastapp/core/exceptions/verify_again_exception.dart';
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
      _setIsLoggedIn(value);
      if (value) {
        // 如果已登录，自动获取用户信息
        await getUserInfo();
      }
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
  String? verifyAgainType; // 'google2fa_code' 或 'email_code'
  
  @observable
  String? verifyAgainEmail; // 邮箱地址（部分隐藏，仅用于显示）

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
    );
    
    final future = _loginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    try {
      await future;
      // 登录成功（无异常），保存状态并获取用户信息
      await _saveLoginStatusUseCase.call(params: true);
      isLoggedIn = true;
      success = true;
      verifyAgainType = null; // 清除二次验证状态
      await getUserInfo();
    } on VerifyAgainException catch (e) {
      // 需要二次验证
      verifyAgainType = e.verifyType;
      verifyAgainEmail = e.email;
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
    verifyAgainType = null;
    verifyAgainEmail = null;
  }

  @action
  void _setIsLoggedIn(bool value) {
    isLoggedIn = value;
  }

  @action
  Future getUserInfo() async {
    final future = _getUserInfoUseCase.call(params: null);
    userInfoFuture = ObservableFuture(future);

    try {
      final user = await future;
      currentUser = user;
    } catch (e) {
      errorStore.setErrorMessage(e.toString());
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

  /// 清除用户状态
  void _clearUserState() {
    isLoggedIn = false;
    currentUser = null;
    verifyAgainType = null;
    verifyAgainEmail = null;
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

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
