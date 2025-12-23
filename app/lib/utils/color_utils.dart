import 'package:flutter/material.dart';

/// 颜色工具类
/// 用于处理颜色字符串的转换
class ColorUtils {
  /// 将十六进制颜色字符串转换为 Color 对象
  ///
  /// 支持以下格式：
  /// - #RGB (例如：#F00)
  /// - #RRGGBB (例如：#FF0000)
  /// - #AARRGGBB (例如：#80FF0000)
  /// - 0xRRGGBB
  /// - 0xAARRGGBB
  ///
  /// [hexString] 十六进制颜色字符串
  /// 返回对应的 Color 对象，如果解析失败则返回 null
  static Color? fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return null;
    }

    String colorString = hexString.trim();

    // 移除 # 前缀
    if (colorString.startsWith('#')) {
      colorString = colorString.substring(1);
    }

    // 移除 0x 前缀
    if (colorString.toLowerCase().startsWith('0x')) {
      colorString = colorString.substring(2);
    }

    try {
      // 处理 #RGB 格式 (例如：#F00 -> #FF0000)
      if (colorString.length == 3) {
        colorString = colorString.split('').map((c) => c + c).join();
      }

      // 处理 #RRGGBB 格式，添加完全不透明的 alpha 值
      if (colorString.length == 6) {
        colorString = 'FF$colorString';
      }

      // 处理 #AARRGGBB 格式
      if (colorString.length == 8) {
        final int value = int.parse(colorString, radix: 16);
        return Color(value);
      }

      return null;
    } catch (e) {
      // 解析失败，返回 null
      return null;
    }
  }

  /// 将 Color 对象转换为十六进制字符串
  ///
  /// [color] Color 对象
  /// [includeAlpha] 是否包含 alpha 通道，默认为 false
  /// [prefix] 前缀，默认为 '#'
  /// 返回十六进制颜色字符串
  static String toHex(
    Color color, {
    bool includeAlpha = false,
    String prefix = '#',
  }) {
    if (includeAlpha) {
      return '$prefix${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    } else {
      // 只返回 RGB 部分
      final rgb = color.value & 0xFFFFFF;
      return '$prefix${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
    }
  }

  /// 批量解析颜色字符串
  ///
  /// [hexStrings] 十六进制颜色字符串列表
  /// 返回 Color 对象列表（失败的会被跳过）
  static List<Color> fromHexList(List<String> hexStrings) {
    return hexStrings
        .map((hex) => fromHex(hex))
        .where((color) => color != null)
        .cast<Color>()
        .toList();
  }
}
