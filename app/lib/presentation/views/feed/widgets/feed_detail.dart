import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_comment.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/views/feed/feed_profile.dart';
import 'package:fastapp/presentation/views/common/image_preview_page.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'feed_comment_list.dart';
import 'feed_comment_input_sheet.dart';
import 'feed_menu_sheet.dart';
import 'user_avatar.dart';

class FeedDetail extends StatefulWidget {
  final int postId;
  final int userId;
  final String username;
  final String time;
  final String content;
  final String? title;
  final String? originalLink;
  final List<String>? mediaUrls;
  final int commentCount;
  final int likeCount;
  final int repostCount;
  final int shareCount;
  final String avatarAsset;
  final bool isVerified;
  final int viewCount;
  final bool scrollToComments;
  final int type; // 帖子类型：1帖子 2文章
  final bool isLiked; // 是否已点赞

  const FeedDetail({
    super.key,
    required this.postId,
    required this.userId,
    required this.username,
    required this.time,
    required this.content,
    this.title,
    this.originalLink,
    this.mediaUrls,
    this.commentCount = 0,
    this.likeCount = 0,
    this.repostCount = 0,
    this.shareCount = 0,
    this.avatarAsset = '',
    this.isVerified = false,
    this.viewCount = 0,
    this.scrollToComments = false,
    this.type = 1, // 默认为帖子
    this.isLiked = false, // 默认未点赞
  });

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();
  final UserApi _userApi = getIt<UserApi>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  late bool _isLiked;
  late int _likeCount;
  bool _isLiking = false;
  bool _isCollected = false;
  bool _isCollecting = false;
  bool _isLoadingDetail = true;
  late int _commentCount;

  // 评论列表的key，用于刷新评论列表
  final GlobalKey<_FeedCommentListWrapperState> _commentListKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // 初始化点赞状态和评论数
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
    _commentCount = widget.commentCount;

    // 加载帖子详情（包含所有状态）
    _loadPostDetail();

    if (widget.scrollToComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComments();
      });
    }
  }

  /// 加载帖子详情（包含所有状态）
  Future<void> _loadPostDetail() async {
    try {
      final post = await _feedRepository.getPostDetail(id: widget.postId);
      if (post != null && mounted) {
        setState(() {
          // 更新所有状态
          _isCollected = post.isCollected ?? false;
          _isFollowing = post.isFollowing ?? false;
          _isLiked = post.isLiked ?? _isLiked;
          _likeCount = post.likeCount;
          _commentCount = post.commentCount;
          _isLoadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDetail = false);
      }
      debugPrint('加载帖子详情失败: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    final context = _commentsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                key: ValueKey(_isCollected),
                _isCollected ? Icons.star : Icons.star_border,
                color: _isCollected ? Colors.orange.shade600 : Colors.black,
              ),
            ),
            onPressed: _isCollecting ? null : _handleCollect,
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.black),
            onPressed: _navigateToReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorSection(),
            _buildTitle(),
            _buildContent(),
            if (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMediaGallery(),
            ],
            const SizedBox(height: 24),
            _buildDisclaimer(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 24),
            KeyedSubtree(
              key: _commentsKey,
              child: _buildCommentsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAuthorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          UserAvatar(
            avatarAsset: widget.avatarAsset,
            isVerified: widget.isVerified,
            onTap: _navigateToUserProfile,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToUserProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _isFollowLoading ? null : _handleFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isFollowing ? Colors.grey.shade300 : Colors.orange.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isFollowLoading
                  ? SizedBox(
                      width: 40,
                      height: 18,
                      child: Center(
                        child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isFollowing ? Colors.grey.shade600 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _isFollowing ? '已关注' : '+ 关注',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isFollowing ? Colors.grey.shade700 : Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: widget.userId),
      ),
    );
  }

  Future<void> _handleFollow() async {
    if (_isFollowLoading) return;

    // 乐观更新：先更新UI，提升用户体验
    final previousState = _isFollowing;
    setState(() {
      _isFollowing = !_isFollowing;
      _isFollowLoading = true;
    });

    try {
      final result = await _feedRepository.toggleFollow(
        followUserId: widget.userId,
      );
      if (mounted) {
        setState(() {
          _isFollowing = result.isFollowing;
          _isFollowLoading = false;
        });
        // 显示操作提示
        if (result.message != null) {
          MessageService.success(result.message!);
        }
      }
    } catch (e) {
      // 发生错误时回滚状态
      if (mounted) {
        setState(() {
          _isFollowing = previousState;
          _isFollowLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
      debugPrint('关注操作失败: $e');
    }
  }

  /// 处理点赞
  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);

    try {
      final result = await _feedRepository.toggleLike(
        targetType: widget.type,
        targetId: widget.postId,
      );
      if (mounted) {
        setState(() {
          _isLiked = result.isLiked;
          _likeCount = result.likeCount;
          _isLiking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLiking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点赞失败: $e')),
        );
      }
      debugPrint('点赞失败: $e');
    }
  }

  /// 处理收藏
  Future<void> _handleCollect() async {
    if (_isCollecting) return;

    final previousState = _isCollected;
    setState(() {
      _isCollected = !_isCollected;
      _isCollecting = true;
    });

    try {
      final result = await _feedRepository.toggleCollect(
        targetType: widget.type,
        targetId: widget.postId,
      );
      if (mounted) {
        setState(() {
          _isCollected = result.isCollected;
          _isCollecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCollected = previousState;
          _isCollecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('收藏失败: $e')),
        );
      }
      debugPrint('收藏失败: $e');
    }
  }

  void _navigateToReport() async {
    final result = await FeedMenuSheet.show(
      context,
      username: widget.username,
      topic: null, // TODO: 从帖子内容中提取话题
      targetId: widget.postId,
      targetType: widget.type,
      userId: widget.userId,
    );

    // 处理不感兴趣操作
    if (result != null && mounted) {
      if (result == 'not_interested_post') {
        MessageService.success('已标记为不感兴趣');
        // 关闭详情页返回上一页
        Navigator.of(context).pop(true); // 返回 true 表示需要刷新列表
      } else if (result == 'not_interested_user') {
        MessageService.success('已屏蔽该用户');
        // 关闭详情页返回上一页
        Navigator.of(context).pop(true); // 返回 true 表示需要刷新列表
      }
    }
  }

  Widget _buildTitle() {
    if (widget.title == null || widget.title!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.title!,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Html(
        data: widget.content,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            color: Colors.black87,
            lineHeight: const LineHeight(1.6),
          ),
        },
      ),
    );
  }

  Widget _buildMediaGallery() {
    final mediaUrls = widget.mediaUrls!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImagePreview(context, mediaUrls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                mediaUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImagePreview(BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ImagePreviewPage(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: '免责声明：含第三方意见，不构成财务建议，并且可能包含赞助内容。详见'),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () {
                            MessageService.info('请阅读完整的条款和条件以了解详细信息');
                          },
                          child: Text(
                            '《条款和条件》',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '。'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final viewCountText = widget.viewCount >= 1000
        ? '${(widget.viewCount / 1000).toStringAsFixed(1)}K 次浏览'
        : '${widget.viewCount} 次浏览';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(viewCountText),
          const SizedBox(width: 16),
          _buildStatItem('$_likeCount 次点赞'),
          const SizedBox(width: 16),
          _buildStatItem('${widget.repostCount} 次引用'),
          const SizedBox(width: 16),
          _buildStatItem('${widget.shareCount} 次分享'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
    );
  }

  Widget _buildCommentsSection() {
    return _FeedCommentListWrapper(
      key: _commentListKey,
      postId: widget.postId,
      postType: widget.type,
      commentCount: _commentCount,
      onReply: (parentId, replyToUserId, replyToUsername) {
        _showCommentInput(
          parentId: parentId,
          replyToUserId: replyToUserId,
          replyToUsername: replyToUsername,
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showCommentInput,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '分享你的想法...',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomIcon(Icons.comment_outlined, _commentCount,
                    onTap: _showCommentInput),
                _buildBottomIcon(
                    _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    _likeCount,
                    onTap: _handleLike,
                    isActive: _isLiked),
                _buildBottomIcon(Icons.share, widget.shareCount, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentInput({int? parentId, int? replyToUserId, String? replyToUsername}) {
    FeedCommentInputSheet.show(
      context,
      placeholder: (replyToUsername?.isNotEmpty ?? false)
          ? '回复 @$replyToUsername'
          : '添加回复...',
      showRepostOption: false,
      parentId: parentId,
      replyToUserId: replyToUserId,
      replyToUsername: replyToUsername,
      onSend: (content, images) => _sendComment(
        content: content,
        images: images,
        parentId: parentId ?? 0,
        replyToUserId: replyToUserId,
      ),
    );
  }

  /// 发送评论
  Future<void> _sendComment({
    required String content,
    required List<String> images,
    int parentId = 0,
    int? replyToUserId,
  }) async {
    try {
      final response = await _feedRepository.createComment(
        targetType: widget.type,
        targetId: widget.postId,
        content: content,
        parentId: parentId,
        replyToUserId: replyToUserId,
        images: images.isNotEmpty ? images : null,
      );

      if (!mounted) return;

      // 更新评论数
      final newCommentCount = response['comment_count'];
      if (newCommentCount is int) {
        setState(() => _commentCount = newCommentCount);
      } else if (parentId == 0) {
        setState(() => _commentCount++);
      }

      // 直接添加新评论到列表
      try {
        _commentListKey.currentState?.addComment(FeedComment.fromJson(response));
      } catch (e) {
        debugPrint('解析新评论失败: $e，重新加载列表');
        _commentListKey.currentState?._loadComments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('评论失败: $e')),
        );
      }
      debugPrint('评论失败: $e');
    }
  }

  Widget _buildBottomIcon(IconData icon, int count,
      {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 20,
              color: isActive ? Colors.orange.shade600 : Colors.grey.shade600),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 10,
                color:
                    isActive ? Colors.orange.shade600 : Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// 评论列表包装组件，用于外部刷新
class _FeedCommentListWrapper extends StatefulWidget {
  final int postId;
  final int postType;
  final int commentCount;
  final Function(int parentId, int replyToUserId, String replyToUsername)? onReply;

  const _FeedCommentListWrapper({
    super.key,
    required this.postId,
    required this.postType,
    required this.commentCount,
    this.onReply,
  });

  @override
  State<_FeedCommentListWrapper> createState() => _FeedCommentListWrapperState();
}

class _FeedCommentListWrapperState extends State<_FeedCommentListWrapper> {
  final GlobalKey<FeedCommentListState> _listKey = GlobalKey();

  void _loadComments() => _listKey.currentState?.loadComments();

  void addComment(FeedComment comment) => _listKey.currentState?.addComment(comment);

  @override
  Widget build(BuildContext context) {
    return FeedCommentList(
      key: _listKey,
      postId: widget.postId,
      postType: widget.postType,
      commentCount: widget.commentCount,
      onReply: widget.onReply,
    );
  }
}
