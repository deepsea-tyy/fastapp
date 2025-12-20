import '../../../constants/app_config.dart';

/// 网络端点配置
class Endpoints {
  Endpoints._();

  // ==================== 基础配置 ====================
  
  /// API 基础 URL
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// 连接超时时间（毫秒）
  static const int connectionTimeout = AppConfig.connectionTimeout;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = AppConfig.receiveTimeout;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = AppConfig.sendTimeout;

  // ==================== API 端点路径 ====================
  
  // 行情相关
  static const String marketTicker = AppConfig.marketTicker;
  static const String marketKline = AppConfig.marketKline;
  static const String marketDepth = AppConfig.marketDepth;

  // 交易相关
  static const String tradePlaceOrder = AppConfig.tradePlaceOrder;
  static const String tradeCancelOrder = AppConfig.tradeCancelOrder;

  // 订单相关
  static const String orderList = AppConfig.orderList;
  static const String orderDetail = AppConfig.orderDetail;

  // 钱包相关
  static const String walletBalance = AppConfig.walletBalance;
  static const String walletTransactions = AppConfig.walletTransactions;

  // 合约相关
  static const String futuresPosition = AppConfig.futuresPosition;
  static const String futuresLeverage = AppConfig.futuresLeverage;
  static const String futuresFundingRate = AppConfig.futuresFundingRate;

  // 用户相关
  static const String userLogin = '/api/user/login';
  static const String userRegister = '/api/user/register';
  static const String userInfo = '/api/user/info';
  static const String userLogout = '/api/user/logout';
  static const String userRefreshToken = '/api/user/refreshToken';
  static const String userAccountLogs = '/api/user/accountLogs';
  static const String userProfileUpdate = '/api/user/profile/update';
  static const String userSmsCheck = '/api/user/smsCheck';

  // 验证码相关
  static const String userSms = '/api/sms';

  // Google2FA 相关
  static const String google2faQrcode = '/api/user/google2fa/qrcode';
  static const String google2faBind = '/api/user/google2fa/bind';
  static const String google2faUnbind = '/api/user/google2fa/unbind';

  // 邮箱相关
  static const String emailBind = '/api/user/email/bind';
  static const String emailUnbind = '/api/user/email/unbind';

  // 手机号相关
  static const String mobileBind = '/api/user/mobile/bind';
  static const String mobileUnbind = '/api/user/mobile/unbind';

  // 密码相关
  static const String passwordChange = '/api/user/password/change';
  static const String passwordReset = '/api/user/resetPassword';

  // 账户管理相关
  static const String accountDisable = '/api/user/account/disable';
  static const String accountDelete = '/api/user/account/delete';

  // 应用相关
  static const String pageContentDownload = '/api/app/page-content/download';

  // VIP相关
  static const String vipDetail = '/api/ex/vip/detail';

  // KYC认证相关
  static const String kycSubmit = '/api/ex/kyc/submit';
  static const String kycDetail = '/api/ex/kyc/detail';

  // 附件上传相关
  static const String attachmentUpload = '/api/attachment/upload';
  static const String attachmentList = '/api/attachment/list';
  static const String attachmentDelete = '/api/attachment';

  // ==================== 信息流相关 ====================

  // 信息流列表
  static const String feedList = '/api/feed/list';
  static const String feedListByTag = '/api/feed/list/byTag';
  static const String feedListByFollowing = '/api/feed/list/byFollowing';
  static const String feedListHot = '/api/feed/list/hot';
  static const String feedTagsHot = '/api/feed/tags/hot';
  static const String feedMayInterested = '/api/feed/mayInterested';

  // 文章相关（新闻、公告）
  static const String feedArticleNews = '/api/feed/article/news';
  static const String feedArticleNotice = '/api/feed/article/notice';

  // 帖子管理
  static const String feedPostDetail = '/api/feed/post/detail';
  static const String feedPostList = '/api/feed/post/list';
  static const String feedPostCreate = '/api/feed/post/create';
  static const String feedPostUpdate = '/api/feed/post/update';
  static const String feedPostDelete = '/api/feed/post/delete';

  // 评论管理
  static const String feedCommentList = '/api/feed/comment/list';
  static const String feedCommentReplies = '/api/feed/comment/replies';
  static const String feedCommentCreate = '/api/feed/comment/create';
  static const String feedCommentDelete = '/api/feed/comment/delete';

  // 用户操作
  static const String feedUserCollectToggle = '/api/feed/user/collectToggle';
  static const String feedUserCollectList = '/api/feed/user/collectList';
  static const String feedUserCollectStatus = '/api/feed/user/collectStatus';
  static const String feedUserLikeToggle = '/api/feed/user/likeToggle';
  static const String feedUserFollowToggle = '/api/feed/user/followToggle';
  static const String feedUserFollowingList = '/api/feed/user/followingList';
  static const String feedUserFollowersList = '/api/feed/user/followersList';
  static const String feedUserStats = '/api/feed/user/stats';
  static const String feedUserFollowStatus = '/api/feed/user/followStatus';
  static const String feedQualityFeedback = '/api/feed/user/qualityFeedback';

  // 举报管理
  static const String feedReportSubmit = '/api/feed/report/submit';
}