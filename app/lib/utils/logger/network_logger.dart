import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// 网络请求日志打印工具
class NetworkLogger {
  NetworkLogger._();

  static const String _indent = '  ';

  /// 打印请求信息
  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    debugPrint('📤 [REQUEST] ${options.method} ${options.uri}');
    if (options.data != null) {
      _printData(options.data);
    }
  }

  /// 打印响应信息
  static void logResponse(Response response) {
    if (!kDebugMode) return;

    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final icon = isSuccess ? '✅' : '⚠️';

    debugPrint('$icon [RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri}');
    if (response.data != null) {
      _printData(response.data);
    }
  }

  /// 打印错误信息
  static void logError(DioException error) {
    if (!kDebugMode) return;

    debugPrint('❌ [ERROR] ${error.requestOptions.method} ${error.requestOptions.uri}');

    if (error.response != null && error.response!.data != null) {
      _printData(error.response!.data);
    }
  }

  /// 打印数据（统一格式化为 JSON 字符串，只打印数据本身）
  static void _printData(dynamic data) {
    if (data is FormData) {
      _printFormData(data);
      return;
    }

    // 尝试解析为 JSON
    dynamic jsonData;
    if (data is String) {
      try {
        jsonData = jsonDecode(data);
      } catch (_) {
        debugPrint(data);
        return;
      }
    } else {
      jsonData = data;
    }

    // 格式化为 JSON 字符串打印，只打印数据本身
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(jsonData);
      debugPrint(jsonString);
    } catch (_) {
      debugPrint(data.toString());
    }
  }

  /// 打印 FormData
  static void _printFormData(FormData formData) {
    formData.fields.forEach((field) {
      debugPrint('${field.key}: ${field.value}');
    });
    if (formData.files.isNotEmpty) {
      formData.files.forEach((file) {
        debugPrint('${file.key}: ${file.value.filename}');
      });
    }
  }
}

