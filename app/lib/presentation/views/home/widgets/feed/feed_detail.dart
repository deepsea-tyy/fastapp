import 'package:flutter/material.dart';
import 'feed_comment_list.dart';

/// 信息流详情页面
///
/// 显示完整的帖子内容、统计数据、评论等
class FeedDetail extends StatelessWidget {
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
  final int viewCount;

  const FeedDetail({
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
    this.viewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: 显示菜单
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorSection(),
            _buildTitle(),
            _buildContent(),
            if (media != null && media!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...media!,
            ],
            const SizedBox(height: 24),
            _buildDisclaimer(),
            const SizedBox(height: 16),
            _buildShareButtons(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 24),
            _buildCommentsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAuthorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Stack(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '关注',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    if (title == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title!,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '免责声明:含第三方意见,不构成财务建议,并且可能包含赞助内容。',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '详见',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: 打开条款和条件
                },
                child: Text(
                  '《条款和条件》',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                '。',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildShareButton(Colors.lightBlue, Icons.send, 'Telegram'),
          _buildShareButton(Colors.green, Icons.chat, 'WhatsApp'),
          _buildShareButton(Colors.grey.shade300, Icons.link, '链接'),
        ],
      ),
    );
  }

  Widget _buildShareButton(Color color, IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final viewCountText = viewCount >= 1000 
        ? '${(viewCount / 1000).toStringAsFixed(1)}K 次浏览'
        : '$viewCount 次浏览';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildStatItem(viewCountText),
          const SizedBox(width: 16),
          _buildStatItem('$likeCount 次点赞'),
          const SizedBox(width: 16),
          _buildStatItem('$repostCount 次引用'),
          const SizedBox(width: 16),
          _buildStatItem('$shareCount 次分享'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildCommentsSection() {
    return FeedCommentList(commentCount: commentCount);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '分享你的想法...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildBottomIcon(Icons.comment, commentCount.toString()),
          const SizedBox(width: 12),
          _buildBottomIcon(Icons.thumb_up, likeCount.toString()),
          const SizedBox(width: 12),
          _buildBottomIcon(Icons.repeat, repostCount.toString()),
          const SizedBox(width: 12),
          _buildBottomIcon(Icons.share, shareCount.toString()),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        Text(
          count,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
