/// 标记价格实体
class MarkPrice {
  /// 交易对符号
  final String symbol;
  
  /// 标记价格
  final double price;
  
  /// 指数价格
  final double indexPrice;
  
  /// 更新时间戳
  final int timestamp;

  MarkPrice({
    required this.symbol,
    required this.price,
    required this.indexPrice,
    required this.timestamp,
  });

  /// 从JSON创建
  factory MarkPrice.fromJson(Map<String, dynamic> json) {
    return MarkPrice(
      symbol: json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      indexPrice: (json['indexPrice'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
      'indexPrice': indexPrice,
      'timestamp': timestamp,
    };
  }

  /// 标记价格与指数价格的偏差（百分比）
  double get deviationPercent {
    if (indexPrice == 0) return 0;
    return ((price - indexPrice) / indexPrice) * 100;
  }
}

