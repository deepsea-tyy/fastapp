import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/announcement_tabs.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/announcement_item.dart';

/// 公告列表组件
///
/// 包含子标签栏和公告列表
class AnnouncementList extends StatefulWidget {
  const AnnouncementList({super.key});

  @override
  State<AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  int _currentSubTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnnouncementTabs(
            onTabChanged: (index) {
              setState(() {
                _currentSubTab = index;
              });
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildAnnouncementList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnnouncementList() {
    final announcements = _getAnnouncements(_currentSubTab);

    return announcements.asMap().entries.map((entry) {
      final index = entry.key;
      final announcement = entry.value;
      final isLast = index == announcements.length - 1;

      return Column(
        children: [
          AnnouncementItem(
            title: announcement['title']!,
            timestamp: announcement['timestamp']!,
          ),
          if (!isLast) const Divider(height: 1, indent: 52),
        ],
      );
    }).toList();
  }

  List<Map<String, String>> _getAnnouncements(int subTab) {
    final allAnnouncements = [
      {
        'title': 'LAB 交易竞赛:交易LAB (LAB) ,分享50万美元等值奖励',
        'timestamp': '11月28日 22:00:15',
        'category': 'all',
      },
      {
        'title': '交易APRO (AT) :即可瓜分15,000,000 AT 奖池!',
        'timestamp': '11月28日 19:00:15',
        'category': 'new',
      },
      {
        'title': '币安合约聪明钱将采用新ROI计算方式',
        'timestamp': '11月28日 18:00:14',
        'category': 'binance',
      },
      {
        'title': '币安更新法币交易做市商计划 (2025-11-28)',
        'timestamp': '11月28日 16:00:08',
        'category': 'binance',
      },
    ];

    if (subTab == 0) {
      return allAnnouncements;
    } else if (subTab == 1) {
      return allAnnouncements.where((a) => a['category'] == 'new').toList();
    } else {
      return allAnnouncements.where((a) => a['category'] == 'binance').toList();
    }
  }
}
