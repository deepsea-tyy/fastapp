import 'dart:async';
import '../../network/apis/trade/trade_api.dart';
import '../../../domain/entity/trade/trade_request.dart';
import '../../../domain/entity/trade/trade_response.dart';
import '../../../domain/repository/trade_repository.dart';

/// 交易仓库实现
class TradeRepositoryImpl implements TradeRepository {
  final TradeApi _tradeApi;

  TradeRepositoryImpl(this._tradeApi);

  @override
  Future<TradeResponse> placeOrder(TradeRequest request) async {
    try {
      return await _tradeApi.placeOrder(request);
    } catch (e) {
      return TradeResponse.failure(e.toString());
    }
  }

  @override
  Future<List<TradeResponse>> placeOrders(List<TradeRequest> requests) async {
    try {
      return await _tradeApi.placeOrders(requests);
    } catch (e) {
      // 如果批量下单失败，返回失败响应列表
      return requests
          .map((req) => TradeResponse.failure(e.toString()))
          .toList();
    }
  }
}

