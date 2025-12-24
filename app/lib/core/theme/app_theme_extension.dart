import 'package:flutter/material.dart';
import 'package:fastapp/constants/app_theme.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:get_it/get_it.dart';

/// 应用主题扩展
///
/// 提供便捷方法访问主题颜色配置
extension AppThemeExtension on BuildContext {
  /// 获取空状态颜色配置
  EmptyStateThemeColors get emptyStateTheme {
    final themeStore = GetIt.instance<ThemeStore>();
    final themeConfig = AppTheme.getConfig(themeStore.currentTheme);
    return EmptyStateThemeColors.fromConfig(themeConfig.emptyState);
  }

  /// 获取底部导航颜色配置
  BottomNavThemeColors get bottomNavTheme {
    final themeStore = GetIt.instance<ThemeStore>();
    final themeConfig = AppTheme.getConfig(themeStore.currentTheme);
    return BottomNavThemeColors.fromConfig(themeConfig.bottomNav);
  }

  /// 获取背景颜色配置
  BackgroundThemeColors get backgroundTheme {
    final themeStore = GetIt.instance<ThemeStore>();
    final themeConfig = AppTheme.getConfig(themeStore.currentTheme);
    return BackgroundThemeColors.fromConfig(themeConfig.background);
  }

  /// 获取文本颜色配置
  TextThemeColors get textTheme {
    final themeStore = GetIt.instance<ThemeStore>();
    final themeConfig = AppTheme.getConfig(themeStore.currentTheme);
    return TextThemeColors.fromConfig(themeConfig.text);
  }
}

/// 空状态主题颜色
class EmptyStateThemeColors {
  final Color icon;
  final Color titleText;
  final Color descriptionText;
  final Color buttonBackground;
  final Color buttonForeground;

  const EmptyStateThemeColors({
    required this.icon,
    required this.titleText,
    required this.descriptionText,
    required this.buttonBackground,
    required this.buttonForeground,
  });

  /// 从配置创建
  factory EmptyStateThemeColors.fromConfig(dynamic config) {
    return EmptyStateThemeColors(
      icon: _hexToColor(config.icon),
      titleText: _hexToColor(config.titleText),
      descriptionText: _hexToColor(config.descriptionText),
      buttonBackground: _hexToColor(config.buttonBackground),
      buttonForeground: _hexToColor(config.buttonForeground),
    );
  }

  /// 将 hex 颜色字符串转换为 Color
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// 底部导航主题颜色
class BottomNavThemeColors {
  final Color background;
  final Color selectedItem;
  final Color unselectedItem;

  const BottomNavThemeColors({
    required this.background,
    required this.selectedItem,
    required this.unselectedItem,
  });

  /// 从配置创建
  factory BottomNavThemeColors.fromConfig(dynamic config) {
    return BottomNavThemeColors(
      background: _hexToColor(config.background),
      selectedItem: _hexToColor(config.selectedItem),
      unselectedItem: _hexToColor(config.unselectedItem),
    );
  }

  /// 将 hex 颜色字符串转换为 Color
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// 背景主题颜色
class BackgroundThemeColors {
  final Color? scaffold;
  final Color? page;
  final Color card;
  final Color? section;
  final Color input;
  final Color? dialog;
  final Color? bottomSheet;
  final Color? elevated;

  const BackgroundThemeColors({
    this.scaffold,
    this.page,
    required this.card,
    this.section,
    required this.input,
    this.dialog,
    this.bottomSheet,
    this.elevated,
  });

  /// 从配置创建
  factory BackgroundThemeColors.fromConfig(dynamic config) {
    return BackgroundThemeColors(
      scaffold: config.scaffold != null ? _hexToColor(config.scaffold!) : null,
      page: config.page != null ? _hexToColor(config.page!) : null,
      card: _hexToColor(config.card),
      section: config.section != null ? _hexToColor(config.section!) : null,
      input: _hexToColor(config.input),
      dialog: config.dialog != null ? _hexToColor(config.dialog!) : null,
      bottomSheet: config.bottomSheet != null ? _hexToColor(config.bottomSheet!) : null,
      elevated: config.elevated != null ? _hexToColor(config.elevated!) : null,
    );
  }

  /// 将 hex 颜色字符串转换为 Color
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// 文本主题颜色
class TextThemeColors {
  final Color primary;
  final Color secondary;
  final Color hint;
  final Color disabled;

  const TextThemeColors({
    required this.primary,
    required this.secondary,
    required this.hint,
    required this.disabled,
  });

  /// 从配置创建
  factory TextThemeColors.fromConfig(dynamic config) {
    return TextThemeColors(
      primary: _hexToColor(config.primary),
      secondary: _hexToColor(config.secondary),
      hint: _hexToColor(config.hint),
      disabled: _hexToColor(config.disabled),
    );
  }

  /// 将 hex 颜色字符串转换为 Color
  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
