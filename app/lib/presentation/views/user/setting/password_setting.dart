import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/presentation/views/common/google_code_input.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'widgets.dart';

/// 密码设置页面
class PasswordSettingScreen extends StatefulWidget {
  const PasswordSettingScreen({super.key});

  @override
  State<PasswordSettingScreen> createState() => _PasswordSettingScreenState();
}

class _PasswordSettingScreenState extends State<PasswordSettingScreen> {
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _vcodeController = TextEditingController();
  final GlobalKey<CodeInputFieldState> _google2faCodeKey = GlobalKey<CodeInputFieldState>();
  
  bool _isLoading = false;
  final Map<String, bool> _obscurePasswords = {
    'old': true,
    'new': true,
    'confirm': true,
  };

  // 间距常量
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 12.0;
  static const double _spacingLarge = 16.0;
  static const double _pagePadding = 12.0;

  // 输入框边框样式
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  );

  // 通用输入框装饰
  InputDecoration _buildInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsets? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: _spacingLarge, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: '',
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _vcodeController.dispose();
    super.dispose();
  }

  /// 获取当前用户信息
  dynamic get _currentUser => _userStore.currentUser;

  /// 判断是否已设置密码
  bool get _isPasswordSet => _currentUser?.isPassword == 1;

  /// 获取验证方式类型
  /// 返回: 'google2fa' | 'email' | 'mobile' | null
  String? get _verificationType {
    if (_currentUser?.isGoogle2fa == 1) return 'google2fa';
    final email = _currentUser?.email;
    if (email != null && email.isNotEmpty) return 'email';
    final mobile = _currentUser?.mobile;
    if (mobile != null && mobile.isNotEmpty) return 'mobile';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: '密码设置'),
            Expanded(
              child: Observer(
                builder: (_) => _isPasswordSet 
                    ? _buildChangePasswordView(context) 
                    : _buildSetPasswordView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设置密码界面（未设置密码时）
  Widget _buildSetPasswordView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityTip(context, isSetPassword: true),
          const SizedBox(height: _spacingMedium),
          _buildDescriptionText(context, isSetPassword: true),
          const SizedBox(height: _spacingMedium),
          _buildPasswordInput(
            controller: _newPasswordController,
            hintText: '请输入新密码',
            key: 'new',
          ),
          const SizedBox(height: _spacingMedium),
          _buildPasswordInput(
            controller: _confirmPasswordController,
            hintText: '请再次输入新密码',
            key: 'confirm',
          ),
          if (_verificationType != null) ...[
            const SizedBox(height: _spacingMedium),
            _buildVerificationCodeInput(context),
          ],
          const SizedBox(height: _spacingMedium),
          _buildActionButton(
            text: '设置密码',
            onPressed: () => _handleSetPassword(context),
          ),
        ],
      ),
    );
  }

  /// 构建修改密码界面（已设置密码时）
  Widget _buildChangePasswordView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityTip(context, isSetPassword: false),
          const SizedBox(height: _spacingMedium),
          _buildDescriptionText(context, isSetPassword: false),
          const SizedBox(height: _spacingMedium),
          _buildPasswordInput(
            controller: _oldPasswordController,
            hintText: '请输入旧密码',
            key: 'old',
          ),
          const SizedBox(height: _spacingMedium),
          _buildPasswordInput(
            controller: _newPasswordController,
            hintText: '请输入新密码',
            key: 'new',
          ),
          const SizedBox(height: _spacingMedium),
          _buildPasswordInput(
            controller: _confirmPasswordController,
            hintText: '请再次输入新密码',
            key: 'confirm',
          ),
          if (_verificationType != null) ...[
            const SizedBox(height: _spacingMedium),
            _buildVerificationCodeInput(context),
          ],
          const SizedBox(height: _spacingMedium),
          _buildActionButton(
            text: '修改密码',
            onPressed: () => _handleChangePassword(context),
          ),
        ],
      ),
    );
  }

  /// 构建说明文字
  Widget _buildDescriptionText(BuildContext context, {required bool isSetPassword}) {
    return Text(
      isSetPassword
          ? '设置密码可以增强账户安全性，用于用户名密码登录。'
          : '修改密码可以增强账户安全性，请确保新密码强度足够。',
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  /// 构建密码输入框（通用方法）
  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hintText,
    required String key,
  }) {
    final isObscure = _obscurePasswords[key] ?? true;
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: _buildInputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() {
                _obscurePasswords[key] = !isObscure;
              });
            },
          ),
        ),
        style: const TextStyle(fontSize: 16),
        enabled: !_isLoading,
      ),
    );
  }

  /// 构建Google验证码输入框
  Widget _buildGoogle2faCodeInput(BuildContext context) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: CodeInputField(
        key: _google2faCodeKey,
        label: 'Google验证码',
        autofocus: false,
        validator: (value) => value == null || value.isEmpty
            ? '请输入Google验证码'
            : _validateCodeForForm(value, label: 'Google验证码'),
      ),
    );
  }

  /// 构建验证码输入框（根据验证方式显示不同的输入框）
  Widget _buildVerificationCodeInput(BuildContext context) {
    final verificationType = _verificationType;
    if (verificationType == null) {
      return const SizedBox.shrink();
    }

    switch (verificationType) {
      case 'google2fa':
        return _buildGoogle2faCodeInput(context);
      case 'email':
        return _buildVerificationCodeInputField(
          hintText: '请输入邮箱验证码',
          prefixIcon: Icons.email_outlined,
          recipient: _currentUser?.email ?? '',
          description: '验证码将发送到您的邮箱',
          type: VerifyCodeType.email,
          onSend: _sendEmailCode,
        );
      case 'mobile':
        return _buildVerificationCodeInputField(
          hintText: '请输入手机验证码',
          prefixIcon: Icons.phone_outlined,
          recipient: _currentUser?.mobile ?? '',
          description: '验证码将发送到您的手机',
          type: VerifyCodeType.sms,
          onSend: _sendMobileCode,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建验证码输入框（邮箱/手机通用）
  Widget _buildVerificationCodeInputField({
    required String hintText,
    required IconData prefixIcon,
    required String recipient,
    required String description,
    required VerifyCodeType type,
    required Future<bool> Function(String) onSend,
  }) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _vcodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: _buildInputDecoration(
              hintText: hintText,
              prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
            ),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
            enabled: !_isLoading,
          ),
          const SizedBox(height: _spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              VerifyCodeButton(
                onSend: onSend,
                recipient: recipient,
                type: type,
                scene: 'change',
                disabled: _isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      shadowColor: colorScheme.primary.withOpacity(0.3),
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
      ),
    );
  }

  /// 构建安全提示
  Widget _buildSecurityTip(BuildContext context, {required bool isSetPassword}) {
    return Container(
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '安全提示',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSetPassword
                      ? '设置密码后，您可以使用用户名和密码进行登录。密码长度至少6位，建议使用字母、数字和特殊字符的组合。'
                      : '修改密码后，您需要使用新密码进行登录。密码长度至少6位，建议使用字母、数字和特殊字符的组合。',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 验证密码格式
  bool _validatePassword(String password, {String label = '密码'}) {
    if (password.isEmpty) {
      MessageService.error('请输入$label');
      return false;
    }
    if (password.length < 6) {
      MessageService.error('$label长度至少6位');
      return false;
    }
    return true;
  }

  /// 验证验证码格式（返回错误消息，用于FormField validator）
  String? _validateCodeForForm(String code, {String label = '验证码'}) {
    return code.isEmpty ? '请输入$label' : null;
  }

  /// 验证验证码格式
  bool _validateCode(String code, {String label = '验证码'}) {
    if (code.isEmpty) {
      MessageService.error('请输入$label');
      return false;
    }
    if (code.length != 6) {
      MessageService.error('$label必须是6位数字');
      return false;
    }
    return true;
  }

  /// 获取验证码（根据验证方式）
  Map<String, String?> _getVerificationCode() {
    final verificationType = _verificationType;
    String? google2faCode;
    String? vcode;

    switch (verificationType) {
      case 'google2fa':
        google2faCode = _google2faCodeKey.currentState?.value ?? '';
        if (google2faCode.isEmpty) {
          MessageService.error('请输入Google验证码');
          return {};
        }
        break;
      case 'email':
        vcode = _vcodeController.text.trim();
        if (!_validateCode(vcode, label: '邮箱验证码')) {
          return {};
        }
        break;
      case 'mobile':
        vcode = _vcodeController.text.trim();
        if (!_validateCode(vcode, label: '手机验证码')) {
          return {};
        }
        break;
    }

    return {'google2faCode': google2faCode, 'vcode': vcode};
  }

  /// 发送邮箱验证码
  Future<bool> _sendEmailCode(String email) async {
    try {
      final response = await _userApi.sendEmailCode(
        email: email,
        scene: 'change',
      );
      if (response['code'] == 200) {
        MessageService.success(response['message'] ?? '验证码已发送');
        return true;
      } else {
        MessageService.error(response['message'] ?? '验证码发送失败');
        return false;
      }
    } catch (e) {
      MessageService.error(e.toString());
      return false;
    }
  }

  /// 发送手机验证码
  Future<bool> _sendMobileCode(String mobile) async {
    try {
      final response = await _userApi.sendSms(
        mobile: mobile,
        code: _currentUser?.code?.toString(),
        scene: 'change',
      );
      if (response['code'] == 200) {
        MessageService.success(response['message'] ?? '验证码已发送');
        return true;
      } else {
        MessageService.error(response['message'] ?? '验证码发送失败');
        return false;
      }
    } catch (e) {
      MessageService.error(e.toString());
      return false;
    }
  }

  /// 清空所有输入框
  void _clearAllInputs() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _vcodeController.clear();
    _google2faCodeKey.currentState?.clear();
  }

  /// 执行带加载状态的异步操作
  Future<void> _executeWithLoading(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) MessageService.error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 验证密码输入
  bool _validatePasswordInputs({
    String? oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (oldPassword != null && !_validatePassword(oldPassword, label: '旧密码')) {
      return false;
    }
    if (!_validatePassword(newPassword, label: '新密码')) return false;
    if (!_validatePassword(confirmPassword, label: '确认密码')) return false;
    
    if (newPassword != confirmPassword) {
      MessageService.error('两次输入的密码不一致');
      return false;
    }
    
    if (oldPassword != null && oldPassword == newPassword) {
      MessageService.error('新密码不能与旧密码相同');
      return false;
    }
    
    return true;
  }

  /// 处理设置密码操作
  Future<void> _handleSetPassword(BuildContext context) async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    if (!_validatePasswordInputs(newPassword: newPassword, confirmPassword: confirmPassword)) {
      return;
    }

    // 根据验证方式获取验证码
    final verificationCodes = _getVerificationCode();
    if (verificationCodes.isEmpty) return;

    // 执行设置密码操作
    await _performChangePassword(
      oldPassword: null,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      google2faCode: verificationCodes['google2faCode'],
      vcode: verificationCodes['vcode'],
    );
  }

  /// 处理修改密码操作
  Future<void> _handleChangePassword(BuildContext context) async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    if (!_validatePasswordInputs(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    )) {
      return;
    }

    // 根据验证方式获取验证码
    final verificationCodes = _getVerificationCode();
    if (verificationCodes.isEmpty) return;

    // 执行修改密码操作
    await _performChangePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
      google2faCode: verificationCodes['google2faCode'],
      vcode: verificationCodes['vcode'],
    );
  }

  /// 执行密码修改操作
  Future<void> _performChangePassword({
    String? oldPassword,
    required String newPassword,
    required String confirmPassword,
    String? google2faCode,
    String? vcode,
  }) async {
    await _executeWithLoading(() async {
      final response = await _userApi.changePassword(
        oldPassword: oldPassword,
        password: newPassword,
        passwordConfirmation: confirmPassword,
        google2faCode: google2faCode,
        vcode: vcode,
      );
      
      await _handleApiResponse(
        response,
        successMessage: _isPasswordSet ? '密码修改成功' : '密码设置成功',
        errorMessage: _isPasswordSet ? '密码修改失败' : '密码设置失败',
        onSuccess: _clearAllInputs,
      );
    });
  }

  /// 显示密码修改成功提示弹框
  Future<void> _showPasswordChangeSuccessDialog() async {
    if (!mounted) return;
    
    final shouldLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('密码修改成功'),
        content: const Text('您的密码已修改成功，为了账户安全，请重新登录。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // 返回 false，跳转到首页
            },
            child: const Text('稍后登录'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true); // 返回 true，跳转到登录页
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('立即登录'),
          ),
        ],
      ),
    );
    
    // 根据用户选择跳转
    if (!mounted) return;
    
    if (shouldLogin == true) {
      // 用户选择立即登录，跳转到登录页面
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      // 用户选择稍后登录或关闭弹框，跳转到首页
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  /// 处理API响应
  Future<bool> _handleApiResponse(
    Map<String, dynamic> response, {
    required String successMessage,
    required String errorMessage,
    VoidCallback? onSuccess,
  }) async {
    if (response['code'] == 200) {
      // 先显示成功消息
      MessageService.success(response['message'] ?? successMessage);
      // 执行成功回调
      onSuccess?.call();
      
      // 密码修改成功后，后端已将token加入黑名单，需要退出登录并清除数据
      try {
        // 退出登录（会清除本地token和用户数据）
        await _userStore.logout();
        // 延迟一下，确保消息显示
        await Future.delayed(const Duration(milliseconds: 500));
        
        // 显示提示弹框，让用户选择立即登录或跳转到首页
        await _showPasswordChangeSuccessDialog();
      } catch (e) {
        // 即使退出登录失败，也要显示弹框
        if (kDebugMode) {
          print('退出登录失败: $e');
        }
        await _showPasswordChangeSuccessDialog();
      }
      return true;
    } else {
      MessageService.error(response['message'] ?? errorMessage);
      return false;
    }
  }
}
