/// 交易类型枚举
enum TradeType {
  /// 现货交易
  spot,
  /// 杠杆交易
  leverage,
}

/// 交易类型扩展
extension TradeTypeExtension on TradeType {
  /// 是否是杠杆交易
  bool get isLeverage => this == TradeType.leverage;

  /// 是否是现货交易
  bool get isSpot => this == TradeType.spot;

  /// 获取持仓标签文字
  String get positionTabLabel => switch (this) {
    TradeType.spot => '持有币种',
    TradeType.leverage => '仓位',
  };

  /// 获取买入按钮前缀
  String get buyButtonPrefix => switch (this) {
    TradeType.spot => '买入',
    TradeType.leverage => '杠杆买入',
  };

  /// 获取卖出按钮前缀
  String get sellButtonPrefix => switch (this) {
    TradeType.spot => '卖出',
    TradeType.leverage => '杠杆卖出',
  };

  /// 获取价格输入标签
  String get priceInputLabel => switch (this) {
    TradeType.spot => '价格',
    TradeType.leverage => '委托价',
  };
}
