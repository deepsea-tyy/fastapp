import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/domain/entity/user/user.dart';
import 'package:fastapp/presentation/views/common/google_code_input.dart';
import 'package:fastapp/presentation/views/common/verify_code_button.dart';
import 'package:fastapp/presentation/views/common/country_selector.dart';
import 'widgets.dart';

/// 手机号绑定页面
class MobileBindingScreen extends StatefulWidget {
  const MobileBindingScreen({super.key});

  @override
  State<MobileBindingScreen> createState() => _MobileBindingScreenState();
}

class _MobileBindingScreenState extends State<MobileBindingScreen> {
  final UserStore _userStore = getIt<UserStore>();
  final UserApi _userApi = getIt<UserApi>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<CodeInputFieldState> _google2faCodeKey = GlobalKey<CodeInputFieldState>();
  
  bool _isLoading = false;
  bool _showUnbindView = false; // 是否显示解绑验证码输入界面
  final GlobalKey<CodeInputFieldState> _unbindCodeInputKey = GlobalKey<CodeInputFieldState>();
  final GlobalKey<CodeInputFieldState> _unbindGoogle2faCodeKey = GlobalKey<CodeInputFieldState>();
  String _selectedCountryCode = '+86';
  String _selectedCountryFlag = '🇨🇳';

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
      counterText: '',
    );
  }

  // 验证码输入框样式
  static const _codeTextStyle = TextStyle(
    fontSize: 20,
    letterSpacing: 6,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 获取当前用户信息
  dynamic get _currentUser => _userStore.currentUser;

  /// 判断是否已绑定手机号
  bool get _isMobileBound {
    final mobile = _currentUser?.mobile;
    return mobile != null && mobile.isNotEmpty;
  }

  /// 判断是否已设置 Google2FA
  bool get _isGoogle2faEnabled => _currentUser?.isGoogle2fa == 1;

  /// 获取当前绑定的手机号
  String? get _boundMobile => _currentUser?.mobile;

  /// 获取当前绑定的国家代码
  String? get _boundCountryCode {
    final code = _currentUser?.code;
    if (code != null) {
      return '+$code';
    }
    return '+86';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: '手机号绑定'),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_showUnbindView) {
                    return _buildUnbindView(context);
                  }
                  return _isMobileBound 
                      ? _buildBoundView(context) 
                      : _buildUnboundView(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建未绑定状态下的设置界面
  Widget _buildUnboundView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityTip(context),
          const SizedBox(height: _spacingMedium),
          _buildDescriptionText(context),
          const SizedBox(height: _spacingMedium),
          _buildMobileInput(context),
          const SizedBox(height: _spacingMedium),
          _buildVerificationCodeInput(context),
          if (_isGoogle2faEnabled) ...[
            const SizedBox(height: _spacingMedium),
            _buildGoogle2faCodeInput(context),
          ],
          const SizedBox(height: _spacingMedium),
          _buildActionButton(
            text: '绑定手机号',
            onPressed: () => _handleBind(context),
          ),
        ],
      ),
    );
  }

  /// 构建已绑定状态下的界面
  Widget _buildBoundView(BuildContext context) {
    final mobile = _boundMobile ?? '';
    final countryCode = _boundCountryCode ?? '+86';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityTip(context),
          const SizedBox(height: _spacingMedium),
          _buildMobileCard(context, mobile, countryCode),
          const SizedBox(height: _spacingMedium),
          _buildActionButton(
            text: '解绑手机号',
            onPressed: () => _handleUnbind(context),
            isOutlined: true,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  /// 构建解绑验证码输入视图
  Widget _buildUnbindView(BuildContext context) {
    final mobile = _boundMobile ?? '';
    final countryCode = _boundCountryCode ?? '+86';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(_pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提示信息
          Container(
            padding: const EdgeInsets.all(_spacingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '解绑手机号后，您将无法使用该手机号进行登录和安全验证。\n\n请点击下方按钮发送验证码到您的手机 $countryCode $mobile，然后输入手机验证码${_isGoogle2faEnabled ? '和Google验证码' : ''}。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: _spacingLarge),
          // 手机验证码输入框
          SettingCard(
            padding: const EdgeInsets.all(_spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CodeInputField(
                  key: _unbindCodeInputKey,
                  label: '手机验证码',
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入6位验证码';
                    }
                    if (value.length != 6) {
                      return '验证码必须是6位数字';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: _spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '验证码将发送到您的手机',
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
                          onSend: (recipient) async {
                            try {
                              final response = await _userApi.sendSms(
                                mobile: recipient,
                                code: countryCode.replaceFirst('+', ''),
                                scene: 'bind',
                              );
                              MessageService.success(response['message'] ?? '验证码已发送');
                              return true;
                            } catch (e) {
                              return false;
                            }
                          },
                          recipient: mobile,
                          type: VerifyCodeType.sms,
                          scene: 'bind',
                          disabled: _isLoading,
                          minimumSize: const Size(100, 32),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Google2FA验证码输入框（如果需要）
          if (_isGoogle2faEnabled) ...[
            const SizedBox(height: _spacingMedium),
            SettingCard(
              padding: const EdgeInsets.all(_spacingMedium),
              child: CodeInputField(
                key: _unbindGoogle2faCodeKey,
                label: 'Google验证码',
                autofocus: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入6位Google验证码';
                  }
                  if (value.length != 6) {
                    return '验证码必须是6位数字';
                  }
                  return null;
                },
              ),
            ),
          ],
          const SizedBox(height: _spacingLarge),
          // 操作按钮
          _buildActionButton(
            text: '解绑',
            onPressed: () => _handleConfirmUnbind(context),
            isDanger: true,
          ),
          const SizedBox(height: _spacingMedium),
          // 取消按钮
          _buildActionButton(
            text: '取消',
            onPressed: () {
              setState(() {
                _showUnbindView = false;
                _unbindCodeInputKey.currentState?.clear();
                _unbindGoogle2faCodeKey.currentState?.clear();
              });
            },
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  /// 处理确认解绑操作
  Future<void> _handleConfirmUnbind(BuildContext context) async {
    final code = _unbindCodeInputKey.currentState?.value ?? '';
    if (code.isEmpty || code.length != 6) {
      MessageService.error('请输入6位验证码');
      return;
    }

    final google2faCode = _isGoogle2faEnabled
        ? (_unbindGoogle2faCodeKey.currentState?.value ?? '')
        : null;
    
    if (_isGoogle2faEnabled && (google2faCode == null || google2faCode.isEmpty)) {
      MessageService.error('请输入Google验证码');
      return;
    }

    final countryCode = _boundCountryCode ?? '+86';
    
    // 执行解绑操作
    final success = await _performUnbind(
      code: countryCode.replaceFirst('+', ''),
      vcode: code,
      google2faCode: google2faCode,
    );
    
    if (success) {
      setState(() {
        _showUnbindView = false;
        _unbindCodeInputKey.currentState?.clear();
        _unbindGoogle2faCodeKey.currentState?.clear();
      });
    }
  }

  /// 构建说明文字
  Widget _buildDescriptionText(BuildContext context) {
    return Text(
      '绑定手机号可以增强安全设置性，用于接收重要通知和验证码。',
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  /// 构建手机号输入框
  Widget _buildMobileInput(BuildContext context) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
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
          Container(
            width: 1.0,
            height: 24.0,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          Expanded(
            child: TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                hintText: '请输入手机号',
                prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey.shade600),
              ),
              style: const TextStyle(fontSize: 16),
              enabled: !_isLoading,
              onChanged: (_) => setState(() {}), // 更新验证码按钮状态
            ),
          ),
        ],
      ),
    );
  }

  /// 构建验证码输入框
  Widget _buildVerificationCodeInput(BuildContext context) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: _buildInputDecoration(hintText: '请输入验证码'),
            style: _codeTextStyle,
            textAlign: TextAlign.center,
            enabled: !_isLoading,
          ),
          const SizedBox(height: _spacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '验证码将发送到您的手机',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              VerifyCodeButton(
                onSend: (mobile) => _sendVerificationCode(mobile),
                recipient: _mobileController.text,
                type: VerifyCodeType.sms,
                scene: 'bind',
                disabled: _isLoading,
              ),
            ],
          ),
        ],
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
            : (_validateCodeForForm(value, label: 'Google验证码') ? null : '请输入Google验证码'),
      ),
    );
  }

  /// 构建手机号卡片
  Widget _buildMobileCard(BuildContext context, String mobile, String countryCode) {
    return SettingCard(
      padding: const EdgeInsets.all(_spacingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.phone,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: _spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '已绑定手机号',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '$countryCode $mobile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: _spacingSmall, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '已绑定',
              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool isDanger = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonStyle = _buildButtonStyle(colorScheme, isOutlined: isOutlined, isDanger: isDanger);
    
    final button = isOutlined
        ? OutlinedButton(
            style: buttonStyle,
            onPressed: _isLoading ? null : onPressed,
            child: _buildButtonChild(text, isDanger: isDanger),
          )
        : ElevatedButton(
            style: buttonStyle,
            onPressed: _isLoading ? null : onPressed,
            child: _buildButtonChild(text, isDanger: isDanger),
          );

    return SizedBox(width: double.infinity, child: button);
  }

  /// 构建按钮样式
  ButtonStyle _buildButtonStyle(ColorScheme colorScheme, {required bool isOutlined, required bool isDanger}) {
    final baseStyle = ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 14)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );

    if (isOutlined) {
      final dangerColor = Colors.red.shade600;
      final primaryColor = colorScheme.primary;
      return baseStyle.copyWith(
        foregroundColor: WidgetStatePropertyAll(isDanger ? dangerColor : primaryColor),
        side: WidgetStatePropertyAll(BorderSide(
          color: isDanger ? Colors.red.shade400 : primaryColor.withOpacity(0.5),
          width: 1.5,
        )),
        backgroundColor: WidgetStatePropertyAll(
          isDanger ? Colors.red.shade50.withOpacity(0.1) : colorScheme.primaryContainer.withOpacity(0.1),
        ),
        elevation: const WidgetStatePropertyAll(0),
      );
    }
    
    return baseStyle.copyWith(
      backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
      foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
      elevation: const WidgetStatePropertyAll(2),
      shadowColor: WidgetStatePropertyAll(colorScheme.primary.withOpacity(0.3)),
    );
  }

  /// 构建按钮子组件
  Widget _buildButtonChild(String text, {bool isDanger = false}) {
    if (_isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDanger ? Colors.red.shade600 : Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }

  /// 构建安全提示
  Widget _buildSecurityTip(BuildContext context) {
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
                  '绑定手机号后，您可以使用手机号接收验证码进行登录和安全验证。请确保手机号正确且可以正常接收短信。',
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

  /// 发送验证码
  Future<bool> _sendVerificationCode(String mobile) async {
    if (!_validateMobile(mobile)) return false;

    try {
      final response = await _userApi.sendSms(
        mobile: mobile,
        code: _selectedCountryCode.replaceFirst('+', ''),
        scene: 'bind',
      );
      MessageService.success(response['message'] ?? '验证码已发送');
      return true;
    } catch (e) {
      // 响应拦截器已通过 EventBus 发送错误消息
      return false;
    }
  }

  /// 验证手机号并显示错误
  bool _validateMobile(String mobile) {
    if (mobile.isEmpty) {
      MessageService.error('请输入手机号');
      return false;
    }
    return true;
  }

  /// 验证验证码格式
  bool _validateCode(String code, {String label = '验证码'}) {
    if (code.isEmpty) {
      MessageService.error('请输入$label');
      return false;
    }
    return true;
  }

  /// 验证验证码格式（返回错误消息，用于FormField validator）
  bool _validateCodeForForm(String code, {String label = '验证码'}) {
    return code.isNotEmpty;
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

  /// 处理绑定操作
  Future<void> _handleBind(BuildContext context) async {
    final mobile = _mobileController.text.trim();
    final code = _codeController.text.trim();
    
    if (!_validateMobile(mobile) || !_validateCode(code)) return;

    // 如果启用了 Google2FA，获取 Google 验证码
    String? google2faCode;
    if (_isGoogle2faEnabled) {
      google2faCode = _google2faCodeKey.currentState?.value ?? '';
      if (google2faCode.isEmpty) {
        MessageService.error('请输入Google验证码');
        return;
      }
    }

    // 直接执行绑定操作
    await _performBind(
      mobile: mobile,
      code: _selectedCountryCode.replaceFirst('+', ''),
      vcode: code,
      google2faCode: google2faCode,
    );
  }

  /// 执行绑定操作
  Future<void> _performBind({
    required String mobile,
    required String code,
    required String vcode,
    String? google2faCode,
  }) async {
    await _executeWithLoading(() async {
      final response = await _userApi.bindMobile(
        mobile: mobile,
        code: code,
        vcode: vcode,
        google2faCode: google2faCode,
      );
      
      await _handleApiResponse(
        response,
        successMessage: '手机号绑定成功',
        errorMessage: '手机号绑定失败',
        onSuccess: () {
          _mobileController.clear();
          _codeController.clear();
          // 清空 Google 验证码输入框
          if (_isGoogle2faEnabled) {
            _google2faCodeKey.currentState?.clear();
          }
        },
      );
    });
  }

  /// 处理解绑操作
  void _handleUnbind(BuildContext context) {
    final mobile = _boundMobile ?? '';
    final countryCode = _boundCountryCode ?? '+86';
    if (mobile.isEmpty) {
      MessageService.error('未绑定手机号');
      return;
    }

    // 切换显示验证码输入界面
    setState(() {
      _showUnbindView = true;
      _unbindCodeInputKey.currentState?.clear();
      _unbindGoogle2faCodeKey.currentState?.clear();
    });
  }

  /// 发送解绑验证码
  Future<bool> _sendUnbindCode(String mobile, String countryCode) async {
    setState(() => _isLoading = true);
    try {
      final response = await _userApi.sendSms(
        mobile: mobile,
        code: countryCode.replaceFirst('+', ''),
        scene: 'bind',
      );
      MessageService.success(response['message'] ?? '验证码已发送');
      return true;
    } catch (e) {
      // 响应拦截器已通过 EventBus 发送错误消息
      return false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 执行解绑操作
  Future<bool> _performUnbind({
    required String code,
    required String vcode,
    String? google2faCode,
  }) async {
    bool success = false;
    await _executeWithLoading(() async {
      final response = await _userApi.unbindMobile(
        code: code,
        vcode: vcode,
        google2faCode: google2faCode,
      );
      
      success = await _handleApiResponse(
        response,
        successMessage: '手机号解绑成功',
        errorMessage: '手机号解绑失败',
        shouldClearMobile: true, // 解绑成功后清空手机号字段
      );
    });
    return success;
  }

  /// 处理API响应
  Future<bool> _handleApiResponse(
    Map<String, dynamic> response, {
    required String successMessage,
    required String errorMessage,
    VoidCallback? onSuccess,
    bool shouldClearMobile = false, // 是否需要在成功后清空手机号字段
  }) async {
    // 响应拦截器已处理错误，到这里说明操作成功
    // 先显示成功消息
    MessageService.success(successMessage);
    // 执行成功回调
    onSuccess?.call();
    // 刷新用户信息并等待完成，确保界面切换
    try {
      await _userStore.getUserInfo();
      // 如果解绑操作，确保手机号字段被清空
      if (shouldClearMobile && _userStore.currentUser?.mobile != null) {
        _clearUserMobile();
      }
    } catch (e) {
      // 静默处理错误，避免影响用户体验
      if (kDebugMode) {
        print('刷新用户信息失败: $e');
      }
      // 即使刷新失败，如果是解绑操作，也要清空手机号字段
      if (shouldClearMobile) {
        _clearUserMobile();
      }
    }
    return true;
  }

  /// 清空用户手机号字段
  void _clearUserMobile() {
    final currentUser = _userStore.currentUser;
    if (currentUser != null && currentUser.mobile != null) {
      // 创建一个新的 User 对象，手机号字段设置为 null
      final updatedUser = User(
        id: currentUser.id,
        username: currentUser.username,
        mobile: null, // 清空手机号
        email: currentUser.email,
        code: currentUser.code,
        isGoogle2fa: currentUser.isGoogle2fa,
        isTransPassword: currentUser.isTransPassword,
        no: currentUser.no,
        profile: currentUser.profile,
      );
      // 使用 runInAction 确保 MobX 的响应式更新
      runInAction(() {
        _userStore.currentUser = updatedUser;
      });
    }
  }

  /// 显示解绑确认和验证码输入对话框
  Future<Map<String, String?>?> _showUnbindConfirmDialog(
    BuildContext context, {
    required String mobile,
    required String countryCode,
    required bool needGoogle2fa,
  }) async {
    final google2faKey = needGoogle2fa ? GlobalKey<CodeInputFieldState>() : null;
    final customFieldValues = needGoogle2fa
        ? <String, String Function()>{
            'Google验证码': () => google2faKey!.currentState?.value ?? '',
          }
        : null;

    final fields = <InputField>[
      InputField(
        label: '手机验证码',
        hintText: '请输入手机验证码',
        keyboardType: TextInputType.number,
        maxLength: 6,
        autofocus: true,
        validator: (value) => _validateCodeForForm(value, label: '手机验证码'),
        decoration: _buildInputDecoration(
          hintText: '请输入手机验证码',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      if (needGoogle2fa) InputField(
        label: 'Google验证码',
        customWidget: CodeInputField(
          key: google2faKey!,
          label: 'Google验证码',
          autofocus: false,
          validator: (value) => value == null || value.isEmpty
              ? '请输入Google验证码'
              : (_validateCodeForForm(value, label: 'Google验证码') ? null : '请输入Google验证码'),
        ),
      ),
    ];

    final result = await MessageService.inputDialog(
      title: '确认解绑',
      message: '解绑手机号后，您将无法使用该手机号进行登录和安全验证。\n\n'
          '验证码已发送到您的手机 $countryCode $mobile，'
          '${needGoogle2fa ? '请输入手机验证码和Google验证码' : '请输入手机验证码'}',
      confirmText: '解绑',
      confirmColor: Colors.red,
      customFieldValues: customFieldValues,
      fields: fields,
    );

    if (result == null) return null;

    return {
      'mobileCode': result['手机验证码'],
      if (needGoogle2fa) 'google2faCode': result['Google验证码'],
    };
  }
}
