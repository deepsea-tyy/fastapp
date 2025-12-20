import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/repository/feed/feed_repository.dart';
import '../../../domain/entity/feed/feed_post.dart';
import '../../../domain/entity/feed/feed_comment.dart';
import '../../../domain/entity/feed/feed_operation_result.dart';
import '../../../domain/entity/feed/feed_article.dart';
import '../../../domain/entity/feed/feed_user_profile.dart';
import '../../../core/utils/error_handler.dart';
import '../../network/apis/feed/feed_api.dart';

/// 信息流Repository实现类
class FeedRepositoryImpl implements FeedRepository {
  final FeedApi _feedApi;

  FeedRepositoryImpl(this._feedApi);

  // ==================== 信息流列表 ====================

  @override
  Future<List<FeedPost>> getFeedList({
    String filter = 'latest',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getFeedList(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

      // 从响应中提取数据数组
      // ResponseInterceptor 已经提取了 data 字段，所以 response 就是 data 的内容
      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取信息流失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedPost>> getFeedListByTag({
    required int tagId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getFeedListByTag(
        tagId: tagId,
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取标签信息流失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedPost>> getFollowingFeedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getFollowingFeedList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取关注信息流失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedPost>> getHotFeedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getHotFeedList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取热门信息流失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedTag>> getHotTags({
    int limit = 10,
  }) async {
    try {
      final response = await _feedApi.getHotTags(limit: limit);

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedTag.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedTag.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取热门标签失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedArticle>> getNewsList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getNewsList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedArticle.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedArticle.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取新闻列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedArticle>> getAnnouncementList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getAnnouncementList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedArticle.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedArticle.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取公告列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== 帖子管理 ====================

  @override
  Future<FeedPost?> getPostDetail({
    required int id,
  }) async {
    try {
      final response = await _feedApi.getPostDetail(id: id);

      if (response is Map<String, dynamic>) {
        return FeedPost.fromJson(response);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取帖子详情失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedPost>> getUserPostList({
    required int userId,
    int? type,
    int? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getUserPostList(
        userId: userId,
        type: type,
        status: status,
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取用户帖子失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<FeedPost> createPost({
    int type = 1,
    int contentType = 1,
    String? title,
    required String content,
    List<String>? images,
    List<String>? videos,
    int? quotedType,
    int? quotedId,
  }) async {
    try {
      final response = await _feedApi.createPost(
        type: type,
        contentType: contentType,
        title: title,
        content: content,
        images: images,
        videos: videos,
        quotedType: quotedType,
        quotedId: quotedId,
      );

      if (response is Map<String, dynamic>) {
        return FeedPost.fromJson(response);
      }
      throw Exception('发布帖子失败：返回数据格式错误');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '发布帖子失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> updatePost({
    required int id,
    int? status,
  }) async {
    try {
      final response = await _feedApi.updatePost(
        id: id,
        status: status,
      );
      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '更新帖子失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> deletePost({
    required int id,
  }) async {
    try {
      final response = await _feedApi.deletePost(id: id);
      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '删除帖子失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== 评论管理 ====================

  @override
  Future<List<FeedComment>> getCommentList({
    required int targetType,
    required int targetId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getCommentList(
        targetType: targetType,
        targetId: targetId,
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedComment.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedComment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取评论列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedComment>> getCommentReplies({
    required int id,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getCommentReplies(
        id: id,
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedComment.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedComment.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取回复列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createComment({
    required int targetType,
    required int targetId,
    required String content,
    int parentId = 0,
    int? replyToUserId,
    List<String>? images,
  }) async {
    try {
      final response = await _feedApi.createComment(
        targetType: targetType,
        targetId: targetId,
        content: content,
        parentId: parentId,
        replyToUserId: replyToUserId,
        images: images,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '发表评论失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> deleteComment({
    required int id,
  }) async {
    try {
      final response = await _feedApi.deleteComment(id: id);
      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '删除评论失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== 用户操作 ====================

  @override
  Future<CollectResult> toggleCollect({
    required int targetType,
    required int targetId,
  }) async {
    try {
      final response = await _feedApi.toggleCollect(
        targetType: targetType,
        targetId: targetId,
      );

      if (response is Map<String, dynamic>) {
        return CollectResult.fromJson(response);
      }
      throw Exception('收藏操作失败：返回数据格式错误');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '收藏操作失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FeedPost>> getCollectList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getCollectList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取收藏列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<LikeResult> toggleLike({
    required int targetType,
    required int targetId,
  }) async {
    try {
      final response = await _feedApi.toggleLike(
        targetType: targetType,
        targetId: targetId,
      );

      if (response is Map<String, dynamic>) {
        return LikeResult.fromJson(response);
      }
      throw Exception('点赞操作失败：返回数据格式错误');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '点赞操作失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<FollowResult> toggleFollow({
    required int followUserId,
  }) async {
    try {
      final response = await _feedApi.toggleFollow(
        followUserId: followUserId,
      );

      if (response is Map<String, dynamic>) {
        return FollowResult.fromJson(response);
      }
      throw Exception('关注操作失败：返回数据格式错误');
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '关注操作失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<int>> getFollowingList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getFollowingList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => (item as Map<String, dynamic>)['user_id'] as int)
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => (item as Map<String, dynamic>)['user_id'] as int)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取关注列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowingUserList({
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await _feedApi.getFollowingList(
        page: page,
        pageSize: pageSize,
      );

      // 解析返回数据，后端返回格式为：
      // [
      //   {
      //     'follow_user_id' => ...,
      //     'user_id' => ...,
      //     'nickname' => ...,
      //     'avatar' => ...,
      //   },
      //   ...
      // ]
      final dynamic data = response;
      List<dynamic> list = [];
      if (data is Map<String, dynamic> && data['list'] is List) {
        list = data['list'] as List;
      } else if (data is List) {
        list = data;
      }

      return list
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取关注列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<int>> getFollowersList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getFollowersList(
        page: page,
        pageSize: pageSize,
      );

      // 兼容两种返回格式：直接数组 或 {"list": [...]}
      final dynamic data = response;
      if (data is List) {
        return data
            .map((item) => (item as Map<String, dynamic>)['user_id'] as int)
            .toList();
      } else if (data is Map<String, dynamic> && data['list'] is List) {
        return (data['list'] as List)
            .map((item) => (item as Map<String, dynamic>)['user_id'] as int)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取粉丝列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserFollowStats?> getUserFollowStats({int? userId}) async {
    try {
      final response = await _feedApi.getUserFollowStats(userId: userId);

      return UserFollowStats.fromJson(response);
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取关注统计失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> checkFollowStatus({
    required int followUserId,
  }) async {
    try {
      final response = await _feedApi.checkFollowStatus(
        followUserId: followUserId,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '检查关注状态失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMayInterestedList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _feedApi.getMayInterestedList(
        page: page,
        pageSize: pageSize,
      );

      final dynamic data = response;
      List<dynamic> list = [];
      if (data is Map<String, dynamic> && data['list'] is List) {
        list = data['list'] as List;
      } else if (data is List) {
        list = data;
      }

      return list
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '获取感兴趣人列表失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==================== 举报管理 ====================

  @override
  Future<Map<String, dynamic>> submitReport({
    required int targetType,
    required int targetId,
    required int reportType,
    String? content,
    List<String>? images,
  }) async {
    try {
      final response = await _feedApi.submitReport(
        targetType: targetType,
        targetId: targetId,
        reportType: reportType,
        content: content,
        images: images,
      );

      return response;
    } on DioException catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e, defaultMessage: '提交举报失败'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
