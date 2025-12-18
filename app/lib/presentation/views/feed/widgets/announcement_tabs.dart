import 'package:flutter/material.dart';

/// 公告子标签栏组件
///
/// 显示：全部、数字货币及交易对上新、币安最新动态
class AnnouncementTabs extends StatefulWidget {
  final Function(int)? onTabChanged;

  const AnnouncementTabs({
    super.key,
    this.onTabChanged,
  });

  @override
  State<AnnouncementTabs> createState() => _AnnouncementTabsState();
}

class _AnnouncementTabsState extends State<AnnouncementTabs> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    '全部',
    '数字货币及交易对上新',
    '币安最新动态',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      color: Colors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = _selectedIndex == index;

              return InkWell(
                onTap: () {
                  // 如果点击的是已选中的标签，则不触发任何操作
                  if (_selectedIndex == index) {
                    return;
                  }
                  setState(() => _selectedIndex = index);
                  widget.onTabChanged?.call(index);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                  margin: EdgeInsets.only(right: index < _tabs.length - 1 ? 8.0 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
