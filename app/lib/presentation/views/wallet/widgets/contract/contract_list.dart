import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// 合约列表
class ContractList extends StatelessWidget {
  final String selectedTab;

  const ContractList({
    super.key,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTab == '资产') {
      return _buildAssetList();
    } else {
      return _buildEmptyPositions();
    }
  }

  Widget _buildAssetList() {
    // 示例数据
    final assets = [
      {
        'currency': 'USDT',
        'walletBalance': 0.78221273,
        'unrealizedPnL': 0.00000000,
        'marginBalance': 0.78221273,
        'transferable': 0.78221273,
      },
    ];

    if (assets.isEmpty) {
      return const EmptyState(text: '暂无资产', height: 300);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return _buildAssetItem(
          currency: asset['currency'] as String,
          walletBalance: asset['walletBalance'] as double,
          unrealizedPnL: asset['unrealizedPnL'] as double,
          marginBalance: asset['marginBalance'] as double,
          transferable: asset['transferable'] as double,
        );
      },
    );
  }

  Widget _buildAssetItem({
    required String currency,
    required double walletBalance,
    required double unrealizedPnL,
    required double marginBalance,
    required double transferable,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCurrencyIcon(currency),
              const SizedBox(width: 12),
              Text(
                currency,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem('钱包余额', walletBalance),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceItem('未实现盈亏', unrealizedPnL),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem('保证金余额', marginBalance),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceItem('可转出', transferable),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(8),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyIcon(String currency) {
    Color iconColor;
    String iconText;

    switch (currency) {
      case 'USDT':
        iconColor = Colors.teal;
        iconText = 'T';
        break;
      default:
        iconColor = Colors.grey;
        iconText = currency.substring(0, 1);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          iconText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPositions() {
    return const EmptyState(text: '暂无仓位', height: 300);
  }
}
