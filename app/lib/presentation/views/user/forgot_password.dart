import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/core/stores/form/form_store.dart';
import 'package:fastapp/core/widgets/center_message_dialog.dart';
import 'package:fastapp/core/widgets/empty_app_bar_widget.dart';
import 'package:fastapp/core/widgets/progress_indicator_widget.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
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

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  late final TabController _tabController;

  // Stores
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  // Country code
  String _selectedCountryCode = '+86';
  String _selectedCountryFlag = '🇨🇳';

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: EmptyAppBar(),
      body: _buildBody(),
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
                padding: const EdgeInsets.only(left: _horizontalPadding, top: 40.0),
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
                    const SizedBox(height: 16.0),
                    const Text(
                      '重置密码',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _buildTabBar(),
                    const SizedBox(height: 16.0),
                    _buildInputField(),
                    const SizedBox(height: 16.0),
                    _buildCodeField(),
                    const SizedBox(height: 16.0),
                    _buildPasswordField(),
                    const SizedBox(height: 16.0),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 24.0),
                    _buildResetButton(),
                    const SizedBox(height: 16.0),
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
            return _showErrorMessage(_formStore.errorStore.errorMessage);
          },
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

  Widget _buildPhoneField() {
    return Container(
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
    return Container(
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
          hintText: '请输入邮箱地址',
          controller: _emailController,
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
              decoration: InputDecoration(
                hintText: '请输入验证码',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 16.0,
                  bottom: 16.0,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8.0),
          OutlinedButton(
            onPressed: () {
              // TODO: 发送验证码
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.amber),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
              ),
            ),
            child: const Text(
              '获取验证码',
              style: TextStyle(fontSize: 12.0, color: Colors.amber),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: '请输入新密码',
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: 16.0,
            bottom: 16.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              size: 20.0,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(right: 4.0),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: !_isConfirmPasswordVisible,
        decoration: InputDecoration(
          hintText: '请确认新密码',
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: 16.0,
            bottom: 16.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              size: 20.0,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  void _handleResetPassword() {
    final isPhoneReset = _tabController.index == 0;
    final accountController = isPhoneReset ? _phoneController : _emailController;
    final accountType = isPhoneReset ? '手机号码' : '邮箱地址';

    if (accountController.text.isEmpty) {
      _showErrorMessage('请输入$accountType');
      return;
    }

    if (_codeController.text.isEmpty) {
      _showErrorMessage('请输入验证码');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorMessage('请输入新密码');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorMessage('密码长度至少6位');
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showErrorMessage('请确认新密码');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('两次输入的密码不一致');
      return;
    }

    DeviceUtils.hideKeyboard(context);
    // TODO: 调用重置密码接口
    _showErrorMessage('重置密码功能待实现');
  }

  Widget _buildResetButton() {
    return SizedBox(
      height: _buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
        ),
        child: const Text(
          '重置密码',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
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
          '返回登录',
          style: TextStyle(color: Colors.orange, fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CenterMessageDialog.showError(
          context: context,
          message: message,
          duration: const Duration(seconds: 2),
        );
      });
    }
    return const SizedBox.shrink();
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
