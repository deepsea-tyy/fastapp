import 'package:flutter/material.dart';

/// 服务页面常量配置
class ServiceConstants {
  // 颜色
  static final primaryColor = Colors.amber.shade700;
  static final backgroundColor = Colors.white;
  static final searchBarColor = Colors.grey.shade100;
  static final iconBackgroundColor = Colors.grey.shade50;
  static final textPrimary = Colors.black87;
  static final textSecondary = Colors.grey.shade600;
  static const hintColor = Colors.grey;

  // 尺寸
  static const double searchBarHeight = 40.0;
  static const double iconSize = 32.0;
  static const double iconContainerSize = 56.0;
  static const double iconBorderRadius = 12.0;
  static const double searchBorderRadius = 8.0;
  static const double gridSpacing = 16.0;
  static const double gridAspectRatio = 0.85;
  static const int gridCrossAxisCount = 4;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;
  static const double paddingXXLarge = 32.0;

  // 字体大小
  static const double fontSizeSmall = 13.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;

  // 文本样式
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle sectionTitleBoldStyle = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle itemLabelStyle = TextStyle(
    fontSize: fontSizeSmall,
    color: Colors.black87,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle emptyStateStyle = TextStyle(
    fontSize: fontSizeMedium,
    color: Colors.grey,
  );

  static const TextStyle hintTextStyle = TextStyle(
    color: hintColor,
    fontSize: fontSizeMedium,
  );

  // Tab标签
  static const List<String> tabLabels = [
    '常用功能',
    '活动和奖励',
    '交易',
    '理财',
    '金融业务',
    '资讯',
  ];
}
