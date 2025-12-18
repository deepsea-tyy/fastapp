import '../../../../core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

/// 信息流API实现
class FeedApi {
  final DioClient _dioClient;

  FeedApi(this._dioClient);

  // ==================== 信息流列表 ====================

  /// 获取信息流列表
  /// [filter] 筛选条件：latest最新 hot热门
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getFeedList({
    String filter = 'latest',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedList,
      queryParameters: {
        'filter': filter,
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取指定标签的信息流
  /// [tagId] 标签ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getFeedListByTag({
    required int tagId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedListByTag,
      queryParameters: {
        'tag_id': tagId,
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取关注用户的信息流
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getFollowingFeedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedListByFollowing,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取热门信息流
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getHotFeedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedListHot,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取热门标签
  /// [limit] 数量限制
  Future<dynamic> getHotTags({
    int limit = 10,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedTagsHot,
      queryParameters: {
        'limit': limit,
      },
    );
    return response.data;
  }

  /// 获取新闻列表
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getNewsList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedArticleNews,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取公告列表
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getAnnouncementList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedArticleNotice,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  // ==================== 帖子管理 ====================

  /// 获取帖子详情
  /// [id] 帖子ID
  Future<Map<String, dynamic>> getPostDetail({
    required int id,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedPostDetail,
      queryParameters: {
        'id': id,
      },
    );
    return response.data;
  }

  /// 获取用户发布的帖子列表
  /// [userId] 用户ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getUserPostList({
    required int userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedPostList,
      queryParameters: {
        'user_id': userId,
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 创建帖子
  /// [type] 帖子类型：1帖子 2文章
  /// [contentType] 内容类型：1纯文本 2图文 3视频 4链接
  /// [title] 标题（可选）
  /// [content] 内容
  /// [images] 图片URL列表
  /// [videos] 视频URL列表
  Future<Map<String, dynamic>> createPost({
    int type = 1,
    int contentType = 1,
    String? title,
    required String content,
    List<String>? images,
    List<String>? videos,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.feedPostCreate,
      data: {
        'type': type,
        'content_type': contentType,
        if (title != null) 'title': title,
        'content': content,
        if (images != null) 'images': images,
        if (videos != null) 'videos': videos,
      },
    );
    return response.data;
  }

  /// 删除帖子
  /// [id] 帖子ID
  Future<Map<String, dynamic>> deletePost({
    required int id,
  }) async {
    final response = await _dioClient.dio.delete(
      Endpoints.feedPostDelete,
      queryParameters: {
        'id': id,
      },
    );
    return response.data;
  }

  // ==================== 评论管理 ====================

  /// 获取评论列表
  /// [targetType] 目标类型：1帖子 2文章
  /// [targetId] 目标ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getCommentList({
    required int targetType,
    required int targetId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedCommentList,
      queryParameters: {
        'target_type': targetType,
        'target_id': targetId,
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取评论的回复列表
  /// [id] 评论ID
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getCommentReplies({
    required int id,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedCommentReplies,
      queryParameters: {
        'id': id,
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 创建评论
  /// [targetType] 目标类型：1帖子 2文章
  /// [targetId] 目标ID
  /// [content] 评论内容
  /// [parentId] 父评论ID，0为顶级评论
  /// [replyToUserId] 回复的用户ID
  /// [images] 图片URL列表
  Future<Map<String, dynamic>> createComment({
    required int targetType,
    required int targetId,
    required String content,
    int parentId = 0,
    int? replyToUserId,
    List<String>? images,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.feedCommentCreate,
      data: {
        'target_type': targetType,
        'target_id': targetId,
        'content': content,
        'parent_id': parentId,
        if (replyToUserId != null) 'reply_to_user_id': replyToUserId,
        if (images != null) 'images': images,
      },
    );
    return response.data;
  }

  /// 删除评论
  /// [id] 评论ID
  Future<Map<String, dynamic>> deleteComment({
    required int id,
  }) async {
    final response = await _dioClient.dio.delete(
      Endpoints.feedCommentDelete,
      queryParameters: {
        'id': id,
      },
    );
    return response.data;
  }

  // ==================== 用户操作 ====================

  /// 切换收藏状态
  /// [targetType] 目标类型：1帖子 2文章（注意：不支持公告和新闻）
  /// [targetId] 目标ID
  Future<Map<String, dynamic>> toggleCollect({
    required int targetType,
    required int targetId,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.feedUserCollectToggle,
      data: {
        'target_type': targetType,
        'target_id': targetId,
      },
    );
    return response.data;
  }

  /// 获取收藏列表
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getCollectList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedUserCollectList,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 切换点赞状态
  /// [targetType] 目标类型：1帖子 2文章 3评论
  /// [targetId] 目标ID
  Future<Map<String, dynamic>> toggleLike({
    required int targetType,
    required int targetId,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.feedUserLikeToggle,
      data: {
        'target_type': targetType,
        'target_id': targetId,
      },
    );
    return response.data;
  }

  /// 切换关注状态
  /// [followUserId] 被关注用户ID
  Future<Map<String, dynamic>> toggleFollow({
    required int followUserId,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.feedUserFollowToggle,
      data: {
        'follow_user_id': followUserId,
      },
    );
    return response.data;
  }

  /// 获取关注列表
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getFollowingList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedUserFollowingList,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取粉丝列表
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getFollowersList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedUserFollowersList,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取可能感兴趣的人列表
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<dynamic> getMayInterestedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedMayInterested,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return response.data;
  }

  /// 获取用户关注统计
  Future<Map<String, dynamic>> getUserFollowStats() async {
    final response = await _dioClient.dio.get(Endpoints.feedUserStats);
    return response.data;
  }

  /// 检查是否关注某用户
  /// [followUserId] 被关注用户ID
  Future<Map<String, dynamic>> checkFollowStatus({
    required int followUserId,
  }) async {
    final response = await _dioClient.dio.get(
      Endpoints.feedUserFollowStatus,
      queryParameters: {
        'follow_user_id': followUserId,
      },
    );
    return response.data;
  }

  // ==================== 举报管理 ====================

  /// 提交举报
  /// [targetType] 目标类型：1帖子 2文章 3评论
  /// [targetId] 目标ID
  /// [reportType] 举报类型：1垃圾广告 2色情低俗 3违法违规 4侮辱谩骂 5其他
  /// [content] 举报说明（可选）
  /// [images] 举报图片（可选）
  Future<Map<String, dynamic>> submitReport({
    required int targetType,
    required int targetId,
    required int reportType,
    String? content,
    List<String>? images,
  }) async {
    final response = await _dioClient.dio.post(
      Endpoints.feedReportSubmit,
      data: {
        'target_type': targetType,
        'target_id': targetId,
        'report_type': reportType,
        if (content != null && content.isNotEmpty) 'content': content,
        if (images != null && images.isNotEmpty) 'images': images,
      },
    );
    return response.data;
  }
}
