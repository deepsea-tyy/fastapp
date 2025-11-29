import '../order/order_type.dart';
import '../order/order_side.dart';

/// 交易请求实体
class TradeRequest {
  /// 交易对符号
  final String symbol;
  
  /// 订单类型
  final OrderType type;
  
  /// 订单方向（买入/卖出）
  final OrderSide side;
  
  /// 价格（限价单必填）
  final double? price;
  
  /// 数量
  final double quantity;
  
  /// 金额（市价单买入时使用）
  final double? amount;
  
  /// 备注
  final String? remark;

  TradeRequest({
    required this.symbol,
    required this.type,
    required this.side,
    this.price,
    required this.quantity,
    this.amount,
    this.remark,
  });

  /// 从JSON创建
  factory TradeRequest.fromJson(Map<String, dynamic> json) {
    return TradeRequest(
      symbol: json['symbol'] as String,
      type: OrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderType.limit,
      ),
      side: OrderSide.values.firstWhere(
        (e) => e.name == json['side'],
        orElse: () => OrderSide.buy,
      ),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      quantity: (json['quantity'] as num).toDouble(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      remark: json['remark'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'type': type.name,
      'side': side.name,
      'price': price,
      'quantity': quantity,
      'amount': amount,
      'remark': remark,
    };
  }

  /// 验证请求是否有效
  bool isValid() {
    if (symbol.isEmpty || quantity <= 0) {
      return false;
    }
    
    // 限价单必须有价格
    if (type == OrderType.limit && (price == null || price! <= 0)) {
      return false;
    }
    
    // 市价单买入必须有金额
    if (type == OrderType.market &&
        side == OrderSide.buy &&
        (amount == null || amount! <= 0)) {
      return false;
    }
    
    return true;
  }
}

