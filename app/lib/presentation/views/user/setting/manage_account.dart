import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/views/common/google_code_input.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'package:fastapp/presentation/views/main/main_screen.dart';
import 'widgets.dart';

/// 管理账户页面
class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final UserApi _userApi = getIt<UserApi>();
  final UserStore _userStore = getIt<UserStore>();
  bool _isLoading = false;
  
  String? _currentAction; // 'disable' 或 'delete'
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _vcodeController = TextEditingController();
  final GlobalKey<CodeInputFieldState> _google2faCodeKey = GlobalKey<CodeInputFieldState>();
  bool _obscurePassword = true;

  // 间距常量
  static const double _spacingMedium = 12.0;
  static const double _spacingLarge = 16.0;
  static const double _pagePadding = 12.0;

  // 输入框边框样式
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  );

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

  /// 清除所有输入
  void _clearInputs() {
    _passwordController.clear();
    _vcodeController.clear();
    _google2faCodeKey.currentState?.clear();
  }

  void _handleAccountAction(String action) {
    if (_isLoading) return;
    setState(() {
      _currentAction = action;
      _clearInputs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseSettingScreen(
      title: '管理账户',
      body: _currentAction != null
          ? _buildVerificationView(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccountOptionCard(
                    title: '禁用账户',
                    description: '一旦账户禁用，大多数操作都会受限，例如登录和交易等。您可以随时选择解锁该账户。本操作不会删除您的账户。',
                    onTap: _isLoading ? null : () => _handleAccountAction('disable'),
                  ),
                  const SizedBox(height: 24),
                  AccountOptionCard(
                    title: '删除账户',
                    description: '请注意，账户删除后无法恢复。一旦删除，将无法访问账户或查看交易历史记录。此外，若尝试创建新账户，您的身份认证可能有所延迟。',
                    onTap: _isLoading ? null : () => _handleAccountAction('delete'),
                  ),
                ],
              ),
            ),
    );
  }

  /// 获取操作配置
  ({String message, IconData icon, Color color, String confirmText}) get _actionConfig {
    final isDisable = _currentAction == 'disable';
    return (
      message: isDisable
          ? '为了安全设置，请先验证您的身份。一旦账户禁用，大多数操作都会受限，例如登录和交易等。您可以随时选择解锁该账户。本操作不会删除您的账户。'
          : '为了安全设置，请先验证您的身份。请注意，账户删除后无法恢复。一旦删除，将无法访问账户或查看交易历史记录。',
      icon: isDisable ? Icons.warning_amber_rounded : Icons.error_outline,
      color: isDisable ? Colors.orange : Colors.red,
      confirmText: isDisable ? '禁用' : '删除',
    );
  }

  /// 构建验证码输入视图
  Widget _buildVerificationView(BuildContext context) {
    final config = _actionConfig;
    
    return Observer(
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(_pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipCard(context, config.message, config.icon, config.color),
            const SizedBox(height: _spacingLarge),
            if (_isPasswordSet) ...[
              _buildPasswordInput(context),
              if (_verificationType != null) const SizedBox(height: _spacingMedium),
            ],
            if (_verificationType != null) _buildVerificationCodeInput(context),
            const SizedBox(height: _spacingLarge),
            _buildActionButton(
              text: config.confirmText,
              onPressed: () => _handleConfirmAction(context, config.color),
              isDanger: _currentAction == 'delete',
              backgroundColor: config.color,
            ),
            const SizedBox(height: _spacingMedium),
            _buildActionButton(
              text: '取消',
              onPressed: () => setState(() {
                _currentAction = null;
                _clearInputs();
              }),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建提示卡片
  Widget _buildTipCard(BuildContext context, String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(_spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建密码输入框
  Widget _buildPasswordInput(BuildContext context) {
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
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        style: const TextStyle(fontSize: 16),
        enabled: !_isLoading,
      ),
    );
  }

  /// 构建通用输入框装饰
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

  /// 构建验证码输入框（根据验证方式显示不同的输入框）
  Widget _buildVerificationCodeInput(BuildContext context) {
    final verificationType = _verificationType;
    if (verificationType == null) return const SizedBox.shrink();

    switch (verificationType) {
      case 'google2fa':
        return SettingCard(
          padding: const EdgeInsets.all(_spacingMedium),
          child: CodeInputField(
            key: _google2faCodeKey,
            label: 'Google验证码',
            validator: (value) => _validateCode(value, 'Google验证码'),
          ),
        );
      case 'email':
        return _buildVerificationCodeInputField(
          context: context,
          hintText: '请输入邮箱验证码',
          prefixIcon: Icons.email_outlined,
          recipient: _currentUser?.email ?? '',
          description: '验证码将发送到您的邮箱',
          type: VerifyCodeType.email,
          onSend: (email) => _sendCode(() => _userApi.sendEmailCode(email: email, scene: 'change')),
        );
      case 'mobile':
        return _buildVerificationCodeInputField(
          context: context,
          hintText: '请输入手机验证码',
          prefixIcon: Icons.phone_outlined,
          recipient: _currentUser?.mobile ?? '',
          description: '验证码将发送到您的手机',
          type: VerifyCodeType.sms,
          onSend: (mobile) => _sendCode(() => _userApi.sendSms(
            mobile: mobile,
            code: _currentUser?.code?.toString(),
            scene: 'change',
          )),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 验证验证码格式
  String? _validateCode(String? value, String label) {
    if (value == null || value.isEmpty) {
      return '请输入6位$label';
    }
    if (value.length != 6) {
      return '验证码必须是6位数字';
    }
    return null;
  }

  /// 构建验证码输入框（邮箱/手机通用）
  Widget _buildVerificationCodeInputField({
    required BuildContext context,
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
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: _spacingLarge, vertical: 14),
              prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
              counterText: '',
            ),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
            enabled: !_isLoading,
          ),
          const SizedBox(height: _spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RepaintBoundary(
                child: SizedBox(
                  width: 100,
                  height: 32,
                  child: VerifyCodeButton(
                    onSend: onSend,
                    recipient: recipient,
                    type: type,
                    scene: 'change',
                    disabled: _isLoading,
                    minimumSize: const Size(100, 32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 统一发送验证码方法
  Future<bool> _sendCode(Future<Map<String, dynamic>> Function() apiCall) async {
    try {
      await apiCall();
      // 响应拦截器已处理错误，到这里说明发送成功
      MessageService.success('验证码已发送');
      return true;
    } catch (e) {
      // 错误已由拦截器处理
      return false;
    }
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool isDanger = false,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonColor = backgroundColor ?? (isDanger ? Colors.red.shade600 : Colors.orange);
    
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: isDanger ? Colors.red.shade600 : colorScheme.primary,
                side: BorderSide(
                  color: isDanger ? Colors.red.shade400 : colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                ),
                backgroundColor: isDanger 
                    ? Colors.red.shade50.withOpacity(0.1)
                    : colorScheme.primaryContainer.withOpacity(0.1),
              ),
              onPressed: _isLoading ? null : onPressed,
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: buttonColor.withOpacity(0.3),
              ),
              onPressed: _isLoading ? null : onPressed,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
    );
  }

  /// 获取验证码
  ({String? google2faCode, String? vcode}) _getVerificationCodes() {
    final verificationType = _verificationType;
    switch (verificationType) {
      case 'google2fa':
        final code = _google2faCodeKey.currentState?.value ?? '';
        if (code.isEmpty) {
          MessageService.error('请输入Google验证码');
          return (google2faCode: null, vcode: null);
        }
        return (google2faCode: code, vcode: null);
      case 'email':
        final code = _vcodeController.text.trim();
        if (code.isEmpty || code.length != 6) {
          MessageService.error('请输入6位邮箱验证码');
          return (google2faCode: null, vcode: null);
        }
        return (google2faCode: null, vcode: code);
      case 'mobile':
        final code = _vcodeController.text.trim();
        if (code.isEmpty || code.length != 6) {
          MessageService.error('请输入6位手机验证码');
          return (google2faCode: null, vcode: null);
        }
        return (google2faCode: null, vcode: code);
      default:
        return (google2faCode: null, vcode: null);
    }
  }

  /// 处理确认操作
  Future<void> _handleConfirmAction(BuildContext context, Color confirmColor) async {
    final password = _passwordController.text.trim();
    
    if (_isPasswordSet && (password.isEmpty || password.length < 6)) {
      MessageService.error('请输入密码（至少6位）');
      return;
    }

    final codes = _getVerificationCodes();
    if (codes.google2faCode == null && codes.vcode == null) return;

    setState(() => _isLoading = true);
    
    try {
      final apiCall = _currentAction == 'disable'
          ? _userApi.disableAccount(
              password: password,
              google2faCode: codes.google2faCode,
              vcode: codes.vcode,
            )
          : _userApi.deleteAccount(
              password: password,
              google2faCode: codes.google2faCode,
              vcode: codes.vcode,
            );

      await apiCall;
      // 响应拦截器已处理错误，到这里说明操作成功
      final message = _currentAction == 'disable' ? '账户已禁用' : '账户已删除';
      MessageService.success(message);
      await _navigateToHomeAndClearCache();
    } catch (e) {
      if (mounted) MessageService.error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToHomeAndClearCache() async {
    if (!mounted) return;

    try {
      // 使用统一方法清除所有用户相关数据（包括登录状态、token、设备ID等）
      await _userStore.clearAllUserCache();

      // 然后导航到首页
      final navigator = Navigator.of(context, rootNavigator: true);
      await navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('导航失败: $e');
      }
    }
  }
}
