/// 需要二次验证的异常
class VerifyAgainException implements Exception {
  final String verifyType; // 'google2fa_code'、'email_code' 或 'mobile_code'
  final String? email; // 邮箱地址（部分隐藏，仅用于显示）
  final String? mobile; // 手机号（部分隐藏，仅用于显示）
  final String? code; // 手机区号（如 "86"）
  final String? deviceId; // 设备唯一标识

  VerifyAgainException(this.verifyType, {this.email, this.mobile, this.code, this.deviceId});

  @override
  String toString() => '需要二次验证: $verifyType';
}

