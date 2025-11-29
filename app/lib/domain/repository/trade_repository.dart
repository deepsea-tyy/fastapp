import 'dart:async';

import '../entity/trade/trade_request.dart';
import '../entity/trade/trade_response.dart';

/// 交易仓库接口
abstract class TradeRepository {
  /// 下单
  Future<TradeResponse> placeOrder(TradeRequest request);

  /// 批量下单
  Future<List<TradeResponse>> placeOrders(List<TradeRequest> requests);
}

