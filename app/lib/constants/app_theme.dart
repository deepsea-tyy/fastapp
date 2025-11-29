import 'package:flutter/material.dart';
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

  // 主题缓存，避免重复创建
  static final Map<AppThemeType, ThemeData> _themeCache = {};

  /// 获取指定主题的 ThemeData（带缓存）
  static ThemeData getTheme(AppThemeType themeType) {
    return _themeCache.putIfAbsent(
      themeType,
      () => _buildTheme(themeType),
    );
  }

  /// 构建主题配置
  static ThemeData _buildTheme(AppThemeType themeType) {
    final brightness = themeType.brightness;
    
    // 将 hex 颜色字符串转换为 Color
    final seedColor = _hexToColor(AppConfig.seedColor);
    final borderRadius = AppConfig.defaultBorderRadius;
    
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
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

  /// 清除主题缓存（用于动态更新主题时）
  static void clearCache() {
    _themeCache.clear();
  }
}

