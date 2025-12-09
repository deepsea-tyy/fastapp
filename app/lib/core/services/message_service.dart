import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import '../data/network/dio/interceptors/response_interceptor.dart';

/// 全局消息服务
/// 统一管理所有类型的提示消息（错误、成功、警告、信息、SnackBar）
/// 
/// 使用方式：
/// 1. 通过静态方法调用（推荐）：
///    MessageService.error('错误消息');
///    MessageService.success('成功消息');
///    MessageService.warning('警告消息');
///    MessageService.info('信息消息');
///    MessageService.snackBar('简单提示');
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
  void showError(String message, {Duration? duration}) {
    _showCenterMessage(message, duration: duration);
  }

  /// 显示成功消息
  void showSuccess(String message, {Duration? duration}) {
    _showCenterMessage(message, duration: duration);
  }

  /// 显示警告消息
  void showWarning(String message, {Duration? duration}) {
    _showCenterMessage(message, duration: duration);
  }

  /// 显示信息消息
  void showInfo(String message, {Duration? duration}) {
    _showCenterMessage(message, duration: duration);
  }

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
  static void error(String message, {Duration? duration}) {
    _instance?.showError(message, duration: duration);
  }

  /// 静态方法：显示成功消息
  static void success(String message, {Duration? duration}) {
    _instance?.showSuccess(message, duration: duration);
  }

  /// 静态方法：显示警告消息
  static void warning(String message, {Duration? duration}) {
    _instance?.showWarning(message, duration: duration);
  }

  /// 静态方法：显示信息消息
  static void info(String message, {Duration? duration}) {
    _instance?.showInfo(message, duration: duration);
  }

  /// 静态方法：显示 SnackBar 提示
  static void snackBar(String message, {Duration? duration, Color? backgroundColor, Color? textColor}) {
    _instance?.showSnackBar(message, duration: duration, backgroundColor: backgroundColor, textColor: textColor);
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

