/// 资金费率实体
class FundingRate {
  /// 交易对符号
  final String symbol;
  
  /// 资金费率（百分比）
  final double rate;
  
  /// 下次结算时间戳
  final int nextFundingTime;
  
  /// 更新时间戳
  final int timestamp;

  FundingRate({
    required this.symbol,
    required this.rate,
    required this.nextFundingTime,
    required this.timestamp,
  });

  /// 从JSON创建
  factory FundingRate.fromJson(Map<String, dynamic> json) {
    return FundingRate(
      symbol: json['symbol'] as String,
      rate: (json['rate'] as num).toDouble(),
      nextFundingTime: json['nextFundingTime'] as int,
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'rate': rate,
      'nextFundingTime': nextFundingTime,
      'timestamp': timestamp,
    };
  }

  /// 是否为正费率（多头支付空头）
  bool get isPositive => rate > 0;

  /// 是否为负费率（空头支付多头）
  bool get isNegative => rate < 0;
}

