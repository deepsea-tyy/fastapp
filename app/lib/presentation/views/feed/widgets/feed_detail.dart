import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fastapp/presentation/views/feed/feed_profile.dart';
import 'package:fastapp/presentation/views/common/image_preview_page.dart';
import 'feed_comment_list.dart';
import 'feed_comment_input_sheet.dart';
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
  });

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollToComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComments();
      });
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
          GestureDetector(
            onTap: _isFollowLoading ? null : _handleFollow,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _isFollowing ? Colors.grey.shade300 : Colors.orange.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isFollowLoading
                  ? SizedBox(
                      width: 40,
                      height: 20,
                      child: Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
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
    setState(() => _isFollowLoading = true);

    try {
      // TODO: 调用关注/取消关注接口
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络请求

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _isFollowLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFollowLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _navigateToReport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('举报此帖子'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 跳转到举报页面或显示举报表单
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('举报功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('屏蔽此用户'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 调用屏蔽用户接口
              },
            ),
          ],
        ),
      ),
    );
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
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '免责声明:含第三方意见,不构成财务建议,并且可能包含赞助内容。',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              children: [
                const TextSpan(text: '详见'),
                TextSpan(
                  text: '《条款和条件》',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: '。'),
              ],
            ),
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
          _buildStatItem('${widget.likeCount} 次点赞'),
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
    return FeedCommentList(
      postId: widget.postId,
      commentCount: widget.commentCount,
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
                _buildBottomIcon(Icons.comment_outlined, widget.commentCount,
                    onTap: _showCommentInput),
                _buildBottomIcon(Icons.thumb_up_outlined, widget.likeCount,
                    onTap: () {}),
                _buildBottomIcon(Icons.share, widget.shareCount, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentInput() {
    FeedCommentInputSheet.show(
      context,
      placeholder: '添加回复...',
      onSend: () {},
    );
  }

  Widget _buildBottomIcon(IconData icon, int count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
