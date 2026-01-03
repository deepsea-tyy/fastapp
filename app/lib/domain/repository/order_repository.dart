import 'dart:async';

import '../entity/order/order.dart';
import '../entity/order/order_status.dart';

/// 订单仓库接口
abstract class OrderRepository {
  /// 获取订单列表
  /// [symbol] 交易对符号（可选）
  /// [status] 订单状态（可选）
  /// [startTime] 开始时间戳（可选）
  /// [endTime] 结束时间戳（可选）
  /// [page] 页码（可选，默认为1）
  /// [limit] 返回数量限制（可选）
  Future<List<Order>> getOrders({
    String? symbol,
    OrderStatus? status,
    int? startTime,
    int? endTime,
    int? page,
    int? limit,
  });

  /// 根据ID获取订单详情
  Future<Order?> getOrderById(String orderId);

  /// 取消订单
  Future<bool> cancelOrder(String orderId);

  /// 批量取消订单
  Future<int> cancelOrders(List<String> orderIds);
}

