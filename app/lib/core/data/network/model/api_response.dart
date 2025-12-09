/// 统一的 API 响应结构
class ApiResponse<T> {
  /// 响应码：200=成功，422=验证错误，500=服务器错误
  final int code;

  /// 响应消息
  final String message;

  /// 响应数据
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 从 JSON 创建
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? (fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
    };
  }

  /// 是否成功
  bool get isSuccess => code == 200;

  /// 是否需要显示错误消息
  bool get shouldShowError => code == 422 || code == 500;
}

