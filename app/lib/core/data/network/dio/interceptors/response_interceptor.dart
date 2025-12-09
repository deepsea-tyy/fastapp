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
      
      // 如果响应数据是 Map，检查是否符合统一响应结构
      if (data is Map<String, dynamic>) {
        // 检查是否有 code 字段（标准响应格式）
        if (data.containsKey('code')) {
          final apiResponse = ApiResponse.fromJson(data);
          
          // 如果 code 不是 200，需要处理错误
          if (!apiResponse.isSuccess) {
            // 如果是 422 或 500，发送消息事件
            if (apiResponse.shouldShowError && apiResponse.message.isNotEmpty) {
              _eventBus.fire(ErrorMessageEvent(message: apiResponse.message));
            }
            
            // 抛出 DioException，让 ErrorInterceptor 处理
            final error = DioException(
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
            
            return handler.reject(error);
          }
          
          // 成功时，将 data 字段提取出来作为响应数据
          // 如果 data 为 null，保留原始响应（可能是直接返回的数据）
          response.data = apiResponse.data ?? data;
        }
        // 如果没有 code 字段，说明响应直接是数据，保持不变
      }
    } catch (e) {
      // 如果解析失败，继续正常流程
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

