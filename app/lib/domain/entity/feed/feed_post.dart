import 'package:json_annotation/json_annotation.dart';
import 'package:fastapp/domain/entity/user/user_profile.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/utils/json_converters.dart';

part 'feed_post.g.dart';

/// 信息流帖子实体
///
/// 对应后端 feed_post 表
@JsonSerializable()
class FeedPost {
  /// 帖子ID
  final int id;

  /// 发布用户ID
  @JsonKey(name: 'user_id')
  final int? userId;

  /// 用户名（需要额外获取）
  final String? username;

  /// 用户头像（需要额外获取）
  final String? avatar;

  /// 是否认证用户（需要额外获取）
  @JsonKey(name: 'is_verified')
  final bool? isVerified;

  /// 用户资料
  final UserProfile? profile;

  /// 内容类型：1纯文本 2图文 3视频 4链接
  @JsonKey(name: 'content_type')
  final int? contentType;

  /// 标题（可选）
  final String? title;

  /// 内容
  final String? content;

  /// 图片列表
  final List<String>? images;

  /// 视频列表
  final List<String>? videos;

  /// 外链地址
  @JsonKey(name: 'link_url')
  final String? linkUrl;

  /// 链接元数据
  @JsonKey(name: 'link_meta')
  final Map<String, dynamic>? linkMeta;

  /// 引用类型：1帖子 2文章
  @JsonKey(name: 'quoted_type')
  final int? quotedType;

  /// 引用的内容ID
  @JsonKey(name: 'quoted_id')
  final int? quotedId;

  /// 是否置顶：0否 1是
  @JsonKey(name: 'is_top')
  final int? isTop;

  /// 是否热门：0否 1是
  @JsonKey(name: 'is_hot')
  final int? isHot;

  /// 浏览次数
  @JsonKey(name: 'view_count')
  final int? viewCount;

  /// 点赞数
  @JsonKey(name: 'like_count')
  final int likeCount;

  /// 评论数
  @JsonKey(name: 'comment_count')
  final int commentCount;

  /// 分享数
  @JsonKey(name: 'share_count')
  final int? shareCount;

  /// 收藏数
  @JsonKey(name: 'collect_count')
  final int? collectCount;

  /// 引用数（注意：不是repost_count）
  @JsonKey(name: 'quote_count')
  final int? quoteCount;

  /// 是否已点赞（登录后附加）
  @JsonKey(name: 'is_liked', fromJson: intToBoolNullable)
  final bool? isLiked;

  /// 是否已收藏（登录后附加）
  @JsonKey(name: 'is_collected', fromJson: intToBoolNullable)
  final bool? isCollected;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// 帖子类型：1帖子 2文章
  final int? type;

  /// 帖子状态：0草稿 1已发布 2已删除
  final int? status;

  FeedPost({
    required this.id,
    this.userId,
    this.username,
    this.avatar,
    this.isVerified,
    this.profile,
    this.contentType,
    this.title,
    this.content,
    this.images,
    this.videos,
    this.linkUrl,
    this.linkMeta,
    this.quotedType,
    this.quotedId,
    this.isTop,
    this.isHot,
    this.viewCount,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount,
    this.collectCount,
    this.quoteCount,
    this.isLiked,
    this.isCollected,
    this.createdAt,
    this.type,
    this.status,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) =>
      _$FeedPostFromJson(json);

  Map<String, dynamic> toJson() => _$FeedPostToJson(this);

  /// 复制并更新字段
  FeedPost copyWith({
    int? id,
    int? userId,
    String? username,
    String? avatar,
    bool? isVerified,
    UserProfile? profile,
    int? contentType,
    String? title,
    String? content,
    List<String>? images,
    List<String>? videos,
    String? linkUrl,
    Map<String, dynamic>? linkMeta,
    int? quotedType,
    int? quotedId,
    int? isTop,
    int? isHot,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? collectCount,
    int? quoteCount,
    bool? isLiked,
    bool? isCollected,
    String? createdAt,
    int? type,
    int? status,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      profile: profile ?? this.profile,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      linkUrl: linkUrl ?? this.linkUrl,
      linkMeta: linkMeta ?? this.linkMeta,
      quotedType: quotedType ?? this.quotedType,
      quotedId: quotedId ?? this.quotedId,
      isTop: isTop ?? this.isTop,
      isHot: isHot ?? this.isHot,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      collectCount: collectCount ?? this.collectCount,
      quoteCount: quoteCount ?? this.quoteCount,
      isLiked: isLiked ?? this.isLiked,
      isCollected: isCollected ?? this.isCollected,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      status: status ?? this.status,
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

  /// 是否置顶
  bool get isPinned => isTop == 1;

  /// 是否热门
  bool get isHotPost => isHot == 1;

  /// 获取格式化后的图片列表
  List<String> get formattedImages {
    if (images == null || images!.isEmpty) {
      return [];
    }
    return images!
        .map((url) => ImageUtils.formatSingleImagePath(url))
        .toList();
  }

  /// 获取第一张图片
  String? get firstImage {
    final imgs = formattedImages;
    return imgs.isEmpty ? null : imgs.first;
  }
}
