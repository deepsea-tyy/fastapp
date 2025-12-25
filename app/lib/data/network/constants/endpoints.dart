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

  // ==================== 行情相关 ====================

  /// 获取单个交易对 Ticker 数据（支持批量，用逗号分隔）
  static const String marketTicker = '/api/ds/ex/currency/ticker';

  /// 市场数据配置下载（币种、现货、合约、期权）
  static const String currencyDownload = '/api/ds/ex/currency/download';

  /// 获取交易对列表
  static const String marketPairs = '/api/ds/ex/currency/marketPair';

  /// 获取币种详情
  static const String currencyDetail = '/api/ds/ex/currency/detail';

  /// 汇率相关
  static const String exchangeRate = '/api/ds/ex/currency/exchangeRate';

  // ==================== 交易相关 ====================
  // 注意：以下接口为预留接口，后端暂未实现，实际使用时需更新

  // static const String tradePlaceOrder = '/api/v1/trade/order';
  // static const String tradeCancelOrder = '/api/v1/trade/order/cancel';

  // ==================== 订单相关 ====================
  // 注意：以下接口为预留接口，后端暂未实现，实际使用时需更新

  // static const String orderList = '/api/v1/order/list';
  // static const String orderDetail = '/api/v1/order/detail';

  // ==================== 钱包相关 ====================
  // 注意：以下接口为预留接口，后端暂未实现，实际使用时需更新

  // static const String walletBalance = '/api/v1/wallet/balance';
  // static const String walletTransactions = '/api/v1/wallet/transactions';

  // ==================== 合约相关 ====================
  // 注意：以下接口为预留接口，后端暂未实现，实际使用时需更新

  // static const String futuresPosition = '/api/v1/futures/position';
  // static const String futuresLeverage = '/api/v1/futures/leverage';
  // static const String futuresFundingRate = '/api/v1/futures/funding-rate';

  // 用户相关
  static const String userLogin = '/api/user/login';
  static const String userRegister = '/api/user/register';
  static const String userInfo = '/api/user/info';
  static const String userBaseInfo = '/api/user/baseInfo';
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
  static const String feedArticleList = '/api/feed/article/list';
  static const String feedArticleDetail = '/api/feed/article/detail';

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

  // ==================== 搜索相关 ====================

  // 全局搜索
  static const String search = '/api/search';

  // 搜索建议
  static const String searchSuggest = '/api/search/suggest';

  // 热门关键词
  static const String searchKeywordsHot = '/api/search/keywords/hot';

  // 搜索排行榜
  static const String searchRanking = '/api/search/ranking';

  // 记录搜索结果点击
  static const String searchClick = '/api/search/click';

  // ==================== 消息通知相关 ====================

  // 消息列表
  static const String messageNotifyList = '/api/sysNotify/list';

  // 更新已读状态
  static const String messageNotifyRead = '/api/sysNotify/read';

  // 分类未读统计
  static const String messageNotifyUnreadStatistics = '/api/sysNotify/unread-statistics';

  // 总未读数
  static const String messageNotifyUnreadTotal = '/api/sysNotify/unread-total';

  // 清除未读消息
  static const String messageNotifyClearUnread = '/api/sysNotify/clear-unread';
}