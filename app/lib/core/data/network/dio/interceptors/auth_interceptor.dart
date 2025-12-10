import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';

class AuthInterceptor extends Interceptor {
  final AsyncValueGetter<String?> accessToken;

  AuthInterceptor({
    required this.accessToken,
  });

  /// 检查是否是无需添加token的请求
  bool _shouldSkipToken(String path) {
    return path == Endpoints.userRefreshToken || 
           path == Endpoints.userLogout ||
           path == Endpoints.userLogin;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 跳过refresh token、logout和login请求的token添加
    if (!_shouldSkipToken(options.path)) {
      final String token = await accessToken() ?? '';
      if (token.isNotEmpty) {
        options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
      }
    }

    super.onRequest(options, handler);
  }
}
