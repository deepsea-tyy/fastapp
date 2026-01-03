import 'dart:async';
import '../../../../domain/entity/order/order.dart';
import '../../../../domain/entity/order/order_status.dart';
import '../../constants/endpoints.dart';
import '../../http_client_wrapper.dart';

/// 订单API实现
class OrderApi {
  final HttpClientWrapper _httpClient;

  OrderApi(this._httpClient);

  /// 获取订单列表
  Future<List<Order>> getOrders({
    String? symbol,
    OrderStatus? status,
    int? startTime,
    int? endTime,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (symbol != null && symbol.isNotEmpty) {
        // 转换交易对符号格式：BTC/USDT -> BTCUSDT
        final normalizedSymbol = symbol.replaceAll('/', '').toUpperCase();
        queryParams['symbol'] = normalizedSymbol;
      }

      if (status != null) {
        // 映射前端状态到后端状态
        final statusMap = {
          OrderStatus.pending: 'pending',
          OrderStatus.partiallyFilled: 'partiallyFilled',
          OrderStatus.filled: 'filled',
          OrderStatus.cancelled: 'cancelled',
          OrderStatus.rejected: 'rejected',
          OrderStatus.expired: 'expired',
        };
        queryParams['status'] = statusMap[status] ?? 'pending';
      }

      if (startTime != null) {
        // 前端传入的是毫秒时间戳，后端需要秒时间戳
        queryParams['start_time'] = (startTime / 1000).round();
      }

      if (endTime != null) {
        queryParams['end_time'] = (endTime / 1000).round();
      }

      if (page != null) {
        queryParams['page'] = page;
      }

      if (limit != null) {
        queryParams['limit'] = limit;
      }

      // 调用后端接口
      final response = await _httpClient.get(
        Endpoints.spotOrderList,
        queryParameters: queryParams,
      );

      // 解析响应数据
      // 后端返回格式：{ "code": 200, "message": "success", "data": { "items": [...], "total": 100, "page": 1, "limit": 50 } }
      if (response is Map<String, dynamic>) {
        final code = response['code'] as int?;
        final data = response['data'] as Map<String, dynamic>?;

        if (code == 200 && data != null) {
          final items = data['items'] as List<dynamic>?;
          if (items != null) {
            return items
                .map((item) => Order.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      }

      return [];
    } catch (e) {
      throw e;
    }
  }

  /// 根据ID获取订单详情
  Future<Order?> getOrderById(String orderId) async {
    try {
      // 通过订单列表接口查询，使用订单ID作为筛选条件
      final orders = await getOrders(limit: 1);
      return orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// 取消订单
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _httpClient.delete(
        Endpoints.spotOrderCancel,
        queryParameters: {'order_id': orderId},
      );

      // 解析响应数据
      if (response is Map<String, dynamic>) {
        final code = response['code'] as int?;
        return code == 200;
      }

      return false;
    } catch (e) {
      throw e;
    }
  }

  /// 批量取消订单
  Future<int> cancelOrders(List<String> orderIds) async {
    int successCount = 0;
    for (final orderId in orderIds) {
      try {
        final success = await cancelOrder(orderId);
        if (success) {
          successCount++;
        }
      } catch (e) {
        // 继续处理下一个订单
        continue;
      }
    }
    return successCount;
  }
}

