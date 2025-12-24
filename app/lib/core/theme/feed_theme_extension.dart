import 'package:flutter/material.dart';
import 'package:fastapp/constants/app_theme.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:get_it/get_it.dart';

/// Feed 主题扩展
///
/// 提供便捷方法访问 Feed 相关的主题颜色
extension FeedThemeExtension on BuildContext {
  /// 获取 Feed 颜色配置
  FeedThemeColors get feedTheme {
    final themeStore = GetIt.instance<ThemeStore>();
    final themeConfig = AppTheme.getConfig(themeStore.currentTheme);
    return FeedThemeColors.fromConfig(themeConfig.feed);
  }
}

/// Feed 主题颜色
class FeedThemeColors {
  final Color cardBackground;
  final Color userNameText;
  final Color timeText;
  final Color contentText;
  final Color titleText;
  final Color linkText;
  final Color menuIcon;
  final Color actionIconActive;
  final Color actionIconDefault;
  final Color actionTextActive;
  final Color actionTextDefault;

  const FeedThemeColors({
    required this.cardBackground,
    required this.userNameText,
    required this.timeText,
    required this.contentText,
    required this.titleText,
    required this.linkText,
    required this.menuIcon,
    required this.actionIconActive,
    required this.actionIconDefault,
    required this.actionTextActive,
    required this.actionTextDefault,
  });

  /// 从配置创建
  factory FeedThemeColors.fromConfig(dynamic feedConfig) {
    return FeedThemeColors(
      cardBackground: _hexToColor(feedConfig.cardBackground),
      userNameText: _hexToColor(feedConfig.userNameText),
      timeText: _hexToColor(feedConfig.timeText),
      contentText: _hexToColor(feedConfig.contentText),
      titleText: _hexToColor(feedConfig.titleText),
      linkText: _hexToColor(feedConfig.linkText),
      menuIcon: _hexToColor(feedConfig.menuIcon),
      actionIconActive: _hexToColor(feedConfig.actionIconActive),
      actionIconDefault: _hexToColor(feedConfig.actionIconDefault),
      actionTextActive: _hexToColor(feedConfig.actionTextActive),
      actionTextDefault: _hexToColor(feedConfig.actionTextDefault),
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
