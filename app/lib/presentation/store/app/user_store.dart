import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:fastapp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:fastapp/domain/usecase/user/get_user_info_usecase.dart';
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

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  @computed
  bool get isUserInfoLoading => userInfoFuture.status == FutureStatus.pending;

  @action
  Future login({
    required int type,
    String? username,
    String? password,
    String? mobile,
    String? code,
    String? scene,
  }) async {
    final loginParams = LoginParams(
      type: type,
      username: username,
      password: password,
      mobile: mobile,
      code: code,
      scene: scene,
    );
    
    final future = _loginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    try {
      await future;
      // 登录成功（无异常），保存状态并获取用户信息
      await _saveLoginStatusUseCase.call(params: true);
      isLoggedIn = true;
      success = true;
      await getUserInfo();
    } catch (e) {
      isLoggedIn = false;
      success = false;
      errorStore.setErrorMessage(e.toString());
      rethrow;
    }
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
  logout() async {
    isLoggedIn = false;
    currentUser = null;
    await _saveLoginStatusUseCase.call(params: false);
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
