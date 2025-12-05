import 'package:flutter/material.dart';
import 'swap/instant_swap_view.dart';
import 'swap/recurring_investment_view.dart';
import 'swap/limit_order_view.dart';

/// 交易主页面 - 包含闪兑、定投、限价三个独立页面
class SwapTrade extends StatefulWidget {
  const SwapTrade({super.key});

  @override
  State<SwapTrade> createState() => _SwapTradeState();
}

class _SwapTradeState extends State<SwapTrade> {
  int _selectedTab = 0; // 0: 闪兑, 1: 定投, 2: 限价

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopTabs(),
        Expanded(
          child: _buildCurrentView(),
        ),
      ],
    );
  }

  Widget _buildTopTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTab('闪兑', 0),
          const SizedBox(width: 24),
          _buildTab('定投', 1),
          const SizedBox(width: 24),
          _buildTab('限价', 2),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.grey.shade700, size: 24),
            onPressed: () {
              // TODO: 显示图表
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.access_time, color: Colors.grey.shade700, size: 24),
            onPressed: () {
              // TODO: 显示历史记录
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black87 : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedTab) {
      case 0:
        return const InstantSwapView();
      case 1:
        return const RecurringInvestmentView();
      case 2:
        return const LimitOrderView();
      default:
        return const InstantSwapView();
    }
  }
}
