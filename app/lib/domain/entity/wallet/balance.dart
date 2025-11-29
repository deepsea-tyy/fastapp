/// 余额实体
class Balance {
  /// 币种符号
  final String currency;
  
  /// 可用余额
  final double available;
  
  /// 冻结余额
  final double frozen;
  
  /// 总余额（可用+冻结）
  double get total => available + frozen;
  
  /// 币种名称
  final String? name;
  
  /// 币种图标URL
  final String? logoUrl;

  Balance({
    required this.currency,
    required this.available,
    required this.frozen,
    this.name,
    this.logoUrl,
  });

  /// 从JSON创建
  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      currency: json['currency'] as String,
      available: (json['available'] as num).toDouble(),
      frozen: (json['frozen'] as num).toDouble(),
      name: json['name'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'available': available,
      'frozen': frozen,
      'name': name,
      'logoUrl': logoUrl,
    };
  }
}

