import 'package:fastapp/data/network/constants/endpoints.dart';

/// HTTP 客户端配置类
/// 
/// 用于控制哪些接口使用 RestClient，哪些使用 DioClient
/// 
/// 【开发阶段】
/// - 默认所有接口使用 DioClient，方便调试和查看日志
/// - 所有请求都会通过 LoggingInterceptor 打印请求路由和响应
/// 
/// 【生产环境优化】
/// - 可以将高频、不需要认证的接口配置为使用 RestClient
/// - RestClient 更轻量，可以减少包体积和内存占用
/// - 但会失去日志、自动 Token 刷新等功能
/// 
/// 【使用示例】
/// ```dart
/// // 开发时：默认使用 DioClient，无需配置
/// 
/// // 生产环境：配置特定接口使用 RestClient
/// HttpClientConfig.addRestClientEndpoint(Endpoints.marketTicker);
/// HttpClientConfig.addRestClientEndpoint(Endpoints.marketKline);
/// 
/// // 查看当前配置
/// print(HttpClientConfig.restClientEndpoints);
/// 
/// // 清空配置（全部使用 DioClient）
/// HttpClientConfig.clearRestClientEndpoints();
/// ```
class HttpClientConfig {
  HttpClientConfig._();

  /// 默认使用 DioClient（开发时方便调试）
  /// 
  /// - true: 默认使用 DioClient（推荐开发时使用）
  /// - false: 默认使用 RestClient（不推荐，会失去日志等功能）
  static const bool defaultUseDioClient = true;

  /// 配置哪些端点使用 RestClient（生产环境优化）
  /// 
  /// 当端点在此集合中时，将使用 RestClient 而不是 DioClient
  /// 返回 true 表示使用 RestClient，false 表示使用 DioClient
  /// 
  /// 【注意事项】
  /// - RestClient 不支持拦截器，因此不会打印日志
  /// - RestClient 不会自动添加 Token 和认证信息
  /// - RestClient 不会自动刷新过期的 Token
  /// - 建议只对公开的、高频的、不需要认证的接口使用 RestClient
  static final Set<String> _restClientEndpoints = {
    // 生产环境可以在这里配置需要使用 RestClient 的端点
    // 例如：
    // Endpoints.marketTicker,  // 行情 Ticker 接口（高频、公开）
    // Endpoints.marketKline,   // K线数据接口（高频、公开）
    // Endpoints.marketDepth,   // 深度数据接口（高频、公开）
  };

  /// 检查指定端点是否应该使用 RestClient
  /// 
  /// 【逻辑说明】
  /// 1. 如果配置了使用 RestClient 的端点列表，则检查端点是否在列表中
  /// 2. 如果列表为空，则根据 defaultUseDioClient 决定
  /// 3. 默认返回 false（使用 DioClient）
  /// 
  /// @param endpoint 端点路径，例如：'/api/ds/ex/currency/ticker'
  /// @return true 表示使用 RestClient，false 表示使用 DioClient
  static bool shouldUseRestClient(String endpoint) {
    // 如果配置了使用 RestClient 的端点列表，则检查
    if (_restClientEndpoints.isNotEmpty) {
      return _restClientEndpoints.contains(endpoint);
    }
    
    // 默认使用 DioClient（开发时）
    return !defaultUseDioClient;
  }

  /// 添加需要使用 RestClient 的端点（生产环境配置）
  /// 
  /// 【使用场景】
  /// - 高频接口（如行情数据）
  /// - 公开接口（不需要认证）
  /// - 对性能要求极高的接口
  /// 
  /// @param endpoint 端点路径，例如：Endpoints.marketTicker
  /// 
  /// 【示例】
  /// ```dart
  /// HttpClientConfig.addRestClientEndpoint(Endpoints.marketTicker);
  /// ```
  static void addRestClientEndpoint(String endpoint) {
    _restClientEndpoints.add(endpoint);
  }

  /// 批量添加需要使用 RestClient 的端点
  /// 
  /// @param endpoints 端点路径列表
  /// 
  /// 【示例】
  /// ```dart
  /// HttpClientConfig.addRestClientEndpoints([
  ///   Endpoints.marketTicker,
  ///   Endpoints.marketKline,
  ///   Endpoints.marketDepth,
  /// ]);
  /// ```
  static void addRestClientEndpoints(List<String> endpoints) {
    _restClientEndpoints.addAll(endpoints);
  }

  /// 移除 RestClient 端点配置
  /// 
  /// 移除后，该端点将使用 DioClient
  /// 
  /// @param endpoint 端点路径
  static void removeRestClientEndpoint(String endpoint) {
    _restClientEndpoints.remove(endpoint);
  }

  /// 清空所有 RestClient 端点配置（全部使用 DioClient）
  /// 
  /// 【使用场景】
  /// - 开发阶段：确保所有接口都使用 DioClient，方便调试
  /// - 需要重新配置时：先清空再重新添加
  /// 
  /// 【示例】
  /// ```dart
  /// // 开发时：清空配置，全部使用 DioClient
  /// HttpClientConfig.clearRestClientEndpoints();
  /// ```
  static void clearRestClientEndpoints() {
    _restClientEndpoints.clear();
  }

  /// 获取所有配置的 RestClient 端点（只读）
  /// 
  /// @return 不可修改的端点集合
  static Set<String> get restClientEndpoints => Set.unmodifiable(_restClientEndpoints);

  /// 检查是否配置了任何 RestClient 端点
  /// 
  /// @return true 如果配置了 RestClient 端点，false 否则
  static bool get hasRestClientEndpoints => _restClientEndpoints.isNotEmpty;
}

