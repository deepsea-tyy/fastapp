import 'package:flutter/material.dart';

/// 图标映射工具类
///
/// 用于将 Web 端的图标名称映射到 Flutter 的 Material Icons
/// 与 Web 端配置文件 search-keyword-icon.ts 保持同步
///
/// 支持的图标列表：
/// - material-symbols:local-fire-department: 火焰图标(热门)
/// - material-symbols:search: 搜索图标
/// - material-symbols:history: 时钟图标(历史)
/// - material-symbols:star: 星标图标(收藏)
/// - material-symbols:trending-up: 趋势图标(上升)
/// - material-symbols:location-on: 位置图标(附近)
/// - material-symbols:label: 标签图标
/// - material-symbols:flash-on: 闪电图标(快速)
/// - material-symbols:new-releases: 新品图标
/// - material-symbols:recommend: 推荐图标
class IconMapper {
  IconMapper._(); // 私有构造函数，防止实例化

  // Web 图标名称到 Flutter IconData 的映射
  // 与 web/src/modules/search/dictionary/search-keyword-icon.ts 保持同步
  static final Map<String, IconData> _iconMap = {
    'material-symbols:local-fire-department': Icons.local_fire_department, // 火焰图标(热门)
    'material-symbols:search': Icons.search,                               // 搜索图标
    'material-symbols:history': Icons.history,                             // 时钟图标(历史)
    'material-symbols:star': Icons.star,                                   // 星标图标(收藏)
    'material-symbols:trending-up': Icons.trending_up,                     // 趋势图标(上升)
    'material-symbols:location-on': Icons.location_on,                     // 位置图标(附近)
    'material-symbols:label': Icons.label,                                 // 标签图标
    'material-symbols:flash-on': Icons.flash_on,                           // 闪电图标(快速)
    'material-symbols:new-releases': Icons.new_releases,                   // 新品图标
    'material-symbols:recommend': Icons.recommend,                         // 推荐图标
  };

  // 颜色映射
  // 与 web/src/modules/search/dictionary/search-keyword-icon.ts 保持同步
  static final Map<String, Color> _colorMap = {
    'material-symbols:local-fire-department': const Color(0xFFFF6B35), // #FF6B35
    'material-symbols:search': const Color(0xFF666666),                // #666666
    'material-symbols:history': const Color(0xFF999999),               // #999999
    'material-symbols:star': const Color(0xFFFFD700),                  // #FFD700
    'material-symbols:trending-up': const Color(0xFF4CAF50),           // #4CAF50
    'material-symbols:location-on': const Color(0xFF2196F3),           // #2196F3
    'material-symbols:label': const Color(0xFF9C27B0),                 // #9C27B0
    'material-symbols:flash-on': const Color(0xFFFFC107),              // #FFC107
    'material-symbols:new-releases': const Color(0xFFE91E63),          // #E91E63
    'material-symbols:recommend': const Color(0xFF00BCD4),             // #00BCD4
  };

  // 图标标签映射（用于调试和显示）
  static final Map<String, String> _labelMap = {
    'material-symbols:local-fire-department': '火焰图标(热门)',
    'material-symbols:search': '搜索图标',
    'material-symbols:history': '时钟图标(历史)',
    'material-symbols:star': '星标图标(收藏)',
    'material-symbols:trending-up': '趋势图标(上升)',
    'material-symbols:location-on': '位置图标(附近)',
    'material-symbols:label': '标签图标',
    'material-symbols:flash-on': '闪电图标(快速)',
    'material-symbols:new-releases': '新品图标',
    'material-symbols:recommend': '推荐图标',
  };

  /// 根据 Web 图标名称获取 Flutter IconData
  ///
  /// [webIconName] Web 端的图标名称，如 'material-symbols:local-fire-department'
  /// 返回对应的 IconData，如果找不到则返回默认图标
  ///
  /// Example:
  /// ```dart
  /// final icon = IconMapper.getIcon('material-symbols:star');
  /// Icon(icon, size: 24);
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// final color = IconMapper.getColor('material-symbols:star');
  /// Icon(Icons.star, color: color);
  /// ```
  static Color getColor(String? webIconName) {
    if (webIconName == null || webIconName.isEmpty) {
      return Colors.grey;
    }
    return _colorMap[webIconName] ?? Colors.grey;
  }

  /// 根据 Web 图标名称获取标签
  ///
  /// [webIconName] Web 端的图标名称
  /// 返回对应的中文标签，如果找不到则返回 '未知图标'
  ///
  /// Example:
  /// ```dart
  /// final label = IconMapper.getLabel('material-symbols:star');
  /// print(label); // 输出: 星标图标(收藏)
  /// ```
  static String getLabel(String? webIconName) {
    if (webIconName == null || webIconName.isEmpty) {
      return '未知图标';
    }
    return _labelMap[webIconName] ?? '未知图标';
  }

  /// 创建带颜色的图标 Widget
  ///
  /// [webIconName] Web 端的图标名称
  /// [size] 图标大小，默认 24
  /// [color] 自定义颜色，如果为 null 则使用默认配置的颜色
  ///
  /// Example:
  /// ```dart
  /// IconMapper.buildIcon(
  ///   'material-symbols:star',
  ///   size: 32,
  ///   color: Colors.amber,
  /// );
  /// ```
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
  ///
  /// [webIconName] Web 端的图标名称
  /// 返回 true 如果图标存在，否则返回 false
  ///
  /// Example:
  /// ```dart
  /// if (IconMapper.hasIcon('material-symbols:star')) {
  ///   // 使用图标
  /// }
  /// ```
  static bool hasIcon(String? webIconName) {
    if (webIconName == null || webIconName.isEmpty) return false;
    return _iconMap.containsKey(webIconName);
  }

  /// 获取所有支持的图标列表
  ///
  /// 返回一个包含所有图标名称的列表
  ///
  /// Example:
  /// ```dart
  /// final icons = IconMapper.getAllIcons();
  /// for (var iconName in icons) {
  ///   print(iconName);
  /// }
  /// ```
  static List<String> getAllIcons() {
    return _iconMap.keys.toList();
  }

  /// 获取图标配置信息
  ///
  /// [webIconName] Web 端的图标名称
  /// 返回包含图标、颜色和标签的 Map
  ///
  /// Example:
  /// ```dart
  /// final config = IconMapper.getIconConfig('material-symbols:star');
  /// print(config['label']); // 星标图标(收藏)
  /// ```
  static Map<String, dynamic> getIconConfig(String? webIconName) {
    return {
      'name': webIconName,
      'icon': getIcon(webIconName),
      'color': getColor(webIconName),
      'label': getLabel(webIconName),
      'exists': hasIcon(webIconName),
    };
  }

  /// 解析颜色字符串
  ///
  /// [colorString] 颜色字符串，支持 '#RRGGBB' 和 '#AARRGGBB' 格式
  /// 返回 Color 对象，如果解析失败则返回 null
  ///
  /// Example:
  /// ```dart
  /// final color = IconMapper.parseColor('#FF6B35');
  /// final colorWithAlpha = IconMapper.parseColor('#80FF6B35');
  /// ```
  static Color? parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return null;
    }

    try {
      // 移除 # 符号（如果存在）
      String hexColor = colorString.replaceAll('#', '');

      // 如果是 6 位颜色代码，添加 FF 作为透明度
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      // 解析为整数并创建颜色
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
