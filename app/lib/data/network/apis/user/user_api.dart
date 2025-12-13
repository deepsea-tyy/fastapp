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
  /// [deviceId] 设备唯一标识（iOS/Android/Web通用，可选）
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
    String? deviceId,
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

    // 设备唯一标识（iOS/Android/Web通用）
    if (deviceId != null && deviceId.isNotEmpty) {
      data['device_id'] = deviceId;
    }

    final response = await _dioClient.dio.post(Endpoints.userLogin, data: data);
    return response.data;
  }

  /// 发送验证码
  /// [mobile] 手机号
  /// [code] 国家代码（可选，默认86）
  /// [scene] 验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)
  Future<Map<String, dynamic>> sendSms({
    required String mobile,
    String? code,
    String scene = 'login',
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.userSms,
      queryParameters: {
        'type': 'sms',
        'to': mobile,
        if (code != null) 'code': code,
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
        'type': 'email',
        'to': email,
        'scene': scene,
      },
    );

    return response.data;
  }

  /// 验证验证码
  /// [type] 验证码类型：'sms'(手机短信)或'email'(邮箱)
  /// [to] 接收地址：手机号或邮箱地址
  /// [vcode] 验证码
  /// [scene] 验证码场景：login(登录)、register(注册)、reset_password(找回密码)、bind(绑定)、change(修改)、default(默认)
  /// [code] 国家代码（仅手机短信需要，可选，默认86）
  Future<Map<String, dynamic>> smsCheck({
    required String type,
    required String to,
    required String vcode,
    String scene = 'register',
    String? code,
  }) async {
    final data = {
      'type': type,
      'to': to,
      'vcode': vcode,
      'scene': scene,
    };
    if (code != null) {
      data['code'] = code;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.userSmsCheck,
      data: data,
    );

    return response.data;
  }

  /// 注册
  /// [type] 注册类型：2=手机验证码，3=邮箱验证码
  /// [mobile] 手机号（type=2时使用）
  /// [email] 邮箱（type=3时使用）
  /// [code] 国家代码（type=2时使用）
  /// [vcode] 验证码
  /// [password] 密码
  /// [passwordConfirmation] 确认密码
  /// [scene] 验证码场景（默认为'register'）
  /// [deviceId] 设备唯一标识（可选）
  Future<Map<String, dynamic>> register({
    required int type,
    String? mobile,
    String? email,
    String? code,
    required String vcode,
    required String password,
    required String passwordConfirmation,
    String scene = 'register',
    String? deviceId,
  }) async {
    final data = <String, dynamic>{
      'type': type,
      'vcode': vcode,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'scene': scene,
    };

    if (type == 2) {
      // 手机验证码注册
      if (mobile != null) data['mobile'] = mobile;
      if (code != null) data['code'] = code;
    } else if (type == 3) {
      // 邮箱验证码注册
      if (email != null) data['email'] = email;
    }

    // 添加设备ID
    if (deviceId != null && deviceId.isNotEmpty) {
      data['device_id'] = deviceId;
    }

    final response = await _dioClient.dio.post(
      Endpoints.userRegister,
      data: data,
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

  /// 绑定邮箱
  /// [email] 邮箱地址
  /// [vcode] 6位验证码
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  Future<Map<String, dynamic>> bindEmail({
    required String email,
    required String vcode,
    String? google2faCode,
  }) async {
    final data = {
      'email': email,
      'vcode': vcode,
    };
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.emailBind,
      data: data,
    );
    return response.data;
  }

  /// 解绑邮箱
  /// [vcode] 6位验证码
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  Future<Map<String, dynamic>> unbindEmail({
    required String vcode,
    String? google2faCode,
  }) async {
    final data = {
      'vcode': vcode,
    };
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.emailUnbind,
      data: data,
    );
    return response.data;
  }

  /// 绑定手机号
  /// [mobile] 手机号
  /// [code] 国家代码（如 "86"）
  /// [vcode] 6位验证码
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  Future<Map<String, dynamic>> bindMobile({
    required String mobile,
    required String code,
    required String vcode,
    String? google2faCode,
  }) async {
    final data = {
      'mobile': mobile,
      'code': code,
      'vcode': vcode,
    };
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.mobileBind,
      data: data,
    );
    return response.data;
  }

  /// 解绑手机号
  /// [code] 国家代码（如 "86"）
  /// [vcode] 6位验证码
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  Future<Map<String, dynamic>> unbindMobile({
    required String code,
    required String vcode,
    String? google2faCode,
  }) async {
    final data = {
      'code': code,
      'vcode': vcode,
    };
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.mobileUnbind,
      data: data,
    );
    return response.data;
  }

  /// 修改密码
  /// [oldPassword] 旧密码（如果已设置密码则必填）
  /// [password] 新密码
  /// [passwordConfirmation] 确认新密码
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  /// [vcode] 验证码（如果用户没有设置Google2FA，则根据邮箱或手机号必填）
  Future<Map<String, dynamic>> changePassword({
    String? oldPassword,
    required String password,
    required String passwordConfirmation,
    String? google2faCode,
    String? vcode,
  }) async {
    final data = {
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    if (oldPassword != null && oldPassword.isNotEmpty) {
      data['old_password'] = oldPassword;
    }
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    if (vcode != null && vcode.isNotEmpty) {
      data['vcode'] = vcode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.passwordChange,
      data: data,
    );
    return response.data;
  }

  /// 禁用账户
  /// [password] 密码（如果已设置密码则必填）
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  /// [vcode] 验证码（如果用户没有设置Google2FA，则根据邮箱或手机号必填）
  Future<Map<String, dynamic>> disableAccount({
    required String password,
    String? google2faCode,
    String? vcode,
  }) async {
    final data = {
      'password': password,
    };
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    if (vcode != null && vcode.isNotEmpty) {
      data['vcode'] = vcode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.accountDisable,
      data: data,
    );
    return response.data;
  }

  /// 删除账户
  /// [password] 密码（如果已设置密码则必填）
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  /// [vcode] 验证码（如果用户没有设置Google2FA，则根据邮箱或手机号必填）
  Future<Map<String, dynamic>> deleteAccount({
    required String password,
    String? google2faCode,
    String? vcode,
  }) async {
    final data = {
      'password': password,
    };
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    if (vcode != null && vcode.isNotEmpty) {
      data['vcode'] = vcode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.accountDelete,
      data: data,
    );
    return response.data;
  }

  /// 获取账户日志
  /// [page] 页码（可选，默认1）
  /// [pageSize] 每页数量（可选，默认20）
  /// [type] 日志类型（可选）：1:登录,2:注册,3:重置密码,4:绑定手机,5:绑定邮箱,6:解绑手机,7:解绑邮箱,8:禁用账户,9:删除账户,10:绑定2fa,11:解绑2fa
  Future<Map<String, dynamic>> getAccountLogs({
    int page = 1,
    int pageSize = 20,
    int? type,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (type != null) {
      queryParams['type'] = type;
    }
    final response = await _dioClient.dio.get(
      Endpoints.userAccountLogs,
      queryParameters: queryParams,
    );
    return response.data;
  }

  /// 更新用户资料
  /// [nickname] 昵称
  Future<Map<String, dynamic>> updateProfile({
    String? nickname,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) {
      data['nickname'] = nickname;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.userProfileUpdate,
      data: data,
    );
    return response.data;
  }

  /// 重置密码
  /// [type] 类型：2=手机验证码，3=邮箱验证码
  /// [mobile] 手机号（与email二选一）
  /// [email] 邮箱（与mobile二选一）
  /// [code] 国家代码（手机号时必填）
  /// [vcode] 验证码（首次验证码或双重认证验证码）
  /// [password] 新密码（可选，用于获取二次认证方式时可不传）
  /// [passwordConfirmation] 确认新密码（可选，用于获取二次认证方式时可不传）
  /// [google2faCode] Google2FA验证码（如果用户设置了Google2FA则必填）
  /// [step] 请求步骤（第一次请求为1，按请求次数递增）
  Future<Map<String, dynamic>> resetPassword({
    int? type,
    String? mobile,
    String? email,
    String? code,
    String? vcode,
    String? password,
    String? passwordConfirmation,
    String? google2faCode,
    int? step,
  }) async {
    final data = <String, dynamic>{};
    
    if (type != null) {
      data['type'] = type;
    }
    
    if (step != null) {
      data['step'] = step;
    }
    
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    
    if (passwordConfirmation != null && passwordConfirmation.isNotEmpty) {
      data['password_confirmation'] = passwordConfirmation;
    }
    
    if (mobile != null && mobile.isNotEmpty) {
      data['mobile'] = mobile;
      if (code != null) {
        data['code'] = code;
      }
    } else if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }
    
    if (vcode != null && vcode.isNotEmpty) {
      data['vcode'] = vcode;
    }
    
    if (google2faCode != null && google2faCode.isNotEmpty) {
      data['google2fa_code'] = google2faCode;
    }
    
    final response = await _dioClient.dio.post(
      Endpoints.passwordReset,
      data: data,
    );
    return response.data;
  }

  /// 获取VIP详细信息（包含VIP等级配置、费率、升级进度等）
  Future<Map<String, dynamic>> getVipDetail() async {
    final response = await _dioClient.dio.get(
      Endpoints.vipDetail,
    );
    return response.data;
  }
}

