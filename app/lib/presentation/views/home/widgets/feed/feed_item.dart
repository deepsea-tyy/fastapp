import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_detail.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_action_bar.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_comment_input_sheet.dart';
import 'package:fastapp/presentation/views/user/user_profile_page.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:get_it/get_it.dart';

/// 信息流帖子组件
///
/// 显示用户发布的帖子，包含头像、用户名、时间、内容、图片/图表和互动按钮
class FeedItem extends StatefulWidget {
  final int postId;
  final int userId;
  final String username;
  final String time;
  final String content;
  final String? title;
  final String? originalLink;
  final List<Widget>? media;
  final int commentCount;
  final int likeCount;
  final int repostCount;
  final int shareCount;
  final String avatarAsset;
  final bool isVerified;
  final bool showMenu;
  final IconData? menuIcon;
  final bool isLiked;

  const FeedItem({
    super.key,
    required this.postId,
    required this.userId,
    required this.username,
    required this.time,
    required this.content,
    this.title,
    this.originalLink,
    this.media,
    this.commentCount = 0,
    this.likeCount = 0,
    this.repostCount = 0,
    this.shareCount = 0,
    this.avatarAsset = '',
    this.isVerified = false,
    this.showMenu = true,
    this.menuIcon,
    this.isLiked = false,
  });

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  final FeedRepository _feedRepository = GetIt.instance<FeedRepository>();
  late bool _isLiked;
  late int _likeCount;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildContent(context),
            if (widget.media != null && widget.media!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMedia(context),
            ],
            const SizedBox(height: 12),
            _buildEngagementBar(),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, {bool scrollToComments = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: widget.postId,
          userId: widget.userId,
          username: widget.username,
          time: widget.time,
          content: widget.content,
          title: widget.title,
          originalLink: widget.originalLink,
          media: widget.media,
          commentCount: widget.commentCount,
          likeCount: _likeCount,
          repostCount: widget.repostCount,
          shareCount: widget.shareCount,
          avatarAsset: widget.avatarAsset,
          isVerified: widget.isVerified,
          viewCount: 15400,
          scrollToComments: scrollToComments,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToUserProfile(context),
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: widget.avatarAsset.isNotEmpty &&
                        widget.avatarAsset != '/404.png'
                    ? ClipOval(
                        child: Image.network(
                          widget.avatarAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              if (widget.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToUserProfile(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
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
        if (widget.showMenu)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // TODO: 显示菜单
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                widget.menuIcon ?? Icons.close,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: widget.userId),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            widget.content,
            style: TextStyle(
              fontSize: widget.title != null ? 14 : 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (widget.originalLink != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // TODO: 查看原文
              },
              child: Text(
                widget.originalLink!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    if (widget.media == null || widget.media!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.media!.length == 1) {
      return GestureDetector(
        onTap: () => _navigateToDetail(context),
        child: widget.media!.first,
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToDetail(context),
            child: widget.media![0],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToDetail(context),
            child: widget.media![1],
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementBar() {
    return Builder(
      builder: (context) {
        return FeedActionBar(
          commentCount: widget.commentCount,
          likeCount: _likeCount,
          repostCount: widget.repostCount,
          shareCount: widget.shareCount,
          isLiked: _isLiked,
          onCommentTap: () => _navigateToDetail(context, scrollToComments: true),
          onLikeTap: _handleLike,
          onRepostTap: () => _showRepostSheet(context),
          onShareTap: () {
            // TODO: 分享功能
          },
        );
      },
    );
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final result = await _feedRepository.toggleLike(
        targetType: 1, // 1表示帖子
        targetId: widget.postId,
      );

      setState(() {
        _isLiked = result.isLiked;
        _likeCount = result.likeCount;
        _isLiking = false;
      });
    } catch (e) {
      setState(() {
        _isLiking = false;
      });
      debugPrint('点赞操作失败: $e');
      // TODO: 显示错误提示
    }
  }

  void _showRepostSheet(BuildContext context) {
    FeedCommentInputSheet.show(
      context,
      placeholder: '评论并转发...',
      showRepostOption: true,
      onSend: () {
        // TODO: 转发功能
      },
    );
  }
}
