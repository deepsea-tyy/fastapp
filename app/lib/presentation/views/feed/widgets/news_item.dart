import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_detail.dart';
import 'package:fastapp/domain/entity/user/user_profile.dart';
import 'package:fastapp/core/theme/app_theme_extension.dart';

/// 新闻项组件
///
/// 显示时间戳和新闻标题，带时间线样式
class NewsItem extends StatelessWidget {
  final String time;
  final String? title;
  final UserProfile? profile;
  final VoidCallback? onTap;
  final bool isLast;
  final int id; // 文章ID
  final int type; // 文章类型：4=新闻

  const NewsItem({
    super.key,
    required this.time,
    this.title,
    this.profile,
    this.onTap,
    this.isLast = false,
    required this.id,
    this.type = 4, // 默认为新闻类型
  });

  void _navigateToDetail(BuildContext context) {
    final userName = profile?.displayNickname ?? '新闻';
    final userAvatar = profile?.displayAvatar ?? '';
    final userId = profile?.userId ?? 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: id,
          userId: userId,
          username: userName,
          time: time,
          content: title ?? '',
          title: title ?? '',
          commentCount: 0,
          likeCount: 0,
          repostCount: 0,
          shareCount: 0,
          viewCount: 0,
          avatarAsset: userAvatar,
          type: type, // 传递类型，用于判断调用哪个接口
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return InkWell(
      onTap: onTap ?? () => _navigateToDetail(context),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: textTheme.hint,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    transform: Matrix4.rotationZ(0.785398), // 45度旋转，形成菱形
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 1,
                      height: 50,
                      decoration: BoxDecoration(
                        color: textTheme.hint.withValues(alpha: 0.5),
                        border: Border(
                          left: BorderSide(
                            color: textTheme.hint.withValues(alpha: 0.5),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: textTheme.hint,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textTheme.primary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
