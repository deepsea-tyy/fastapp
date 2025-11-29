import 'dart:async';
import '../../../mock/mock_market_data.dart';
import '../../../../domain/entity/market/kline_data.dart';
import '../../../../domain/entity/market/depth_data.dart';
import '../../../../domain/entity/market/ticker_data.dart';
import '../../../../domain/entity/market/market_pair.dart';

/// 行情API实现（使用模拟数据）
class MarketApi {
  /// 模拟延迟
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// 获取K线数据
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    await _simulateDelay();
    return MockMarketData.generateKlineData(
      symbol: symbol,
      interval: interval,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
    );
  }

  /// 获取深度图数据
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  }) async {
    await _simulateDelay();
    return MockMarketData.generateDepthData(
      symbol: symbol,
      limit: limit ?? 20,
    );
  }

  /// 获取Ticker数据
  Future<TickerData?> getTickerData({String? symbol}) async {
    await _simulateDelay();
    if (symbol == null) {
      return null;
    }
    return MockMarketData.generateTickerData(symbol);
  }

  /// 获取所有Ticker数据
  Future<List<TickerData>> getAllTickerData() async {
    await _simulateDelay();
    return MockMarketData.generateAllTickerData();
  }

  /// 获取交易对列表
  Future<List<MarketPair>> getMarketPairs() async {
    await _simulateDelay();
    return MockMarketData.generateMarketPairs();
  }

  /// 根据符号获取交易对
  Future<MarketPair?> getMarketPairBySymbol(String symbol) async {
    await _simulateDelay();
    final pairs = MockMarketData.generateMarketPairs();
    try {
      return pairs.firstWhere((pair) => pair.symbol == symbol);
    } catch (e) {
      return null;
    }
  }
}

