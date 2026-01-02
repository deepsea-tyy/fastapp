/// K线数据实体
class KlineData {
  /// 时间戳（毫秒）
  final int timestamp;
  
  /// 开盘价
  final double open;
  
  /// 最高价
  final double high;
  
  /// 最低价
  final double low;
  
  /// 收盘价
  final double close;
  
  /// 成交量
  final double volume;
  
  /// 成交额
  final double amount;

  KlineData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.amount,
  });

  /// 从JSON创建
  factory KlineData.fromJson(Map<String, dynamic> json) {
    return KlineData(
      timestamp: json['timestamp'] as int,
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'amount': amount,
    };
  }
}

