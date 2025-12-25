import 'notify_type.dart';

/// 消息分类统计
class MessageCategoryStats {
  /// 未读数
  final int unreadCount;

  /// 标题（已本地化）
  final String title;

  /// 内容（已本地化）
  final String content;

  /// 最新消息ID
  final int lastId;

  /// 创建时间
  final String createdAt;

  MessageCategoryStats({
    required this.unreadCount,
    required this.title,
    required this.content,
    required this.lastId,
    required this.createdAt,
  });

  factory MessageCategoryStats.fromJson(Map<String, dynamic> json) {
    return MessageCategoryStats(
      unreadCount: json['unread_count'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      lastId: json['last_id'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unread_count': unreadCount,
      'title': title,
      'content': content,
      'last_id': lastId,
      'created_at': createdAt,
    };
  }

  /// 创建空的统计数据
  factory MessageCategoryStats.empty() {
    return MessageCategoryStats(
      unreadCount: 0,
      title: '',
      content: '',
      lastId: 0,
      createdAt: '',
    );
  }
}

/// 未读统计实体
class UnreadStatistics {
  /// 公告统计
  final MessageCategoryStats announcement;

  /// 活动统计
  final MessageCategoryStats activity;

  /// 账户统计
  final MessageCategoryStats account;

  /// 广场统计
  final MessageCategoryStats community;

  /// 交易统计
  final MessageCategoryStats funds;

  /// 总未读数
  final int totalUnread;

  UnreadStatistics({
    required this.announcement,
    required this.activity,
    required this.account,
    required this.community,
    required this.funds,
    required this.totalUnread,
  });

  /// 从JSON创建
  factory UnreadStatistics.fromJson(Map<String, dynamic> json) {
    return UnreadStatistics(
      announcement: json['1'] != null
          ? MessageCategoryStats.fromJson(json['1'])
          : MessageCategoryStats.empty(),
      activity: json['2'] != null
          ? MessageCategoryStats.fromJson(json['2'])
          : MessageCategoryStats.empty(),
      account: json['3'] != null
          ? MessageCategoryStats.fromJson(json['3'])
          : MessageCategoryStats.empty(),
      community: json['4'] != null
          ? MessageCategoryStats.fromJson(json['4'])
          : MessageCategoryStats.empty(),
      funds: json['5'] != null
          ? MessageCategoryStats.fromJson(json['5'])
          : MessageCategoryStats.empty(),
      totalUnread: json['total'] as int? ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      '1': announcement.toJson(),
      '2': activity.toJson(),
      '3': account.toJson(),
      '4': community.toJson(),
      '5': funds.toJson(),
      'total': totalUnread,
    };
  }

  /// 根据通知类型获取未读数
  int getUnreadByType(NotifyType type) {
    switch (type) {
      case NotifyType.announcement:
        return announcement.unreadCount;
      case NotifyType.activity:
        return activity.unreadCount;
      case NotifyType.account:
        return account.unreadCount;
      case NotifyType.community:
        return community.unreadCount;
      case NotifyType.funds:
        return funds.unreadCount;
    }
  }

  /// 根据通知类型获取分类统计
  MessageCategoryStats getStatsByType(NotifyType type) {
    switch (type) {
      case NotifyType.announcement:
        return announcement;
      case NotifyType.activity:
        return activity;
      case NotifyType.account:
        return account;
      case NotifyType.community:
        return community;
      case NotifyType.funds:
        return funds;
    }
  }

  /// 是否有未读消息
  bool get hasUnread => totalUnread > 0;

  /// 创建空的统计数据
  factory UnreadStatistics.empty() {
    return UnreadStatistics(
      announcement: MessageCategoryStats.empty(),
      activity: MessageCategoryStats.empty(),
      account: MessageCategoryStats.empty(),
      community: MessageCategoryStats.empty(),
      funds: MessageCategoryStats.empty(),
      totalUnread: 0,
    );
  }
}
