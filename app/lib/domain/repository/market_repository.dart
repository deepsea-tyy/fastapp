import 'dart:async';

import '../entity/market/kline_data.dart';
import '../entity/market/depth_data.dart';
import '../entity/market/ticker_data.dart';
import '../entity/market/market_pair.dart';
import '../entity/market/market_data_config.dart';
import '../entity/market/currency_detail.dart';
import '../entity/market/exchange_rate_response.dart';

/// 行情仓库接口
abstract class MarketRepository {
  /// 获取K线数据
  /// [symbol] 交易对符号
  /// [interval] 时间周期（1m、5m、15m、1h、4h、1d等）
  /// [startTime] 开始时间戳（可选）
  /// [endTime] 结束时间戳（可选）
  /// [limit] 返回数量限制（可选）
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit,
  });

  /// 获取深度图数据
  /// [symbol] 交易对符号
  /// [limit] 深度数量（可选，默认20）
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  });

  /// 获取Ticker数据
  /// [symbol] 交易对符号（可选，为空则获取所有）
  Future<TickerData?> getTickerData({String? symbol});

  /// 获取所有Ticker数据
  /// [symbols] 交易对符号列表（可选，如果为空则返回空列表）
  Future<List<TickerData>> getAllTickerData({List<String>? symbols});

  /// 获取交易对列表
  Future<List<MarketPair>> getMarketPairs();

  /// 根据符号获取交易对
  Future<MarketPair?> getMarketPairBySymbol(String symbol);

  /// 下载市场数据配置
  Future<MarketDataConfig> downloadMarketData();

  /// 获取币种详情
  /// [symbol] 币种符号（如：'BTC'）
  Future<CurrencyDetail?> getCurrencyDetail({required String symbol});

  /// 获取汇率
  Future<ExchangeRateResponse?> getExchangeRate();
}

