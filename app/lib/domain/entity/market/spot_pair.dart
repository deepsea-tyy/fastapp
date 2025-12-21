/// 现货交易对实体
class SpotPair {
  /// 交易对符号（如：BTCUSDT）
  final String symbol;

  /// 链名称（如：BNB）
  final String chain;

  /// 基础货币符号
  final String baseCurrencySymbol;

  /// 计价货币符号
  final String quoteCurrencySymbol;

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

  /// 状态（1: 启用, 0: 禁用）
  final int status;

  SpotPair({
    required this.symbol,
    required this.chain,
    required this.baseCurrencySymbol,
    required this.quoteCurrencySymbol,
    required this.pricePrecision,
    required this.quantityPrecision,
    required this.minQuantity,
    required this.minAmount,
    required this.makerFeeRate,
    required this.takerFeeRate,
    required this.status,
  });

  /// 从JSON创建
  factory SpotPair.fromJson(Map<String, dynamic> json) {
    return SpotPair(
      symbol: json['symbol'] as String,
      chain: json['chain'] as String,
      baseCurrencySymbol: json['base_currency_symbol'] as String,
      quoteCurrencySymbol: json['quote_currency_symbol'] as String,
      pricePrecision: (json['price_precision'] ?? 2) as int,
      quantityPrecision: (json['quantity_precision'] ?? 8) as int,
      minQuantity: json['min_quantity']?.toString() ?? '0.00',
      minAmount: json['min_amount']?.toString() ?? '0.00',
      makerFeeRate: json['maker_fee_rate']?.toString() ?? '0.00',
      takerFeeRate: json['taker_fee_rate']?.toString() ?? '0.00',
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
      'price_precision': pricePrecision,
      'quantity_precision': quantityPrecision,
      'min_quantity': minQuantity,
      'min_amount': minAmount,
      'maker_fee_rate': makerFeeRate,
      'taker_fee_rate': takerFeeRate,
      'status': status,
    };
  }

  /// 是否启用
  bool get isEnabled => status == 1;
}
