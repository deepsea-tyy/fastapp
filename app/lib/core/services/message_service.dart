import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import '../data/network/dio/interceptors/response_interceptor.dart';

/// 输入框配置
class InputField {
  final String label;
  final String? hintText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool Function(String)? validator;
  final bool autofocus;
  final InputDecoration? decoration;
  final Widget? customWidget; // 自定义Widget，如果提供则使用此Widget而不是TextField

  InputField({
    required this.label,
    this.hintText,
    this.initialValue,
    this.keyboardType,
    this.maxLength,
    this.validator,
    this.autofocus = false,
    this.decoration,
    this.customWidget,
  });
}

/// 全局消息服务
/// 统一管理所有类型的提示消息（错误、成功、警告、信息、SnackBar、确认对话框）
/// 
/// 使用方式：
/// 1. 通过静态方法调用（推荐）：
///    MessageService.error('错误消息');
///    MessageService.success('成功消息');
///    MessageService.warning('警告消息');
///    MessageService.info('信息消息');
///    MessageService.snackBar('简单提示');
///    MessageService.confirm(
///      title: '确认标题',
///      message: '确认内容',
///      onConfirm: () { /* 确认操作 */ },
///    );
/// 
/// 2. 通过 EventBus 发送事件：
///    eventBus.fire(ErrorMessageEvent(message: '错误消息'));
class MessageService {
  final EventBus _eventBus;
  final List<StreamSubscription> _subscriptions = [];
  BuildContext? _context;
  GlobalKey<NavigatorState>? _navigatorKey;
  
  static MessageService? _instance;
  static OverlayEntry? _overlayEntry;

  // 去重相关
  String? _lastMessage;
  DateTime? _lastMessageTime;
  static const _debounceDuration = Duration(milliseconds: 500);
  
  // 样式常量
  static const _defaultBackgroundColor = Color(0xFF424242);
  static const _defaultTextColor = Colors.white;
  static const _defaultDuration = Duration(seconds: 2);
  static const _snackBarDuration = Duration(seconds: 1);
  static const _animationDuration = Duration(milliseconds: 250);
  static const _maxMessageWidth = 300.0;
  static const _minMessageWidth = 120.0;
  static const _messageMargin = 40.0;
  static const _messagePadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0);
  static const _borderRadius = 10.0;
  
  // 确认对话框样式常量
  static const _confirmDialogMaxWidth = 320.0;
  static const _confirmDialogPadding = EdgeInsets.all(24);
  static const _confirmDialogBorderRadius = 16.0;
  static const _confirmDialogShadowAlpha = 0.15;
  static const _confirmButtonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  static const _confirmButtonBorderRadius = 8.0;
  static const _confirmButtonBackgroundAlpha = 0.1;

  // 输入框样式常量
  static const _inputBorderRadius = 8.0;
  static const _inputContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const _inputFieldSpacing = 20.0;

  MessageService._internal(this._eventBus);

  /// 创建消息服务实例
  factory MessageService(EventBus eventBus) {
    _instance ??= MessageService._internal(eventBus);
    return _instance!;
  }

  /// 获取单例实例（如果已创建）
  static MessageService? get instance => _instance;

  /// 初始化，监听所有消息事件
  void init(BuildContext context, {GlobalKey<NavigatorState>? navigatorKey}) {
    _context = context;
    _navigatorKey = navigatorKey;
    
    if (_subscriptions.isNotEmpty) return;

    // 统一监听所有消息事件
    _subscribeToEvent<ErrorMessageEvent>((e) => _showCenterMessage(e.message, duration: e.duration));
    _subscribeToEvent<SuccessMessageEvent>((e) => _showCenterMessage(e.message, duration: e.duration));
    _subscribeToEvent<WarningMessageEvent>((e) => _showCenterMessage(e.message, duration: e.duration));
    _subscribeToEvent<InfoMessageEvent>((e) => _showCenterMessage(e.message, duration: e.duration));
  }

  /// 统一的事件订阅方法
  void _subscribeToEvent<T extends MessageEvent>(void Function(T) handler) {
    _subscriptions.add(
      _eventBus.on<T>().listen((event) {
        if (event.message.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => handler(event));
        }
      }),
    );
  }

  /// 获取有效的 context
  BuildContext? _getValidContext() {
    return _navigatorKey?.currentContext ?? 
           (_context?.mounted == true ? _context : null);
  }

  /// 检查并更新去重状态
  bool _shouldSkipMessage(String message) {
    final now = DateTime.now();
    if (_lastMessage == message && 
        _lastMessageTime != null && 
        now.difference(_lastMessageTime!) < _debounceDuration) {
      return true;
    }
    _lastMessage = message;
    _lastMessageTime = now;
    return false;
  }

  /// 获取 overlay
  OverlayState? _getOverlay() {
    return _navigatorKey?.currentState?.overlay ?? 
           (_getValidContext() != null ? Overlay.of(_getValidContext()!, rootOverlay: true) : null);
  }

  /// 显示居中消息弹窗
  void _showCenterMessage(String message, {Duration? duration}) {
    if (_shouldSkipMessage(message)) return;

    final overlay = _getOverlay();
    if (overlay == null) {
      _showFallbackSnackBar(message, duration: duration);
      return;
    }

    try {
      _removeCenterMessage();
      _overlayEntry = OverlayEntry(
        builder: (_) => _buildCenterMessage(message),
      );
      overlay.insert(_overlayEntry!);
      
      Future.delayed(duration ?? _defaultDuration, () {
        _removeCenterMessage();
        if (_lastMessage == message) {
          _lastMessage = null;
          _lastMessageTime = null;
        }
      });
    } catch (e) {
      _showFallbackSnackBar(message, duration: duration);
    }
  }

  /// 降级方案：使用 SnackBar 显示消息
  void _showFallbackSnackBar(String message, {Duration? duration}) {
    final context = _getValidContext();
    if (context == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(message, duration: duration),
      );
    } catch (e) {
      // 静默失败
    }
  }

  /// 构建 SnackBar
  SnackBar _buildSnackBar(String message, {Duration? duration, Color? backgroundColor, Color? textColor}) {
    return SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor ?? _defaultTextColor),
      ),
      duration: duration ?? _defaultDuration,
      backgroundColor: backgroundColor ?? _defaultBackgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    );
  }

  /// 构建居中消息 Widget
  Widget _buildCenterMessage(String message) {
    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: _animationDuration,
                curve: Curves.easeOut,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: child,
                  ),
                ),
                child: _buildMessageContainer(message),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建消息容器
  Widget _buildMessageContainer(String message) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: _maxMessageWidth,
        minWidth: _minMessageWidth,
      ),
      margin: const EdgeInsets.symmetric(horizontal: _messageMargin),
      padding: _messagePadding,
      decoration: BoxDecoration(
        color: _defaultBackgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12.0,
            offset: const Offset(0, 4.0),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 15.0,
          color: _defaultTextColor,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 移除居中消息弹窗
  static void _removeCenterMessage() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 显示错误消息
  void showError(String message, {Duration? duration}) => _showCenterMessage(message, duration: duration);

  /// 显示成功消息
  void showSuccess(String message, {Duration? duration}) => _showCenterMessage(message, duration: duration);

  /// 显示警告消息
  void showWarning(String message, {Duration? duration}) => _showCenterMessage(message, duration: duration);

  /// 显示信息消息
  void showInfo(String message, {Duration? duration}) => _showCenterMessage(message, duration: duration);

  /// 显示 SnackBar 风格的提示
  void showSnackBar(String message, {Duration? duration, Color? backgroundColor, Color? textColor}) {
    final context = _getValidContext();
    if (context == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(message, duration: duration ?? _snackBarDuration, backgroundColor: backgroundColor, textColor: textColor),
      );
    } catch (e) {
      // 静默失败
    }
  }

  /// 静态方法：显示错误消息
  static void error(String message, {Duration? duration}) => _instance?.showError(message, duration: duration);

  /// 静态方法：显示成功消息
  static void success(String message, {Duration? duration}) => _instance?.showSuccess(message, duration: duration);

  /// 静态方法：显示警告消息
  static void warning(String message, {Duration? duration}) => _instance?.showWarning(message, duration: duration);

  /// 静态方法：显示信息消息
  static void info(String message, {Duration? duration}) => _instance?.showInfo(message, duration: duration);

  /// 静态方法：显示 SnackBar 提示
  static void snackBar(String message, {Duration? duration, Color? backgroundColor, Color? textColor}) =>
      _instance?.showSnackBar(message, duration: duration, backgroundColor: backgroundColor, textColor: textColor);

  /// 显示确认对话框
  /// [title] 对话框标题
  /// [message] 对话框内容
  /// [confirmText] 确认按钮文本，默认为"确定"
  /// [cancelText] 取消按钮文本，默认为"取消"
  /// [confirmColor] 确认按钮颜色，默认为红色
  /// [onConfirm] 确认回调
  /// [onCancel] 取消回调（可选）
  Future<bool?> showConfirm({
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) async {
    final context = _getValidContext();
    if (context == null) return false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _buildConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor ?? Colors.red,
        onConfirm: () {
          Navigator.of(dialogContext).pop(true);
          onConfirm();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop(false);
          onCancel?.call();
        },
      ),
    );
  }

  /// 构建对话框容器样式
  BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_confirmDialogBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _confirmDialogShadowAlpha),
          blurRadius: 20.0,
          offset: const Offset(0, 8.0),
        ),
      ],
    );
  }

  /// 构建对话框标题
  Widget _buildDialogTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// 构建对话框按钮组
  Widget _buildDialogButtons({
    required String cancelText,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildDialogButton(
          text: cancelText,
          onPressed: onCancel,
          textColor: Colors.black54,
        ),
        const SizedBox(width: 12),
        _buildDialogButton(
          text: confirmText,
          onPressed: onConfirm,
          backgroundColor: confirmColor.withValues(alpha: _confirmButtonBackgroundAlpha),
          textColor: confirmColor,
          isBold: true,
        ),
      ],
    );
  }

  /// 构建确认对话框
  Widget _buildConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required Color confirmColor,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: _confirmDialogMaxWidth),
        padding: _confirmDialogPadding,
        decoration: _buildDialogDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogTitle(title),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildDialogButtons(
              cancelText: cancelText,
              confirmText: confirmText,
              confirmColor: confirmColor,
              onCancel: onCancel,
              onConfirm: onConfirm,
            ),
          ],
        ),
      ),
    );
  }

  /// 获取默认输入框装饰
  InputDecoration _getDefaultInputDecoration(String? hintText) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_inputBorderRadius),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      contentPadding: _inputContentPadding,
      counterText: '',
    );
  }

  /// 构建对话框按钮
  Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    required Color textColor,
    bool isBold = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: _confirmButtonPadding,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_confirmButtonBorderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  /// 静态方法：显示确认对话框
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return _instance?.showConfirm(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmColor: confirmColor,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ) ??
        Future.value(false);
  }


  /// 显示多输入框对话框
  /// [title] 对话框标题
  /// [message] 对话框说明文字（可选）
  /// [fields] 输入框配置列表
  /// [confirmText] 确认按钮文本，默认为"确定"
  /// [cancelText] 取消按钮文本，默认为"取消"
  /// [confirmColor] 确认按钮颜色
  /// [customFieldValues] 自定义Widget的值获取函数，key为field的label
  /// 返回 Map<String, String>，key 为输入框的 label，value 为输入的值
  Future<Map<String, String>?> showInputDialog({
    required String title,
    String? message,
    required List<InputField> fields,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
    Map<String, String Function()>? customFieldValues,
  }) async {
    final context = _getValidContext();
    if (context == null) return null;

    final controllers = fields.map((field) => TextEditingController(text: field.initialValue)).toList();

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _buildInputDialog(
        title: title,
        message: message,
        fields: fields,
        controllers: controllers,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor ?? Theme.of(context).colorScheme.primary,
        customFieldValues: customFieldValues,
        onConfirm: () => _handleInputDialogConfirm(dialogContext, fields, controllers, customFieldValues),
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  /// 处理输入框对话框确认
  void _handleInputDialogConfirm(
    BuildContext dialogContext,
    List<InputField> fields,
    List<TextEditingController> controllers,
    Map<String, String Function()>? customFieldValues,
  ) {
    final values = <String, String>{};
    
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final value = field.customWidget != null && customFieldValues?.containsKey(field.label) == true
          ? customFieldValues![field.label]!()
          : controllers[i].text.trim();

      if (field.validator != null && !field.validator!(value)) return;
      values[field.label] = value;
    }

    Navigator.of(dialogContext).pop(values);
  }

  /// 构建输入框字段
  Widget _buildInputField({
    required InputField field,
    required TextEditingController controller,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : _inputFieldSpacing),
      child: field.customWidget ?? _buildDefaultInputField(field, controller),
    );
  }

  /// 构建默认输入框
  Widget _buildDefaultInputField(InputField field, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: field.keyboardType ?? TextInputType.text,
          maxLength: field.maxLength,
          autofocus: field.autofocus,
          decoration: field.decoration ?? _getDefaultInputDecoration(field.hintText),
        ),
      ],
    );
  }

  /// 构建多输入框对话框
  Widget _buildInputDialog({
    required String title,
    String? message,
    required List<InputField> fields,
    required List<TextEditingController> controllers,
    required String confirmText,
    required String cancelText,
    required Color confirmColor,
    Map<String, String Function()>? customFieldValues,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: _confirmDialogMaxWidth),
        padding: _confirmDialogPadding,
        decoration: _buildDialogDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogTitle(title),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 24),
            ...fields.asMap().entries.map((entry) => _buildInputField(
              field: entry.value,
              controller: controllers[entry.key],
              isLast: entry.key == fields.length - 1,
            )),
            const SizedBox(height: 24),
            _buildDialogButtons(
              cancelText: cancelText,
              confirmText: confirmText,
              confirmColor: confirmColor,
              onCancel: onCancel,
              onConfirm: onConfirm,
            ),
          ],
        ),
      ),
    );
  }

  /// 静态方法：显示多输入框对话框
  static Future<Map<String, String>?> inputDialog({
    required String title,
    String? message,
    required List<InputField> fields,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
    Map<String, String Function()>? customFieldValues,
  }) {
    return _instance?.showInputDialog(
          title: title,
          message: message,
          fields: fields,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmColor: confirmColor,
          customFieldValues: customFieldValues,
        ) ??
        Future.value(null);
  }

  /// 清理资源
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _removeCenterMessage();
    _context = null;
    _navigatorKey = null;
    _lastMessage = null;
    _lastMessageTime = null;
  }
}

