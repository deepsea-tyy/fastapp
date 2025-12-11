import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import '../../model/api_response.dart';

/// 响应拦截器：统一处理 API 响应结构
class ResponseInterceptor extends Interceptor {
  final EventBus _eventBus;

  ResponseInterceptor(this._eventBus);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final data = response.data;
      
      if (data is! Map<String, dynamic>) {
        return handler.next(response);
      }
      
      if (!data.containsKey('code')) {
        return handler.next(response);
      }
      
      final apiResponse = ApiResponse.fromJson(data);
      
      if (!apiResponse.isSuccess) {
        if (apiResponse.shouldShowError && apiResponse.message.isNotEmpty) {
          _eventBus.fire(ErrorMessageEvent(message: apiResponse.message));
        }
        
        return handler.reject(
          DioException(
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
          ),
        );
      }
      
      final responseData = apiResponse.data ?? data;
      if (!responseData.containsKey('code')) {
        responseData['code'] = apiResponse.code;
      }
      if (!responseData.containsKey('message')) {
        responseData['message'] = apiResponse.message;
      }
      response.data = responseData;
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

