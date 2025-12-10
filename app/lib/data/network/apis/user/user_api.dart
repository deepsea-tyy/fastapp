import 'package:dio/dio.dart';
import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 用户API实现
class UserApi {
  final DioClient _dioClient;

  UserApi(this._dioClient);

  /// 登录
  /// [type] 登录类型：1=用户名密码，2=手机验证码，3=邮箱验证码
  /// [username] 用户名（type=1时使用，可选）
  /// [password] 密码（type=1时使用）
  /// [mobile] 手机号（type=1或2时使用）
  /// [email] 邮箱（type=1或3时使用）
  /// [code] mobile code（手机区号）
  /// [vcode] 验证码（type=2或3时使用，或二次验证时使用）
  /// [scene] 验证码场景（type=2或3时使用，默认为'login'）
  /// [google2faCode] Google2FA验证码（二次验证时使用）
  Future<Map<String, dynamic>> login({
    required int type,
    String? username,
    String? password,
    String? mobile,
    String? email,
    String? code,
    String? vcode,
    String? scene,
    int? google2faCode,
  }) async {
    final data = <String, dynamic>{'type': type};

    // 根据登录类型设置参数
    switch (type) {
      case 1: // 用户名密码登录
        if (username != null) data['username'] = username;
        if (mobile != null) data['mobile'] = mobile;
        if (email != null) data['email'] = email;
        if (password != null) data['password'] = password;
        if (code != null) data['code'] = code;
        if (vcode != null) {
          data['vcode'] = vcode;
          data['scene'] = scene ?? 'login';
        }
        break;
      case 2: // 手机验证码登录
        if (mobile != null) data['mobile'] = mobile;
        if (code != null) data['code'] = code;
        if (vcode != null) data['vcode'] = vcode;
        data['scene'] = scene ?? 'login';
        break;
      case 3: // 邮箱验证码登录
        if (email != null) data['email'] = email;
        if (vcode != null) data['vcode'] = vcode;
        data['scene'] = scene ?? 'login';
        break;
    }

    // 二次验证参数
    if (google2faCode != null) {
      data['google2fa_code'] = google2faCode;
    }

    final response = await _dioClient.dio.post(Endpoints.userLogin, data: data);
    return response.data;
  }

  /// 发送验证码
  /// [mobile] 手机号
  /// [scene] 验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)
  Future<Map<String, dynamic>> sendSms({
    required String mobile,
    String scene = 'login',
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.userSms,
      queryParameters: {
        'mobile': mobile,
        'scene': scene,
      },
    );

    return response.data;
  }

  /// 发送邮箱验证码
  /// [email] 邮箱地址
  /// [scene] 验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)
  Future<Map<String, dynamic>> sendEmailCode({
    required String email,
    String scene = 'login',
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.userSms,
      queryParameters: {
        'mobile': email, // 服务端使用 mobile 字段接收邮箱
        'scene': scene,
      },
    );

    return response.data;
  }

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _dioClient.dio.get(
      Endpoints.userInfo,
    );

    return response.data;
  }

  /// 退出登录
  Future<Map<String, dynamic>> logout() async {
    final response = await _dioClient.dio.post(
      Endpoints.userLogout,
    );

    return response.data;
  }

  /// 刷新token
  /// [refreshTokenValue] refresh_token 字符串
  Future<Map<String, dynamic>> refreshToken(String refreshTokenValue) async {
    final response = await _dioClient.dio.post(
      Endpoints.userRefreshToken,
      options: Options(
        headers: {'token': refreshTokenValue},
      ),
    );
    return response.data;
  }

  /// 获取Google2FA二维码和密钥
  /// 返回: { "google2fa": "密钥", "qrcode": "base64编码的SVG二维码" }
  Future<Map<String, dynamic>> getGoogle2faQrcode() async {
    final response = await _dioClient.dio.get(Endpoints.google2faQrcode);
    return response.data;
  }

  /// 绑定Google2FA
  /// [secret] Google2FA密钥
  /// [code] 6位验证码
  Future<Map<String, dynamic>> bindGoogle2fa({
    required String secret,
    required String code,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.google2faBind,
      data: {
        'google2fa': secret,
        'google2fa_code': code,
      },
    );
    return response.data;
  }

  /// 解绑Google2FA
  /// [code] 6位验证码
  Future<Map<String, dynamic>> unbindGoogle2fa({
    required String code,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.google2faUnbind,
      data: {
        'google2fa_code': code,
      },
    );
    return response.data;
  }
}

