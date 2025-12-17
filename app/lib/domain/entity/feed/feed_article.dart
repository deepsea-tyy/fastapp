import 'package:json_annotation/json_annotation.dart';
import 'package:fastapp/domain/entity/user/user_profile.dart';
import 'package:fastapp/domain/entity/feed/converters/multi_lang_list_converter.dart';
import 'package:fastapp/utils/image_utils.dart';

part 'feed_article.g.dart';

/// 信息流文章实体（新闻、公告等）
///
/// 对应后端 article 表
@JsonSerializable()
class FeedArticle {
  /// 文章ID
  final int id;

  /// 标题（多语言字段，后端会格式化为字符串）
  final String title;

  /// 副标题（多语言字段，后端会格式化为字符串）
  final String? subtitle;

  /// 摘要（多语言字段，后端会格式化为字符串）
  final String? brief;

  /// 内容（多语言字段，后端会格式化为字符串）
  final String? content;

  /// 封面图（多语言数组格式，会自动转换为字符串列表）
  @MultiLangListConverter()
  final List<String>? cover;

  /// 作者
  final String? author;

  /// 用户资料
  final UserProfile? profile;

  /// 浏览次数
  @JsonKey(name: 'view_count')
  final int viewCount;

  /// 点赞数
  @JsonKey(name: 'like_count')
  final int likeCount;

  /// 评论数
  @JsonKey(name: 'comment_count')
  final int commentCount;

  /// 分享数
  @JsonKey(name: 'share_count')
  final int shareCount;

  /// 收藏数
  @JsonKey(name: 'collect_count')
  final int collectCount;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final String? createdAt;

  FeedArticle({
    required this.id,
    required this.title,
    this.subtitle,
    this.brief,
    this.content,
    this.cover,
    this.author,
    this.profile,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.collectCount = 0,
    this.createdAt,
  });

  factory FeedArticle.fromJson(Map<String, dynamic> json) =>
      _$FeedArticleFromJson(json);

  Map<String, dynamic> toJson() => _$FeedArticleToJson(this);

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

  /// 格式化日期（用于分组显示）
  String getFormattedDate() {
    if (createdAt == null) return '';

    try {
      final dateTime = DateTime.parse(createdAt!);
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return '';
    }
  }

  /// 格式化时间（HH:mm格式）
  String getTimeOnly() {
    if (createdAt == null) return '';

    try {
      final dateTime = DateTime.parse(createdAt!);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }

  /// 获取格式化后的封面图列表
  List<String> get formattedCovers {
    if (cover == null || cover!.isEmpty) {
      return [];
    }
    return cover!
        .map((url) => ImageUtils.formatSingleImagePath(url))
        .toList();
  }

  /// 获取第一张封面图
  String? get firstCover {
    final covers = formattedCovers;
    return covers.isEmpty ? null : covers.first;
  }
}
