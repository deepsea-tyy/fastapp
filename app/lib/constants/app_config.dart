/// 应用配置文件
/// 
/// 统一管理应用的配置信息，包括：
/// - 应用名称
/// - 应用版本
/// - 其他应用级配置
/// 
/// 注意：此文件由 app_config.json 自动生成，请勿手动修改。
/// 修改配置请编辑 app_config.json，然后运行: dart run scripts/sync_config.dart
class AppConfig {
  AppConfig._();

  /// 应用名称
  /// 同步到: AndroidManifest.xml, Info.plist, web/index.html, web/manifest.json
  static const String appName = 'fastapp';

  /// 应用版本号（从 pubspec.yaml 读取，需要手动同步）
  static const String appVersion = '1.0.0';

  /// 构建号
  static const int buildNumber = 1;

  /// 应用描述
  static const String appDescription = 'A flutter boilerplate project created using MobX and Provider.';

  /// 包名（Android）
  static const String androidPackageName = 'com.iotecksolutions.todoapp';

  /// Bundle Identifier（iOS）
  static const String iosBundleId = 'com.iotecksolutions.todoapp';

  /// 获取完整版本号
  static String get fullVersion => '$appVersion+$buildNumber';

  // ==================== 网络配置 ====================
  
  /// API 基础 URL
  static const String apiBaseUrl = 'http://192.168.1.4:9501';

  /// WebSocket 基础 URL
  static const String wsBaseUrl = 'ws://192.168.1.4:9502/ws';

  /// 连接超时时间（毫秒）
  static const int connectionTimeout = 5000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 5000;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = 5000;

  // ==================== API 端点路径 ====================
  
  /// 行情相关端点
  static const String marketTicker = '/api/v1/market/ticker';
  static const String marketKline = '/api/v1/market/kline';
  static const String marketDepth = '/api/v1/market/depth';

  /// 交易相关端点
  static const String tradePlaceOrder = '/api/v1/trade/order';
  static const String tradeCancelOrder = '/api/v1/trade/order/cancel';

  /// 订单相关端点
  static const String orderList = '/api/v1/order/list';
  static const String orderDetail = '/api/v1/order/detail';

  /// 钱包相关端点
  static const String walletBalance = '/api/v1/wallet/balance';
  static const String walletTransactions = '/api/v1/wallet/transactions';

  /// 合约相关端点
  static const String futuresPosition = '/api/v1/futures/position';
  static const String futuresLeverage = '/api/v1/futures/leverage';
  static const String futuresFundingRate = '/api/v1/futures/funding-rate';

  // ==================== 主题配置 ====================

  /// 亮色主题种子颜色
  static const String seedColorLight = '#2196F3';

  /// 暗色主题种子颜色
  static const String seedColorDark = '#2196F3';

  /// 亮色主题 Scaffold 背景色
  static const String scaffoldBackgroundColorLight = '#FFFFFF';

  /// 暗色主题 Scaffold 背景色（null 表示使用系统默认）
  static const String scaffoldBackgroundColorDark = '';

  /// 亮色主题按钮背景色
  static const String buttonBackgroundColorLight = '#424242';

  /// 暗色主题按钮背景色
  static const String buttonBackgroundColorDark = '#757575';

  /// 亮色主题按钮前景色
  static const String buttonForegroundColorLight = '#FFFFFF';

  /// 暗色主题按钮前景色
  static const String buttonForegroundColorDark = '#FFFFFF';

  /// 亮色主题按钮禁用背景色
  static const String buttonDisabledBackgroundColorLight = '#BDBDBD';

  /// 暗色主题按钮禁用背景色
  static const String buttonDisabledBackgroundColorDark = '#616161';

  /// 亮色主题按钮禁用前景色
  static const String buttonDisabledForegroundColorLight = '#B3FFFFFF';

  /// 暗色主题按钮禁用前景色
  static const String buttonDisabledForegroundColorDark = '#B3FFFFFF';

  // ==================== 资源配置 ====================
  
  /// 图片 CDN 基础 URL
  static const String imageCdnBaseUrl = 'http://192.168.1.4:9501/api/file?path=';

  // ==================== UI 配置 ====================
  
  /// 默认水平内边距
  static const double defaultHorizontalPadding = 12.0;

  /// 默认垂直内边距
  static const double defaultVerticalPadding = 12.0;

  /// 默认圆角半径
  static const double defaultBorderRadius = 8.0;

  // ==================== 资源路径配置 ====================
  
  /// 应用 Logo 路径
  static const String appLogo = 'assets/images/launch/logo.png';

  /// 登录页背景图片路径
  static const String carBackground = 'assets/images/img_login.jpg';

  // ==================== 字体配置 ====================
  
  /// ProductSans 字体
  static const String productSans = 'ProductSans';

  /// Roboto 字体
  static const String roboto = 'Roboto';

  // ==================== 启动图配置 ====================
  
  /// 启动图图片路径
  static const String splashImage = 'assets/images/launch/logo.png';
  
  /// Android 启动图背景颜色
  static const String splashBackgroundColorAndroid = '#ffffff';
  
  /// iOS 启动图背景颜色
  static const String splashBackgroundColorIos = '#ffffff';
  
  /// Web 启动图背景颜色
  static const String splashBackgroundColorWeb = '#ffffff';
  
  /// Web 端启动图背景尺寸
  static const String splashWebBackgroundSize = 'cover';
  
  /// Web 端启动图淡出时间（毫秒）
  static const int splashWebFadeOutTime = 400;
  
  /// Web 端启动图隐藏延迟（毫秒）
  static const int splashWebHideDelay = 500;
}

