import 'dart:async';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:fastapp/data/network/constants/endpoints.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';

class TokenRefreshInterceptor extends Interceptor {
  final SharedPreferenceHelper _sharedPrefsHelper;
  final Dio _dio;
  final EventBus _eventBus;
  
  Completer<void>? _refreshTokenCompleter;
  bool _isRefreshing = false;

  TokenRefreshInterceptor({
    required SharedPreferenceHelper sharedPrefsHelper,
    required Dio dio,
    required EventBus eventBus,
  })  : _sharedPrefsHelper = sharedPrefsHelper,
        _dio = dio,
        _eventBus = eventBus;

  bool _shouldSkipRequest(String path) {
    return path == Endpoints.userRefreshToken ||
           path == Endpoints.userLogin ||
           path == Endpoints.userLogout ||
           path == Endpoints.userRegister;
  }

  bool _isUnauthorizedResponse(Response response) {
    if (response.statusCode == 401) return true;
    final data = response.data;
    return data is Map<String, dynamic> && data['code'] == 401;
  }

  Future<void> _refreshToken() async {
    if (_isRefreshing) {
      return _refreshTokenCompleter?.future ?? Future.value();
    }

    _isRefreshing = true;
    _refreshTokenCompleter = Completer<void>();

    try {
      final refreshTokenValue = await _sharedPrefsHelper.refreshToken;
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        print('❌ [TokenRefresh] 未找到refresh_token，无法刷新token');
        throw Exception('刷新token失败：未找到refresh_token');
      }

      final refreshDio = Dio(_dio.options);
      refreshDio.interceptors.clear();
      
      final response = await refreshDio.post(
        Endpoints.userRefreshToken,
        data: {
          'refresh_token': refreshTokenValue,
        },
        options: Options(
          headers: {
            'Accept-Language': _dio.options.headers['Accept-Language'] ?? 'zh-CN',
          },
        ),
      );
      
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('刷新token失败：响应格式错误');
      }
      
      if (data.containsKey('code') && data['code'] == 401) {
        final message = data['message'] as String? ?? '刷新token失败：refresh_token已过期';
        print('❌ [TokenRefresh] 刷新token失败: $message');
        throw Exception(message);
      }
      
      Map<String, dynamic> tokenData;
      if (data.containsKey('code') && data['code'] == 200 && data.containsKey('data')) {
        tokenData = data['data'] as Map<String, dynamic>;
      } else if (data.containsKey('access_token')) {
        tokenData = data;
      } else {
        throw Exception(data['message'] as String? ?? '刷新token失败：响应格式错误');
      }
      
      final accessToken = tokenData['access_token'] as String?;
      if (accessToken == null) {
        throw Exception('刷新token失败：未获取到访问令牌');
      }

      await _sharedPrefsHelper.saveAuthToken(accessToken);
      if (tokenData['refresh_token'] != null) {
        await _sharedPrefsHelper.saveRefreshToken(tokenData['refresh_token'] as String);
      }
      if (tokenData['expire_at'] != null) {
        await _sharedPrefsHelper.saveExpireAt(tokenData['expire_at'] as int);
      }

      _refreshTokenCompleter!.complete();
    } catch (e) {
      print('❌ [TokenRefresh] 刷新token失败: $e');
      _refreshTokenCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshTokenCompleter = null;
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final path = response.requestOptions.path;
    
    if (_shouldSkipRequest(path) || !_isUnauthorizedResponse(response)) {
      return handler.next(response);
    }

    final refreshTokenValue = await _sharedPrefsHelper.refreshToken;
    if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
      print('❌ [TokenRefresh] 未找到refresh_token，无法刷新token');
      await _clearAllUserData();
      _eventBus.fire(ForceLogoutEvent(message: '登录已过期，请重新登录'));
      final data = response.data;
      final errorMessage = (data is Map<String, dynamic>) 
          ? (data['message'] as String? ?? '未授权')
          : '未授权';
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: errorMessage,
        ),
      );
    }

    try {
      await _refreshToken();
      final newToken = await _sharedPrefsHelper.authToken;
      if (newToken == null || newToken.isEmpty) {
        throw Exception('刷新token后未获取到新的访问令牌');
      }

      response.requestOptions.headers['Token'] = newToken;
      response.requestOptions.headers.remove('Authorization');
      
      final retryResponse = await _dio.request(
        path,
        data: response.requestOptions.data,
        queryParameters: response.requestOptions.queryParameters,
        options: Options(
          method: response.requestOptions.method,
          headers: response.requestOptions.headers,
          extra: response.requestOptions.extra,
          responseType: response.requestOptions.responseType,
          contentType: response.requestOptions.contentType,
          validateStatus: response.requestOptions.validateStatus,
          receiveDataWhenStatusError: response.requestOptions.receiveDataWhenStatusError,
          followRedirects: response.requestOptions.followRedirects,
          maxRedirects: response.requestOptions.maxRedirects,
          persistentConnection: response.requestOptions.persistentConnection,
          requestEncoder: response.requestOptions.requestEncoder,
          responseDecoder: response.requestOptions.responseDecoder,
          listFormat: response.requestOptions.listFormat,
        ),
        cancelToken: response.requestOptions.cancelToken,
        onSendProgress: response.requestOptions.onSendProgress,
        onReceiveProgress: response.requestOptions.onReceiveProgress,
      );

      return handler.resolve(retryResponse);
    } catch (e) {
      print('❌ [TokenRefresh] 刷新token流程失败: $e');
      await _clearAllUserData();
      _eventBus.fire(ForceLogoutEvent(message: '登录已过期，请重新登录'));
      final data = response.data;
      final errorMessage = (data is Map<String, dynamic>) 
          ? (data['message'] as String? ?? '未授权')
          : '未授权';
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: errorMessage,
        ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    
    if (_shouldSkipRequest(path) || err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }
    
    try {
      await _refreshToken();
      final newToken = await _sharedPrefsHelper.authToken;
      if (newToken == null || newToken.isEmpty) {
        throw Exception('刷新token后未获取到新的访问令牌');
      }

      err.requestOptions.headers['Token'] = newToken;
      err.requestOptions.headers.remove('Authorization');
      
      final response = await _dio.request(
        path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: err.requestOptions.extra,
          responseType: err.requestOptions.responseType,
          contentType: err.requestOptions.contentType,
          validateStatus: err.requestOptions.validateStatus,
          receiveDataWhenStatusError: err.requestOptions.receiveDataWhenStatusError,
          followRedirects: err.requestOptions.followRedirects,
          maxRedirects: err.requestOptions.maxRedirects,
          persistentConnection: err.requestOptions.persistentConnection,
          requestEncoder: err.requestOptions.requestEncoder,
          responseDecoder: err.requestOptions.responseDecoder,
          listFormat: err.requestOptions.listFormat,
        ),
        cancelToken: err.requestOptions.cancelToken,
        onSendProgress: err.requestOptions.onSendProgress,
        onReceiveProgress: err.requestOptions.onReceiveProgress,
      );

      return handler.resolve(response);
    } catch (e) {
      print('❌ [TokenRefresh] 刷新token流程失败: $e');
      await _clearAllUserData();
      _eventBus.fire(ForceLogoutEvent(message: '登录已过期，请重新登录'));
      return super.onError(err, handler);
    }
  }

  Future<void> _clearAllUserData() async {
    try {
      // 使用统一方法清除所有用户相关数据（认证 + 用户数据）
      await _sharedPrefsHelper.clearAllUserRelatedData();
    } catch (e) {
      // 忽略清除失败
    }
  }
}

class ForceLogoutEvent {
  final String message;

  ForceLogoutEvent({required this.message});
}
