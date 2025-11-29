import 'dart:async';
import '../../../mock/mock_order_data.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../domain/entity/order/order_status.dart';

/// 订单API实现（使用模拟数据）
class OrderApi {
  /// 模拟延迟
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// 获取订单列表
  Future<List<Order>> getOrders({
    String? symbol,
    OrderStatus? status,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    await _simulateDelay();
    return MockOrderData.generateOrders(
      symbol: symbol,
      status: status,
      limit: limit,
    );
  }

  /// 根据ID获取订单详情
  Future<Order?> getOrderById(String orderId) async {
    await _simulateDelay();
    return MockOrderData.generateOrderById(orderId);
  }

  /// 取消订单
  Future<bool> cancelOrder(String orderId) async {
    await _simulateDelay();
    // 模拟取消操作，返回成功
    return true;
  }

  /// 批量取消订单
  Future<int> cancelOrders(List<String> orderIds) async {
    await _simulateDelay();
    // 模拟批量取消，返回成功数量
    return orderIds.length;
  }
}

