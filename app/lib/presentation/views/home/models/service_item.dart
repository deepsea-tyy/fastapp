import 'package:flutter/material.dart';

/// 服务项数据模型
class ServiceItem {
  final IconData icon;
  final String label;
  final Function(BuildContext)? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const ServiceItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  /// 创建简单服务项（无点击事件）
  factory ServiceItem.simple({
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    return ServiceItem(
      icon: icon,
      label: label,
      iconColor: iconColor,
    );
  }

  /// 创建可点击服务项
  factory ServiceItem.clickable({
    required IconData icon,
    required String label,
    required Function(BuildContext) onTap,
    Color? iconColor,
  }) {
    return ServiceItem(
      icon: icon,
      label: label,
      onTap: onTap,
      iconColor: iconColor,
    );
  }

  /// 创建导航服务项（跳转到新页面）
  factory ServiceItem.navigable({
    required IconData icon,
    required String label,
    required Widget destination,
    Color? iconColor,
  }) {
    return ServiceItem(
      icon: icon,
      label: label,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      iconColor: iconColor,
    );
  }
}
