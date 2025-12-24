import 'package:flutter/material.dart';
import '../common/search_input_widget.dart';

/// 搜索页面
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> _historyRecords = ['TON/USDT'];

  final List<Map<String, String?>> _hotSearchItems = [
    {'text': '美联储降息预期升至87%', 'badge': 'HOT'},
    {'text': '贝莱德大额增持BTC与ETH', 'badge': 'HOT'},
    {'text': '比特币止跌反弹超9万美元', 'badge': null},
    {'text': '白银价格创历史新高', 'badge': null},
    {'text': '山寨币ETF集中上市', 'badge': null},
    {'text': 'Tom Lee预期ETH达7000美元', 'badge': 'NEW'},
    {'text': '爆涨币种MBL行情解析', 'badge': null},
  ];

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  Future<List<SearchResultItem>> _handleSearch(String keyword) async {
    // TODO: 实现实际的搜索逻辑
    await Future.delayed(const Duration(milliseconds: 500));

    // 返回模拟数据
    return [
      SearchResultItem(
        id: '1',
        title: 'TON/USDT',
        subtitle: 'The Open Network',
      ),
      SearchResultItem(
        id: '2',
        title: 'BTC/USDT',
        subtitle: 'Bitcoin',
      ),
    ];
  }

  void _handleItemTap(SearchResultItem item) {
    // TODO: 处理搜索结果项点击
    setState(() {
      if (!_historyRecords.contains(item.title)) {
        _historyRecords.insert(0, item.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SearchInputWidget(
              hintText: 'ZEC',
              prefixIcon: Icons.search,
              iconColor: Colors.grey.shade600,
              backgroundColor: Colors.grey[100],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              autofocus: true,
              showBackButton: true,
              onBack: () => Navigator.of(context).pop(),
              onSearch: _handleSearch,
              onItemTap: _handleItemTap,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHistorySection(),
                    _buildUpcomingSection(),
                    _buildHotSearchSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_historyRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('历史记录', style: _sectionTitleStyle),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => setState(() => _historyRecords.clear()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _historyRecords.map((record) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(record, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('即将开启', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASTERIDR 即将上线',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '结束日期 2025-11-29',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('热搜排行榜', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          ..._hotSearchItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: index < 3 ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['text']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (item['badge'] != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: item['badge'] == 'HOT' ? Colors.amber : Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['badge']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
