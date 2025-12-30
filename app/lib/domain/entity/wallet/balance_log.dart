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
      id: json['id'] as int,
      userId: json['user_id'] as int,
      walletType: json['wallet_type'] as String,
      symbol: json['symbol'] as String,
      changeType: json['change_type'] as String,
      amount: double.parse(json['amount'].toString()),
      availableBefore: double.parse(json['available_before'].toString()),
      availableAfter: double.parse(json['available_after'].toString()),
      frozenBefore: double.parse(json['frozen_before'].toString()),
      frozenAfter: double.parse(json['frozen_after'].toString()),
      refId: json['ref_id'] as String?,
      refType: json['ref_type'] as String?,
      remark: json['remark'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'wallet_type': walletType,
        'symbol': symbol,
        'change_type': changeType,
        'amount': amount,
        'available_before': availableBefore,
        'available_after': availableAfter,
        'frozen_before': frozenBefore,
        'frozen_after': frozenAfter,
        'ref_id': refId,
        'ref_type': refType,
        'remark': remark,
        'created_at': createdAt,
      };

  /// 是否为增加
  bool get isIncrease => amount > 0;

  /// 是否为减少
  bool get isDecrease => amount < 0;
}
