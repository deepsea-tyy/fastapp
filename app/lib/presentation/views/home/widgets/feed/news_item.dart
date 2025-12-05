import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_detail.dart';

/// 新闻项组件
///
/// 显示时间戳和新闻标题，带时间线样式
class NewsItem extends StatelessWidget {
  final String time;
  final String title;
  final VoidCallback? onTap;
  final bool isLast;

  const NewsItem({
    super.key,
    required this.time,
    required this.title,
    this.onTap,
    this.isLast = false,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          username: '新闻',
          time: time,
          content: title,
          title: title,
          commentCount: 0,
          likeCount: 0,
          repostCount: 0,
          shareCount: 0,
          viewCount: 0,
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
                      color: Colors.grey.shade400,
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
                        color: Colors.grey.shade300,
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.shade300,
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
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
