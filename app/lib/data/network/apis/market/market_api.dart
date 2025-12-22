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
  /// 【注意】后端接口暂未实现，当前返回空列表
  /// TODO: 后端实现后更新此方法，添加真实接口路径到 Endpoints
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    // 后端接口暂未实现，返回空列表避免报错
    print('[MarketApi] ⚠️ getKlineData 接口暂未实现，返回空数据');
    return [];

    // TODO: 后端实现后启用以下代码
    // try {
    //   final queryParams = <String, dynamic>{
    //     'symbol': symbol,
    //     'interval': interval,
    //   };
    //   if (startTime != null) queryParams['startTime'] = startTime;
    //   if (endTime != null) queryParams['endTime'] = endTime;
    //   if (limit != null) queryParams['limit'] = limit;
    //
    //   final response = await _httpClient.get(
    //     Endpoints.marketKline,  // 需要在 Endpoints 中添加此常量
    //     queryParameters: queryParams,
    //   );
    //
    //   if (response is List) {
    //     return response
    //         .map((item) => KlineData.fromJson(item as Map<String, dynamic>))
    //         .toList();
    //   }
    //   return [];
    // } catch (e) {
    //   rethrow;
    // }
  }

  /// 获取深度图数据
  ///
  /// 【注意】后端接口暂未实现，当前返回空数据
  /// TODO: 后端实现后更新此方法，添加真实接口路径到 Endpoints
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  }) async {
    // 后端接口暂未实现，返回空数据避免报错
    print('[MarketApi] ⚠️ getDepthData 接口暂未实现，返回空数据');
    return DepthChartData(
      bids: [],
      asks: [],
      lastPrice: 0.0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // TODO: 后端实现后启用以下代码
    // try {
    //   final response = await _httpClient.get(
    //     Endpoints.marketDepth,  // 需要在 Endpoints 中添加此常量
    //     queryParameters: {
    //       'symbol': symbol,
    //       if (limit != null) 'limit': limit,
    //     },
    //   );
    //
    //   return DepthChartData.fromJson(response as Map<String, dynamic>);
    // } catch (e) {
    //   rethrow;
    // }
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

