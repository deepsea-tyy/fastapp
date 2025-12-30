/// 钱包余额变动日志
class BalanceLog {
  /// 主键
  final int id;

  /// 用户ID
  final int userId;

  /// 钱包类型
  final String walletType;

  /// 币种
  final String symbol;

  /// 变动类型
  final String changeType;

  /// 变动金额(正数为增加,负数为减少)
  final double amount;

  /// 变动前可用
  final double availableBefore;

  /// 变动后可用
  final double availableAfter;

  /// 变动前冻结
  final double frozenBefore;

  /// 变动后冻结
  final double frozenAfter;

  /// 关联业务ID
  final String? refId;

  /// 业务类型
  final String? refType;

  /// 备注
  final String? remark;

  /// 创建时间
  final String createdAt;

  BalanceLog({
    required this.id,
    required this.userId,
    required this.walletType,
    required this.symbol,
    required this.changeType,
    required this.amount,
    required this.availableBefore,
    required this.availableAfter,
    required this.frozenBefore,
    required this.frozenAfter,
    this.refId,
    this.refType,
    this.remark,
    required this.createdAt,
  });

  factory BalanceLog.fromJson(Map<String, dynamic> json) {
    return BalanceLog(
      id: int.parse(json['id'].toString()),
      userId: json['userId'] != null ? int.parse(json['userId'].toString()) : 0,
      walletType: json['walletType'] as String,
      symbol: json['symbol'] as String,
      changeType: json['changeType'] as String,
      amount: double.parse(json['amount'].toString()),
      availableBefore: double.parse(json['availableBefore'].toString()),
      availableAfter: double.parse(json['availableAfter'].toString()),
      frozenBefore: double.parse(json['frozenBefore'].toString()),
      frozenAfter: double.parse(json['frozenAfter'].toString()),
      refId: json['refId'] as String?,
      refType: json['refType'] as String?,
      remark: json['remark'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'walletType': walletType,
        'symbol': symbol,
        'changeType': changeType,
        'amount': amount,
        'availableBefore': availableBefore,
        'availableAfter': availableAfter,
        'frozenBefore': frozenBefore,
        'frozenAfter': frozenAfter,
        'refId': refId,
        'refType': refType,
        'remark': remark,
        'createdAt': createdAt,
      };

  /// 是否为增加
  bool get isIncrease => amount > 0;

  /// 是否为减少
  bool get isDecrease => amount < 0;
}
