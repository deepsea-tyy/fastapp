import 'package:flutter/material.dart';

/// 时间周期选择器
class DetailIntervalSelector extends StatelessWidget {
  final List<String> intervals;
  final Map<String, String> intervalMap;
  final String selectedInterval;
  final ValueChanged<String> onIntervalChanged;
  final VoidCallback onDepthTap;
  final VoidCallback onSettingsTap;
  final bool isDepthSelected;

  const DetailIntervalSelector({
    super.key,
    required this.intervals,
    required this.intervalMap,
    required this.selectedInterval,
    required this.onIntervalChanged,
    required this.onDepthTap,
    required this.onSettingsTap,
    this.isDepthSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: intervals.map((interval) {
                  final isSelected = !isDepthSelected && selectedInterval == interval;
                  return GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        onIntervalChanged(interval);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        interval,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDepthTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '深度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isDepthSelected ? FontWeight.bold : FontWeight.normal,
                  color: isDepthSelected ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.tune, size: 20, color: Colors.black87),
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
