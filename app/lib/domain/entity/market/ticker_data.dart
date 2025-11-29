/// Ticker数据实体（24小时行情）
class TickerData {
  /// 交易对符号
  final String symbol;
  
  /// 最新价格
  final double lastPrice;
  
  /// 24小时开盘价
  final double openPrice;
  
  /// 24小时最高价
  final double highPrice;
  
  /// 24小时最低价
  final double lowPrice;
  
  /// 24小时成交量
  final double volume;
  
  /// 24小时成交额
  final double amount;
  
  /// 24小时涨跌幅（百分比）
  final double changePercent;
  
  /// 24小时涨跌额
  final double changeAmount;
  
  /// 更新时间戳
  final int timestamp;

  TickerData({
    required this.symbol,
    required this.lastPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.amount,
    required this.changePercent,
    required this.changeAmount,
    required this.timestamp,
  });

  /// 从JSON创建
  factory TickerData.fromJson(Map<String, dynamic> json) {
    return TickerData(
      symbol: json['symbol'] as String,
      lastPrice: (json['lastPrice'] as num).toDouble(),
      openPrice: (json['openPrice'] as num).toDouble(),
      highPrice: (json['highPrice'] as num).toDouble(),
      lowPrice: (json['lowPrice'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      changeAmount: (json['changeAmount'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'lastPrice': lastPrice,
      'openPrice': openPrice,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'volume': volume,
      'amount': amount,
      'changePercent': changePercent,
      'changeAmount': changeAmount,
      'timestamp': timestamp,
    };
  }
}

