import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 主题配置类
/// 从 JSON 文件加载主题配置
class ThemeConfig {
  final String id;
  final String name;
  final String seedColor;
  final String? scaffoldBackground;
  final ButtonColors button;
  final TextColors text;
  final BorderColors border;
  final StatusColors status;
  final BackgroundColors background;

  ThemeConfig({
    required this.id,
    required this.name,
    required this.seedColor,
    this.scaffoldBackground,
    required this.button,
    required this.text,
    required this.border,
    required this.status,
    required this.background,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      seedColor: json['seedColor'] as String,
      scaffoldBackground: json['scaffoldBackground'] as String?,
      button: ButtonColors.fromJson(json['button'] as Map<String, dynamic>),
      text: TextColors.fromJson(json['text'] as Map<String, dynamic>),
      border: BorderColors.fromJson(json['border'] as Map<String, dynamic>),
      status: StatusColors.fromJson(json['status'] as Map<String, dynamic>),
      background: BackgroundColors.fromJson(json['background'] as Map<String, dynamic>),
    );
  }
}

/// 按钮颜色配置
class ButtonColors {
  final String background;
  final String foreground;
  final String disabledBackground;
  final String disabledForeground;

  ButtonColors({
    required this.background,
    required this.foreground,
    required this.disabledBackground,
    required this.disabledForeground,
  });

  factory ButtonColors.fromJson(Map<String, dynamic> json) {
    return ButtonColors(
      background: json['background'] as String,
      foreground: json['foreground'] as String,
      disabledBackground: json['disabledBackground'] as String,
      disabledForeground: json['disabledForeground'] as String,
    );
  }
}

/// 文字颜色配置
class TextColors {
  final String primary;
  final String secondary;
  final String hint;
  final String disabled;

  TextColors({
    required this.primary,
    required this.secondary,
    required this.hint,
    required this.disabled,
  });

  factory TextColors.fromJson(Map<String, dynamic> json) {
    return TextColors(
      primary: json['primary'] as String,
      secondary: json['secondary'] as String,
      hint: json['hint'] as String,
      disabled: json['disabled'] as String,
    );
  }
}

/// 边框颜色配置
class BorderColors {
  final String defaultColor;
  final String focused;
  final String error;

  BorderColors({
    required this.defaultColor,
    required this.focused,
    required this.error,
  });

  factory BorderColors.fromJson(Map<String, dynamic> json) {
    return BorderColors(
      defaultColor: json['default'] as String,
      focused: json['focused'] as String,
      error: json['error'] as String,
    );
  }
}

/// 状态颜色配置
class StatusColors {
  final String success;
  final String error;
  final String warning;
  final String info;

  StatusColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  factory StatusColors.fromJson(Map<String, dynamic> json) {
    return StatusColors(
      success: json['success'] as String,
      error: json['error'] as String,
      warning: json['warning'] as String,
      info: json['info'] as String,
    );
  }
}

/// 背景颜色配置
class BackgroundColors {
  final String? scaffold;
  final String? page;
  final String card;
  final String? section;
  final String input;
  final String? dialog;
  final String? bottomSheet;
  final String? elevated;

  BackgroundColors({
    this.scaffold,
    this.page,
    required this.card,
    this.section,
    required this.input,
    this.dialog,
    this.bottomSheet,
    this.elevated,
  });

  factory BackgroundColors.fromJson(Map<String, dynamic> json) {
    return BackgroundColors(
      scaffold: json['scaffold'] as String?,
      page: json['page'] as String?,
      card: json['card'] as String,
      section: json['section'] as String?,
      input: json['input'] as String,
      dialog: json['dialog'] as String?,
      bottomSheet: json['bottomSheet'] as String?,
      elevated: json['elevated'] as String?,
    );
  }
}

/// 主题配置管理器
class ThemeConfigManager {
  ThemeConfigManager._();

  static final Map<String, ThemeConfig> _cache = {};
  static List<String>? _availableThemes;
  static String? _defaultTheme;

  /// 加载主题配置元数据
  static Future<void> loadThemeMetadata() async {
    try {
      final jsonString = await rootBundle.loadString('config/themes/theme_config.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _availableThemes = (json['themes'] as List).cast<String>();
      _defaultTheme = json['default'] as String;
    } catch (e) {
      print('加载主题元数据失败: $e');
      _availableThemes = ['light', 'dark'];
      _defaultTheme = 'light';
    }
  }

  /// 获取可用主题列表
  static List<String> get availableThemes => _availableThemes ?? ['light', 'dark'];

  /// 获取默认主题
  static String get defaultTheme => _defaultTheme ?? 'light';

  /// 加载指定主题配置
  static Future<ThemeConfig> loadTheme(String themeId) async {
    // 如果已缓存，直接返回
    if (_cache.containsKey(themeId)) {
      return _cache[themeId]!;
    }

    try {
      final jsonString = await rootBundle.loadString('config/themes/$themeId.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = ThemeConfig.fromJson(json);
      _cache[themeId] = config;
      return config;
    } catch (e) {
      print('加载主题 $themeId 失败: $e，使用默认主题');
      // 如果加载失败，尝试加载默认主题
      if (themeId != 'light') {
        return loadTheme('light');
      }
      rethrow;
    }
  }

  /// 清除主题缓存
  static void clearCache() {
    _cache.clear();
  }
}
