import 'package:json_annotation/json_annotation.dart';

part 'feed_comment.g.dart';

/// int 转 bool 的转换器
class IntToBoolConverter implements JsonConverter<bool?, dynamic> {
  const IntToBoolConverter();

  @override
  bool? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  @override
  dynamic toJson(bool? value) {
    if (value == null) return null;
    return value ? 1 : 0;
  }
}

/// 信息流评论实体
///
/// 对应后端 feed_comment 表
@JsonSerializable()
class FeedComment {
  /// 评论ID
  final int id;

  /// 目标类型：1帖子 2文章
  @JsonKey(name: 'target_type')
  final int targetType;

  /// 目标ID
  @JsonKey(name: 'target_id')
  final int targetId;

  /// 评论用户ID
  @JsonKey(name: 'user_id')
  final int userId;

  /// 用户名（需要额外获取）
  final String? username;

  /// 用户头像（需要额外获取）
  final String? avatar;

  /// 父评论ID（0为顶级评论）
  @JsonKey(name: 'parent_id')
  final int parentId;

  /// 根评论ID（用于楼中楼）
  @JsonKey(name: 'root_id')
  final int rootId;

  /// 回复的用户ID
  @JsonKey(name: 'reply_to_user_id')
  final int? replyToUserId;

  /// 回复的用户名（需要额外获取）
  @JsonKey(name: 'reply_to_username')
  final String? replyToUsername;

  /// 评论内容
  final String content;

  /// 图片列表
  final List<String>? images;

  /// 点赞数
  @JsonKey(name: 'like_count')
  final int likeCount;

  /// 回复数
  @JsonKey(name: 'reply_count')
  final int replyCount;

  /// 是否已点赞（后端返回 int 0/1）
  @JsonKey(name: 'is_liked')
  @IntToBoolConverter()
  final bool? isLiked;

  /// 是否是帖子作者（后端返回 int 0/1）
  @JsonKey(name: 'is_author')
  @IntToBoolConverter()
  final bool? isAuthor;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// 子评论列表
  final List<FeedComment>? children;

  FeedComment({
    required this.id,
    this.targetType = 1,
    this.targetId = 0,
    required this.userId,
    this.username,
    this.avatar,
    this.parentId = 0,
    this.rootId = 0,
    this.replyToUserId,
    this.replyToUsername,
    required this.content,
    this.images,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLiked,
    this.isAuthor,
    this.createdAt,
    this.children,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) =>
      _$FeedCommentFromJson(json);

  Map<String, dynamic> toJson() => _$FeedCommentToJson(this);

  /// 复制并更新字段
  FeedComment copyWith({
    int? id,
    int? targetType,
    int? targetId,
    int? userId,
    String? username,
    String? avatar,
    int? parentId,
    int? rootId,
    int? replyToUserId,
    String? replyToUsername,
    String? content,
    List<String>? images,
    int? likeCount,
    int? replyCount,
    bool? isLiked,
    bool? isAuthor,
    String? createdAt,
    List<FeedComment>? children,
  }) {
    return FeedComment(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      parentId: parentId ?? this.parentId,
      rootId: rootId ?? this.rootId,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToUsername: replyToUsername ?? this.replyToUsername,
      content: content ?? this.content,
      images: images ?? this.images,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      isAuthor: isAuthor ?? this.isAuthor,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
    );
  }

  /// 格式化时间显示
  String getFormattedTime() {
    if (createdAt == null) return '';

    try {
      final dateTime = DateTime.parse(createdAt!);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      if (diff.inDays < 7) return '${diff.inDays}天前';

      return '${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return createdAt ?? '';
    }
  }

  /// 是否是顶级评论
  bool get isTopLevel => parentId == 0;

  /// 是否是嵌套回复
  bool get isNested => parentId != 0;

  /// 是否有回复
  bool get hasReplies => replyCount > 0;
}
