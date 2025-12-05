import 'package:flutter/material.dart';

/// 合约列表头部
class ContractListHeader extends StatefulWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const ContractListHeader({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  State<ContractListHeader> createState() => _ContractListHeaderState();
}

class _ContractListHeaderState extends State<ContractListHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildSubTab('持有仓位', widget.selectedTab == '持有仓位'),
          const SizedBox(width: 24),
          _buildSubTab('资产', widget.selectedTab == '资产'),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSubTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onTabChanged(text),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.black87 : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 20,
              height: 2,
              color: Colors.amber,
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}
