import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/user/user_profile.dart';
import 'package:fastapp/presentation/views/feed/feed_profile.dart';
import 'package:fastapp/presentation/views/common/image_preview_page.dart';
import 'package:fastapp/presentation/views/common/safe_network_image.dart';
import 'package:fastapp/core/theme/feed_theme_extension.dart';
import 'feed_detail.dart';
import 'feed_action_bar.dart';
import 'feed_comment_input_sheet.dart';
import 'feed_menu_sheet.dart';
import 'user_avatar.dart';

class FeedItem extends StatefulWidget {
  final int postId;
  final UserProfile profile;
  final String time;
  final String content;
  final String? title;
  final String? originalLink;
  final List<String>? mediaUrls;
  final int commentCount;
  final int likeCount;
  final int repostCount;
  final int shareCount;
  final bool showMenu;
  final IconData? menuIcon;
  final bool isLiked;
  final int type; // 帖子类型：1帖子 2文章
  final VoidCallback? onRemove; // 删除回调
  final Function(bool isLiked, int likeCount)? onLikeChanged; // 点赞状态变化回调

  const FeedItem({
    super.key,
    required this.postId,
    required this.profile,
    required this.time,
    required this.content,
    this.title,
    this.originalLink,
    this.mediaUrls,
    this.commentCount = 0,
    this.likeCount = 0,
    this.repostCount = 0,
    this.shareCount = 0,
    this.showMenu = true,
    this.menuIcon,
    this.isLiked = false,
    this.type = 1, // 默认为帖子
    this.onRemove,
    this.onLikeChanged,
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
  void didUpdateWidget(FeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部传入的点赞状态或点赞数发生变化时，同步更新内部状态
    // 注意：如果正在执行点赞操作，不要更新状态，避免冲突
    if (!_isLiking) {
      if (oldWidget.isLiked != widget.isLiked) {
        _isLiked = widget.isLiked;
      }
      if (oldWidget.likeCount != widget.likeCount) {
        _likeCount = widget.likeCount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedTheme = context.feedTheme;
    return Container(
      color: feedTheme.cardBackground,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildContent(context),
          if (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMedia(context),
          ],
          const SizedBox(height: 12),
          _buildEngagementBar(),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, {bool scrollToComments = false}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: widget.postId,
          userId: widget.profile.userId ?? 0,
          username: widget.profile.displayNickname,
          time: widget.time,
          content: widget.content,
          title: widget.title,
          originalLink: widget.originalLink,
          mediaUrls: widget.mediaUrls,
          commentCount: widget.commentCount,
          likeCount: _likeCount,
          repostCount: widget.repostCount,
          shareCount: widget.shareCount,
          avatarAsset: widget.profile.displayAvatar,
          isVerified: false, // TODO: 需要在 UserProfile 中添加认证标识
          viewCount: 15400,
          type: widget.type,
          scrollToComments: scrollToComments,
          isLiked: _isLiked,
        ),
      ),
    );

    // 如果详情页返回 true，表示用户点击了不感兴趣，需要从列表移除
    if (result == true && widget.onRemove != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRemove?.call();
      });
    }
  }

  Widget _buildHeader(BuildContext context) {
    final feedTheme = context.feedTheme;
    return Row(
      children: [
        UserAvatar(
          avatarAsset: widget.profile.displayAvatar,
          isVerified: false, // TODO: 需要在 UserProfile 中添加认证标识
          onTap: () => _navigateToUserProfile(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToUserProfile(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.displayNickname,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: feedTheme.userNameText,
                  ),
                ),
                Text(
                  widget.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: feedTheme.timeText,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.showMenu)
          IconButton(
            icon: Icon(
              widget.menuIcon ?? Icons.close,
              size: 20,
              color: feedTheme.menuIcon,
            ),
            onPressed: () => _showMenu(context),
          ),
      ],
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: widget.profile.userId ?? 0),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final feedTheme = context.feedTheme;
    final hasTitle = widget.title != null && widget.title!.isNotEmpty;
    final fontSize = hasTitle ? 14.0 : 15.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _navigateToDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            SizedBox(
              width: double.infinity,
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: feedTheme.titleText,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: fontSize * 1.5 * 5),
            child: Html(
              data: widget.content,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(fontSize),
                  color: feedTheme.contentText,
                  lineHeight: const LineHeight(1.5),
                  maxLines: 5,
                  textOverflow: TextOverflow.ellipsis,
                ),
              },
            ),
          ),
          if (widget.originalLink != null && widget.originalLink!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.originalLink!,
              style: TextStyle(
                fontSize: 14,
                color: feedTheme.linkText,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    final mediaUrls = widget.mediaUrls!;

    // 整个图片区域可点击跳转详情
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        child: _buildMediaContent(context, mediaUrls),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context, List<String> mediaUrls) {
    if (mediaUrls.length == 1) {
      // 单张图片：60x60 正方形，左对齐
      return Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => _showImagePreview(context, mediaUrls, 0),
          child: SizedBox(
            width: 60,
            height: 60,
            child: SafeNetworkImage(
              imageUrl: mediaUrls.first,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // 多张图片：每张60x60正方形，靠左排列，最多显示3张
    final displayCount = mediaUrls.length > 3 ? 3 : mediaUrls.length;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          displayCount,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < displayCount - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => _showImagePreview(context, mediaUrls, index),
              child: SafeNetworkImage(
                imageUrl: mediaUrls[index],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
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

  Widget _buildEngagementBar() {
    return FeedActionBar(
      commentCount: widget.commentCount,
      likeCount: _likeCount,
      repostCount: widget.repostCount,
      shareCount: widget.shareCount,
      isLiked: _isLiked,
      onCommentTap: () => _navigateToDetail(context, scrollToComments: true),
      onLikeTap: _handleLike,
      onRepostTap: () => _showRepostSheet(context),
      onShareTap: () {},
    );
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);

    try {
      final result = await _feedRepository.toggleLike(
        targetType: widget.type, // 使用 widget.type：1帖子 2文章
        targetId: widget.postId,
      );
      if (mounted) {
        setState(() {
          _isLiked = result.isLiked;
          _likeCount = result.likeCount;
          _isLiking = false;
        });

        // 触发点赞状态变化回调
        widget.onLikeChanged?.call(result.isLiked, result.likeCount);
      }
    } catch (e) {
      if (mounted) setState(() => _isLiking = false);
      debugPrint('点赞失败: $e');
    }
  }

  void _showRepostSheet(BuildContext context) {
    FeedCommentInputSheet.show(
      context,
      placeholder: '评论并转发...',
      showRepostOption: true,
      defaultRepostChecked: true,
      quotedContent: QuotedContent(
        username: widget.profile.displayNickname,
        avatar: widget.profile.displayAvatar,
        content: widget.content,
        firstImageUrl: widget.mediaUrls?.isNotEmpty == true ? widget.mediaUrls!.first : null,
      ),
      onSendWithRepost: (content, images, isRepost) async {
        if (isRepost) {
          await _createRepost(content: content, images: images);
        } else {
          await _createComment(content: content, images: images);
        }
      },
    );
  }

  /// 创建转发帖子
  Future<void> _createRepost({
    required String content,
    required List<String> images,
  }) async {
    try {
      await _feedRepository.createPost(
        type: widget.type,
        contentType: images.isNotEmpty ? 2 : 1,
        content: content,
        images: images.isNotEmpty ? images : null,
        quotedType: widget.type,
        quotedId: widget.postId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('转发成功')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('转发失败: $e')),
        );
      }
      debugPrint('转发失败: $e');
    }
  }

  /// 创建评论（不转发）
  Future<void> _createComment({
    required String content,
    required List<String> images,
  }) async {
    try {
      await _feedRepository.createComment(
        targetType: widget.type,
        targetId: widget.postId,
        content: content,
        images: images.isNotEmpty ? images : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('评论失败: $e')),
        );
      }
      debugPrint('评论失败: $e');
    }
  }

  void _showMenu(BuildContext context) async {
    final result = await FeedMenuSheet.show(
      context,
      username: widget.profile.displayNickname,
      topic: null,
      targetId: widget.postId,
      targetType: widget.type,
      userId: widget.profile.userId,
    );

    // 处理不感兴趣操作：从列表中移除
    if (result != null && widget.onRemove != null) {
      final shouldRemove = [
        'not_interested_post',
        'not_interested_user',
        'not_interested_topic',
        'low_quality_1',
        'low_quality_2',
      ].contains(result);

      if (shouldRemove) {
        // 延迟一帧执行，避免在 build 期间调用 setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onRemove?.call();
        });
      }
    }
  }
}
