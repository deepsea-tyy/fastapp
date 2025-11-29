import '../order/order.dart';

/// 交易响应实体
class TradeResponse {
  /// 是否成功
  final bool success;
  
  /// 订单信息（成功时）
  final Order? order;
  
  /// 错误消息（失败时）
  final String? errorMessage;
  
  /// 错误代码（失败时）
  final String? errorCode;
  
  /// 响应时间戳
  final int timestamp;

  TradeResponse({
    required this.success,
    this.order,
    this.errorMessage,
    this.errorCode,
    required this.timestamp,
  });

  /// 从JSON创建
  factory TradeResponse.fromJson(Map<String, dynamic> json) {
    return TradeResponse(
      success: json['success'] as bool,
      order: json['order'] != null
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      errorMessage: json['errorMessage'] as String?,
      errorCode: json['errorCode'] as String?,
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'order': order?.toJson(),
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'timestamp': timestamp,
    };
  }

  /// 创建成功响应
  factory TradeResponse.success(Order order) {
    return TradeResponse(
      success: true,
      order: order,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 创建失败响应
  factory TradeResponse.failure(String errorMessage, {String? errorCode}) {
    return TradeResponse(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

