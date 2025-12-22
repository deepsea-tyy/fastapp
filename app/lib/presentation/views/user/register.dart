import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/data/sharedpref/constants/preferences.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'package:fastapp/utils/device/device_utils.dart';
import 'package:fastapp/utils/device/device_id_utils.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fastapp/di/service_locator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  // Constants
  static const double _horizontalPadding = 24.0;
  static const double _buttonHeight = 48.0;
  static const double _inputHeight = 56.0;
  static const double _fieldSpacing = 16.0;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  late final TabController _tabController;

  // Stores
  final UserApi _userApi = getIt<UserApi>();
  final SharedPreferenceHelper _sharedPrefsHelper = getIt<SharedPreferenceHelper>();
  final UserStore _userStore = getIt<UserStore>();

  // Country code
  String _selectedCountryCode = '+86';
  String _selectedCountryFlag = '🇨🇳';

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _showPasswordFields = false; // 控制密码输入框显示
  bool _isCodeVerified = false; // 验证码是否已验证
  bool _isLoading = false; // 是否正在加载
  int _previousTabIndex = 0; // 记录之前的Tab索引

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _previousTabIndex = _tabController.index;
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index != _previousTabIndex) {
      _resetAllFields();
    }
  }

  void _resetAllFields() {
    setState(() {
      _previousTabIndex = _tabController.index;
      _showPasswordFields = false;
      _isCodeVerified = false;
      _isLoading = false;
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;
      _phoneController.clear();
      _emailController.clear();
      _codeController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _selectedCountryCode = '+86';
      _selectedCountryFlag = '🇨🇳';
    });
  }

  void _clearControllers() {
    _phoneController.clear();
    _emailController.clear();
    _codeController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
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
    final contentHeight = _inputHeight * 2 + _fieldSpacing;
    
    return Column(
      children: [
        _buildTabBar(),
        const SizedBox(height: _fieldSpacing),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: contentHeight,
          child: _showPasswordFields
              ? Column(
                  children: [
                    _buildPasswordField(),
                    const SizedBox(height: _fieldSpacing),
                    _buildConfirmPasswordField(),
                  ],
                )
              : Column(
                  children: [
                    IndexedStack(
                      index: _tabController.index,
                      children: [_buildPhoneField(), _buildEmailField()],
                    ),
                    const SizedBox(height: _fieldSpacing),
                    _buildCodeField(),
                  ],
                ),
        ),
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
                    const Text(
                      '注册',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _buildInputField(),
                    const SizedBox(height: 24.0),
                    _buildRegisterButton(),
                    const SizedBox(height: 16.0),
                    _buildLoginButton(),
                    const SizedBox(height: 32.0),
                    _buildDivider(),
                    const SizedBox(height: 32.0),
                    _buildGoogleRegisterButton(),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildInputContainer(Widget child) {
    return Container(
      height: _inputHeight,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(right: 4.0),
      child: child,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close, size: 20.0),
              onPressed: () => setState(() => controller.clear()),
            )
          : null,
    );
  }

  InputDecoration _buildPasswordDecoration({
    required String hintText,
    required VoidCallback onToggleVisibility,
    required bool isVisible,
  }) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          size: 20.0,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }

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
              style: const TextStyle(height: 1.5),
              decoration: _buildInputDecoration(
                hintText: '请输入手机号码',
                controller: _phoneController,
              ),
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
        style: const TextStyle(height: 1.5),
        decoration: _buildInputDecoration(
          hintText: '请输入邮箱地址',
          controller: _emailController,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildInputContainer(
      TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(height: 1.5),
        decoration: _buildPasswordDecoration(
          hintText: '请输入密码',
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          isVisible: _isPasswordVisible,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildInputContainer(
      TextField(
        controller: _confirmPasswordController,
        obscureText: !_isConfirmPasswordVisible,
        style: const TextStyle(height: 1.5),
        decoration: _buildPasswordDecoration(
          hintText: '请确认密码',
          onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          isVisible: _isConfirmPasswordVisible,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  bool get _isPhoneRegister => _tabController.index == 0;
  
  String get _recipient => _isPhoneRegister 
      ? _phoneController.text.trim() 
      : _emailController.text.trim();

  Widget _buildCodeField() {
    return _buildInputContainer(
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.text,
              style: const TextStyle(height: 1.5),
              decoration: const InputDecoration(
                hintText: '请输入验证码',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8.0),
          VerifyCodeButton(
            onSend: _sendVerificationCode,
            recipient: _recipient,
            type: _isPhoneRegister ? VerifyCodeType.sms : VerifyCodeType.email,
            scene: 'register',
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
              ),
            ),
            textStyle: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Future<bool> _sendVerificationCode(String recipient) async {
    try {
      if (_isPhoneRegister) {
        await _userApi.sendSms(
          mobile: recipient,
          code: _selectedCountryCode.replaceAll('+', ''),
          scene: 'register',
        );
      } else {
        await _userApi.sendEmailCode(
          email: recipient,
          scene: 'register',
        );
      }
      // 响应拦截器已处理错误，到这里说明发送成功
      return true;
    } catch (e) {
      // 错误已由拦截器处理
      return false;
    }
  }

  Future<void> _handleRegister() async {
    if (!_isCodeVerified) {
      await _verifyCode();
      return;
    }
    await _submitRegister();
  }

  Future<void> _verifyCode() async {
    final accountController = _isPhoneRegister ? _phoneController : _emailController;
    final accountType = _isPhoneRegister ? '手机号码' : '邮箱地址';

    if (accountController.text.isEmpty) {
      _showErrorMessage('请输入$accountType');
      return;
    }
    if (_codeController.text.isEmpty) {
      _showErrorMessage('请输入验证码');
      return;
    }

    DeviceUtils.hideKeyboard(context);
    _setLoading(true);

    try {
      await _userApi.smsCheck(
        type: _isPhoneRegister ? 'sms' : 'email',
        to: accountController.text.trim(),
        vcode: _codeController.text.trim(),
        scene: 'register',
        code: _isPhoneRegister ? _selectedCountryCode.replaceAll('+', '') : null,
      );

      // 响应拦截器已处理错误，到这里说明验证成功
      setState(() {
        _isCodeVerified = true;
        _showPasswordFields = true;
        _isLoading = false;
      });
    } catch (e) {
      _setLoading(false);
      // 错误已由拦截器处理
    }
  }

  String? _validatePassword() {
    if (_passwordController.text.isEmpty) return '请输入密码';
    if (_passwordController.text.length < 6) return '密码长度至少6位';
    if (_confirmPasswordController.text.isEmpty) return '请确认密码';
    if (_passwordController.text != _confirmPasswordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  Future<void> _submitRegister() async {
    final error = _validatePassword();
    if (error != null) {
      _showErrorMessage(error);
      return;
    }

    DeviceUtils.hideKeyboard(context);
    _setLoading(true);

    try {
      final deviceId = await DeviceIdUtils.getDeviceId().catchError((_) => null);
      final response = await _userApi.register(
        type: _isPhoneRegister ? 2 : 3,
        mobile: _isPhoneRegister ? _phoneController.text.trim() : null,
        email: _isPhoneRegister ? null : _emailController.text.trim(),
        code: _isPhoneRegister ? _selectedCountryCode.replaceAll('+', '') : null,
        vcode: _codeController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        scene: 'register',
        deviceId: deviceId,
      );

      // 响应拦截器已处理错误，到这里说明注册成功
      await _handleRegisterSuccess(response);
    } catch (e) {
      _setLoading(false);
      // 错误已由拦截器处理
    }
  }

  Future<void> _handleRegisterSuccess(Map<String, dynamic> response) async {
    final accessToken = response['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      _setLoading(false);
      _showErrorMessage('注册失败：未获取到访问令牌');
      return;
    }

    // 保存 token 和设备ID
    await _saveTokens(response);

    // 同步用户状态到 UserStore
    try {
      await _userStore.handleLoginSuccess();
    } catch (e) {
      if (mounted) _showErrorMessage('获取用户信息失败：${e.toString()}');
    }

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> response) async {
    final futures = <Future>[
      _sharedPrefsHelper.saveAuthToken(response['access_token'] as String),
    ];

    final refreshToken = response['refresh_token'] as String?;
    final expireAt = response['expire_at'] as int?;
    final deviceId = response['device_id'] as String?;

    if (refreshToken?.isNotEmpty == true) {
      futures.add(_sharedPrefsHelper.saveRefreshToken(refreshToken!));
    }
    if (expireAt != null) {
      futures.add(_sharedPrefsHelper.saveExpireAt(expireAt));
    }
    if (deviceId?.isNotEmpty == true) {
      futures.add(DeviceIdUtils.saveDeviceId(deviceId!));
    }

    await Future.wait(futures);
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  Widget _buildRegisterButton() {
    // 判断按钮是否可用
    bool isEnabled = !_isLoading;
    if (!_isCodeVerified) {
      // 验证码阶段：需要账号和验证码都不为空
      final accountController = _isPhoneRegister ? _phoneController : _emailController;
      isEnabled = accountController.text.trim().isNotEmpty && 
                  _codeController.text.trim().isNotEmpty;
    } else {
      // 注册阶段：需要密码验证通过
      isEnabled = _validatePassword() == null;
    }
    
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleRegister : null,
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
        child: _isLoading
            ? const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isCodeVerified ? '注册' : '确认',
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        },
        child: const Text(
          '已有账号？立即登录',
          style: TextStyle(color: Colors.grey, fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1.0)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '或',
            style: TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ),
        const Expanded(child: Divider(color: Colors.grey, thickness: 1.0)),
      ],
    );
  }

  Widget _buildGoogleRegisterButton() {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: 处理Google注册
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
            const Text(
              '通过 Google 注册',
              style: TextStyle(color: Colors.black87, fontSize: 14.0),
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

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
