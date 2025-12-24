import 'package:flutter/material.dart';
import 'package:fastapp/constants/theme_config.dart';
import 'package:fastapp/constants/themes/light_theme.dart';
import 'package:fastapp/constants/themes/dark_theme.dart';
import 'package:fastapp/constants/app_config.dart';

/// 主题类型枚举
enum AppThemeType {
  /// 亮色主题
  light,

  /// 暗色主题
  dark;

  /// 获取主题名称
  String get name {
    switch (this) {
      case AppThemeType.light:
        return '亮色';
      case AppThemeType.dark:
        return '暗色';
    }
  }

  /// 获取主题ID（用于加载JSON配置）
  String get themeId {
    switch (this) {
      case AppThemeType.light:
        return 'light';
      case AppThemeType.dark:
        return 'dark';
    }
  }

  /// 获取对应的亮度
  Brightness get brightness {
    switch (this) {
      case AppThemeType.light:
        return Brightness.light;
      case AppThemeType.dark:
        return Brightness.dark;
    }
  }

  /// 切换主题（在亮色和暗色之间）
  AppThemeType toggle() {
    return this == AppThemeType.dark ? AppThemeType.light : AppThemeType.dark;
  }
}

/// 主题配置提供者
class AppTheme {
  AppTheme._();

  /// 主题配置映射
  static const _themeConfigs = {
    'light': lightTheme,
    'dark': darkTheme,
  };

  /// 获取指定主题的配置
  static ThemeConfig getConfig(AppThemeType themeType) {
    return _themeConfigs[themeType.themeId]!;
  }

  /// 获取指定主题的 ThemeData
  static ThemeData getTheme(AppThemeType themeType) {
    final config = getConfig(themeType);
    return _buildThemeFromConfig(config, themeType.brightness);
  }

  /// 构建主题配置（从 ThemeConfig）
  static ThemeData _buildThemeFromConfig(ThemeConfig config, Brightness brightness) {
    final seedColor = _hexToColor(config.seedColor);
    final scaffoldBgColor = config.background.scaffold != null && config.background.scaffold!.isNotEmpty
        ? _hexToColor(config.background.scaffold!)
        : (config.scaffoldBackground != null && config.scaffoldBackground!.isNotEmpty
            ? _hexToColor(config.scaffoldBackground!)
            : null);
    final borderRadius = AppConfig.defaultBorderRadius;

    // 按钮颜色
    final buttonBgColor = _hexToColor(config.button.background);
    final buttonFgColor = _hexToColor(config.button.foreground);
    final buttonDisabledBgColor = _hexToColor(config.button.disabledBackground);
    final buttonDisabledFgColor = _hexToColor(config.button.disabledForeground);

    // 文字颜色
    final primaryTextColor = _hexToColor(config.text.primary);
    final secondaryTextColor = _hexToColor(config.text.secondary);
    final hintTextColor = _hexToColor(config.text.hint);

    // 边框颜色
    final borderColor = _hexToColor(config.border.defaultColor);
    final focusedBorderColor = _hexToColor(config.border.focused);
    final errorBorderColor = _hexToColor(config.border.error);

    // 背景颜色
    final cardBgColor = _hexToColor(config.background.card);
    final inputBgColor = _hexToColor(config.background.input);
    final dialogBgColor = config.background.dialog != null
        ? _hexToColor(config.background.dialog!)
        : cardBgColor;
    final bottomSheetBgColor = config.background.bottomSheet != null
        ? _hexToColor(config.background.bottomSheet!)
        : cardBgColor;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: scaffoldBgColor,
      dialogBackgroundColor: dialogBgColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bottomSheetBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius * 2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBgColor,
        hintStyle: TextStyle(color: hintTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorBorderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonBgColor,
          foregroundColor: buttonFgColor,
          disabledBackgroundColor: buttonDisabledBgColor,
          disabledForegroundColor: buttonDisabledFgColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: primaryTextColor),
        bodyMedium: TextStyle(color: primaryTextColor),
        bodySmall: TextStyle(color: secondaryTextColor),
      ),
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
