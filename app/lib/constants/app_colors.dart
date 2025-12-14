import 'package:flutter/material.dart';

/// 应用颜色常量
/// 统一管理应用中使用的颜色，便于维护和主题切换
class AppColors {
  AppColors._();

  // ==================== 按钮颜色 ====================

  /// 主要按钮颜色（深灰色，参考登录页面）
  static const Color primaryButtonColor = Color(0xFF424242); // Colors.grey[800]

  /// 主要按钮文字颜色
  static const Color primaryButtonTextColor = Colors.white;

  /// 次要按钮颜色
  static const Color secondaryButtonColor = Color(0xFFEEEEEE); // Colors.grey[200]

  /// 次要按钮文字颜色
  static const Color secondaryButtonTextColor = Color(0xFF212121);

  /// 禁用按钮颜色
  static const Color disabledButtonColor = Color(0xFFBDBDBD); // Colors.grey[400]

  /// 禁用按钮文字颜色
  static const Color disabledButtonTextColor = Color(0x80FFFFFF); // Colors.white70

  // ==================== 状态颜色 ====================

  /// 成功/涨幅颜色（绿色）
  static const Color successColor = Color(0xFF4CAF50);

  /// 错误/跌幅颜色（红色）
  static const Color errorColor = Color(0xFFF44336);

  /// 警告颜色（橙色）
  static const Color warningColor = Color(0xFFFF9800);

  /// 信息颜色（蓝色）
  static const Color infoColor = Color(0xFF2196F3);

  // ==================== 背景颜色 ====================

  /// 主背景色（白色，light 主题）
  static const Color backgroundLight = Colors.white;

  /// 卡片背景色
  static const Color cardBackground = Colors.white;

  /// 输入框背景色（浅灰）
  static const Color inputBackground = Color(0xFFF5F5F5);

  // ==================== 文字颜色 ====================

  /// 主要文字颜色
  static const Color primaryText = Color(0xFF212121);

  /// 次要文字颜色
  static const Color secondaryText = Color(0xFF757575);

  /// 禁用文字颜色
  static const Color disabledText = Color(0xFFBDBDBD);

  /// 提示文字颜色
  static const Color hintText = Color(0xFF9E9E9E);

  // ==================== 边框颜色 ====================

  /// 默认边框颜色
  static const Color borderColor = Color(0xFFE0E0E0);

  /// 聚焦边框颜色
  static const Color focusedBorderColor = Color(0xFF2196F3);

  /// 错误边框颜色
  static const Color errorBorderColor = Color(0xFFF44336);

  // ==================== 分隔线颜色 ====================

  /// 分隔线颜色
  static const Color dividerColor = Color(0xFFE0E0E0);

  // ==================== 渐变色 ====================

  /// 主要渐变（示例）
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF616161)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
