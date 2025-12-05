/// 交易详情页面工具函数
class DetailUtils {
  /// 格式化价格
  static String formatPrice(double price) {
    try {
      if (price.isNaN || price.isInfinite) {
        return '0.00';
      }

      if (price >= 1000) {
        final parts = price.toStringAsFixed(2).split('.');
        final integerPart = parts.isNotEmpty ? parts[0] : '0';
        final decimalPart = parts.length > 1 ? parts[1] : '';
        final formattedInteger = addThousandSeparator(integerPart);
        return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
      } else if (price >= 1) {
        return price.toStringAsFixed(2);
      } else if (price >= 0.01) {
        return price.toStringAsFixed(4);
      } else {
        return price.toStringAsFixed(6);
      }
    } catch (e) {
      return '0.00';
    }
  }

  /// 格式化成交量
  static String formatVolume(double volume) {
    try {
      if (volume.isNaN || volume.isInfinite) {
        return '0';
      }

      if (volume >= 100000000) {
        return (volume / 100000000).toStringAsFixed(2);
      } else if (volume >= 10000) {
        return (volume / 10000).toStringAsFixed(2);
      } else {
        return volume.toStringAsFixed(2);
      }
    } catch (e) {
      return '0';
    }
  }

  /// 添加千分位分隔符
  static String addThousandSeparator(String number) {
    if (number.isEmpty) {
      return '0';
    }

    try {
      final reversed = number.split('').reversed.join();
      final chunks = <String>[];

      for (int i = 0; i < reversed.length; i += 3) {
        final end = (i + 3 > reversed.length) ? reversed.length : i + 3;
        chunks.add(reversed.substring(i, end));
      }

      return chunks.join(',').split('').reversed.join();
    } catch (e) {
      return number;
    }
  }
}
