import 'dart:async';
import '../../network/apis/market/market_api.dart';
import '../../../domain/entity/market/kline_data.dart';
import '../../../domain/entity/market/depth_data.dart';
import '../../../domain/entity/market/ticker_data.dart';
import '../../../domain/entity/market/market_pair.dart';
import '../../../domain/repository/market_repository.dart';

/// 行情仓库实现
class MarketRepositoryImpl implements MarketRepository {
  final MarketApi _marketApi;

  MarketRepositoryImpl(this._marketApi);

  @override
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    try {
      return await _marketApi.getKlineData(
        symbol: symbol,
        interval: interval,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  }) async {
    try {
      return await _marketApi.getDepthData(
        symbol: symbol,
        limit: limit,
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<TickerData?> getTickerData({String? symbol}) async {
    try {
      return await _marketApi.getTickerData(symbol: symbol);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<TickerData>> getAllTickerData() async {
    try {
      return await _marketApi.getAllTickerData();
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<MarketPair>> getMarketPairs() async {
    try {
      return await _marketApi.getMarketPairs();
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<MarketPair?> getMarketPairBySymbol(String symbol) async {
    try {
      return await _marketApi.getMarketPairBySymbol(symbol);
    } catch (e) {
      throw e;
    }
  }
}

