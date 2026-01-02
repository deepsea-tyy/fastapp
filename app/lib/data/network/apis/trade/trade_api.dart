import 'dart:async';
import '../../../../domain/entity/trade/trade_request.dart';
import '../../../../domain/entity/trade/trade_response.dart';
import '../../../../domain/entity/order/order.dart';
import '../../../../domain/entity/order/order_type.dart';
import '../../../../domain/entity/order/order_status.dart';
import '../../constants/endpoints.dart';
import '../../http_client_wrapper.dart';

/// 交易API实现
class TradeApi {
  final HttpClientWrapper _httpClient;

  TradeApi(this._httpClient);

  /// 下单
  Future<TradeResponse> placeOrder(TradeRequest request) async {
    try {
      // 验证请求
      if (!request.isValid()) {
        return TradeResponse.failure('Invalid trade request', errorCode: 'INVALID_REQUEST');
      }

      // 转换交易对符号格式：BTC/USDT -> BTCUSDT
      final normalizedSymbol = request.symbol.replaceAll('/', '').toUpperCase();

      // 准备请求数据
      final requestData = <String, dynamic>{
        'symbol': normalizedSymbol,
        'side': request.side.name,
        'type': request.type.name,
        'quantity': request.quantity,
      };

      if (request.price != null) {
        requestData['price'] = request.price;
      }

      if (request.amount != null) {
        requestData['amount'] = request.amount;
      }

      if (request.remark != null && request.remark!.isNotEmpty) {
        requestData['client_order_id'] = request.remark;
      }

      // 调用后端接口
      final response = await _httpClient.post(
        Endpoints.spotOrderPlace,
        data: requestData,
      );

      // 解析响应数据
      // 后端返回格式：{ "code": 200, "message": "下单成功", "data": { ... } }
      if (response is Map<String, dynamic>) {
        final code = response['code'] as int?;
        final message = response['message'] as String?;
        final data = response['data'] as Map<String, dynamic>?;

        if (code == 200 && data != null) {
          // 将后端返回的数据转换为 Order 对象
          final order = Order.fromJson(data);
          return TradeResponse.success(order);
        } else {
          return TradeResponse.failure(
            message ?? '下单失败',
            errorCode: code?.toString() ?? 'UNKNOWN_ERROR',
          );
        }
      }

      return TradeResponse.failure('Invalid response format', errorCode: 'INVALID_RESPONSE');
    } catch (e) {
      return TradeResponse.failure(e.toString(), errorCode: 'NETWORK_ERROR');
    }
  }

  /// 批量下单
  Future<List<TradeResponse>> placeOrders(List<TradeRequest> requests) async {
    final List<TradeResponse> responses = [];
    for (final request in requests) {
      final response = await placeOrder(request);
      responses.add(response);
    }
    return responses;
  }
}

