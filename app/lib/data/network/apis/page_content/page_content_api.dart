import 'package:dio/dio.dart';
import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 页面内容API实现
class PageContentApi {
  final DioClient _dioClient;

  PageContentApi(this._dioClient);

  /// 下载页面内容文件
  /// [platform] 平台：1Web 2App，默认为2（App）
  /// 返回文件内容的字符串
  Future<String> downloadPageContent({
    int platform = 2,
  }) async {
    // 服务器返回的是文件下载格式（Content-Disposition: attachment）
    // 使用 ResponseType.plain 获取原始字符串
    final response = await _dioClient.dio.get(
      Endpoints.pageContentDownload,
      queryParameters: {
        'platform': platform,
      },
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    if (response.data is String) {
      return response.data as String;
    } else {
      throw Exception('响应数据格式不正确，期望字符串，实际类型: ${response.data.runtimeType}');
    }
  }
}

