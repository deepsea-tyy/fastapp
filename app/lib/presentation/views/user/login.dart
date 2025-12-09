import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:fastapp/core/widgets/empty_app_bar_widget.dart';
import 'package:fastapp/data/sharedpref/constants/preferences.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
import 'package:fastapp/utils/device/device_utils.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:fastapp/di/service_locator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // Constants
  static const double _horizontalPadding = 24.0;
  static const double _buttonHeight = 48.0;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  late final TabController _tabController;
  
  // Login mode: true = password, false = code
  bool _isPasswordMode = true;

  // Stores
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();
  final PageContentManager _pageContent = getIt<PageContentManager>();

  // Country code
  String _selectedCountryCode = '+86';
  String _selectedCountryFlag = '🇨🇳';
  
  // 验证码倒计时
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // 确保页面内容管理器已初始化
    _pageContent.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(text: _pageContent.getText('login.tab.phone', defaultValue: '手机号')),
          Tab(text: _pageContent.getText('login.tab.email', defaultValue: '邮箱')),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        _buildPhoneLoginFields(),
        _buildEmailLoginFields(),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4.0),
                    Text(
                      _pageContent.getText('login.title', defaultValue: '登录'),
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _buildTabBar(),
                    const SizedBox(height: 16.0),
                    if (_tabController.index == 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordMode = !_isPasswordMode;
                                _passwordController.clear();
                                _codeController.clear();
                              });
                            },
                            child: Text(
                              _isPasswordMode 
                                ? _pageContent.getText('login.switch.code', defaultValue: '使用验证码登录')
                                : _pageContent.getText('login.switch.password', defaultValue: '使用密码登录'),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    _buildInputField(),
                    const SizedBox(height: 24.0),
                    _buildContinueButton(),
                    const SizedBox(height: 16.0),
                    _buildRegisterButton(),
                    const SizedBox(height: 32.0),
                    _buildDivider(),
                    const SizedBox(height: 32.0),
                    _buildGoogleLoginButton(),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        Observer(
          builder: (context) {
            return _userStore.success
                ? navigate(context)
                : _showErrorMessage(_formStore.errorStore.errorMessage);
          },
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required TextEditingController controller,
  }) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.only(
        left: 12.0,
        right: controller.text.isNotEmpty ? 0.0 : 12.0,
        top: 16.0,
        bottom: 16.0,
      ),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close, size: 20.0),
              onPressed: () {
                setState(() {
                  controller.clear();
                });
              },
            )
          : null,
    );
  }

  Widget _buildPhoneLoginFields() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.only(right: 4.0),
          child: Row(
            children: [
              CountrySelector(
                selectedCode: _selectedCountryCode,
                selectedFlag: _selectedCountryFlag,
                onChanged: (code, flag) {
                  setState(() {
                    _selectedCountryCode = code;
                    _selectedCountryFlag = flag;
                  });
                },
              ),
              Container(width: 1.0, height: 24.0, color: Colors.grey[300]),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _buildInputDecoration(
                    hintText: _pageContent.getText('login.input.phone.placeholder'),
                    controller: _phoneController,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        if (_isPasswordMode)
          _buildPasswordField()
        else
          _buildCodeField(),
      ],
    );
  }

  Widget _buildEmailLoginFields() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.only(right: 4.0),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              hintText: _pageContent.getText('login.input.email.placeholder', defaultValue: '请输入邮箱地址'),
              controller: _emailController,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16.0),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(right: 4.0),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: _buildInputDecoration(
          hintText: _pageContent.getText('login.input.password.placeholder', defaultValue: '请输入密码'),
          controller: _passwordController,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildCodeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(right: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _buildInputDecoration(
                hintText: _pageContent.getText('login.input.code.placeholder', defaultValue: '请输入验证码'),
                controller: _codeController,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          TextButton(
            onPressed: _countdown > 0 ? null : _sendVerificationCode,
            child: Text(
              _countdown > 0 
                ? _pageContent.getText('login.button.retry_code', defaultValue: '{count}秒后重试', params: {'count': _countdown.toString()})
                : _pageContent.getText('login.button.get_code', defaultValue: '获取验证码'),
              style: TextStyle(
                color: _countdown > 0 ? Colors.grey : Colors.orange,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    final isPhoneLogin = _tabController.index == 0;

    if (isPhoneLogin) {
      // 手机号登录
      if (_phoneController.text.isEmpty) {
        _showErrorMessage(_pageContent.getText('login.error.phone_required', defaultValue: '请输入手机号码'));
        return;
      }

      if (_isPasswordMode) {
        // 手机号密码登录
        if (_passwordController.text.isEmpty) {
          _showErrorMessage(_pageContent.getText('login.error.password_required', defaultValue: '请输入密码'));
          return;
        }
        DeviceUtils.hideKeyboard(context);
        final mobile = '$_selectedCountryCode${_phoneController.text}';
        _userStore.login(
          type: 1,
          username: mobile,
          password: _passwordController.text,
        );
      } else {
        // 手机号验证码登录
        if (_codeController.text.isEmpty) {
          _showErrorMessage(_pageContent.getText('login.error.code_required', defaultValue: '请输入验证码'));
          return;
        }
        DeviceUtils.hideKeyboard(context);
        final mobile = '$_selectedCountryCode${_phoneController.text}';
        _userStore.login(
          type: 2,
          mobile: mobile,
          code: _codeController.text,
          scene: 'login',
        );
      }
    } else {
      // 邮箱登录（只能使用密码）
      if (_emailController.text.isEmpty) {
        _showErrorMessage(_pageContent.getText('login.error.email_required', defaultValue: '请输入邮箱地址'));
        return;
      }
      if (_passwordController.text.isEmpty) {
        _showErrorMessage(_pageContent.getText('login.error.password_required', defaultValue: '请输入密码'));
        return;
      }
      DeviceUtils.hideKeyboard(context);
      _userStore.login(
        type: 1,
        username: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  Widget _buildContinueButton() {
    return Observer(
      builder: (context) {
        final isLoading = _userStore.isLoading;
        return SizedBox(
          height: _buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.amber.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(
                    _pageContent.getText('login.button.continue', defaultValue: '继续'),
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.forgotPassword);
          },
          child: Text(
            _pageContent.getText('login.link.forgot_password', defaultValue: '忘记密码'),
            style: const TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.register);
          },
          child: Text(
            _pageContent.getText('login.link.register', defaultValue: '立即注册'),
            style: const TextStyle(color: Colors.orange, fontSize: 14.0),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1.0)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _pageContent.getText('login.divider.or', defaultValue: '或'),
            style: const TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey, thickness: 1.0)),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: 处理Google登录
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/google.png',
              width: 24.0,
              height: 24.0,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata,
                size: 24.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              _pageContent.getText('login.button.google', defaultValue: '通过 Google 继续'),
              style: const TextStyle(color: Colors.black87, fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (Route<dynamic> route) => false,
      );
    });
    return const SizedBox.shrink();
  }

  Widget _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessageService.error(message);
      });
    }
    return const SizedBox.shrink();
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.phone_required', defaultValue: '请输入手机号码'));
      return;
    }

    try {
      final mobile = '$_selectedCountryCode${_phoneController.text}';
      final response = await _userApi.sendSms(
        mobile: mobile,
        scene: 'login',
      );

      if (response['code'] == 200) {
        _showErrorMessage(response['message'] ?? _pageContent.getText('login.error.code_send_success', defaultValue: '验证码发送成功'));
        // 开始倒计时
        _startCountdown();
      } else {
        _showErrorMessage(response['message'] ?? _pageContent.getText('login.error.code_send_failed', defaultValue: '验证码发送失败'));
      }
    } catch (e) {
      String errorMessage = _pageContent.getText('login.error.code_send_failed', defaultValue: '验证码发送失败');
      if (e.toString().contains('message')) {
        // 尝试提取错误消息
        errorMessage = e.toString();
      }
      _showErrorMessage(errorMessage);
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    _countdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
