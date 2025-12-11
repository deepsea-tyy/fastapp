import 'dart:async';
import 'package:flutter/material.dart';

/// 验证码类型
enum VerifyCodeType {
  email, // 邮箱验证码
  sms,   // 短信验证码
}

/// 统一的验证码发送按钮组件
/// 
/// 该组件封装了验证码发送按钮的通用功能，包括：
/// - 倒计时功能
/// - 发送状态管理
/// - 统一的UI样式
/// 
/// 使用示例：
/// ```dart
/// VerifyCodeButton(
///   onSend: (String recipient) async {
///     // 发送验证码的逻辑
///     await userApi.sendEmailCode(email: recipient, scene: 'login');
///   },
///   recipient: emailController.text,
///   type: VerifyCodeType.email,
///   scene: 'login',
/// )
/// ```
class VerifyCodeButton extends StatefulWidget {
  /// 发送验证码的回调函数
  /// [recipient] 接收验证码的地址（邮箱或手机号）
  /// 返回 Future<bool>，true表示发送成功，false表示发送失败
  final Future<bool> Function(String recipient) onSend;

  /// 接收验证码的地址（邮箱或手机号）
  final String recipient;

  /// 验证码类型
  final VerifyCodeType type;

  /// 验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)
  final String scene;

  /// 倒计时时长（秒），默认60秒
  final int countdownSeconds;

  /// 是否禁用按钮（外部控制）
  final bool disabled;

  /// 按钮样式
  final ButtonStyle? style;

  /// 按钮文本样式
  final TextStyle? textStyle;

  /// 按钮内边距
  final EdgeInsetsGeometry? padding;

  /// 最小尺寸
  final Size? minimumSize;

  /// 点击目标大小
  final MaterialTapTargetSize? tapTargetSize;

  const VerifyCodeButton({
    super.key,
    required this.onSend,
    required this.recipient,
    required this.type,
    this.scene = 'login',
    this.countdownSeconds = 60,
    this.disabled = false,
    this.style,
    this.textStyle,
    this.padding,
    this.minimumSize,
    this.tapTargetSize,
  });

  @override
  State<VerifyCodeButton> createState() => _VerifyCodeButtonState();
}

class _VerifyCodeButtonState extends State<VerifyCodeButton> {
  int _countdown = 0;
  bool _isLoading = false;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _handleSend() async {
    final recipient = widget.recipient.trim();
    if (recipient.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await widget.onSend(recipient);
      if (success && mounted) {
        _startCountdown();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    _countdown = widget.countdownSeconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  /// 获取按钮文本
  String _getButtonText() {
    if (_countdown > 0) {
      return '${_countdown}秒后重发';
    }
    return widget.type == VerifyCodeType.email ? '发送验证码' : '获取验证码';
  }

  /// 是否禁用按钮
  bool get _isDisabled {
    return widget.disabled || 
           _isLoading || 
           _countdown > 0 || 
           widget.recipient.trim().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultTextStyle = widget.textStyle ?? TextStyle(
      fontSize: 12,
      color: _isDisabled
          ? Colors.grey
          : colorScheme.primary,
    );

    final defaultStyle = widget.style ?? TextButton.styleFrom(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      minimumSize: widget.minimumSize ?? Size.zero,
      tapTargetSize: widget.tapTargetSize ?? MaterialTapTargetSize.shrinkWrap,
    );

    return TextButton(
      onPressed: _isDisabled ? null : _handleSend,
      style: defaultStyle,
      child: _isLoading
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isDisabled ? Colors.grey : colorScheme.primary,
                ),
              ),
            )
          : Text(
              _getButtonText(),
              style: defaultTextStyle,
            ),
    );
  }
}
