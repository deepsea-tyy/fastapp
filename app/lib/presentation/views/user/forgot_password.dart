import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/widgets/progress_indicator_widget.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'package:fastapp/presentation/views/common/google_code_input.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/utils/device/device_utils.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  // Constants
  static const double _horizontalPadding = 24.0;
  static const double _buttonHeight = 48.0;
  static const double _spacing = 16.0;
  
  // 按钮样式
  static final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[800],
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
    ),
  );
  
  static const TextStyle _primaryButtonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  final TextEditingController _mobileCodeController = TextEditingController();
  final GlobalKey<CodeInputFieldState> _google2faCodeKey = GlobalKey<CodeInputFieldState>();
  late final TabController _tabController;

  // Stores
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();

  // Country code
  String _selectedCountryCode = '+86';
  String _selectedCountryFlag = '🇨🇳';

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // 双重认证状态
  String? _verifyAgainType;
  String? _verifyAgainEmail;
  String? _verifyAgainMobile;
  String? _verifyAgainCode;
  
  // 是否已获取二次认证方式（用于控制密码输入框显示）
  bool _hasVerifiedCode = false;
  
  // 记录上一次的标签页索引，用于检测切换
  int _previousTabIndex = 0;
  
  // 请求步骤计数器
  int _step = 1;
  
  // 是否为手机号重置
  bool get _isPhoneReset => _tabController.index == 0;
  
  // 当前账号输入框
  TextEditingController get _accountController => 
      _isPhoneReset ? _phoneController : _emailController;
  
  // 当前账号值
  String get _accountValue => _accountController.text.trim();
  
  // 国家代码（手机号时使用）
  String get _countryCode => _selectedCountryCode.replaceAll('+', '');
  
  // 获取请求的 code 参数（优先使用保存的 code，否则使用当前国家代码）
  String? get _requestCode => _isPhoneReset ? (_verifyAgainCode ?? _countryCode) : null;
  
  // 获取请求的 mobile 参数
  String? get _requestMobile => _isPhoneReset ? (_verifyAgainMobile ?? _accountValue) : null;
  
  // 获取请求的 email 参数
  String? get _requestEmail => _isPhoneReset ? null : (_verifyAgainEmail ?? _accountValue);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _previousTabIndex = _tabController.index;
    _tabController.addListener(() {
      // 检测标签页切换
      if (_tabController.index != _previousTabIndex) {
        _previousTabIndex = _tabController.index;
        // 切换标签页时清除状态
        _clearTabSwitchState();
      }
      setState(() {});
    });
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
        labelStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: '手机号'),
          Tab(text: '邮箱'),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        _buildPhoneField(),
        _buildEmailField(),
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _verifyAgainType != null
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _clearVerifyAgainState,
                        )
                      : const BackButton(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4.0),
                    const Text(
                      '重置密码',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    if (_verifyAgainType == null) ...[
                      _buildTabBar(),
                      SizedBox(height: _spacing),
                      _buildInputField(),
                      SizedBox(height: _spacing),
                      _buildCodeField(),
                    ] else ...[
                      _buildSecondVerificationField(),
                      SizedBox(height: _spacing),
                      if (!_hasVerifiedCode) _buildVerifySecondAuthButton(),
                    ],
                    if (_hasVerifiedCode) ...[
                      SizedBox(height: _spacing),
                      _buildPasswordField(),
                      SizedBox(height: _spacing),
                      _buildConfirmPasswordField(),
                    ],
                    const SizedBox(height: 24.0),
                    _buildResetButton(),
                    SizedBox(height: _spacing),
                    _buildLoginButton(),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _userStore.isLoading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        ),
      ],
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
      child: child,
    );
  }

  /// 构建基础输入框装饰
  InputDecoration _buildBaseInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
    );
  }

  /// 清除所有状态
  void _clearAllState({bool clearInputs = true}) {
    setState(() {
      _hasVerifiedCode = false;
      _verifyAgainType = null;
      _verifyAgainEmail = null;
      _verifyAgainMobile = null;
      _verifyAgainCode = null;
      _step = 1;
      
      if (clearInputs) {
        _codeController.clear();
        _google2faCodeKey.currentState?.clear();
        _emailCodeController.clear();
        _mobileCodeController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  /// 清除双重认证状态
  void _clearVerifyAgainState() {
    _clearAllState(clearInputs: false);
    _google2faCodeKey.currentState?.clear();
    _emailCodeController.clear();
    _mobileCodeController.clear();
  }

  /// 清除切换标签页时的状态
  void _clearTabSwitchState() => _clearAllState();

  // 验证码按钮样式
  static final ButtonStyle _verifyCodeButtonStyle = OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.grey[400]!),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
    ),
  );

  static final TextStyle _verifyCodeTextStyle = TextStyle(fontSize: 12.0, color: Colors.grey[700]);

  Widget _buildPhoneField() {
    return _buildInputContainer(
      Row(
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
              decoration: _buildBaseInputDecoration('请输入手机号码'),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildInputContainer(
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: _buildBaseInputDecoration('请输入邮箱地址'),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      children: [
        _buildCodeInputWithButton(
          controller: _codeController,
          hintText: '请输入验证码',
          recipient: _accountValue,
          type: _isPhoneReset ? VerifyCodeType.sms : VerifyCodeType.email,
          onSend: (_) => _sendVerificationCode(_accountValue, _isPhoneReset),
        ),
        if (!_hasVerifiedCode) ...[
          SizedBox(height: _spacing),
          _buildPrimaryButton(
            text: '验证',
            onPressed: _codeController.text.isEmpty ? null : _verifyCodeAndGetAuthMethod,
          ),
        ],
      ],
    );
  }

  /// 发送验证码
  Future<bool> _sendVerificationCode(String recipient, bool isPhone) async {
    try {
      if (isPhone) {
        await _userApi.sendSms(
          mobile: recipient,
          code: _countryCode,
          scene: 'reset_password',
        );
      } else {
        await _userApi.sendEmailCode(
          email: recipient,
          scene: 'reset_password',
        );
      }
      return true;
    } catch (e) {
      if (mounted) MessageService.error(e.toString());
      return false;
    }
  }

  /// 验证验证码并获取二次认证方式
  Future<void> _verifyCodeAndGetAuthMethod() async {
    if (_accountValue.isEmpty) {
      MessageService.error('请输入${_isPhoneReset ? '手机号码' : '邮箱地址'}');
      return;
    }
    
    if (_codeController.text.isEmpty) {
      MessageService.error('请输入验证码');
      return;
    }

    DeviceUtils.hideKeyboard(context);

    try {
      final response = await _userApi.resetPassword(
        type: _isPhoneReset ? 2 : 3,
        mobile: _requestMobile,
        email: _requestEmail,
        code: _requestCode,
        vcode: _codeController.text.trim(),
        step: _step,
      );

      final verifyAgain = response['verify_again'] as String?;
      
      setState(() {
        _step++;
        if (verifyAgain != null && verifyAgain.isNotEmpty) {
          _verifyAgainType = verifyAgain;
          _verifyAgainEmail = response['email'] as String?;
          _verifyAgainMobile = response['mobile'] as String?;
          _verifyAgainCode = _requestCode; // 保存当前使用的 code
          _hasVerifiedCode = false;
        } else {
          _hasVerifiedCode = true;
        }
      });
    } catch (e) {
      if (mounted) MessageService.error('验证失败: ${e.toString()}');
    }
  }

  Widget _buildPasswordField() {
    return _buildPasswordInputField(
      controller: _passwordController,
      hintText: '请输入新密码',
      obscureText: !_isPasswordVisible,
      onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildPasswordInputField(
      controller: _confirmPasswordController,
      hintText: '请确认新密码',
      obscureText: !_isConfirmPasswordVisible,
      onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
    );
  }

  Widget _buildPasswordInputField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return _buildInputContainer(
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: _buildBaseInputDecoration(hintText).copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              size: 20.0,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  /// 验证密码
  String? _validatePassword() {
    if (_passwordController.text.isEmpty) {
      return '请输入新密码';
    }
    if (_passwordController.text.length < 6) {
      return '密码长度至少6位';
    }
    if (_confirmPasswordController.text.isEmpty) {
      return '请确认新密码';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  /// 获取双重认证码
  Map<String, String?> _getVerifyAgainCode() {
    switch (_verifyAgainType) {
      case 'google2fa_code':
        final code = _google2faCodeKey.currentState?.value ?? '';
        if (code.isEmpty || code.length != 6) throw '请输入Google验证码';
        if (int.tryParse(code) == null) throw 'Google验证码格式错误';
        return {'google2faCode': code, 'vcode': null};
      case 'email_code':
        if (_emailCodeController.text.isEmpty) throw '请输入邮箱验证码';
        return {'vcode': _emailCodeController.text.trim(), 'google2faCode': null};
      case 'mobile_code':
        if (_mobileCodeController.text.isEmpty) throw '请输入手机验证码';
        return {'vcode': _mobileCodeController.text.trim(), 'google2faCode': null};
      default:
        return {'vcode': null, 'google2faCode': null};
    }
  }

  /// 处理重置密码成功
  Future<void> _handleResetSuccess() async {
    if (!mounted) return;
    MessageService.success('密码重置成功');
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_hasVerifiedCode) {
      MessageService.error('请先验证验证码');
      return;
    }

    final passwordError = _validatePassword();
    if (passwordError != null) {
      MessageService.error(passwordError);
      return;
    }

    DeviceUtils.hideKeyboard(context);

    try {
      final codes = _verifyAgainType != null ? _getVerifyAgainCode() : null;
      
      await _userApi.resetPassword(
        type: _isPhoneReset ? 2 : 3,
        mobile: _requestMobile,
        email: _requestEmail,
        code: _requestCode,
        vcode: codes?['vcode'] ?? _codeController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        google2faCode: codes?['google2faCode'],
        step: _step,
      );
      
      await _handleResetSuccess();
    } catch (e) {
      if (mounted) MessageService.error('重置密码失败: ${e.toString()}');
    }
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: _primaryButtonStyle,
        child: Text(text, style: _primaryButtonTextStyle),
      ),
    );
  }

  Widget _buildVerifySecondAuthButton() {
    // 判断按钮是否可用
    bool isEnabled = false;
    if (_verifyAgainType != null) {
      switch (_verifyAgainType) {
        case 'google2fa_code':
          final code = _google2faCodeKey.currentState?.value ?? '';
          isEnabled = code.isNotEmpty && code.length == 6;
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
    
    return _buildPrimaryButton(
      text: '验证',
      onPressed: isEnabled ? _verifySecondAuthCode : null,
    );
  }

  Widget _buildResetButton() {
    if (!_hasVerifiedCode) return const SizedBox.shrink();
    
    return _buildPrimaryButton(
      text: '重置密码',
      onPressed: _handleResetPassword,
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        },
        child: const Text(
          '返回登录',
          style: TextStyle(color: Colors.grey, fontSize: 14.0),
        ),
      ),
    );
  }


  /// 构建双重认证输入框
  Widget _buildSecondVerificationField() {
    switch (_verifyAgainType) {
      case 'google2fa_code':
        return _buildGoogle2faField();
      case 'email_code':
        return _buildEmailCodeField();
      case 'mobile_code':
        return _buildMobileCodeField();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建 Google2FA 输入框
  Widget _buildGoogle2faField() {
    return CodeInputField(
      key: _google2faCodeKey,
      label: '请输入Google验证码（6位）',
      autofocus: true,
      onChanged: (_) => setState(() {}),
    );
  }

  /// 构建邮箱验证码输入框
  Widget _buildEmailCodeField() {
    final email = _verifyAgainEmail ?? _emailController.text;
    return _buildCodeInputWithButton(
      controller: _emailCodeController,
      hintText: '请输入邮箱验证码',
      recipient: email,
      type: VerifyCodeType.email,
      onSend: (_) => _sendVerificationCode(email, false),
    );
  }

  /// 验证二次认证码并显示密码输入框
  Future<void> _verifySecondAuthCode() async {
    if (_verifyAgainType == null) return;

    DeviceUtils.hideKeyboard(context);

    try {
      final codes = _getVerifyAgainCode();
      
      await _userApi.resetPassword(
        type: _isPhoneReset ? 2 : 3,
        mobile: _requestMobile,
        email: _requestEmail,
        code: _requestCode,
        vcode: codes['vcode'],
        google2faCode: codes['google2faCode'],
        step: _step,
      );

      setState(() {
        _step++;
        _hasVerifiedCode = true;
      });
    } catch (e) {
      if (mounted) MessageService.error('验证失败: ${e.toString()}');
    }
  }

  /// 构建手机验证码输入框
  Widget _buildMobileCodeField() {
    final mobile = _verifyAgainMobile ?? _phoneController.text;
    return _buildCodeInputWithButton(
      controller: _mobileCodeController,
      hintText: '请输入手机验证码',
      recipient: mobile,
      type: VerifyCodeType.sms,
      onSend: (_) => _sendVerificationCode(mobile, true),
    );
  }

  /// 构建带验证码按钮的输入框
  Widget _buildCodeInputWithButton({
    required TextEditingController controller,
    required String hintText,
    required String recipient,
    required VerifyCodeType type,
    required Future<bool> Function(String) onSend,
  }) {
    return _buildInputContainer(
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _buildBaseInputDecoration(hintText),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8.0),
          VerifyCodeButton(
            onSend: onSend,
            recipient: recipient,
            type: type,
            scene: 'reset_password',
            style: _verifyCodeButtonStyle,
            textStyle: _verifyCodeTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    _emailCodeController.dispose();
    _mobileCodeController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
