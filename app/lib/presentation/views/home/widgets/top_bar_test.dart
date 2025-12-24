import 'package:flutter/material.dart';
import 'package:fastapp/utils/icon_mapper.dart';
import 'package:fastapp/data/network/models/search_keyword.dart';

/// TopBar 图标测试页面
/// 用于验证图标映射和显示逻辑
class TopBarTest extends StatelessWidget {
  const TopBarTest({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟从 API 获取的热门关键词数据
    final testKeyword = SearchKeyword(
      keyword: 'RMB',
      hitCount: 999999,
      icon: 'material-symbols:local-fire-department',
      color: '#966e6e',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('TopBar 图标测试'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('1. 测试数据', [
              Text('关键词: ${testKeyword.keyword}'),
              Text('图标名称: ${testKeyword.icon}'),
              Text('颜色: ${testKeyword.color}'),
              Text('点击次数: ${testKeyword.hitCount}'),
            ]),
            const SizedBox(height: 24),
            _buildSection('2. 图标映射测试', [
              _buildIconTest(
                'material-symbols:local-fire-department',
                '火焰图标',
              ),
              _buildIconTest(
                'material-symbols:search',
                '搜索图标',
              ),
              _buildIconTest(
                'material-symbols:star',
                '星标图标',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('3. 颜色解析测试', [
              _buildColorTest('#966e6e', '深红色'),
              _buildColorTest('#FF6B35', '橙红色'),
              _buildColorTest('#4CAF50', '绿色'),
            ]),
            const SizedBox(height: 24),
            _buildSection('4. 搜索框模拟', [
              _buildSearchBar(testKeyword),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildIconTest(String iconName, String label) {
    final iconData = IconMapper.getIcon(iconName);
    final iconColor = IconMapper.getColor(iconName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(iconData, size: 24, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  iconName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTest(String colorString, String label) {
    final color = IconMapper.parseColor(colorString);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  colorString,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SearchKeyword keyword) {
    final iconData = IconMapper.getIcon(keyword.icon);
    final iconColor = keyword.color != null
        ? IconMapper.parseColor(keyword.color!)
        : IconMapper.getColor(keyword.icon);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            iconData,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Text(
            keyword.keyword,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.search,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
