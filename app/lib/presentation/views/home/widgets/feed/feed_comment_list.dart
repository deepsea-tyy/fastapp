import 'package:flutter/material.dart';
import 'package:fastapp/domain/entity/feed/feed_comment.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/presentation/views/user/user_profile_page.dart';
import 'package:get_it/get_it.dart';

/// 信息流评论列表组件
class FeedCommentList extends StatefulWidget {
  final int postId;
  final int commentCount;

  const FeedCommentList({
    super.key,
    required this.postId,
    required this.commentCount,
  });

  @override
  State<FeedCommentList> createState() => _FeedCommentListState();
}

class _FeedCommentListState extends State<FeedCommentList> {
  final FeedRepository _feedRepository = GetIt.instance<FeedRepository>();
  List<FeedComment> _comments = [];
  bool _isLoading = false;
  String _sortBy = 'hot'; // hot: 热门, latest: 最新

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await _feedRepository.getCommentList(
        targetType: 1, // 1表示帖子
        targetId: widget.postId,
        page: 1,
        pageSize: 20,
      );

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // TODO: 显示错误提示
      debugPrint('加载评论失败: $e');
    }
  }

  void _changeSortBy(String sortBy) {
    if (_sortBy == sortBy) return;

    setState(() {
      _sortBy = sortBy;
    });

    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.commentCount == 0 && _comments.isEmpty) {
      return _buildEmptyComments();
    }

    if (_isLoading && _comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentHeader(),
        const SizedBox(height: 16),
        _buildComments(),
      ],
    );
  }

  /// 评论头部（数量和排序选项）
  Widget _buildCommentHeader() {
    final count = _comments.isNotEmpty ? _comments.length : widget.commentCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            '${count}条回复',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          _buildCommentTab('热门', sortBy: 'hot'),
          const SizedBox(width: 16),
          _buildCommentTab('最新', sortBy: 'latest'),
        ],
      ),
    );
  }

  Widget _buildCommentTab(String text, {required String sortBy}) {
    final isSelected = _sortBy == sortBy;
    return GestureDetector(
      onTap: () => _changeSortBy(sortBy),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? Colors.black87 : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// 空评论状态
  Widget _buildEmptyComments() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              '抢占头条评论,分享你的见解',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: 打开评论输入
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                '添加首评',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 评论列表
  Widget _buildComments() {
    if (_comments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ..._comments.map((comment) {
          return FeedCommentItem(
            comment: comment,
            onReply: () {
              // TODO: 实现回复功能
            },
            onLike: () {
              // TODO: 实现点赞功能
            },
          );
        }),
        // 查看更多按钮
        if (_comments.length >= 20)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: TextButton(
              onPressed: () {
                // TODO: 加载更多评论
              },
              child: Text(
                '查看更多',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 评论项组件
class FeedCommentItem extends StatelessWidget {
  final FeedComment comment;
  final VoidCallback? onReply;
  final VoidCallback? onLike;

  const FeedCommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: comment.isNested ? 48.0 : 0,
        top: comment.isNested ? 8.0 : 12.0,
        bottom: comment.isNested ? 0 : 12.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(context),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
          const SizedBox(width: 12),
          _buildLikeButton(),
        ],
      ),
    );
  }

  /// 用户头像
  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: comment.userId),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 20, color: Colors.grey),
      ),
    );
  }

  /// 评论内容区域
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 4),
        if (comment.replyToUsername != null) _buildReplyMark(),
        _buildCommentText(),
        const SizedBox(height: 8),
        _buildActions(),
      ],
    );
  }

  /// 用户信息（用户名、作者标记、时间）
  Widget _buildUserInfo() {
    return Row(
      children: [
        Text(
          comment.username ?? '未知用户',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (comment.isAuthor == true) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '作者',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
        const Spacer(),
        Text(
          comment.getFormattedTime(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 回复标记
  Widget _buildReplyMark() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '回复 ',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          TextSpan(
            text: '@${comment.replyToUsername}',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ' '),
        ],
      ),
    );
  }

  /// 评论文本
  Widget _buildCommentText() {
    return Text(
      comment.content,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.4,
      ),
    );
  }

  /// 操作按钮（回复、引用、翻译等）
  Widget _buildActions() {
    return Row(
      children: [
        _buildAction('回复', onPressed: onReply),
        const SizedBox(width: 16),
        _buildAction('引用'),
      ],
    );
  }

  Widget _buildAction(String text, {Color? color, VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed ?? () {
        // TODO: 处理评论操作
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color ?? Colors.grey.shade600,
        ),
      ),
    );
  }

  /// 点赞按钮
  Widget _buildLikeButton() {
    final isLiked = comment.isLiked == true;
    return GestureDetector(
      onTap: onLike,
      child: Column(
        children: [
          Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 18,
            color: isLiked ? Colors.orange.shade700 : Colors.grey.shade600,
          ),
          const SizedBox(height: 2),
          Text(
            comment.likeCount.toString(),
            style: TextStyle(
              fontSize: 12,
              color: isLiked ? Colors.orange.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
