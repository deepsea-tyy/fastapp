import '../../../constants/app_config.dart';

/// 网络端点配置
/// 使用 AppConfig 中的网络配置，避免重复定义
class Endpoints {
  Endpoints._();

  /// API 基础 URL
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// 连接超时时间（毫秒）
  static const int connectionTimeout = AppConfig.connectionTimeout;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = AppConfig.receiveTimeout;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = AppConfig.sendTimeout;

  // ==================== API 端点路径 ====================
  
  /// 行情相关端点
  static const String marketTicker = AppConfig.marketTicker;
  static const String marketKline = AppConfig.marketKline;
  static const String marketDepth = AppConfig.marketDepth;

  /// 交易相关端点
  static const String tradePlaceOrder = AppConfig.tradePlaceOrder;
  static const String tradeCancelOrder = AppConfig.tradeCancelOrder;

  /// 订单相关端点
  static const String orderList = AppConfig.orderList;
  static const String orderDetail = AppConfig.orderDetail;

  /// 钱包相关端点
  static const String walletBalance = AppConfig.walletBalance;
  static const String walletTransactions = AppConfig.walletTransactions;

  /// 合约相关端点
  static const String futuresPosition = AppConfig.futuresPosition;
  static const String futuresLeverage = AppConfig.futuresLeverage;
  static const String futuresFundingRate = AppConfig.futuresFundingRate;

  /// 用户相关端点
  static const String userLogin = '/api/user/login';
  static const String userRegister = '/api/user/register';
  static const String userInfo = '/api/user/info';
  static const String userSms = '/api/sms';
  static const String userLogout = '/api/user/logout';
  static const String userRefreshToken = '/api/user/refreshToken';
  
  /// Google2FA 相关端点
  static const String google2faQrcode = '/api/user/google2fa/qrcode';
  static const String google2faBind = '/api/user/google2fa/bind';
  static const String google2faUnbind = '/api/user/google2fa/unbind';
  
  /// 邮箱相关端点
  static const String emailBind = '/api/user/email/bind';
  static const String emailUnbind = '/api/user/email/unbind';
  
  /// 手机号相关端点
  static const String mobileBind = '/api/user/mobile/bind';
  static const String mobileUnbind = '/api/user/mobile/unbind';
  
  /// 密码相关端点
  static const String passwordChange = '/api/user/password/change';
  
  /// 账户管理相关端点
  static const String accountDisable = '/api/user/account/disable';
  static const String accountDelete = '/api/user/account/delete';

  /// 页面内容相关端点
  static const String pageContentDownload = '/api/app/page-content/download';
}