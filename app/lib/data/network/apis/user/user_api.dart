import 'package:dio/dio.dart';
import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 用户API实现
class UserApi {
  final DioClient _dioClient;

  UserApi(this._dioClient);

  /// 登录
  /// [type] 登录类型：1=用户名密码，2=手机验证码
  /// [username] 用户名（type=1时使用）
  /// [password] 密码（type=1时使用）
  /// [mobile] 手机号（type=2时使用）
  /// [code] 验证码（type=2时使用）
  /// [scene] 验证码场景（type=2时使用，默认为'login'）
  Future<Map<String, dynamic>> login({
    required int type,
    String? username,
    String? password,
    String? mobile,
    String? code,
    String? scene,
  }) async {
    final data = <String, dynamic>{
      'type': type,
    };

    if (type == 1) {
      // 用户名密码登录
      if (username != null) data['username'] = username;
      if (password != null) data['password'] = password;
    } else if (type == 2) {
      // 手机验证码登录
      if (mobile != null) data['mobile'] = mobile;
      if (code != null) data['code'] = code;
      // scene 默认为 'login'
      data['scene'] = scene ?? 'login';
    }

    final response = await _dioClient.dio.post(
      Endpoints.userLogin,
      data: data,
    );

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

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _dioClient.dio.get(
      Endpoints.userInfo,
    );

    return response.data;
  }
}

