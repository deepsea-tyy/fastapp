import 'package:dio/dio.dart';

/// 错误处理工具类
class ErrorHandler {
  /// 从 DioException 提取错误消息
  static String getErrorMessage(dynamic error, {String defaultMessage = '操作失败'}) {
    if (error is DioException) {
      // 优先使用响应中的消息
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        // 如果有状态码，返回状态码错误
        if (error.response!.statusCode != null) {
          return '服务器错误: ${error.response!.statusCode}';
        }
      }
      // 使用 DioException 的错误消息
      return error.message ?? defaultMessage;
    }
    // 其他异常
    return error.toString();
  }
}

