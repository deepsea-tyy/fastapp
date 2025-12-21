/// 交易对实体
class MarketPair {
  /// 交易对符号（如：BTC/USDT）
  final String symbol;
  
  /// 基础货币（如：BTC）
  final String baseCurrency;
  
  /// 计价货币（如：USDT）
  final String quoteCurrency;
  
  /// 交易对名称
  final String name;
  
  /// 价格精度（小数位数）
  final int pricePrecision;
  
  /// 数量精度（小数位数）
  final int quantityPrecision;
  
  /// 最小交易数量
  final double minQuantity;
  
  /// 最小交易金额
  final double minAmount;
  
  /// 是否启用
  final bool enabled;
  
  /// 交易对图标URL
  final String? logoUrl;

  MarketPair({
    required this.symbol,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.name,
    required this.pricePrecision,
    required this.quantityPrecision,
    required this.minQuantity,
    required this.minAmount,
    required this.enabled,
    this.logoUrl,
  });

  /// 从JSON创建（支持snake_case和camelCase）
  factory MarketPair.fromJson(Map<String, dynamic> json) {
    return MarketPair(
      symbol: json['symbol'] as String,
      baseCurrency: (json['base_currency'] ?? json['baseCurrency']) as String,
      quoteCurrency: (json['quote_currency'] ?? json['quoteCurrency']) as String,
      name: json['name'] as String? ?? json['symbol'] as String,
      pricePrecision: (json['price_precision'] ?? json['pricePrecision'] ?? 2) as int,
      quantityPrecision: (json['quantity_precision'] ?? json['quantityPrecision'] ?? 8) as int,
      minQuantity: (json['min_quantity'] ?? json['minQuantity'] ?? 0).toDouble(),
      minAmount: (json['min_amount'] ?? json['minAmount'] ?? 0).toDouble(),
      enabled: (json['enabled'] ?? json['status'] == 1) as bool? ?? true,
      logoUrl: json['logo_url'] as String? ?? json['logoUrl'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'baseCurrency': baseCurrency,
      'quoteCurrency': quoteCurrency,
      'name': name,
      'pricePrecision': pricePrecision,
      'quantityPrecision': quantityPrecision,
      'minQuantity': minQuantity,
      'minAmount': minAmount,
      'enabled': enabled,
      'logoUrl': logoUrl,
    };
  }
}

