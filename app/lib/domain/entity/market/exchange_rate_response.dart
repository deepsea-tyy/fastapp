/// 汇率响应实体
class ExchangeRateResponse {
  /// 人民币汇率
  final double cny;

  ExchangeRateResponse({
    required this.cny,
  });

  /// 从 JSON 创建
  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      cny: (json['cny'] as num?)?.toDouble() ?? 7.08,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'cny': cny,
    };
  }
}

