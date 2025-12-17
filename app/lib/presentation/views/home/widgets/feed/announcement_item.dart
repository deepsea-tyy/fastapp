import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_detail.dart';
import 'package:fastapp/domain/entity/user/user_profile.dart';

/// 公告项组件
///
/// 显示公告的标题和时间戳
class AnnouncementItem extends StatelessWidget {
  final String? title;
  final String timestamp;
  final UserProfile? profile;
  final VoidCallback? onTap;

  const AnnouncementItem({
    super.key,
    this.title,
    required this.timestamp,
    this.profile,
    this.onTap,
  });

  void _navigateToDetail(BuildContext context) {
    final userName = profile?.displayNickname ?? '系统公告';
    final userAvatar = profile?.displayAvatar ?? '';
    final userId = profile?.userId ?? 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: 0, // 公告的postId为0
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _navigateToDetail(context),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              color: Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timestamp,
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
      ),
    );
  }
}
