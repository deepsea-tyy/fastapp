import 'package:flutter/material.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/domain/entity/feed/feed_article.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_detail.dart';
import 'package:fastapp/di/service_locator.dart';

/// 公告列表页面
class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final FeedRepository _feedRepository = getIt<FeedRepository>();
  List<FeedArticle> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final list = await _feedRepository.getAnnouncementList(page: 1);

      if (mounted) {
        setState(() {
          _announcements = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('加载公告失败: $e');
    }
  }

  String _getDisplayContent(FeedArticle article) {
    if (article.title.isNotEmpty) return article.title;
    if (article.subtitle?.isNotEmpty == true) return article.subtitle!;
    if (article.brief?.isNotEmpty == true) return article.brief!;
    if (article.content?.isNotEmpty == true) return article.content!;
    return '暂无内容';
  }

  void _navigateToDetail(FeedArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: article.id,
          userId: article.profile?.userId ?? 0,
          username: article.profile?.nickname ?? article.author ?? '',
          time: article.getFormattedTime(),
          content: article.content ?? '',
          title: article.title,
          mediaUrls: article.cover,
          commentCount: article.commentCount,
          likeCount: article.likeCount,
          repostCount: 0,
          shareCount: article.shareCount,
          avatarAsset: article.profile?.avatar ?? '',
          isVerified: false,
          viewCount: article.viewCount,
          type: 3,
          isLiked: article.isLiked ?? false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const Text(
                    '公告',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // 公告列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _announcements.isEmpty
                      ? const Center(child: Text('暂无公告'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            final announcement = _announcements[index];
                            return GestureDetector(
                              onTap: () => _navigateToDetail(announcement),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getDisplayContent(announcement),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        announcement.getFormattedTime(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
