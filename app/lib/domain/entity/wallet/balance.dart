class Balance {
  final String symbol;
  final double available;
  final double frozen;
  final double total;
  final String? name;
  final String? logoUrl;
  final double? profit;  // 今日盈亏
  final double? profitRate;  // 今日盈亏率
  final double? avgPrice;  // 平均买入价

  Balance({
    required this.symbol,
    required this.available,
    required this.frozen,
    required this.total,
    this.name,
    this.logoUrl,
    this.profit,
    this.profitRate,
    this.avgPrice,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      symbol: json['symbol'] as String,
      available: double.parse(json['available'].toString()),
      frozen: double.parse(json['frozen'].toString()),
      total: double.parse(json['total'].toString()),
      name: json['name'] as String?,
      logoUrl: json['logoUrl'] as String?,
      profit: json['profit'] != null ? double.parse(json['profit'].toString()) : null,
      profitRate: json['profitRate'] != null ? double.parse(json['profitRate'].toString()) : null,
      avgPrice: json['avgPrice'] != null ? double.parse(json['avgPrice'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'available': available,
        'frozen': frozen,
        'total': total,
        'name': name,
        'logoUrl': logoUrl,
        'profit': profit,
        'profitRate': profitRate,
        'avgPrice': avgPrice,
      };

  @Deprecated('使用 symbol 替代')
  String get currency => symbol;
}

