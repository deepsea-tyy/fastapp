import 'package:flutter/material.dart';

/// 更多选项底部表单组件
class MoreOptionsBottomSheet extends StatefulWidget {
  const MoreOptionsBottomSheet({super.key});

  @override
  State<MoreOptionsBottomSheet> createState() => _MoreOptionsBottomSheetState();
}

class _MoreOptionsBottomSheetState extends State<MoreOptionsBottomSheet> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['精选功能', '数据', '学习', '公告'];

  final List<Map<String, dynamic>> _featuredFunctions = [
    {'icon': Icons.settings, 'label': '偏好设置'},
    {'icon': Icons.history, 'label': '历史'},
    {'icon': Icons.arrow_downward, 'label': '借款'},
    {'icon': Icons.arrow_upward, 'label': '还款'},
    {'icon': Icons.swap_horiz, 'label': '划转'},
    {'icon': Icons.calculate, 'label': '计算器'},
    {'icon': Icons.ac_unit, 'label': '冷静期'},
    {'icon': Icons.account_circle, 'label': '统一账户'},
    {'icon': Icons.percent, 'label': '费率'},
    {'icon': Icons.star, 'label': '自选'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 选项卡
          _buildTabBar(),
          const Divider(height: 1),
          // 内容区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == _selectedTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTabIndex == 0) {
      return _buildFeaturedFunctions();
    } else {
      return Center(
        child: Text(
          '${_tabs[_selectedTabIndex]} 功能开发中',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
  }

  Widget _buildFeaturedFunctions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.85,
        ),
        itemCount: _featuredFunctions.length,
        itemBuilder: (context, index) {
          final item = _featuredFunctions[index];
          final isStar = item['label'] == '自选';
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isStar ? Colors.amber.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: isStar ? Border.all(color: Colors.amber.shade200, width: 1) : null,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: isStar ? Colors.amber.shade700 : Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
