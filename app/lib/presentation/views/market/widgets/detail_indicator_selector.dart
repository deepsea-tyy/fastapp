import 'package:flutter/material.dart';

/// 底部指标选择器
class DetailIndicatorSelector extends StatelessWidget {
  final List<String> indicators;
  final List<String> selectedIndicators;
  final ValueChanged<String> onIndicatorToggled;

  const DetailIndicatorSelector({
    super.key,
    required this.indicators,
    required this.selectedIndicators,
    required this.onIndicatorToggled,
  });

  @override
  Widget build(BuildContext context) {
    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: indicators.length,
        itemBuilder: (context, index) {
          final indicator = indicators[index];
          final isSelected = selectedIndicators.contains(indicator);
          
          return GestureDetector(
            onTap: () => onIndicatorToggled(indicator),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                indicator,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
