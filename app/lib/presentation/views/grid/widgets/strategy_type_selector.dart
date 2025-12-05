import 'package:flutter/material.dart';

/// 交易机器人类型选择器
class StrategyTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const StrategyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static Future<String?> show(BuildContext context, String currentType) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StrategyTypeSelector(
        selectedType: currentType,
        onTypeSelected: (type) {
          Navigator.pop(context, type);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '交易机器人',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // 机器人类型列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildTypeItem(
                  context,
                  icon: Icons.show_chart,
                  title: '现货网格',
                  description: '低买高卖。全天候可用性。',
                  type: '现货网格',
                ),
                const SizedBox(height: 12),
                _buildTypeItem(
                  context,
                  icon: Icons.description,
                  title: '合约网格',
                  description: '7x24小时自动多空操作',
                  type: '合约网格',
                ),
                const SizedBox(height: 12),
                _buildTypeItem(
                  context,
                  icon: Icons.currency_exchange,
                  title: '套利机器人',
                  description: '以风险中立策略轻松套利资金费率',
                  type: '套利机器人',
                ),
                const SizedBox(height: 12),
                _buildTypeItem(
                  context,
                  icon: Icons.pie_chart,
                  title: '智能持仓',
                  description: '多币投资，智能持有',
                  type: '智能持仓',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String type,
  }) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black87 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // 文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
