import 'dart:async';
import '../../../mock/mock_market_data.dart';
import '../../../../domain/entity/market/kline_data.dart';
import '../../../../domain/entity/market/depth_data.dart';
import '../../../../domain/entity/market/ticker_data.dart';
import '../../../../domain/entity/market/market_pair.dart';
import '../../../../domain/entity/market/market_data_config.dart';
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

  /// 获取K线数据（暂时使用Mock数据）
  Future<List<KlineData>> getKlineData({
    required String symbol,
    required String interval,
    int? startTime,
    int? endTime,
    int? limit,
  }) async {
    // TODO: 对接真实K线API
    return MockMarketData.generateKlineData(
      symbol: symbol,
      interval: interval,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
    );
  }

  /// 获取深度图数据（暂时使用Mock数据）
  Future<DepthChartData> getDepthData({
    required String symbol,
    int? limit,
  }) async {
    // TODO: 对接真实深度API
    return MockMarketData.generateDepthData(
      symbol: symbol,
      limit: limit ?? 20,
    );
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
        '/api/ds/ex/currency/ticker/$symbol',
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
  /// @return TickerData 列表
  Future<List<TickerData>> getAllTickerData() async {
    try {
      final response = await _httpClient.get(
        '/api/ds/ex/currency/tickers',
      );

      List<dynamic> tickerList = [];

      // 支持多种响应格式
      if (response is List) {
        // 格式1: 直接返回 List
        tickerList = response;
      } else if (response is Map) {
        // 格式2: { list: [...] }
        if (response['list'] is List) {
          tickerList = response['list'] as List;
        }
        // 格式3: { data: [...] } (ApiResponse 格式)
        else if (response['data'] is List) {
          tickerList = response['data'] as List;
        }
        // 格式4: { tickers: [...] }
        else if (response['tickers'] is List) {
          tickerList = response['tickers'] as List;
        }
      }

      if (tickerList.isEmpty) {
        return [];
      }
      
      // 解析 TickerData 列表
      final result = tickerList.map((item) {
        try {
          return TickerData.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      }).whereType<TickerData>().toList();

      return result;
    } catch (e) {
      // 重新抛出异常，让上层处理
      rethrow;
    }
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
        '/api/ds/ex/currency/marketPair',
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
        '/api/ds/ex/currency/marketPair',
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
}

