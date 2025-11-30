import 'package:flutter/material.dart';

enum MessageType {
  error,
  success,
  warning,
  info,
}

class CenterMessageDialog {
  static OverlayEntry? _overlayEntry;

  // 默认样式配置
  static Color _getBackgroundColor(MessageType type) {
    switch (type) {
      case MessageType.error:
      case MessageType.success:
      case MessageType.warning:
      case MessageType.info:
        return const Color(0xFF424242);
    }
  }

  static Color _getTextColor(MessageType type) {
    return Colors.white;
  }

  static void show({
    required BuildContext context,
    required String message,
    MessageType type = MessageType.info,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    _remove();

    final bgColor = backgroundColor ?? _getBackgroundColor(type);
    final txtColor = textColor ?? _getTextColor(type);

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildMessage(
        message: message,
        backgroundColor: bgColor,
        textColor: txtColor,
      ),
    );

    overlay.insert(_overlayEntry!);
    Future.delayed(duration, _remove);
  }

  static Widget _buildMessage({
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, value, child) {
            return Opacity(opacity: value, child: child);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.0,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  static void _remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 便捷方法
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context: context, message: message, type: MessageType.error, duration: duration);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context: context, message: message, type: MessageType.success, duration: duration);
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context: context, message: message, type: MessageType.warning, duration: duration);
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context: context, message: message, type: MessageType.info, duration: duration);
  }
}
