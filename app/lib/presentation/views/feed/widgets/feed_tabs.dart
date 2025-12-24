import 'package:flutter/material.dart';
import 'package:fastapp/core/theme/app_theme_extension.dart';

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
    final backgroundTheme = context.backgroundTheme;

    return Container(
      color: backgroundTheme.card,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
      child: Row(
        children: List.generate(
          _tabs.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 20.0 : 0),
            child: _buildTabItem(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index) {
    final isSelected = _selectedIndex == index;
    final hasNotification = _hasNotification[index];
    final textTheme = context.textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                  color: isSelected ? textTheme.primary : textTheme.secondary,
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
                    decoration: BoxDecoration(
                      color: primaryColor,
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
                      color: primaryColor,
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
