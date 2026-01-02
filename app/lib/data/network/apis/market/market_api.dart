import 'dart:async';
import '../../../../domain/entity/market/kline_data.dart';
import '../../../../domain/entity/market/depth_data.dart';
import '../../../../domain/entity/market/ticker_data.dart';
import '../../../../domain/entity/market/market_pair.dart';
import '../../../../domain/entity/market/market_data_config.dart';
import '../../../../domain/entity/market/currency_detail.dart';
import '../../../../domain/entity/market/exchange_rate_response.dart';
import '../../constants/endpoints.dart';
import '../../http_client_wrapper.dart';

/// 行情API实现
/// 
/// 【HTTP 客户端选择】
/// - 使用 HttpClientWrapper 统一管理 HTTP 请求
/// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
/// - 开发时默认使用 DioClient（有日志），生产时可配置部分接口使用 RestClient（性能优化）
/// 
/// 【配置示例】
/// ```dart
/// // 开发时：默认使用 DioClient，无需配置
/// 
/// // 生产环境：配置高频接口使用 RestClient
/// HttpClientConfig.addRestClientEndpoint('/api/ds/ex/currency/tickers');
/// HttpClientConfig.addRestClientEndpoint('/api/ds/ex/currency/marketPair');
/// ```
class MarketApi {
  final HttpClientWrapper _httpClient;

  MarketApi(this._httpClient);

  // ==================== K线和深度图接口 ====================
  // 注意：后端暂未实现这些接口，当前返回空数据

  /// 获取K线数据
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 此接口为高频接口，生产环境可配置使用 RestClient 优化性能
  ///
  /// 【数据格式】
  /// - 后端返回币安格式数组：[[openTime, open, high, low, close, volume, closeTime, quoteVolume, trades, takerBuyBaseVolume, takerBuyQuoteVolume, ignore], ...]
  /// - 自动转换为 KlineData 对象列表
  ///
  /// 【参数说明】
  /// - symbol: 交易对符号，例如：'BTCUSDT'（注意：需要将 'BTC/USDT' 转换为 'BTCUSDT'）
  /// - interval: 时间周期，例如：'1s', '1m', '5m', '1h', '1d' 等
  /// - page: 页数（可选，用于分页）
  /// - pageSize: 每页数量（可选，1-1000，默认500）
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? page,
    int? pageSize,
  }) async {
    try {
      // 转换交易对符号格式：BTC/USDT -> BTCUSDT
      final normalizedSymbol = symbol.replaceAll('/', '').toUpperCase();

      final queryParams = <String, dynamic>{
        'symbol': normalizedSymbol,
        'interval': interval,
      };
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      final response = await _httpClient.get(
        Endpoints.marketKline,
        queryParameters: queryParams,
      );

      // 后端返回的是币安格式数组，需要转换为 KlineData 对象
      if (response is List) {
        return response
            .map((item) => _convertBinanceKlineToKlineData(item))
            .whereType<KlineData>()
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// 将币安格式K线数据转换为KlineData对象
  /// 
  /// 币安格式：[openTime, open, high, low, close, volume, closeTime, quoteVolume, trades, takerBuyBaseVolume, takerBuyQuoteVolume, ignore]
  /// 
  /// @param binanceKline 币安格式的K线数组
  /// @return KlineData 对象，如果数据格式不正确则返回 null
  KlineData? _convertBinanceKlineToKlineData(dynamic binanceKline) {
    try {
      if (binanceKline is! List || binanceKline.length < 7) {
        return null;
      }

      // 币安格式数组索引：
      // [0] openTime (毫秒时间戳)
      // [1] open (开盘价，字符串)
      // [2] high (最高价，字符串)
      // [3] low (最低价，字符串)
      // [4] close (收盘价，字符串)
      // [5] volume (成交量，字符串)
      // [6] closeTime (收盘时间，毫秒时间戳)
      // [7] quoteVolume (成交额，字符串)
      // [8] trades (成交笔数，整数)
      // [9] takerBuyBaseVolume (主动买入成交量，字符串)
      // [10] takerBuyQuoteVolume (主动买入成交额，字符串)
      // [11] ignore (忽略字段)

      return KlineData(
        timestamp: (binanceKline[0] as num).toInt(),
        open: double.parse(binanceKline[1].toString()),
        high: double.parse(binanceKline[2].toString()),
        low: double.parse(binanceKline[3].toString()),
        close: double.parse(binanceKline[4].toString()),
        volume: double.parse(binanceKline[5].toString()),
        amount: binanceKline.length > 7 
            ? double.parse(binanceKline[7].toString()) 
            : 0.0, // quoteVolume 作为成交额
      );
    } catch (e) {
      print('[MarketApi] 转换K线数据失败: $e, 数据: $binanceKline');
      return null;
    }
  }

  /// 获取深度图数据
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 此接口为高频接口，生产环境可配置使用 RestClient 优化性能
  ///
  /// @param symbol 交易对符号，例如：'BTCUSDT'（注意：需要将 'BTC/USDT' 转换为 'BTCUSDT'）
  /// @param limit 深度数量（可选，5, 10, 20, 50, 100, 500, 1000，默认20）
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  }) async {
    try {
      // 转换交易对符号格式：BTC/USDT -> BTCUSDT
      final normalizedSymbol = symbol.replaceAll('/', '').toUpperCase();

      final queryParams = <String, dynamic>{
        'symbol': normalizedSymbol,
      };
      if (limit != null) queryParams['limit'] = limit;

      final response = await _httpClient.get(
        Endpoints.marketDepth,
        queryParameters: queryParams,
      );

      // 后端返回格式：{ bids: [...], asks: [...], lastPrice: ..., timestamp: ... }
      if (response is Map<String, dynamic>) {
        return DepthChartData.fromJson(response);
      }

      // 如果格式不正确，返回空数据
      return DepthChartData(
        bids: [],
        asks: [],
        lastPrice: 0.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // 发生错误时返回空数据，避免崩溃
      print('[MarketApi] 获取深度数据失败: $e');
      return DepthChartData(
        bids: [],
        asks: [],
        lastPrice: 0.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// 获取Ticker数据
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 开发时默认使用 DioClient，会打印请求日志
  ///
  /// @param symbol 交易对符号，例如：'BTC/USDT'
  /// @return TickerData 对象，失败时返回 null
  Future<TickerData?> getTickerData({String? symbol}) async {
    if (symbol == null) {
      return null;
    }

    try {
      final response = await _httpClient.get(
        '${Endpoints.marketTicker}/$symbol',
      );
      return TickerData.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 获取所有Ticker数据
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 此接口为高频接口，生产环境可配置使用 RestClient 优化性能
  ///
  /// 【注意】
  /// - CurrencyController 的 ticker 接口支持批量请求多个符号（用逗号分隔）
  /// - 返回格式：{ data: [...] }，其中 data 是 ticker 对象数组
  ///
  /// @param symbols 交易对符号列表（如：['BTCUSDT', 'ETHUSDT']），如果为空则返回空列表
  /// @return TickerData 列表
  Future<List<TickerData>> getAllTickerData({List<String>? symbols}) async {
    if (symbols == null || symbols.isEmpty) return [];

    try {
      final response = await _httpClient.get(
        Endpoints.marketTicker,
        queryParameters: {'symbol': symbols.join(',')},
      );

      final tickerList = _extractTickerList(response);
      return tickerList
          .map((item) {
            try {
              return TickerData.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          })
          .whereType<TickerData>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 从响应中提取 ticker 列表
  List<dynamic> _extractTickerList(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return [];

    return response['data'] as List? ??
        response['list'] as List? ??
        (response['symbol'] != null ? [response] : []);
  }

  /// 获取交易对列表
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 此接口为高频接口，生产环境可配置使用 RestClient 优化性能
  ///
  /// @return MarketPair 列表
  Future<List<MarketPair>> getMarketPairs() async {
    try {
      final response = await _httpClient.get(
        Endpoints.marketPairs,
      );

      // 后端返回格式：{ list: [...] }
      if (response is Map && response['list'] is List) {
        return (response['list'] as List).map((item) => MarketPair.fromJson(item as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (e) {
      // 发生错误时返回空列表
      rethrow;
    }
  }

  /// 根据符号获取交易对
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  ///
  /// @param symbol 交易对符号，例如：'BTC/USDT'
  /// @return MarketPair 对象，失败时返回 null
  Future<MarketPair?> getMarketPairBySymbol(String symbol) async {
    try {
      final response = await _httpClient.get(
        Endpoints.marketPairs,
        queryParameters: {'symbol': symbol},
      );

      // 返回列表的第一项
      if (response is Map && response['list'] is List) {
        final list = response['list'] as List;
        if (list.isNotEmpty) {
          return MarketPair.fromJson(list.first as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 下载市场数据配置（币种、现货、合约、期权）
  /// 
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 开发时默认使用 DioClient，会打印请求日志
  /// - 此接口在启动时调用，建议使用 DioClient 以便查看日志
  /// 
  /// @return MarketDataConfig 对象
  Future<MarketDataConfig> downloadMarketData() async {
    final response = await _httpClient.get(Endpoints.currencyDownload);
    return MarketDataConfig.fromJson(response as Map<String, dynamic>);
  }

  /// 获取币种详情
  ///
  /// 【HTTP 客户端】
  /// - 根据 HttpClientConfig 配置自动选择 DioClient 或 RestClient
  /// - 开发时默认使用 DioClient，会打印请求日志
  ///
  /// @param symbol 币种符号，例如：'BTC'（不包含交易对，只取基础币种）
  /// @return CurrencyDetail 对象，失败时返回 null
  Future<CurrencyDetail?> getCurrencyDetail({required String symbol}) async {
    if (symbol.isEmpty) {
      return null;
    }

    try {
      final response = await _httpClient.get(
        Endpoints.currencyDetail,
        queryParameters: {'symbol': symbol},
      );

      // 处理响应格式，可能是 { data: {...} } 或直接是对象
      Map<String, dynamic> data;
      if (response is Map) {
        if (response.containsKey('data')) {
          data = response['data'] as Map<String, dynamic>;
        } else {
          data = response as Map<String, dynamic>;
        }
      } else {
        return null;
      }

      return CurrencyDetail.fromJson(data);
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 获取汇率
  /// 
  /// @return ExchangeRateResponse 对象，失败时返回 null
  Future<ExchangeRateResponse?> getExchangeRate() async {
    try {
      final response = await _httpClient.get(Endpoints.exchangeRate);
      
      // 处理响应格式，可能是 { data: {...} } 或直接是对象
      Map<String, dynamic> data;
      if (response is Map) {
        if (response.containsKey('data')) {
          data = response['data'] as Map<String, dynamic>;
        } else {
          data = response as Map<String, dynamic>;
        }
      } else {
        return null;
      }
      
      return ExchangeRateResponse.fromJson(data);
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }
}

