class Preferences {
  Preferences._();

  // 认证相关
  static const String is_logged_in = "isLoggedIn";
  static const String auth_token = "authToken";
  static const String refresh_token = "refreshToken";
  static const String expire_at = "expireAt";

  // 用户相关
  static const String device_id = "device_id";

  // 应用设置
  static const String is_dark_mode = "is_dark_mode";
  static const String current_language = "current_language";

  // 存储类别定义
  static const List<String> authKeys = [
    auth_token,
    refresh_token,
    expire_at,
    is_logged_in,
  ];

  static const List<String> userDataKeys = [
    device_id,
  ];

  static const List<String> appSettingKeys = [
    is_dark_mode,
    current_language,
  ];
}