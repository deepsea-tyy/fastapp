/// 交易记录类型枚举
enum TransactionType {
  /// 充值
  deposit,
  
  /// 提现
  withdrawal,
  
  /// 交易
  trade,
  
  /// 转账
  transfer,
  
  /// 其他
  other,
}

/// 交易记录状态枚举
enum TransactionStatus {
  /// 处理中
  pending,
  
  /// 成功
  success,
  
  /// 失败
  failed,
  
  /// 已取消
  cancelled,
}

/// 交易记录实体
class Transaction {
  /// 交易ID
  final String id;
  
  /// 币种符号
  final String currency;
  
  /// 交易类型
  final TransactionType type;
  
  /// 交易状态
  final TransactionStatus status;
  
  /// 数量
  final double amount;
  
  /// 手续费
  final double fee;
  
  /// 手续费币种
  final String? feeCurrency;
  
  /// 交易对（如果是交易类型）
  final String? symbol;
  
  /// 备注
  final String? remark;
  
  /// 创建时间戳
  final int createdAt;
  
  /// 完成时间戳
  final int? completedAt;
  
  /// 交易哈希（充提币）
  final String? txHash;
  
  /// 地址（充提币）
  final String? address;

  Transaction({
    required this.id,
    required this.currency,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    this.feeCurrency,
    this.symbol,
    this.remark,
    required this.createdAt,
    this.completedAt,
    this.txHash,
    this.address,
  });

  /// 从JSON创建
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      currency: json['currency'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.other,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      feeCurrency: json['feeCurrency'] as String?,
      symbol: json['symbol'] as String?,
      remark: json['remark'] as String?,
      createdAt: json['createdAt'] as int,
      completedAt: json['completedAt'] as int?,
      txHash: json['txHash'] as String?,
      address: json['address'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'fee': fee,
      'feeCurrency': feeCurrency,
      'symbol': symbol,
      'remark': remark,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'txHash': txHash,
      'address': address,
    };
  }

  /// 是否已完成
  bool get isCompleted => status == TransactionStatus.success;

  /// 是否处理中
  bool get isPending => status == TransactionStatus.pending;
}

