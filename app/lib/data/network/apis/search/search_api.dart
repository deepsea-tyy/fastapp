import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 搜索API实现
class SearchApi {
  final DioClient _dioClient;

  SearchApi(this._dioClient);

  /// 全局搜索
  /// [keyword] 搜索关键词
  /// [type] 类型筛选: all|article|feed|activity
  /// [sort] 排序方式: relevance|time|weight|hot
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<Map<String, dynamic>> search({
    required String keyword,
    String type = 'all',
    String sort = 'relevance',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.search,
      queryParameters: {
        'keyword': keyword,
        'type': type,
        'sort': sort,
        'page': page,
        'page_size': pageSize,
      },
    );

    return response.data;
  }

  /// 搜索建议
  /// [keyword] 搜索关键词前缀
  /// [limit] 返回数量
  Future<Map<String, dynamic>> suggest({
    required String keyword,
    int limit = 10,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.searchSuggest,
      queryParameters: {
        'keyword': keyword,
        'limit': limit,
      },
    );

    return response.data;
  }

  /// 热门关键词列表
  /// [limit] 返回数量
  Future<Map<String, dynamic>> hotKeywords({
    int limit = 10,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.searchKeywordsHot,
      queryParameters: {
        'limit': limit,
      },
    );

    return response.data;
  }
}
