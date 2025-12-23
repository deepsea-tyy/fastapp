import 'package:flutter/material.dart';

/// 图标映射工具类
/// 用于将 Web 端的图标名称映射到 Flutter 的 Material Icons
class IconMapper {
  // Web 图标名称到 Flutter IconData 的映射
  static final Map<String, IconData> _iconMap = {
    'material-symbols:local-fire-department': Icons.local_fire_department,
    'material-symbols:search': Icons.search,
    'material-symbols:history': Icons.history,
    'material-symbols:star': Icons.star,
    'material-symbols:trending-up': Icons.trending_up,
    'material-symbols:location-on': Icons.location_on,
    'material-symbols:label': Icons.label,
    'material-symbols:flash-on': Icons.flash_on,
    'material-symbols:new-releases': Icons.new_releases,
    'material-symbols:recommend': Icons.recommend,
  };

  // 颜色映射
  static final Map<String, Color> _colorMap = {
    'material-symbols:local-fire-department': const Color(0xFFFF6B35),
    'material-symbols:search': const Color(0xFF666666),
    'material-symbols:history': const Color(0xFF999999),
    'material-symbols:star': const Color(0xFFFFD700),
    'material-symbols:trending-up': const Color(0xFF4CAF50),
    'material-symbols:location-on': const Color(0xFF2196F3),
    'material-symbols:label': const Color(0xFF9C27B0),
    'material-symbols:flash-on': const Color(0xFFFFC107),
    'material-symbols:new-releases': const Color(0xFFE91E63),
    'material-symbols:recommend': const Color(0xFF00BCD4),
  };

  /// 根据 Web 图标名称获取 Flutter IconData
  ///
  /// [webIconName] Web 端的图标名称，如 'material-symbols:local-fire-department'
  /// 返回对应的 IconData，如果找不到则返回默认图标
  static IconData getIcon(String? webIconName) {
    if (webIconName == null || webIconName.isEmpty) {
      return Icons.search; // 默认图标
    }
    return _iconMap[webIconName] ?? Icons.search;
  }

  /// 根据 Web 图标名称获取颜色
  ///
  /// [webIconName] Web 端的图标名称
  /// 返回对应的颜色，如果找不到则返回灰色
  static Color getColor(String? webIconName) {
    if (webIconName == null || webIconName.isEmpty) {
      return Colors.grey;
    }
    return _colorMap[webIconName] ?? Colors.grey;
  }

  /// 创建带颜色的图标 Widget
  ///
  /// [webIconName] Web 端的图标名称
  /// [size] 图标大小，默认 24
  /// [color] 自定义颜色，如果为 null 则使用默认配置的颜色
  static Widget buildIcon(
    String? webIconName, {
    double size = 24,
    Color? color,
  }) {
    final icon = getIcon(webIconName);
    final iconColor = color ?? getColor(webIconName);

    return Icon(
      icon,
      size: size,
      color: iconColor,
    );
  }

  /// 检查图标是否存在
  static bool hasIcon(String? webIconName) {
    if (webIconName == null || webIconName.isEmpty) return false;
    return _iconMap.containsKey(webIconName);
  }
}
