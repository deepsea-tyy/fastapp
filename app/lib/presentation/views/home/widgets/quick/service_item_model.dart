import 'package:flutter/material.dart';

/// 统一的应用服务项数据模型
/// 同时用于服务中心和快捷入口
class AppServiceItem {
  /// 唯一标识符
  final String id;

  /// 图标
  final IconData icon;

  /// 标签名称
  final String label;

  /// 点击回调
  final Function(BuildContext)? onTap;

  /// 图标颜色
  final Color? iconColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 装饰颜色（用于快捷入口）
  final Color? decorationColor;

  /// 装饰位置（用于快捷入口）
  final Alignment? decorationPosition;

  /// 装饰大小（用于快捷入口）
  final double? decorationSize;

  /// 装饰类型（用于快捷入口：dot/rays/plus/grid）
  final String? decorationType;

  /// 是否可以添加到快捷入口
  final bool canBeQuickEntrance;

  const AppServiceItem({
    required this.id,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.decorationColor,
    this.decorationPosition,
    this.decorationSize,
    this.decorationType,
    this.canBeQuickEntrance = true,
  });

  /// 创建简单服务项（无点击事件）
  factory AppServiceItem.simple({
    required String id,
    required IconData icon,
    required String label,
    Color? iconColor,
    bool canBeQuickEntrance = true,
  }) {
    return AppServiceItem(
      id: id,
      icon: icon,
      label: label,
      iconColor: iconColor,
      canBeQuickEntrance: canBeQuickEntrance,
    );
  }

  /// 创建导航服务项（跳转到新页面）
  factory AppServiceItem.navigable({
    required String id,
    required IconData icon,
    required String label,
    required Widget destination,
    Color? iconColor,
    bool canBeQuickEntrance = true,
  }) {
    return AppServiceItem(
      id: id,
      icon: icon,
      label: label,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      iconColor: iconColor,
      canBeQuickEntrance: canBeQuickEntrance,
    );
  }

  /// 创建命名路由服务项
  factory AppServiceItem.route({
    required String id,
    required IconData icon,
    required String label,
    required String routeName,
    Color? iconColor,
    bool canBeQuickEntrance = true,
  }) {
    return AppServiceItem(
      id: id,
      icon: icon,
      label: label,
      onTap: (context) {
        Navigator.of(context).pushNamed(routeName);
      },
      iconColor: iconColor,
      canBeQuickEntrance: canBeQuickEntrance,
    );
  }

  /// 复制并修改装饰属性（用于快捷入口）
  AppServiceItem withDecoration({
    Color? decorationColor,
    Alignment? decorationPosition,
    double? decorationSize,
    String? decorationType,
  }) {
    return AppServiceItem(
      id: id,
      icon: icon,
      label: label,
      onTap: onTap,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      decorationColor: decorationColor ?? this.decorationColor,
      decorationPosition: decorationPosition ?? this.decorationPosition,
      decorationSize: decorationSize ?? this.decorationSize,
      decorationType: decorationType ?? this.decorationType,
      canBeQuickEntrance: canBeQuickEntrance,
    );
  }
}

