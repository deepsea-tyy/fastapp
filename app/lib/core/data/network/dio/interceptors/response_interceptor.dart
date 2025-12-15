import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:fastapp/utils/logger/network_logger.dart';
import '../../model/api_response.dart';

/// 响应拦截器：统一处理 API 响应结构
class ResponseInterceptor extends Interceptor {
  final EventBus _eventBus;

  ResponseInterceptor(this._eventBus);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 先打印响应日志，确保所有响应都能被记录（包括非200）
    NetworkLogger.logResponse(response);

    try {
      final data = response.data;
      
      if (data is! Map<String, dynamic> || !data.containsKey('code')) {
        return handler.next(response);
      }
      
      final apiResponse = ApiResponse.fromJson(data);

      if (!apiResponse.isSuccess) {
        if (apiResponse.code == 401) {
          final dioException = DioException(
            requestOptions: response.requestOptions,
            response: Response(
              requestOptions: response.requestOptions,
              data: apiResponse.toJson(),
              headers: response.headers,
              isRedirect: response.isRedirect,
              statusCode: 401,
              statusMessage: response.statusMessage,
              redirects: response.redirects,
              extra: response.extra,
            ),
            type: DioExceptionType.badResponse,
            error: apiResponse.message,
          );
          return handler.reject(dioException);
        }

        if (apiResponse.shouldShowError && apiResponse.message.isNotEmpty) {
          _eventBus.fire(ErrorMessageEvent(message: apiResponse.message));
        }

        final dioException = DioException(
          requestOptions: response.requestOptions,
          response: Response(
            requestOptions: response.requestOptions,
            data: apiResponse.toJson(),
            headers: response.headers,
            isRedirect: response.isRedirect,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            redirects: response.redirects,
            extra: response.extra,
          ),
          type: apiResponse.code == 422
              ? DioExceptionType.badResponse
              : DioExceptionType.unknown,
          error: apiResponse.message,
        );

        return handler.reject(dioException);
      }

      // 成功时只返回 data 数据，不再携带 code 和 message
      response.data = apiResponse.data ?? <String, dynamic>{};
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: '响应数据格式错误: $e',
        ),
      );
    }
    
    handler.next(response);
  }
}

/// 消息事件基类
abstract class MessageEvent {
  final String message;
  final Duration? duration;

  const MessageEvent({required this.message, this.duration});
}

/// 错误消息事件
class ErrorMessageEvent extends MessageEvent {
  const ErrorMessageEvent({required super.message, super.duration});
}

/// 成功消息事件
class SuccessMessageEvent extends MessageEvent {
  const SuccessMessageEvent({required super.message, super.duration});
}

/// 警告消息事件
class WarningMessageEvent extends MessageEvent {
  const WarningMessageEvent({required super.message, super.duration});
}

/// 信息消息事件
class InfoMessageEvent extends MessageEvent {
  const InfoMessageEvent({required super.message, super.duration});
}

