import 'dart:math';
import '../../domain/entity/order/order.dart';
import '../../domain/entity/order/order_type.dart';
import '../../domain/entity/order/order_status.dart';
import '../../domain/entity/order/order_side.dart';

/// 模拟订单数据生成器
class MockOrderData {
  static final Random _random = Random();
  static int _orderIdCounter = 1000000;

  /// 生成订单列表
  static List<Order> generateOrders({
    String? symbol,
    OrderStatus? status,
    int? limit = 20,
  }) {
    final symbols = symbol != null
        ? [symbol]
        : ['BTC/USDT', 'ETH/USDT', 'SOL/USDT', 'XRP/USDT', 'BGB/USDT'];
    final statuses = status != null
        ? [status]
        : OrderStatus.values;
    
    final List<Order> orders = [];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < (limit ?? 20); i++) {
      final orderSymbol = symbols[_random.nextInt(symbols.length)];
      final orderStatus = statuses[_random.nextInt(statuses.length)];
      final orderSide = _random.nextBool() ? OrderSide.buy : OrderSide.sell;
      final orderType = _random.nextBool() ? OrderType.limit : OrderType.market;
      
      final basePrice = _getBasePrice(orderSymbol);
      final price = orderType == OrderType.limit
          ? basePrice * (1 + (_random.nextDouble() - 0.5) * 0.02)
          : null;
      final quantity = _random.nextDouble() * 10 + 0.1;
      
      final filledQuantity = orderStatus == OrderStatus.filled
          ? quantity
          : orderStatus == OrderStatus.partiallyFilled
              ? quantity * _random.nextDouble() * 0.8
              : 0.0;
      
      final avgPrice = filledQuantity > 0
          ? (price ?? basePrice) * (1 + (_random.nextDouble() - 0.5) * 0.01)
          : null;
      
      final filledAmount = filledQuantity * (avgPrice ?? price ?? basePrice);
      
      final createdAt = now - (_random.nextInt(7 * 24 * 60 * 60 * 1000)); // 7天内
      final updatedAt = orderStatus == OrderStatus.filled || orderStatus == OrderStatus.cancelled
          ? createdAt + _random.nextInt(60 * 60 * 1000) // 1小时内更新
          : createdAt;
      
      orders.add(Order(
        id: 'ORDER_${_orderIdCounter++}',
        symbol: orderSymbol,
        type: orderType,
        side: orderSide,
        status: orderStatus,
        price: price,
        quantity: quantity,
        filledQuantity: filledQuantity,
        filledAmount: filledAmount,
        avgPrice: avgPrice,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ));
    }
    
    // 按创建时间倒序排列
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return orders;
  }

  /// 根据ID生成订单
  static Order? generateOrderById(String orderId) {
    final orders = generateOrders(limit: 100);
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// 根据交易对获取基础价格
  static double _getBasePrice(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC/USDT':
        return 90714.12;
      case 'ETH/USDT':
        return 3034.23;
      case 'SOL/USDT':
        return 137.45;
      case 'XRP/USDT':
        return 2.1733;
      case 'BGB/USDT':
        return 3.7;
      default:
        return 100.0;
    }
  }
}

