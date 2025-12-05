import 'package:flutter/material.dart';

/// 交易详情页面二级导航标签
class DetailTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const DetailTabBar({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = selectedTab == index;
          
          return Padding(
            padding: EdgeInsets.only(right: index < tabs.length - 1 ? 16.0 : 0),
            child: InkWell(
              onTap: () => onTabChanged(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 3),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
