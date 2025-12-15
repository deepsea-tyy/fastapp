import 'package:flutter/material.dart';

/// 信息流评论列表组件
class FeedCommentList extends StatelessWidget {
  final int commentCount;

  const FeedCommentList({
    super.key,
    required this.commentCount,
  });

  @override
  Widget build(BuildContext context) {
    if (commentCount == 0) {
      return _buildEmptyComments();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            '$commentCount条回复',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          _buildCommentTab('热门', isSelected: true),
          const SizedBox(width: 16),
          _buildCommentTab('最新', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildCommentTab(String text, {required bool isSelected}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: isSelected ? Colors.black87 : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    return Column(
      children: [
        // 示例评论数据
        FeedCommentItem(
          username: 'pippin team',
          time: '11 小时',
          content: 'You are the reason why pippin is pumping',
          likeCount: 4,
          hasTranslation: true,
          isAuthor: false,
        ),
        // 嵌套回复
        FeedCommentItem(
          username: '程小程',
          time: '5 小时',
          content: '这是大户，你敢这样和大户说话，你想爆仓了😂😂',
          likeCount: 0,
          replyToUser: '亏钱户',
          isNested: true,
          isAuthor: false,
        ),
        FeedCommentItem(
          username: '亏钱户',
          time: '11 小时',
          content: '你是 bookmaker 吗? 你整天只是在要花招，然后你就会下注 \$1。',
          likeCount: 2,
          replyToUser: '程小程',
          isNested: true,
          isAuthor: true,
          hasOriginal: true,
        ),
        // 查看更多按钮
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
  final String username;
  final String time;
  final String content;
  final int likeCount;
  final String? replyToUser;
  final bool isNested;
  final bool isAuthor;
  final bool hasTranslation;
  final bool hasOriginal;

  const FeedCommentItem({
    super.key,
    required this.username,
    required this.time,
    required this.content,
    required this.likeCount,
    this.replyToUser,
    this.isNested = false,
    this.isAuthor = false,
    this.hasTranslation = false,
    this.hasOriginal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isNested ? 48.0 : 0,
        top: isNested ? 8.0 : 12.0,
        bottom: isNested ? 0 : 12.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
          const SizedBox(width: 12),
          _buildLikeButton(),
        ],
      ),
    );
  }

  /// 用户头像
  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 20, color: Colors.grey),
    );
  }

  /// 评论内容区域
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfo(),
        const SizedBox(height: 4),
        if (replyToUser != null) _buildReplyMark(),
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
          username,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isAuthor) ...[
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
          time,
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
            text: '@$replyToUser',
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
      content,
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
        _buildAction('回复'),
        const SizedBox(width: 16),
        _buildAction('引用'),
        if (hasTranslation) ...[
          const SizedBox(width: 16),
          _buildAction('查看翻译'),
        ],
        if (hasOriginal) ...[
          const SizedBox(width: 16),
          _buildAction(
            '查看原文',
            color: Colors.orange.shade700,
          ),
        ],
      ],
    );
  }

  Widget _buildAction(String text, {Color? color}) {
    return TextButton(
      onPressed: () {
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
    return Column(
      children: [
        Icon(
          Icons.thumb_up_outlined,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 2),
        Text(
          likeCount.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
