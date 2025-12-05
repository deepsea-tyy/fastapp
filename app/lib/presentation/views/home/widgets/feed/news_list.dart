import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/news_item.dart';

/// 新闻列表组件
///
/// 显示按日期分组的新闻列表，带时间线样式
class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader('2025年11月30日'),
          _buildNewsList(),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(2),
            ),
            transform: Matrix4.rotationZ(0.785398), // 45度旋转，形成菱形
          ),
          const SizedBox(width: 12),
          Text(
            date,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    final newsItems = [
      {'time': '20:23', 'title': 'BNB 突破 880 USDT, 24 小时涨幅0.48%'},
      {'time': '20:23', 'title': '比特币链上交易者亏损幅度达 20%'},
      {'time': '20:03', 'title': 'CertiK 监测显示11月损失约1.27亿美元,其中4500万美元已追回'},
      {'time': '19:43', 'title': '高盛分析师预测美联储12月会议将降息'},
      {'time': '19:35', 'title': 'Strategy 可能在 mNAV 跌破1时出售比特币以保护股东收益'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: newsItems.asMap().entries.map((entry) {
        final index = entry.key;
        final news = entry.value;
        final isLast = index == newsItems.length - 1;

        return NewsItem(
          time: news['time']!,
          title: news['title']!,
          isLast: isLast,
        );
      }).toList(),
    );
  }
}
