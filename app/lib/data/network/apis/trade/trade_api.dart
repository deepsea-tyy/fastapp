import 'dart:async';
import '../../../mock/mock_order_data.dart';
import '../../../../domain/entity/trade/trade_request.dart';
import '../../../../domain/entity/trade/trade_response.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../domain/entity/order/order_type.dart';
import '../../../../domain/entity/order/order_status.dart';

/// 交易API实现（使用模拟数据）
class TradeApi {
  static int _orderIdCounter = 3000000;

  /// 模拟延迟
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 下单
  Future<TradeResponse> placeOrder(TradeRequest request) async {
    await _simulateDelay();
    
    // 验证请求
    if (!request.isValid()) {
      return TradeResponse.failure('Invalid trade request', errorCode: 'INVALID_REQUEST');
    }
    
    // 模拟下单成功
    final now = DateTime.now().millisecondsSinceEpoch;
    final order = Order(
      id: 'ORDER_${_orderIdCounter++}',
      symbol: request.symbol,
      type: request.type,
      side: request.side,
      status: OrderStatus.pending,
      price: request.price,
      quantity: request.quantity,
      filledQuantity: 0.0,
      filledAmount: 0.0,
      avgPrice: null,
      createdAt: now,
      updatedAt: now,
      remark: request.remark,
    );
    
    return TradeResponse.success(order);
  }

  /// 批量下单
  Future<List<TradeResponse>> placeOrders(List<TradeRequest> requests) async {
    await _simulateDelay();
    
    final List<TradeResponse> responses = [];
    for (final request in requests) {
      final response = await placeOrder(request);
      responses.add(response);
    }
    
    return responses;
  }
}

