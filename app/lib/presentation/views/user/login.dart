import 'dart:async';
import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:fastapp/data/sharedpref/constants/preferences.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
import 'package:fastapp/utils/device/device_utils.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // 常量
  static const double _horizontalPadding = 24.0;
  static const double _buttonHeight = 48.0;
  static const double _inputHeight = 56.0;
  static const int _countdownSeconds = 60;
  static const double _fieldSpacing = 16.0;
  static const String _defaultCountryCode = '+86';
  static const String _defaultCountryFlag = '🇨🇳';
  
  // 样式常量
  static const TextStyle _titleTextStyle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle _buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _linkTextStyle = TextStyle(
    fontSize: 14.0,
  );

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _google2faController = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  late final TabController _tabController;

  // Stores
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();
  final PageContentManager _pageContent = getIt<PageContentManager>();

  // State
  String _selectedCountryCode = _defaultCountryCode;
  String _selectedCountryFlag = _defaultCountryFlag;
  int _emailCodeCountdown = 0;
  Timer? _emailCodeCountdownTimer;
  int _previousTabIndex = 0;
  
  // 保存首次登录参数用于二次验证
  Map<String, dynamic>? _firstLoginParams;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _previousTabIndex = _tabController.index;
    _tabController.addListener(_onTabChanged);
    _pageContent.initialize();
    _clearInputFields(clearVerifyAgain: true);
  }

  /// Tab 切换监听器
  void _onTabChanged() {
    if (_tabController.index != _previousTabIndex) {
      _previousTabIndex = _tabController.index;
      _clearInputFields(clearVerifyAgain: true);
    }
    setState(() {});
  }

  /// 清除输入框内容
  void _clearInputFields({bool clearVerifyAgain = false}) {
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _google2faController.clear();
    _emailCodeController.clear();
    _selectedCountryCode = _defaultCountryCode;
    _selectedCountryFlag = _defaultCountryFlag;
    _emailCodeCountdown = 0;
    _emailCodeCountdownTimer?.cancel();
    
    if (clearVerifyAgain) {
      _firstLoginParams = null;
      _userStore.clearVerifyAgain();
    }
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
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return TabBar(
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
              _buildTab(
                text: _pageContent.getText('login.tab.phone', defaultValue: '手机号'),
                isSelected: _tabController.index == 0,
              ),
              _buildTab(
                text: _pageContent.getText('login.tab.email', defaultValue: '邮箱'),
                isSelected: _tabController.index == 1,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab({required String text, required bool isSelected}) {
    return Tab(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          border: isSelected ? null : Border.all(color: Colors.black54, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Text(text),
      ),
    );
  }

  Widget _buildInputField() {
    return Observer(
      builder: (_) {
        const inputAreaHeight = _inputHeight + _fieldSpacing + _inputHeight;
        
        if (_userStore.success) {
          return SizedBox(height: inputAreaHeight);
        }
        
        if (_userStore.needsVerifyAgain) {
          return SizedBox(
            height: inputAreaHeight,
            child: Center(child: _buildSecondVerificationField()),
          );
        }
        
        return IndexedStack(
          index: _tabController.index,
          children: [_buildPhoneLoginFields(), _buildEmailLoginFields()],
        );
      },
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
                child: Row(
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Text(
                        _pageContent.getText('login.title', defaultValue: '登录'),
                        style: _titleTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 占位，保持标题居中
                    const SizedBox(width: 48.0),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4.0),
                    _buildTabBar(),
                    const SizedBox(height: _fieldSpacing),
                    _buildInputField(),
                    const SizedBox(height: 24.0),
                    _buildContinueButton(),
                    const SizedBox(height: _fieldSpacing),
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
        _buildLoginStatusObserver(),
      ],
    );
  }

  /// 构建通用输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintKey,
    String? defaultValue,
    TextInputType? keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefix,
  }) {
    return _buildInputContainer(
      SizedBox(
        height: _inputHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (prefix != null) prefix,
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                inputFormatters: inputFormatters,
                style: const TextStyle(height: 1.5),
                decoration: InputDecoration(
                  hintText: _pageContent.getText(hintKey, defaultValue: defaultValue),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20.0),
                          onPressed: () => setState(() => controller.clear()),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建输入框容器
  Widget _buildInputContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(right: 4.0),
      constraints: const BoxConstraints(minHeight: _inputHeight),
      child: child,
    );
  }

  /// 构建二次验证输入框
  Widget _buildSecondVerificationField() {
    return Observer(
      builder: (_) {
        final verifyType = _userStore.verifyAgainType;
        if (verifyType == null) return const SizedBox.shrink();
        
        return verifyType == 'google2fa_code'
            ? _buildGoogle2faField()
            : _buildEmailCodeField();
      },
    );
  }

  Widget _buildLoginStatusObserver() {
    return Observer(
      builder: (_) => _userStore.success ? _navigateToHome() : const SizedBox.shrink(),
    );
  }

  /// 构建邮箱验证码按钮内容（在 Observer 内部调用）
  Widget _buildEmailCodeButtonContent() {
    final isDisabled = _emailCodeCountdown > 0;
    return TextButton(
      onPressed: isDisabled ? null : _sendEmailVerificationCode,
      child: Text(
        isDisabled
            ? _pageContent.getText('login.button.retry_code', defaultValue: '{count}秒后重试', params: {'count': _emailCodeCountdown.toString()})
            : _pageContent.getText('login.button.get_email_code', defaultValue: '获取邮箱验证码'),
        style: _linkTextStyle.copyWith(
          color: isDisabled ? Colors.grey : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildPhoneLoginFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _phoneController,
          hintKey: 'login.input.phone.placeholder',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefix: _buildCountrySelector(),
        ),
        const SizedBox(height: _fieldSpacing),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildEmailLoginFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          hintKey: 'login.input.email.placeholder',
          defaultValue: '请输入邮箱地址',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: _fieldSpacing),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      hintKey: 'login.input.password.placeholder',
      defaultValue: '请输入密码',
      obscureText: true,
    );
  }

  Widget _buildCountrySelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _inputHeight,
          child: CountrySelector(
            selectedCode: _selectedCountryCode,
            selectedFlag: _selectedCountryFlag,
            onChanged: (code, flag) {
              setState(() {
                _selectedCountryCode = code;
                _selectedCountryFlag = flag;
              });
            },
          ),
        ),
        Container(
          width: 1.0,
          height: 24.0,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ],
    );
  }

  Widget _buildGoogle2faField() {
    return _buildTextField(
      controller: _google2faController,
      hintKey: 'login.input.google2fa.placeholder',
      defaultValue: '请输入Google验证码（6位）',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
    );
  }

  Widget _buildEmailCodeField() {
    return _buildInputContainer(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildTextField(
              controller: _emailCodeController,
              hintKey: 'login.input.email_code.placeholder',
              defaultValue: '请输入邮箱验证码',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          _buildEmailCodeButtonContent(),
        ],
      ),
    );
  }

  /// 获取当前邮箱地址
  String? _getEmail() {
    if (_tabController.index == 1 && _emailController.text.isNotEmpty) {
      return _emailController.text;
    }
    return _firstLoginParams?['email'] as String?;
  }

  /// 验证输入
  String? _validateInput() {
    final isPhoneLogin = _tabController.index == 0;
    
    if (isPhoneLogin && _phoneController.text.isEmpty) {
      return _pageContent.getText('login.error.phone_required', defaultValue: '请输入手机号码');
    }
    if (!isPhoneLogin && _emailController.text.isEmpty) {
      return _pageContent.getText('login.error.email_required', defaultValue: '请输入邮箱地址');
    }
    if (_passwordController.text.isEmpty) {
      return _pageContent.getText('login.error.password_required', defaultValue: '请输入密码');
    }
    return null;
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    DeviceUtils.hideKeyboard(context);

    if (_userStore.needsVerifyAgain) {
      await _handleSecondVerification();
      return;
    }

    final error = _validateInput();
    if (error != null) {
      _showErrorMessage(error);
      return;
    }

    final isPhoneLogin = _tabController.index == 0;
    _firstLoginParams = {
      'type': 1,
      'password': _passwordController.text,
      if (isPhoneLogin) 'mobile': _phoneController.text,
      if (isPhoneLogin) 'code': _selectedCountryCode.replaceFirst('+', ''),
      if (!isPhoneLogin) 'email': _emailController.text,
    };

    await _userStore.login(
      type: 1,
      password: _firstLoginParams!['password'] as String,
      mobile: _firstLoginParams!['mobile'] as String?,
      code: _firstLoginParams!['code'] as String?,
      email: _firstLoginParams!['email'] as String?,
    );
  }

  /// 处理二次验证
  Future<void> _handleSecondVerification() async {
    final verifyType = _userStore.verifyAgainType;
    if (verifyType == null) return;

    if (verifyType == 'google2fa_code') {
      await _handleGoogle2faVerification();
    } else if (verifyType == 'email_code') {
      await _handleEmailCodeVerification();
    }
  }

  Future<void> _handleGoogle2faVerification() async {
    if (_google2faController.text.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.google2fa_required', defaultValue: '请输入Google验证码'));
      return;
    }
    
    final google2faCode = int.tryParse(_google2faController.text);
    if (google2faCode == null) {
      _showErrorMessage(_pageContent.getText('login.error.google2fa_invalid', defaultValue: 'Google验证码格式错误'));
      return;
    }
    
    await _userStore.login(
      type: _firstLoginParams!['type'] as int,
      password: _firstLoginParams!['password'] as String,
      mobile: _firstLoginParams!['mobile'] as String?,
      code: _firstLoginParams!['code'] as String?,
      email: _firstLoginParams!['email'] as String?,
      google2faCode: google2faCode,
    );
  }

  Future<void> _handleEmailCodeVerification() async {
    if (_emailCodeController.text.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.email_code_required', defaultValue: '请输入邮箱验证码'));
      return;
    }
    
    final email = _getEmail();
    if (email == null || email.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.email_not_found', defaultValue: '无法获取邮箱地址'));
      return;
    }
    
    await _userStore.login(
      type: 1,
      email: email,
      password: _firstLoginParams!['password'] as String,
      vcode: _emailCodeController.text,
      scene: 'login',
    );
  }

  Widget _buildContinueButton() {
    return Observer(
      builder: (_) {
        final isLoading = _userStore.isLoading;
        final isVerifyAgain = _userStore.needsVerifyAgain;
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
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(
                    isVerifyAgain
                        ? _pageContent.getText('login.button.confirm', defaultValue: '确认')
                        : _pageContent.getText('login.button.continue', defaultValue: '继续'),
                    style: _buttonTextStyle,
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
          onPressed: () => Navigator.of(context).pushNamed(Routes.forgotPassword),
          child: Text(
            _pageContent.getText('login.link.forgot_password', defaultValue: '忘记密码'),
            style: _linkTextStyle.copyWith(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.register),
          child: Text(
            _pageContent.getText('login.link.register', defaultValue: '立即注册'),
            style: _linkTextStyle.copyWith(color: Colors.orange),
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
            style: _linkTextStyle.copyWith(color: Colors.grey),
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
              style: _linkTextStyle.copyWith(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigateToHome() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home,
          (Route<dynamic> route) => false,
        );
      }
    });
    return const SizedBox.shrink();
  }

  void _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      MessageService.error(message);
    }
  }

  /// 发送邮箱验证码
  Future<void> _sendEmailVerificationCode() async {
    final email = _getEmail();
    if (email == null || email.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.email_not_found', defaultValue: '无法获取邮箱地址'));
      return;
    }

    try {
      final response = await _userApi.sendEmailCode(email: email, scene: 'login');
      if (response['code'] == 200) {
        MessageService.success(response['message'] ?? _pageContent.getText('login.error.email_code_send_success', defaultValue: '邮箱验证码发送成功'));
        _startEmailCodeCountdown();
      } else {
        _showErrorMessage(response['message'] ?? _pageContent.getText('login.error.email_code_send_failed', defaultValue: '邮箱验证码发送失败'));
      }
    } catch (e) {
      _showErrorMessage(_pageContent.getText('login.error.email_code_send_failed', defaultValue: '邮箱验证码发送失败'));
    }
  }

  /// 开始邮箱验证码倒计时
  void _startEmailCodeCountdown() {
    _emailCodeCountdown = _countdownSeconds;
    _emailCodeCountdownTimer?.cancel();
    _emailCodeCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_emailCodeCountdown > 0) {
          _emailCodeCountdown--;
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
    _google2faController.dispose();
    _emailCodeController.dispose();
    _tabController.dispose();
    _emailCodeCountdownTimer?.cancel();
    super.dispose();
  }
}
