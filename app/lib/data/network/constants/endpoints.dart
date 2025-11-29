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
}