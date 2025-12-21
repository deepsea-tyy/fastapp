/// 合约交易对实体
class FuturesPair {
  /// 交易对符号（如：BTCUSDT）
  final String symbol;

  /// 链名称（如：BNB）
  final String chain;

  /// 基础货币符号
  final String baseCurrencySymbol;

  /// 计价货币符号
  final String quoteCurrencySymbol;

  /// 结算货币符号
  final String settlementCurrencySymbol;

  /// 价格精度
  final int pricePrecision;

  /// 数量精度
  final int quantityPrecision;

  /// 最小交易数量
  final String minQuantity;

  /// 最小交易金额
  final String minAmount;

  /// Maker 手续费率
  final String makerFeeRate;

  /// Taker 手续费率
  final String takerFeeRate;

  /// 是否启用杠杆
  final int leverageEnabled;

  /// 最大杠杆倍数
  final String? maxLeverage;

  /// 合约乘数
  final String contractMultiplier;

  /// 状态（1: 启用, 0: 禁用）
  final int status;

  FuturesPair({
    required this.symbol,
    required this.chain,
    required this.baseCurrencySymbol,
    required this.quoteCurrencySymbol,
    required this.settlementCurrencySymbol,
    required this.pricePrecision,
    required this.quantityPrecision,
    required this.minQuantity,
    required this.minAmount,
    required this.makerFeeRate,
    required this.takerFeeRate,
    required this.leverageEnabled,
    this.maxLeverage,
    required this.contractMultiplier,
    required this.status,
  });

  /// 从JSON创建
  factory FuturesPair.fromJson(Map<String, dynamic> json) {
    return FuturesPair(
      symbol: json['symbol'] as String,
      chain: json['chain'] as String,
      baseCurrencySymbol: json['base_currency_symbol'] as String,
      quoteCurrencySymbol: json['quote_currency_symbol'] as String,
      settlementCurrencySymbol: json['settlement_currency_symbol'] as String,
      pricePrecision: (json['price_precision'] ?? 2) as int,
      quantityPrecision: (json['quantity_precision'] ?? 8) as int,
      minQuantity: json['min_quantity']?.toString() ?? '0.00',
      minAmount: json['min_amount']?.toString() ?? '0.00',
      makerFeeRate: json['maker_fee_rate']?.toString() ?? '0.00',
      takerFeeRate: json['taker_fee_rate']?.toString() ?? '0.00',
      leverageEnabled: (json['leverage_enabled'] ?? 0) as int,
      maxLeverage: json['max_leverage']?.toString(),
      contractMultiplier: json['contract_multiplier']?.toString() ?? '1.00',
      status: (json['status'] ?? 1) as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'chain': chain,
      'base_currency_symbol': baseCurrencySymbol,
      'quote_currency_symbol': quoteCurrencySymbol,
      'settlement_currency_symbol': settlementCurrencySymbol,
      'price_precision': pricePrecision,
      'quantity_precision': quantityPrecision,
      'min_quantity': minQuantity,
      'min_amount': minAmount,
      'maker_fee_rate': makerFeeRate,
      'taker_fee_rate': takerFeeRate,
      'leverage_enabled': leverageEnabled,
      'max_leverage': maxLeverage,
      'contract_multiplier': contractMultiplier,
      'status': status,
    };
  }

  /// 是否启用
  bool get isEnabled => status == 1;

  /// 是否启用杠杆
  bool get isLeverageEnabled => leverageEnabled == 1;
}
