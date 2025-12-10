/// 需要二次验证的异常
class VerifyAgainException implements Exception {
  final String verifyType; // 'google2fa_code' 或 'email_code'
  final String? email; // 邮箱地址（部分隐藏，仅用于显示）

  VerifyAgainException(this.verifyType, {this.email});

  @override
  String toString() => '需要二次验证: $verifyType';
}

