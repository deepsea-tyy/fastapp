import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_detail.dart';

/// 信息流帖子组件
///
/// 显示用户发布的帖子，包含头像、用户名、时间、内容、图片/图表和互动按钮
class FeedItem extends StatelessWidget {
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

  const FeedItem({
    super.key,
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
  });

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
            if (media != null && media!.isNotEmpty) ...[
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

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          username: username,
          time: time,
          content: content,
          title: title,
          originalLink: originalLink,
          media: media,
          commentCount: commentCount,
          likeCount: likeCount,
          repostCount: repostCount,
          shareCount: shareCount,
          avatarAsset: avatarAsset,
          isVerified: isVerified,
          viewCount: 15400,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToDetail(context),
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: avatarAsset.isNotEmpty
                    ? ClipOval(
                        child: Image.asset(
                          avatarAsset,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              if (isVerified)
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
            onTap: () => _navigateToDetail(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showMenu)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // TODO: 显示菜单
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                menuIcon ?? Icons.close,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
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
            content,
            style: TextStyle(
              fontSize: title != null ? 14 : 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (originalLink != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // TODO: 查看原文
              },
              child: Text(
                originalLink!,
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
    if (media == null || media!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (media!.length == 1) {
      return GestureDetector(
        onTap: () => _navigateToDetail(context),
        child: media!.first,
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToDetail(context),
            child: media![0],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToDetail(context),
            child: media![1],
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 阻止事件冒泡，互动栏点击不跳转
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEngagementItem(Icons.comment_outlined, commentCount),
          _buildEngagementItem(Icons.thumb_up_outlined, likeCount),
          _buildEngagementItem(Icons.repeat, repostCount),
          _buildEngagementItem(Icons.share, shareCount),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
