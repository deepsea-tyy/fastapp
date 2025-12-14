import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// 网络请求日志打印工具
class NetworkLogger {
  NetworkLogger._();

  /// 打印请求信息
  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final dataStr = options.data != null ? _formatDataToJson(options.data) : '';
    debugPrint('📤 [REQUEST] ${options.method} ${options.uri}${dataStr.isNotEmpty ? " | Data: $dataStr" : ""}');
  }

  /// 打印响应信息
  static void logResponse(Response response) {
    if (!kDebugMode) return;

    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final icon = isSuccess ? '✅' : '⚠️';

    final dataStr = response.data != null ? _formatDataToJson(response.data) : '';
    debugPrint('$icon [RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri} | Status: $statusCode${dataStr.isNotEmpty ? " | Data: $dataStr" : ""}');
  }

  /// 打印错误信息
  static void logError(DioException error) {
    if (!kDebugMode) return;

    final dataStr = error.response?.data != null ? _formatDataToJson(error.response!.data) : '';
    debugPrint('❌ [ERROR] ${error.requestOptions.method} ${error.requestOptions.uri} | Error: ${error.message}${dataStr.isNotEmpty ? " | Data: $dataStr" : ""}');
  }

  /// 格式化数据为紧凑的 JSON 字符串（单行显示）
  static String _formatDataToJson(dynamic data) {
    if (data is FormData) {
      return _formatFormData(data);
    }

    // 尝试解析为 JSON
    dynamic jsonData;
    if (data is String) {
      try {
        jsonData = jsonDecode(data);
      } catch (_) {
        return data;
      }
    } else {
      jsonData = data;
    }

    // 格式化为紧凑的 JSON 字符串（不带缩进）
    try {
      const encoder = JsonEncoder(); // 不带缩进，单行输出
      return encoder.convert(jsonData);
    } catch (_) {
      return data.toString();
    }
  }

  /// 格式化 FormData 为字符串
  static String _formatFormData(FormData formData) {
    final parts = <String>[];
    for (var field in formData.fields) {
      parts.add('${field.key}=${field.value}');
    }
    if (formData.files.isNotEmpty) {
      for (var file in formData.files) {
        parts.add('${file.key}=${file.value.filename}');
      }
    }
    return parts.join(', ');
  }
}

