/// 杠杆设置实体
class Leverage {
  /// 交易对符号
  final String symbol;
  
  /// 杠杆倍数
  final int leverage;
  
  /// 最大杠杆倍数
  final int maxLeverage;
  
  /// 最小杠杆倍数
  final int minLeverage;
  
  /// 更新时间戳
  final int timestamp;

  Leverage({
    required this.symbol,
    required this.leverage,
    required this.maxLeverage,
    required this.minLeverage,
    required this.timestamp,
  });

  /// 从JSON创建
  factory Leverage.fromJson(Map<String, dynamic> json) {
    return Leverage(
      symbol: json['symbol'] as String,
      leverage: json['leverage'] as int,
      maxLeverage: json['maxLeverage'] as int,
      minLeverage: json['minLeverage'] as int,
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'leverage': leverage,
      'maxLeverage': maxLeverage,
      'minLeverage': minLeverage,
      'timestamp': timestamp,
    };
  }

  /// 验证杠杆是否在有效范围内
  bool isValid() {
    return leverage >= minLeverage && leverage <= maxLeverage;
  }
}

