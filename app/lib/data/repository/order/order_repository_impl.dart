import 'dart:async';
import '../../network/apis/order/order_api.dart';
import '../../../domain/entity/order/order.dart';
import '../../../domain/entity/order/order_status.dart';
import '../../../domain/repository/order_repository.dart';

/// 订单仓库实现
class OrderRepositoryImpl implements OrderRepository {
  final OrderApi _orderApi;

  OrderRepositoryImpl(this._orderApi);

  @override
  Future<List<Order>> getOrders({
    String? symbol,
    OrderStatus? status,
    int? startTime,
    int? endTime,
    int? page,
    int? limit,
  }) async {
    try {
      return await _orderApi.getOrders(
        symbol: symbol,
        status: status,
        startTime: startTime,
        endTime: endTime,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      return await _orderApi.getOrderById(orderId);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      return await _orderApi.cancelOrder(orderId);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<int> cancelOrders(List<String> orderIds) async {
    try {
      return await _orderApi.cancelOrders(orderIds);
    } catch (e) {
      throw e;
    }
  }
}

