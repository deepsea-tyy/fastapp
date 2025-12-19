import 'package:json_annotation/json_annotation.dart';
import 'package:fastapp/utils/json_converters.dart';

part 'feed_operation_result.g.dart';

/// 点赞操作结果
@JsonSerializable()
class LikeResult {
  /// 是否已点赞 (0未点赞 1已点赞)
  @JsonKey(name: 'is_liked', fromJson: intToBool)
  final bool isLiked;

  /// 最新点赞数
  @JsonKey(name: 'like_count')
  final int likeCount;

  LikeResult({
    required this.isLiked,
    required this.likeCount,
  });

  factory LikeResult.fromJson(Map<String, dynamic> json) =>
      _$LikeResultFromJson(json);

  Map<String, dynamic> toJson() => _$LikeResultToJson(this);
}

/// 收藏操作结果
@JsonSerializable()
class CollectResult {
  /// 是否已收藏 (0未收藏 1已收藏)
  @JsonKey(name: 'is_collected', fromJson: intToBool)
  final bool isCollected;

  /// 提示消息
  final String? message;

  CollectResult({
    required this.isCollected,
    this.message,
  });

  factory CollectResult.fromJson(Map<String, dynamic> json) =>
      _$CollectResultFromJson(json);

  Map<String, dynamic> toJson() => _$CollectResultToJson(this);
}

/// 关注操作结果
@JsonSerializable()
class FollowResult {
  /// 是否已关注 (0未关注 1已关注)
  @JsonKey(name: 'is_following', fromJson: intToBool)
  final bool isFollowing;

  /// 提示消息
  final String? message;

  FollowResult({
    required this.isFollowing,
    this.message,
  });

  factory FollowResult.fromJson(Map<String, dynamic> json) =>
      _$FollowResultFromJson(json);

  Map<String, dynamic> toJson() => _$FollowResultToJson(this);
}

/// 用户统计信息
@JsonSerializable()
class UserFollowStats {
  /// 用户ID
  @JsonKey(name: 'user_id')
  final int userId;

  /// 关注数
  @JsonKey(name: 'following_count')
  final int followingCount;

  /// 粉丝数
  @JsonKey(name: 'followers_count')
  final int followersCount;

  /// 帖子数
  @JsonKey(name: 'posts_count')
  final int postsCount;

  /// 获赞总数
  @JsonKey(name: 'total_likes')
  final int totalLikes;

  /// 分享总数
  @JsonKey(name: 'total_shares')
  final int totalShares;

  /// 评论总数
  @JsonKey(name: 'total_comments')
  final int totalComments;

  /// 浏览总数
  @JsonKey(name: 'total_views')
  final int totalViews;

  UserFollowStats({
    required this.userId,
    required this.followingCount,
    required this.followersCount,
    this.postsCount = 0,
    this.totalLikes = 0,
    this.totalShares = 0,
    this.totalComments = 0,
    this.totalViews = 0,
  });

  factory UserFollowStats.fromJson(Map<String, dynamic> json) =>
      _$UserFollowStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserFollowStatsToJson(this);
}

/// 热门标签
@JsonSerializable()
class FeedTag {
  /// 标签ID
  final int id;

  /// 标签名称（多语言）
  final Map<String, dynamic> name;

  /// 标签图标
  final String? icon;

  /// 标签颜色
  final String? color;

  /// 内容数量
  @JsonKey(name: 'post_count')
  final int postCount;

  /// 关注数
  @JsonKey(name: 'follow_count')
  final int followCount;

  /// 是否热门
  @JsonKey(name: 'is_hot')
  final int isHot;

  FeedTag({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.postCount = 0,
    this.followCount = 0,
    this.isHot = 0,
  });

  factory FeedTag.fromJson(Map<String, dynamic> json) =>
      _$FeedTagFromJson(json);

  Map<String, dynamic> toJson() => _$FeedTagToJson(this);

  /// 获取标签名称（根据语言）
  String getLocalizedName(String languageCode) {
    return name[languageCode]?.toString() ?? name['zh_CN']?.toString() ?? '';
  }
}
