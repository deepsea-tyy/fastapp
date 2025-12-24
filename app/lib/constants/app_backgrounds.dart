import 'package:flutter/material.dart';
import 'package:fastapp/constants/theme_config.dart';
import 'package:fastapp/constants/app_theme.dart';

/// 应用背景色辅助类
/// 提供便捷的方法访问主题配置中的背景色
class AppBackgrounds {
  AppBackgrounds._();

  /// 从 BuildContext 获取背景色（推荐）
  static AppBackgroundColors of(BuildContext context) {
    return AppBackgroundColors.fromTheme(Theme.of(context));
  }

  /// 从主题类型获取背景色
  static AppBackgroundColors fromThemeType(AppThemeType themeType) {
    final config = AppTheme.getConfig(themeType);
    return fromConfig(config);
  }

  /// 从主题配置获取背景色
  static AppBackgroundColors fromConfig(ThemeConfig config) {
    return AppBackgroundColors._(
      scaffold: _parseColor(config.background.scaffold) ??
                _parseColor(config.scaffoldBackground),
      page: _parseColor(config.background.page),
      card: _parseColor(config.background.card)!,
      section: _parseColor(config.background.section),
      input: _parseColor(config.background.input)!,
      dialog: _parseColor(config.background.dialog),
      bottomSheet: _parseColor(config.background.bottomSheet),
      elevated: _parseColor(config.background.elevated),
    );
  }

  static Color? _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// 背景色集合类
class AppBackgroundColors {
  /// Scaffold 背景色（应用级，最底层）
  final Color? scaffold;

  /// 页面背景色（页面容器）
  final Color? page;

  /// 卡片背景色（Card, Container）
  final Color card;

  /// 分区背景色（Section, Panel）
  final Color? section;

  /// 输入框背景色（TextField）
  final Color input;

  /// 对话框背景色（Dialog, AlertDialog）
  final Color? dialog;

  /// 底部弹窗背景色（BottomSheet）
  final Color? bottomSheet;

  /// 悬浮背景色（Elevated elements）
  final Color? elevated;

  const AppBackgroundColors._({
    this.scaffold,
    this.page,
    required this.card,
    this.section,
    required this.input,
    this.dialog,
    this.bottomSheet,
    this.elevated,
  });

  /// 从 ThemeData 创建
  factory AppBackgroundColors.fromTheme(ThemeData theme) {
    return AppBackgroundColors._(
      scaffold: theme.scaffoldBackgroundColor,
      page: theme.colorScheme.surface,
      card: theme.cardTheme.color ?? theme.colorScheme.surface,
      section: theme.colorScheme.surfaceContainerHighest,
      input: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceContainerHighest,
      dialog: theme.dialogBackgroundColor,
      bottomSheet: theme.bottomSheetTheme.backgroundColor,
      elevated: theme.colorScheme.surfaceContainerHigh,
    );
  }

  /// 获取页面背景色（如果未定义则使用 scaffold）
  Color getPageBackground(BuildContext context) {
    return page ?? scaffold ?? Theme.of(context).scaffoldBackgroundColor!;
  }

  /// 获取分区背景色（如果未定义则使用 page）
  Color getSectionBackground(BuildContext context) {
    return section ?? page ?? scaffold ?? Theme.of(context).scaffoldBackgroundColor!;
  }

  /// 获取对话框背景色（如果未定义则使用 card）
  Color getDialogBackground() {
    return dialog ?? card;
  }

  /// 获取底部弹窗背景色（如果未定义则使用 card）
  Color getBottomSheetBackground() {
    return bottomSheet ?? card;
  }

  /// 获取悬浮元素背景色（如果未定义则使用 card）
  Color getElevatedBackground() {
    return elevated ?? card;
  }
}
