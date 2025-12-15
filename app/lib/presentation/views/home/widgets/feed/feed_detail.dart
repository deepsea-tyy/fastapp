import 'package:flutter/material.dart';
import 'feed_comment_list.dart';
import 'feed_comment_input_sheet.dart';

/// 信息流详情页面
///
/// 显示完整的帖子内容、统计数据、评论等
class FeedDetail extends StatefulWidget {
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
  final bool scrollToComments;

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
    this.scrollToComments = false,
  });

  @override
  State<FeedDetail> createState() => _FeedDetailState();
}

class _FeedDetailState extends State<FeedDetail> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '+ 关注',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.black),
            onPressed: () {
              // TODO: 举报功能
            },
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
            if (widget.media != null && widget.media!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...widget.media!,
            ],
            const SizedBox(height: 24),
            _buildDisclaimer(),
            const SizedBox(height: 16),
            _buildShareButtons(),
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
                child: widget.avatarAsset.isNotEmpty
                    ? ClipOval(
                        child: Image.asset(
                          widget.avatarAsset,
                          fit: BoxFit.cover,
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
          const SizedBox(width: 12),
          Expanded(
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
        ],
      ),
    );
  }

  Widget _buildTitle() {
    if (widget.title == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        widget.content,
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
    return Flexible(
      child: Column(
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
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildCommentsSection() {
    return FeedCommentList(commentCount: widget.commentCount);
  }

  Widget _buildBottomBar() {
    return Builder(
      builder: (context) {
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
                flex: 1,
                child: GestureDetector(
                  onTap: () => _showCommentInput(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '分享你的想法...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomIcon(
                      Icons.comment_outlined,
                      widget.commentCount,
                      onTap: () => _showCommentInput(context),
                    ),
                    _buildBottomIcon(
                      Icons.thumb_up_outlined,
                      widget.likeCount,
                      onTap: () {
                        // TODO: 点赞功能
                      },
                    ),
                    _buildBottomIcon(
                      Icons.share,
                      widget.shareCount,
                      onTap: () {
                        // TODO: 分享功能
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentInput(BuildContext context) {
    FeedCommentInputSheet.show(
      context,
      placeholder: '添加回复...',
      onSend: () {
        // TODO: 发送评论
      },
    );
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

  Widget _buildBottomIcon(IconData icon, int count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
