import '../../../core/domain/usecase/use_case.dart';
import '../../entity/user/user.dart';
import '../../repository/user/user_repository.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_usecase.g.dart';

@JsonSerializable()
class LoginParams {
  final int type; // 1=用户名密码，2=手机验证码，3=邮箱验证码
  final String? username;
  final String? password;
  final String? mobile; // 手机号
  final String? email; // 邮箱
  final String? code; // mobile code（手机区号）
  final String? vcode; // 验证码（type=2或3时使用，或二次验证时使用）
  final String? scene; // 验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)
  @JsonKey(name: 'google2fa_code')
  final int? google2faCode; // Google2FA验证码（二次验证时使用）
  @JsonKey(name: 'device_id')
  final String? deviceId; // 设备唯一标识（iOS/Android/Web通用）

  LoginParams({
    required this.type,
    this.username,
    this.password,
    this.mobile,
    this.email,
    this.code,
    this.vcode,
    this.scene,
    this.google2faCode,
    this.deviceId,
  });

  factory LoginParams.fromJson(Map<String, dynamic> json) =>
      _$LoginParamsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginParamsToJson(this);
}

class LoginUseCase implements UseCase<User?, LoginParams> {
  final UserRepository _userRepository;

  LoginUseCase(this._userRepository);

  @override
  Future<User?> call({required LoginParams params}) async {
    return _userRepository.login(params);
  }
}