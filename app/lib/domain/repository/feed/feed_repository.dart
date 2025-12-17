import '../../entity/feed/feed_post.dart';
import '../../entity/feed/feed_comment.dart';
import '../../entity/feed/feed_operation_result.dart';
import '../../entity/feed/feed_article.dart';

/// 信息流Repository抽象接口
abstract class FeedRepository {
  // ==================== 信息流列表 ====================

  /// 获取信息流列表
  /// [filter] 筛选条件：latest最新 hot热门
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<List<FeedPost>> getFeedList({
    String filter = 'latest',
    int page = 1,
    int pageSize = 20,
  });

  /// 获取指定标签的信息流
  Future<List<FeedPost>> getFeedListByTag({
    required int tagId,
    int page = 1,
    int pageSize = 20,
  });

  /// 获取关注用户的信息流
  Future<List<FeedPost>> getFollowingFeedList({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取热门信息流
  Future<List<FeedPost>> getHotFeedList({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取热门标签
  Future<List<FeedTag>> getHotTags({
    int limit = 10,
  });

  /// 获取新闻列表
  Future<List<FeedArticle>> getNewsList({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取公告列表
  Future<List<FeedArticle>> getAnnouncementList({
    int page = 1,
    int pageSize = 20,
  });

  // ==================== 帖子管理 ====================

  /// 获取帖子详情
  Future<FeedPost?> getPostDetail({
    required int id,
  });

  /// 获取用户发布的帖子列表
  Future<List<FeedPost>> getUserPostList({
    required int userId,
    int page = 1,
    int pageSize = 20,
  });

  /// 创建帖子
  Future<Map<String, dynamic>> createPost({
    int contentType = 1,
    String? title,
    required String content,
    List<String>? images,
    List<String>? videos,
  });

  /// 删除帖子
  Future<Map<String, dynamic>> deletePost({
    required int id,
  });

  // ==================== 评论管理 ====================

  /// 获取评论列表
  Future<List<FeedComment>> getCommentList({
    required int targetType,
    required int targetId,
    int page = 1,
    int pageSize = 20,
  });

  /// 获取评论的回复列表
  Future<List<FeedComment>> getCommentReplies({
    required int id,
    int page = 1,
    int pageSize = 20,
  });

  /// 创建评论
  Future<Map<String, dynamic>> createComment({
    required int targetType,
    required int targetId,
    required String content,
    int parentId = 0,
    int? replyToUserId,
    List<String>? images,
  });

  /// 删除评论
  Future<Map<String, dynamic>> deleteComment({
    required int id,
  });

  // ==================== 用户操作 ====================

  /// 切换收藏状态
  Future<CollectResult> toggleCollect({
    required int targetType,
    required int targetId,
  });

  /// 获取收藏列表
  Future<List<FeedPost>> getCollectList({
    int page = 1,
    int pageSize = 20,
  });

  /// 切换点赞状态
  Future<LikeResult> toggleLike({
    required int targetType,
    required int targetId,
  });

  /// 切换关注状态
  Future<FollowResult> toggleFollow({
    required int followUserId,
  });

  /// 获取关注列表
  Future<List<int>> getFollowingList({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取关注用户详细信息列表（包含profile）
  Future<List<Map<String, dynamic>>> getFollowingUserList({
    int page = 1,
    int pageSize = 5,
  });

  /// 获取粉丝列表
  Future<List<int>> getFollowersList({
    int page = 1,
    int pageSize = 20,
  });

  /// 获取用户关注统计
  Future<UserFollowStats?> getUserFollowStats();

  /// 检查是否关注某用户
  Future<bool> checkFollowStatus({
    required int followUserId,
  });

  /// 获取可能感兴趣的人列表
  Future<List<Map<String, dynamic>>> getMayInterestedList({
    int page = 1,
    int pageSize = 20,
  });
}
