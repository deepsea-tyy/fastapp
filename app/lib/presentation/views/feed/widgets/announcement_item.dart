import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_detail.dart';
import 'package:fastapp/domain/entity/user/user_profile.dart';
import 'package:fastapp/core/theme/app_theme_extension.dart';

/// 公告项组件
///
/// 显示公告的标题和时间戳
class AnnouncementItem extends StatelessWidget {
  final String? title;
  final String timestamp;
  final UserProfile? profile;
  final VoidCallback? onTap;
  final int id; // 文章ID
  final int type; // 文章类型：3=公告

  const AnnouncementItem({
    super.key,
    this.title,
    required this.timestamp,
    this.profile,
    this.onTap,
    required this.id,
    this.type = 3, // 默认为公告类型
  });

  void _navigateToDetail(BuildContext context) {
    final userName = profile?.displayNickname ?? '系统公告';
    final userAvatar = profile?.displayAvatar ?? '';
    final userId = profile?.userId ?? 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: id,
          userId: userId,
          username: userName,
          time: timestamp,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              color: textTheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textTheme.primary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 12,
                      color: textTheme.hint,
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
