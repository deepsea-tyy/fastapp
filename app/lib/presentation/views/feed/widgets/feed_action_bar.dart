import 'package:flutter/material.dart';
import 'package:fastapp/core/theme/feed_theme_extension.dart';

/// Feed 互动操作栏（通用组件）
///
/// 用于列表和详情页的互动按钮（评论、点赞、转发、分享）
class FeedActionBar extends StatelessWidget {
  final int commentCount;
  final int likeCount;
  final int repostCount;
  final int shareCount;
  final VoidCallback? onCommentTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onRepostTap;
  final VoidCallback? onShareTap;
  final bool isLiked;
  final bool isVertical;

  const FeedActionBar({
    super.key,
    required this.commentCount,
    required this.likeCount,
    required this.repostCount,
    required this.shareCount,
    this.onCommentTap,
    this.onLikeTap,
    this.onRepostTap,
    this.onShareTap,
    this.isLiked = false,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionItem(
            icon: Icons.comment_outlined,
            count: commentCount,
            onTap: onCommentTap,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            count: likeCount,
            onTap: onLikeTap,
            isActive: isLiked,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.repeat,
            count: repostCount,
            onTap: onRepostTap,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.share,
            count: shareCount,
            onTap: onShareTap,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: Icons.comment_outlined,
          count: commentCount,
          onTap: onCommentTap,
        ),
        _buildActionItem(
          icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          count: likeCount,
          onTap: onLikeTap,
          isActive: isLiked,
        ),
        _buildActionItem(
          icon: Icons.repeat,
          count: repostCount,
          onTap: onRepostTap,
        ),
        _buildActionItem(
          icon: Icons.share,
          count: shareCount,
          onTap: onShareTap,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required int count,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return Builder(
      builder: (context) {
        final feedTheme = context.feedTheme;
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: isVertical
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 24,
                        color: isActive ? feedTheme.actionIconActive : feedTheme.actionIconDefault,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCount(count),
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? feedTheme.actionTextActive : feedTheme.actionTextDefault,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isActive ? feedTheme.actionIconActive : feedTheme.actionIconDefault,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(count),
                        style: TextStyle(
                          fontSize: 14,
                          color: isActive ? feedTheme.actionTextActive : feedTheme.actionTextDefault,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
