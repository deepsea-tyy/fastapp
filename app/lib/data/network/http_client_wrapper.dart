import 'dart:convert';
import 'package:fastapp/core/data/network/dio/dio_client.dart';
import 'package:fastapp/data/network/config/http_client_config.dart';
import 'package:fastapp/data/network/rest_client.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';

/// HTTP 客户端包装器
/// 
/// 根据配置自动选择使用 DioClient 或 RestClient
/// 
/// 【设计目的】
/// 1. 统一 API 调用接口，简化代码
/// 2. 支持开发时使用 DioClient（有日志），生产时切换部分接口到 RestClient（性能优化）
/// 3. 透明切换，业务代码无需修改
/// 
/// 【工作原理】
/// - 根据 HttpClientConfig.shouldUseRestClient() 判断使用哪个客户端
/// - 如果配置使用 RestClient，则调用 RestClient 并手动拼接 URL
/// - 如果配置使用 DioClient，则调用 DioClient（自动处理 baseUrl、拦截器等）
/// 
/// 【使用示例】
/// ```dart
/// final httpClient = HttpClientWrapper(
///   dioClient: getIt<DioClient>(),
///   restClient: getIt<RestClient>(),
/// );
/// 
/// // GET 请求
/// final data = await httpClient.get('/api/user/info');
/// 
/// // POST 请求
/// final result = await httpClient.post(
///   '/api/user/login',
///   data: {'username': 'test', 'password': '123456'},
/// );
/// ```
class HttpClientWrapper {
  final DioClient _dioClient;
  final RestClient _restClient;

  HttpClientWrapper({
    required DioClient dioClient,
    required RestClient restClient,
  })  : _dioClient = dioClient,
        _restClient = restClient;

  /// GET 请求
  /// 
  /// 【自动选择逻辑】
  /// - 如果端点配置为使用 RestClient，则调用 RestClient.get()
  /// - 否则调用 DioClient.dio.get()（支持拦截器、日志等）
  /// 
  /// @param endpoint 端点路径，例如：'/api/user/info'
  /// @param queryParameters 查询参数，例如：{'page': 1, 'size': 10}
  /// @return 响应数据（已解析为 JSON）
  /// 
  /// 【示例】
  /// ```dart
  /// // 简单 GET 请求
  /// final userInfo = await httpClient.get('/api/user/info');
  /// 
  /// // 带查询参数的 GET 请求
  /// final orders = await httpClient.get(
  ///   '/api/order/list',
  ///   queryParameters: {'page': 1, 'size': 20},
  /// );
  /// ```
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      dynamic responseData;
      int? statusCode;

      if (HttpClientConfig.shouldUseRestClient(endpoint)) {
        // 使用 RestClient（轻量，但无日志、无拦截器）
        final url = _buildUrl(endpoint, queryParameters);
        responseData = await _restClient.get(url);
        statusCode = 200; // RestClient 不返回状态码，假设成功
      } else {
        // 使用 DioClient（支持拦截器、日志、自动 Token 等）
        final response = await _dioClient.dio.get(
          endpoint,
          queryParameters: queryParameters,
        );
        responseData = response.data;
        statusCode = response.statusCode;
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  /// POST 请求
  /// 
  /// @param endpoint 端点路径
  /// @param data 请求体数据（会自动序列化为 JSON）
  /// @param queryParameters 查询参数
  /// @return 响应数据（已解析为 JSON）
  /// 
  /// 【示例】
  /// ```dart
  /// final result = await httpClient.post(
  ///   '/api/user/login',
  ///   data: {
  ///     'username': 'test',
  ///     'password': '123456',
  ///   },
  /// );
  /// ```
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      dynamic responseData;
      int? statusCode;

      if (HttpClientConfig.shouldUseRestClient(endpoint)) {
        // 使用 RestClient
        final url = _buildUrl(endpoint, queryParameters);
        String? body;
        if (data != null) {
          body = jsonEncode(data);
        }
        responseData = await _restClient.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        statusCode = 200; // RestClient 不返回状态码，假设成功
      } else {
        // 使用 DioClient
        final response = await _dioClient.dio.post(
          endpoint,
          data: data,
          queryParameters: queryParameters,
        );
        responseData = response.data;
        statusCode = response.statusCode;
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT 请求
  /// 
  /// @param endpoint 端点路径
  /// @param data 请求体数据
  /// @param queryParameters 查询参数
  /// @return 响应数据（已解析为 JSON）
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      dynamic responseData;
      int? statusCode;

      if (HttpClientConfig.shouldUseRestClient(endpoint)) {
        final url = _buildUrl(endpoint, queryParameters);
        String? body;
        if (data != null) {
          body = jsonEncode(data);
        }
        responseData = await _restClient.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        statusCode = 200;
      } else {
        final response = await _dioClient.dio.put(
          endpoint,
          data: data,
          queryParameters: queryParameters,
        );
        responseData = response.data;
        statusCode = response.statusCode;
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE 请求
  /// 
  /// @param endpoint 端点路径
  /// @param queryParameters 查询参数
  /// @return 响应数据（已解析为 JSON）
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      dynamic responseData;
      int? statusCode;

      if (HttpClientConfig.shouldUseRestClient(endpoint)) {
        final url = _buildUrl(endpoint, queryParameters);
        responseData = await _restClient.delete(url);
        statusCode = 200;
      } else {
        final response = await _dioClient.dio.delete(
          endpoint,
          queryParameters: queryParameters,
        );
        responseData = response.data;
        statusCode = response.statusCode;
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  /// 构建完整的 URL（用于 RestClient）
  /// 
  /// RestClient 需要完整的 URL，而 DioClient 会自动处理 baseUrl
  /// 
  /// @param endpoint 端点路径
  /// @param queryParameters 查询参数
  /// @return 完整的 URL
  String _buildUrl(String endpoint, Map<String, dynamic>? queryParameters) {
    var url = '${Endpoints.baseUrl}$endpoint';
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url = '$url?$queryString';
    }
    return url;
  }
}

