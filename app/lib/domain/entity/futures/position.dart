/// 持仓方向枚举
enum PositionSide {
  /// 做多
  long,
  
  /// 做空
  short,
}

/// 持仓实体（永续合约持仓）
class Position {
  /// 持仓ID
  final String id;
  
  /// 交易对符号
  final String symbol;
  
  /// 持仓方向
  final PositionSide side;
  
  /// 持仓数量
  final double quantity;
  
  /// 开仓均价
  final double openPrice;
  
  /// 标记价格
  final double markPrice;
  
  /// 未实现盈亏
  final double unrealizedPnl;
  
  /// 已实现盈亏
  final double realizedPnl;
  
  /// 杠杆倍数
  final int leverage;
  
  /// 保证金
  final double margin;
  
  /// 维持保证金率
  final double maintenanceMarginRate;
  
  /// 强平价格
  final double? liquidationPrice;
  
  /// 创建时间戳
  final int createdAt;
  
  /// 更新时间戳
  final int updatedAt;

  Position({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.openPrice,
    required this.markPrice,
    required this.unrealizedPnl,
    required this.realizedPnl,
    required this.leverage,
    required this.margin,
    required this.maintenanceMarginRate,
    this.liquidationPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      side: PositionSide.values.firstWhere(
        (e) => e.name == json['side'],
        orElse: () => PositionSide.long,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      openPrice: (json['openPrice'] as num).toDouble(),
      markPrice: (json['markPrice'] as num).toDouble(),
      unrealizedPnl: (json['unrealizedPnl'] as num).toDouble(),
      realizedPnl: (json['realizedPnl'] as num).toDouble(),
      leverage: json['leverage'] as int,
      margin: (json['margin'] as num).toDouble(),
      maintenanceMarginRate: (json['maintenanceMarginRate'] as num).toDouble(),
      liquidationPrice: json['liquidationPrice'] != null
          ? (json['liquidationPrice'] as num).toDouble()
          : null,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side.name,
      'quantity': quantity,
      'openPrice': openPrice,
      'markPrice': markPrice,
      'unrealizedPnl': unrealizedPnl,
      'realizedPnl': realizedPnl,
      'leverage': leverage,
      'margin': margin,
      'maintenanceMarginRate': maintenanceMarginRate,
      'liquidationPrice': liquidationPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 是否盈利
  bool get isProfit => unrealizedPnl > 0;

  /// 是否亏损
  bool get isLoss => unrealizedPnl < 0;
}

