import 'package:flutter/material.dart';

/// 信息流顶部标签栏组件
///
/// 显示：发现、关注、公告、新闻
/// 支持标签切换和选中状态指示
class FeedTabs extends StatefulWidget {
  final Function(int)? onTabChanged;
  final int initialIndex;

  const FeedTabs({
    super.key,
    this.onTabChanged,
    this.initialIndex = 0,
  });

  @override
  State<FeedTabs> createState() => _FeedTabsState();
}

class _FeedTabsState extends State<FeedTabs> {
  late int _selectedIndex;

  final List<String> _tabs = ['发现', '关注', '公告', '新闻'];
  final List<bool> _hasNotification = [false, true, false, false];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
      child: Row(
        children: List.generate(
          _tabs.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 20.0 : 0),
            child: _buildTabItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final isSelected = _selectedIndex == index;
    final hasNotification = _hasNotification[index];

    return InkWell(
      onTap: () {
        // 如果点击的是已选中的标签，则不触发任何操作
        if (_selectedIndex == index) {
          return;
        }
        setState(() => _selectedIndex = index);
        widget.onTabChanged?.call(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.black54,
                  height: 1.2,
                ),
              ),
              if (hasNotification && !isSelected)
                Positioned(
                  top: 0,
                  right: -8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 28,
            height: 3,
            child: isSelected
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
