import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:fastapp/data/sharedpref/constants/preferences.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'package:fastapp/presentation/views/common/google_code_input.dart';
import 'package:fastapp/utils/device/device_utils.dart';
import 'package:fastapp/utils/device/device_id_utils.dart';
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
  final TextEditingController _emailCodeController = TextEditingController();
  final TextEditingController _mobileCodeController = TextEditingController();
  
  // Google 2FA Code Input
  final GlobalKey<CodeInputFieldState> _google2faKey = GlobalKey<CodeInputFieldState>();
  String _google2faCode = '';
  late final TabController _tabController;

  // Stores
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();
  final PageContentManager _pageContent = getIt<PageContentManager>();

  // State
  String _selectedCountryCode = _defaultCountryCode;
  String _selectedCountryFlag = _defaultCountryFlag;
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
  }

  /// 清除输入框内容
  void _clearInputFields({bool clearVerifyAgain = false}) {
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _google2faKey.currentState?.clear();
    _google2faCode = '';
    _emailCodeController.clear();
    _mobileCodeController.clear();
    _selectedCountryCode = _defaultCountryCode;
    _selectedCountryFlag = _defaultCountryFlag;
    
    if (clearVerifyAgain) {
      _firstLoginParams = null;
      _userStore.clearVerifyAgain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // 如果无法返回，则跳转到首页
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(color: Colors.grey[300]!, width: 1.0),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
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
      ),
    );
  }

  Widget _buildTab({required String text, required bool isSelected}) {
    return Tab(
      child: Container(
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // 点击返回按钮时，跳转到首页
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                    ),
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
    ValueChanged<String>? onChanged,
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
                onChanged: onChanged ?? (_) => setState(() {}),
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
        switch (_userStore.verifyAgainType) {
          case 'google2fa_code':
            return _buildGoogle2faField();
          case 'email_code':
            return _buildEmailCodeField();
          case 'mobile_code':
            return _buildMobileCodeField();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildLoginStatusObserver() {
    return Observer(
      builder: (_) {
        if (_userStore.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool(Preferences.is_logged_in, true);
            });
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
            }
          });
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 构建验证码按钮的通用样式
  static final _verifyCodeButtonStyle = _linkTextStyle.copyWith(color: Colors.grey[700]);

  /// 构建邮箱验证码按钮内容
  Widget _buildEmailCodeButtonContent() => VerifyCodeButton(
        onSend: _sendEmailVerificationCode,
        recipient: _getEmail() ?? '',
        type: VerifyCodeType.email,
        scene: 'login',
        textStyle: _verifyCodeButtonStyle,
        padding: EdgeInsets.zero,
      );

  /// 构建手机验证码按钮内容
  Widget _buildMobileCodeButtonContent() => VerifyCodeButton(
        onSend: _sendMobileVerificationCode,
        recipient: _getMobile() ?? '',
        type: VerifyCodeType.sms,
        scene: 'login',
        textStyle: _verifyCodeButtonStyle,
        padding: EdgeInsets.zero,
      );

  Widget _buildPhoneLoginFields() => Column(
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

  Widget _buildEmailLoginFields() => Column(
        children: [
          _buildTextField(
            controller: _emailController,
            hintKey: 'login.input.email.placeholder',
            defaultValue: '请输入邮箱地址',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: _fieldSpacing),
          _buildPasswordField(),
        ],
      );

  Widget _buildPasswordField() => _buildTextField(
        controller: _passwordController,
        hintKey: 'login.input.password.placeholder',
        defaultValue: '请输入密码',
        obscureText: true,
      );

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
    return CodeInputField(
      key: _google2faKey,
      label: _pageContent.getText('login.input.google2fa.label', defaultValue: 'Google验证码'),
      autofocus: true,
      onChanged: (value) {
        setState(() {
          _google2faCode = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _pageContent.getText('login.error.google2fa_required', defaultValue: '请输入Google验证码');
        }
        if (value.length != 6) {
          return _pageContent.getText('login.error.google2fa_invalid', defaultValue: 'Google验证码格式错误');
        }
        return null;
      },
    );
  }

  /// 构建带验证码按钮的输入框
  Widget _buildCodeField({
    required TextEditingController controller,
    required String hintKey,
    required String defaultValue,
    required Widget Function() buttonBuilder,
  }) {
    return Observer(
      builder: (_) => _buildInputContainer(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: _inputHeight,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(height: 1.5),
                  decoration: InputDecoration(
                    hintText: _pageContent.getText(hintKey, defaultValue: defaultValue),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            buttonBuilder(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCodeField() => _buildCodeField(
        controller: _emailCodeController,
        hintKey: 'login.input.email_code.placeholder',
        defaultValue: '请输入邮箱验证码',
        buttonBuilder: _buildEmailCodeButtonContent,
      );

  Widget _buildMobileCodeField() => _buildCodeField(
        controller: _mobileCodeController,
        hintKey: 'login.input.mobile_code.placeholder',
        defaultValue: '请输入手机验证码',
        buttonBuilder: _buildMobileCodeButtonContent,
      );

  /// 获取当前邮箱地址
  String? _getEmail() {
    return _userStore.verifyAgainEmail?.isNotEmpty == true
        ? _userStore.verifyAgainEmail
        : (!_isPhoneLogin && _emailController.text.isNotEmpty
            ? _emailController.text
            : _firstLoginParams?['email'] as String?);
  }

  /// 获取当前手机号
  String? _getMobile() {
    return _userStore.verifyAgainMobile?.isNotEmpty == true
        ? _userStore.verifyAgainMobile
        : (_isPhoneLogin && _phoneController.text.isNotEmpty
            ? _phoneController.text
            : _firstLoginParams?['mobile'] as String?);
  }

  /// 获取当前国家代码
  String? _getCountryCode() {
    return _userStore.verifyAgainCode?.isNotEmpty == true
        ? _userStore.verifyAgainCode
        : (_firstLoginParams?['code'] as String? ?? _selectedCountryCode.replaceFirst('+', ''));
  }

  /// 获取设备ID（优先使用保存的，否则重新获取）
  Future<String?> _getDeviceId() async {
    return _userStore.verifyAgainDeviceId?.isNotEmpty == true
        ? _userStore.verifyAgainDeviceId
        : _firstLoginParams?['device_id'] as String? ?? 
          (await DeviceIdUtils.getDeviceId().catchError((_) => null));
  }

  /// 验证输入
  String? _validateInput() {
    if (_isPhoneLogin && _phoneController.text.isEmpty) {
      return _pageContent.getText('login.error.phone_required', defaultValue: '请输入手机号码');
    }
    if (!_isPhoneLogin && _emailController.text.isEmpty) {
      return _pageContent.getText('login.error.email_required', defaultValue: '请输入邮箱地址');
    }
    if (_passwordController.text.isEmpty) {
      return _pageContent.getText('login.error.password_required', defaultValue: '请输入密码');
    }
    return null;
  }

  /// 判断是否为手机号登录
  bool get _isPhoneLogin => _tabController.index == 0;

  /// 构建首次登录参数
  Future<Map<String, dynamic>> _buildFirstLoginParams() async {
    return {
      'type': 1,
      'password': _passwordController.text,
      if (_isPhoneLogin) ...{
        'mobile': _phoneController.text,
        'code': _selectedCountryCode.replaceFirst('+', ''),
      },
      if (!_isPhoneLogin) 'email': _emailController.text,
      'device_id': await _getDeviceId(),
    };
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

    _firstLoginParams = await _buildFirstLoginParams();
    final params = _firstLoginParams!;

    try {
      await _userStore.login(
        type: params['type'] as int,
        password: params['password'] as String,
        mobile: params['mobile'] as String?,
        code: params['code'] as String?,
        email: params['email'] as String?,
        deviceId: params['device_id'] as String?,
      );
    } catch (e) {
      // 错误消息已经通过响应拦截器的 EventBus 发送了
      // UserStore 也已经处理了 VerifyAgainException
      // 不再重新抛出异常，避免未处理的异常导致应用崩溃
    } finally {
      // 如果收到二次验证响应，保存设备ID到首次登录参数
      if (_userStore.needsVerifyAgain && _userStore.verifyAgainDeviceId?.isNotEmpty == true) {
        _firstLoginParams?['device_id'] = _userStore.verifyAgainDeviceId;
      }
    }
  }

  /// 处理二次验证
  Future<void> _handleSecondVerification() async {
    final verifyType = _userStore.verifyAgainType;
    if (verifyType == null) return;

    final params = _firstLoginParams!;
    final deviceId = await _getDeviceId();
    
    String? errorMessage;
    Map<String, dynamic> loginParams = {
      'type': params['type'] as int,
      'password': params['password'] as String,
      'deviceId': deviceId?.isNotEmpty == true ? deviceId : null,
    };

    switch (verifyType) {
      case 'google2fa_code':
        if (_google2faCode.isEmpty || _google2faCode.length != 6) {
          errorMessage = _pageContent.getText('login.error.google2fa_required', defaultValue: '请输入Google验证码');
        } else {
          final google2faCode = int.tryParse(_google2faCode);
          if (google2faCode == null) {
            errorMessage = _pageContent.getText('login.error.google2fa_invalid', defaultValue: 'Google验证码格式错误');
          } else {
            loginParams['mobile'] = params['mobile'] as String?;
            loginParams['code'] = params['code'] as String?;
            loginParams['email'] = params['email'] as String?;
            loginParams['google2faCode'] = google2faCode;
          }
        }
        break;
      case 'email_code':
        if (_emailCodeController.text.isEmpty) {
          errorMessage = _pageContent.getText('login.error.email_code_required', defaultValue: '请输入邮箱验证码');
        } else {
          final email = _getEmail();
          if (email?.isEmpty != false) {
            errorMessage = _pageContent.getText('login.error.email_not_found', defaultValue: '无法获取邮箱地址');
          } else {
            loginParams['type'] = 1;
            loginParams['email'] = email;
            loginParams['vcode'] = _emailCodeController.text;
            loginParams['scene'] = 'login';
          }
        }
        break;
      case 'mobile_code':
        if (_mobileCodeController.text.isEmpty) {
          errorMessage = _pageContent.getText('login.error.mobile_code_required', defaultValue: '请输入手机验证码');
        } else {
          final mobile = _getMobile();
          if (mobile?.isEmpty != false) {
            errorMessage = _pageContent.getText('login.error.mobile_not_found', defaultValue: '无法获取手机号');
          } else {
            loginParams['type'] = 1;
            loginParams['mobile'] = mobile;
            loginParams['code'] = params['code'] as String? ?? _getCountryCode();
            loginParams['vcode'] = _mobileCodeController.text;
            loginParams['scene'] = 'login';
          }
        }
        break;
    }

    if (errorMessage != null) {
      _showErrorMessage(errorMessage);
      return;
    }

    try {
      await _userStore.login(
        type: loginParams['type'] as int,
        password: loginParams['password'] as String,
        mobile: loginParams['mobile'] as String?,
        code: loginParams['code'] as String?,
        email: loginParams['email'] as String?,
        vcode: loginParams['vcode'] as String?,
        scene: loginParams['scene'] as String?,
        google2faCode: loginParams['google2faCode'] as int?,
        deviceId: loginParams['deviceId'] as String?,
      );
    } catch (e) {
      // 错误消息已经通过响应拦截器的 EventBus 发送了
      // UserStore 也已经处理了 VerifyAgainException
      // 不再重新抛出异常，避免未处理的异常导致应用崩溃
    }
  }

  Widget _buildContinueButton() {
    return Observer(
      builder: (_) {
        final isLoading = _userStore.isLoading;
        final isVerifyAgain = _userStore.needsVerifyAgain;
        
        // 判断按钮是否可用
        bool isEnabled = !isLoading;
        if (!isVerifyAgain) {
          // 首次登录：需要账号和密码都不为空
          final hasAccount = _isPhoneLogin 
              ? _phoneController.text.trim().isNotEmpty 
              : _emailController.text.trim().isNotEmpty;
          final hasPassword = _passwordController.text.trim().isNotEmpty;
          isEnabled = hasAccount && hasPassword;
        } else {
          // 二次验证：根据验证类型判断
          switch (_userStore.verifyAgainType) {
            case 'google2fa_code':
              isEnabled = _google2faCode.length == 6;
              break;
            case 'email_code':
              isEnabled = _emailCodeController.text.trim().isNotEmpty;
              break;
            case 'mobile_code':
              isEnabled = _mobileCodeController.text.trim().isNotEmpty;
              break;
            default:
              isEnabled = false;
          }
        }
        
        return SizedBox(
          height: _buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled ? _handleLogin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[400],
              disabledForegroundColor: Colors.white70,
              elevation: 0,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
            style: _linkTextStyle.copyWith(color: Colors.grey[700]),
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


  void _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      MessageService.error(message);
    }
  }

  /// 发送验证码的通用处理
  Future<bool> _handleSendCode({
    required Future<Map<String, dynamic>> Function() sendRequest,
    required String successKey,
    required String successDefault,
    required String failedKey,
    required String failedDefault,
  }) async {
    try {
      final response = await sendRequest();
      if (response['code'] == 200) {
        MessageService.success(response['message'] ?? _pageContent.getText(successKey, defaultValue: successDefault));
        return true;
      }
      _showErrorMessage(response['message'] ?? _pageContent.getText(failedKey, defaultValue: failedDefault));
      return false;
    } catch (e) {
      _showErrorMessage(_pageContent.getText(failedKey, defaultValue: failedDefault));
      return false;
    }
  }

  /// 发送邮箱验证码
  Future<bool> _sendEmailVerificationCode(String email) async {
    if (email.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.email_not_found', defaultValue: '无法获取邮箱地址'));
      return false;
    }
    return _handleSendCode(
      sendRequest: () => _userApi.sendEmailCode(email: email, scene: 'login'),
      successKey: 'login.error.email_code_send_success',
      successDefault: '邮箱验证码发送成功',
      failedKey: 'login.error.email_code_send_failed',
      failedDefault: '邮箱验证码发送失败',
    );
  }

  /// 发送手机验证码
  Future<bool> _sendMobileVerificationCode(String mobile) async {
    if (mobile.isEmpty) {
      _showErrorMessage(_pageContent.getText('login.error.mobile_not_found', defaultValue: '无法获取手机号'));
      return false;
    }
    return _handleSendCode(
      sendRequest: () => _userApi.sendSms(mobile: mobile, code: _getCountryCode(), scene: 'login'),
      successKey: 'login.error.mobile_code_send_success',
      successDefault: '手机验证码发送成功',
      failedKey: 'login.error.mobile_code_send_failed',
      failedDefault: '手机验证码发送失败',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailCodeController.dispose();
    _mobileCodeController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
