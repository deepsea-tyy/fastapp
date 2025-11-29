import 'order_type.dart';
import 'order_status.dart';
import 'order_side.dart';

/// 订单实体
class Order {
  /// 订单ID
  final String id;
  
  /// 交易对符号
  final String symbol;
  
  /// 订单类型
  final OrderType type;
  
  /// 订单方向（买入/卖出）
  final OrderSide side;
  
  /// 订单状态
  final OrderStatus status;
  
  /// 价格（限价单）
  final double? price;
  
  /// 数量
  final double quantity;
  
  /// 已成交数量
  final double filledQuantity;
  
  /// 已成交金额
  final double filledAmount;
  
  /// 平均成交价格
  final double? avgPrice;
  
  /// 创建时间戳
  final int createdAt;
  
  /// 更新时间戳
  final int updatedAt;
  
  /// 备注
  final String? remark;

  Order({
    required this.id,
    required this.symbol,
    required this.type,
    required this.side,
    required this.status,
    this.price,
    required this.quantity,
    required this.filledQuantity,
    required this.filledAmount,
    this.avgPrice,
    required this.createdAt,
    required this.updatedAt,
    this.remark,
  });

  /// 从JSON创建
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      type: OrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderType.limit,
      ),
      side: OrderSide.values.firstWhere(
        (e) => e.name == json['side'],
        orElse: () => OrderSide.buy,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      quantity: (json['quantity'] as num).toDouble(),
      filledQuantity: (json['filledQuantity'] as num).toDouble(),
      filledAmount: (json['filledAmount'] as num).toDouble(),
      avgPrice: json['avgPrice'] != null
          ? (json['avgPrice'] as num).toDouble()
          : null,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      remark: json['remark'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type.name,
      'side': side.name,
      'status': status.name,
      'price': price,
      'quantity': quantity,
      'filledQuantity': filledQuantity,
      'filledAmount': filledAmount,
      'avgPrice': avgPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'remark': remark,
    };
  }

  /// 是否已完全成交
  bool get isFilled => status == OrderStatus.filled;

  /// 是否已取消
  bool get isCancelled => status == OrderStatus.cancelled;

  /// 是否可取消
  bool get canCancel =>
      status == OrderStatus.pending ||
      status == OrderStatus.partiallyFilled;
}

