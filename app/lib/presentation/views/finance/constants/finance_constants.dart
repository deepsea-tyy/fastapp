import 'package:flutter/material.dart';

/// 理财模块常量配置
class FinanceConstants {
  // 颜色
  static final primaryColor = Colors.amber.shade600;
  static final primaryColorLight = Colors.amber.shade50;
  static final primaryColorDark = Colors.amber.shade700;
  static final textPrimary = Colors.black87;
  static final textSecondary = Colors.grey.shade600;
  static final textTertiary = Colors.grey.shade400;
  static final borderColor = Colors.grey.shade200;
  static final backgroundColor = Colors.white;
  static final successColor = Colors.teal.shade400;
  static final errorColor = Colors.red.shade400;
  static final positiveColor = Colors.green.shade400;

  // 加密货币颜色
  static const Color colorUSDT = Color(0xFF26A17B);
  static const Color colorBTC = Color(0xFFF7931A);
  static const Color colorETH = Color(0xFF627EEA);
  static const Color colorBNB = Color(0xFFF0B90B);
  static const Color colorSOL = Color(0xFF9945FF);
  static const Color colorTRX = Color(0xFFFF0013);
  static const Color colorUSDC = Color(0xFF2775CA);

  // 尺寸
  static const double borderRadiusSmall = 6.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double iconSizeSmall = 14.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;

  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 13.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeRegular = 15.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeading = 20.0;
  static const double fontSizeDisplay = 24.0;

  // 文本样式
  static TextStyle get titleStyle => const TextStyle(
        fontSize: fontSizeTitle,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );

  static TextStyle get headingStyle => const TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      );

  static TextStyle secondaryStyle(Color? color) => TextStyle(
        fontSize: fontSizeNormal,
        color: color ?? textSecondary,
      );

  static TextStyle rateStyle(Color? color) => TextStyle(
        fontSize: fontSizeRegular,
        fontWeight: FontWeight.w600,
        color: color ?? textPrimary,
      );
}
