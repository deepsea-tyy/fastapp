import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_tabs.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_item.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/sources_bar.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/announcement_list.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/news_list.dart';

/// 信息流区域组件
///
/// 包含顶部标签栏和信息流帖子列表
class FeedSection extends StatefulWidget {
  const FeedSection({super.key});

  @override
  State<FeedSection> createState() => _FeedSectionState();
}

class _FeedSectionState extends State<FeedSection> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FeedTabs(
            initialIndex: _currentTab,
            onTabChanged: (index) {
              setState(() {
                _currentTab = index;
              });
            },
          ),
          if (_currentTab == 1) ...[
            const SourcesBar(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildFeedContent(),
            ),
          ] else if (_currentTab == 2) ...[
            const AnnouncementList(),
          ] else if (_currentTab == 3) ...[
            const NewsList(),
          ] else ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildFeedContent(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildFeedContent() {
    if (_currentTab == 1) {
      return [
        FeedItem(
          username: 'Binance News',
          time: '12分钟',
          title: 'BNB 突破 880 USDT, 24 小时涨幅0.48%',
          content: '据币安行情数据显示,BNB 突破 880 USDT,现报价 880.590027 USDT,24 小时涨幅0.48%。',
          isVerified: true,
          commentCount: 0,
          likeCount: 0,
          repostCount: 0,
          shareCount: 0,
          menuIcon: Icons.more_horiz,
        ),
        FeedItem(
          username: 'Binance News',
          time: '12分钟',
          title: '比特币链上交易者亏损幅度达20%',
          content: '据 BlockBeats 报道, 11 月 30 日, 加密分析师 @ali_charts 发文表示, 比特币 (BTC) 通常在链上交易者亏损幅度超 ...',
          isVerified: true,
          commentCount: 0,
          likeCount: 0,
          repostCount: 0,
          shareCount: 0,
          menuIcon: Icons.more_horiz,
        ),
      ];
    } else {
      return [
        FeedItem(
          username: '币123',
          time: '16小时',
          content: '剩下34u,一把搞到1200u,',
          originalLink: '查看原文',
          media: [
            _buildTradingTableImage(),
            _buildTradingDetailImage(),
          ],
          commentCount: 46,
          likeCount: 92,
          repostCount: 9,
          shareCount: 4,
          menuIcon: Icons.close,
        ),
        FeedItem(
          username: '困了就睡',
          time: '11月27日',
          content: '名字好听,买一些',
          commentCount: 61,
          likeCount: 120,
          repostCount: 17,
          shareCount: 1,
          menuIcon: Icons.close,
        ),
      ];
    }
  }

  Widget _buildTradingTableImage() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          '交易表格截图',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTradingDetailImage() {
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text(
              '交易详情截图',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '+1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
