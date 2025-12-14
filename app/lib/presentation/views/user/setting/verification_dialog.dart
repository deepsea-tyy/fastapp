import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/presentation/views/common/google_code_input.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'widgets.dart';

/// 密码和验证码验证对话框
class VerificationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final Future<void> Function({
    required String password,
    String? google2faCode,
    String? vcode,
  }) onConfirm;

  const VerificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();

  /// 显示验证对话框
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required Future<void> Function({
      required String password,
      String? google2faCode,
      String? vcode,
    }) onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerificationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }
}

class _VerificationDialogState extends State<VerificationDialog> {
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _vcodeController = TextEditingController();
  final GlobalKey<CodeInputFieldState> _google2faCodeKey = GlobalKey<CodeInputFieldState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // 间距常量
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 12.0;
  static const double _spacingLarge = 16.0;

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
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: _inputBorder,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: _spacingLarge, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      counterText: '',
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
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

  /// 验证密码格式
  bool _validatePassword(String password) {
    // 如果用户已设置密码，则必须验证密码
    if (_isPasswordSet) {
      if (password.isEmpty) {
        MessageService.error('请输入密码');
        return false;
      }
      if (password.length < 6) {
        MessageService.error('密码长度至少6位');
        return false;
      }
    }
    // 如果用户未设置密码，密码可以为空
    return true;
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
      await _userApi.sendEmailCode(
        email: email,
        scene: 'change',
      );
      // 响应拦截器已处理错误，到这里说明发送成功
      MessageService.success('验证码已发送');
      return true;
    } catch (e) {
      // 错误已由拦截器处理
      return false;
    }
  }

  /// 发送手机验证码
  Future<bool> _sendMobileCode(String mobile) async {
    try {
      await _userApi.sendSms(
        mobile: mobile,
        code: _currentUser?.code?.toString(),
        scene: 'change',
      );
      // 响应拦截器已处理错误，到这里说明发送成功
      MessageService.success('验证码已发送');
      return true;
    } catch (e) {
      // 错误已由拦截器处理
      return false;
    }
  }

  /// 处理确认操作
  Future<void> _handleConfirm() async {
    final password = _passwordController.text.trim();
    
    if (!_validatePassword(password)) return;

    // 根据验证方式获取验证码
    final verificationCodes = _getVerificationCode();
    if (verificationCodes.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await widget.onConfirm(
        password: password,
        google2faCode: verificationCodes['google2faCode'],
        vcode: verificationCodes['vcode'],
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        MessageService.error(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 构建密码输入框
  Widget _buildPasswordInput() {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: _buildInputDecoration(
          hintText: '请输入密码',
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
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
  Widget _buildGoogle2faCodeInput() {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: CodeInputField(
        key: _google2faCodeKey,
        label: 'Google验证码',
        autofocus: false,
        validator: (value) => value == null || value.isEmpty
            ? '请输入Google验证码'
            : null,
      ),
    );
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

  /// 构建验证码输入框（根据验证方式显示不同的输入框）
  Widget _buildVerificationCodeInput() {
    final verificationType = _verificationType;
    if (verificationType == null) {
      return const SizedBox.shrink();
    }

    switch (verificationType) {
      case 'google2fa':
        return _buildGoogle2faCodeInput();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Observer(
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: _spacingLarge),
              if (_isPasswordSet) ...[
                _buildPasswordInput(),
                if (_verificationType != null) const SizedBox(height: _spacingMedium),
              ],
              if (_verificationType != null) _buildVerificationCodeInput(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.confirmColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.confirmText),
        ),
      ],
    );
  }
}
