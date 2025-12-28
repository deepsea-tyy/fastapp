import 'dart:async';
import '../../network/apis/market/market_api.dart';
import '../../../core/services/market_data_service.dart';
import '../../../domain/entity/market/kline_data.dart';
import '../../../domain/entity/market/depth_data.dart';
import '../../../domain/entity/market/ticker_data.dart';
import '../../../domain/entity/market/market_pair.dart';
import '../../../domain/entity/market/market_data_config.dart';
import '../../../domain/entity/market/currency_detail.dart';
import '../../../domain/entity/market/exchange_rate_response.dart';
import '../../../domain/repository/market_repository.dart';

/// 行情仓库实现
class MarketRepositoryImpl implements MarketRepository {
  final MarketApi _marketApi;
  final MarketDataService _marketDataService;

  MarketRepositoryImpl(this._marketApi, this._marketDataService);

  @override
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit,
  }) =>
      _marketApi.getKlineData(
        symbol: symbol,
        interval: interval,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
      );

  @override
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  }) =>
      _marketApi.getDepthData(symbol: symbol, limit: limit);

  @override
  Future<TickerData?> getTickerData({String? symbol}) =>
      _marketApi.getTickerData(symbol: symbol);

  @override
  Future<List<TickerData>> getAllTickerData({List<String>? symbols}) =>
      _marketApi.getAllTickerData(symbols: symbols);

  @override
  Future<List<MarketPair>> getMarketPairs() => _marketApi.getMarketPairs();

  @override
  Future<MarketPair?> getMarketPairBySymbol(String symbol) =>
      _marketApi.getMarketPairBySymbol(symbol);

  @override
  Future<MarketDataConfig> downloadMarketData() async {
    // 使用 MarketDataService 处理下载和缓存逻辑
    // 启动时总是先请求服务器，失败则降级使用本地数据
    final config = await _marketDataService.getMarketData();
    if (config == null) {
      // 只有在服务器和本地都没有数据时才抛出异常
      throw Exception('Failed to load market data from server and local cache');
    }
    return config;
  }

  @override
  Future<CurrencyDetail?> getCurrencyDetail({required String symbol}) =>
      _marketApi.getCurrencyDetail(symbol: symbol);

  @override
  Future<ExchangeRateResponse?> getExchangeRate() =>
      _marketApi.getExchangeRate();
}

