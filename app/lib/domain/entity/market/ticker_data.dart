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

  /// 从JSON创建（支持snake_case和camelCase）
  factory TickerData.fromJson(Map<String, dynamic> json) {
    return TickerData(
      symbol: json['symbol'] as String,
      lastPrice: (json['last_price'] ?? json['lastPrice'] ?? 0).toDouble(),
      openPrice: (json['open_price'] ?? json['openPrice'] ?? 0).toDouble(),
      highPrice: (json['high_price'] ?? json['highPrice'] ?? 0).toDouble(),
      lowPrice: (json['low_price'] ?? json['lowPrice'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      changePercent: (json['change_percent'] ?? json['changePercent'] ?? 0).toDouble(),
      changeAmount: (json['change_amount'] ?? json['changeAmount'] ?? 0).toDouble(),
      timestamp: (json['timestamp'] ?? 0) as int,
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

