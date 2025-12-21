/// 币种实体
class Currency {
  /// 币种ID
  final int id;

  /// 币种符号（如：BTC）
  final String symbol;

  /// 币种名称
  final String name;

  /// 图标URL
  final String? logo;

  /// 链名称（如：BNB）
  final String chain;

  /// 合约地址
  final String? contractAddress;

  /// 类型
  final int type;

  /// 精度（小数位数）
  final int decimals;

  /// 是否为基础货币
  final bool isBaseCurrency;

  /// 是否为计价货币
  final bool isQuoteCurrency;

  /// 状态（1: 启用, 0: 禁用）
  final int status;

  /// 最小充值金额
  final String? minDepositAmount;

  /// 最小提现金额
  final String? minWithdrawAmount;

  /// 提现手续费
  final String? withdrawFee;

  /// 提现手续费类型（fixed/percentage）
  final String withdrawFeeType;

  /// 是否热门
  final bool isHot;

  /// 是否推荐
  final bool isRecommended;

  Currency({
    required this.id,
    required this.symbol,
    required this.name,
    this.logo,
    required this.chain,
    this.contractAddress,
    required this.type,
    required this.decimals,
    required this.isBaseCurrency,
    required this.isQuoteCurrency,
    required this.status,
    this.minDepositAmount,
    this.minWithdrawAmount,
    this.withdrawFee,
    required this.withdrawFeeType,
    this.isHot = false,
    this.isRecommended = false,
  });

  /// 从JSON创建
  factory Currency.fromJson(Map<String, dynamic> json) {
    // 处理 name 字段，可能是字符串或对象（多语言）
    String? nameValue;
    final nameField = json['name'];
    if (nameField is String) {
      nameValue = nameField;
    } else if (nameField is Map) {
      // 如果是多语言对象，优先取中文，其次英文，最后取第一个值
      nameValue = nameField['zh_CN'] as String? ?? 
                  nameField['en'] as String? ?? 
                  nameField.values.first as String?;
    }
    
    return Currency(
      id: (json['id'] ?? 0) as int,
      symbol: json['symbol'] as String,
      name: nameValue ?? json['symbol'] as String,
      logo: json['logo'] as String?,
      chain: json['chain'] as String,
      contractAddress: json['contract_address'] as String?,
      type: (json['type'] ?? 0) as int,
      decimals: (json['decimals'] ?? 8) as int,
      isBaseCurrency: (json['is_base_currency'] ?? 0) == 1,
      isQuoteCurrency: (json['is_quote_currency'] ?? 0) == 1,
      status: (json['status'] ?? 1) as int,
      minDepositAmount: json['min_deposit_amount']?.toString(),
      minWithdrawAmount: json['min_withdraw_amount']?.toString(),
      withdrawFee: json['withdraw_fee']?.toString(),
      withdrawFeeType: json['withdraw_fee_type'] as String? ?? 'fixed',
      isHot: (json['is_hot'] ?? 0) == 1,
      isRecommended: (json['is_recommended'] ?? 0) == 1,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'logo': logo,
      'chain': chain,
      'contract_address': contractAddress,
      'type': type,
      'decimals': decimals,
      'is_base_currency': isBaseCurrency ? 1 : 0,
      'is_quote_currency': isQuoteCurrency ? 1 : 0,
      'status': status,
      'min_deposit_amount': minDepositAmount,
      'min_withdraw_amount': minWithdrawAmount,
      'withdraw_fee': withdrawFee,
      'withdraw_fee_type': withdrawFeeType,
      'is_hot': isHot ? 1 : 0,
      'is_recommended': isRecommended ? 1 : 0,
    };
  }

  /// 是否启用
  bool get isEnabled => status == 1;
}
