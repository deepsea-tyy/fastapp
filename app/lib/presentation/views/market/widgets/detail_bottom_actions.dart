import 'package:flutter/material.dart';

/// 底部固定操作按钮栏
class DetailBottomActions extends StatelessWidget {
  final VoidCallback? onMore;
  final VoidCallback? onAlert;
  final VoidCallback? onLeverage;
  final VoidCallback? onGrid;
  final VoidCallback? onBuy;
  final VoidCallback? onSell;

  const DetailBottomActions({
    super.key,
    this.onMore,
    this.onAlert,
    this.onLeverage,
    this.onGrid,
    this.onBuy,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧小按钮组
          Row(
            children: [
              _buildSmallButton(
                icon: Icons.more_horiz,
                label: '更多',
                onTap: onMore ?? () {},
              ),
              const SizedBox(width: 16),
              _buildSmallButton(
                icon: Icons.notifications_outlined,
                label: '预警',
                onTap: onAlert ?? () {},
              ),
              const SizedBox(width: 16),
              _buildSmallButton(
                icon: Icons.percent,
                label: '杠杆',
                onTap: onLeverage ?? () {},
              ),
              const SizedBox(width: 16),
              _buildSmallButton(
                icon: Icons.grid_view,
                label: '网格',
                onTap: onGrid ?? () {},
              ),
            ],
          ),
          // 右侧大按钮
          Row(
            children: [
              _buildLargeButton(
                label: '买入',
                color: Colors.green,
                onTap: onBuy ?? () {},
              ),
              const SizedBox(width: 12),
              _buildLargeButton(
                label: '卖出',
                color: Colors.red,
                onTap: onSell ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
