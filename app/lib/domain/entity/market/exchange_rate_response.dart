/// 汇率响应实体
class ExchangeRateResponse {
  /// 人民币汇率
  final double cny;

  /// 韩元汇率
  final double krw;

  /// 欧元汇率
  final double eur;

  /// 日元汇率
  final double jpy;

  ExchangeRateResponse({
    required this.cny,
    required this.krw,
    required this.eur,
    required this.jpy,
  });

  /// 从 JSON 创建
  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      cny: double.tryParse(json['cny']?.toString() ?? '7') ?? 7.0,
      krw: double.tryParse(json['krw']?.toString() ?? '1441.55') ?? 1441.55,
      eur: double.tryParse(json['eur']?.toString() ?? '0.848939') ?? 0.848939,
      jpy: double.tryParse(json['jpy']?.toString() ?? '156.5') ?? 156.5,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'cny': cny,
      'krw': krw,
      'eur': eur,
      'jpy': jpy,
    };
  }
}

