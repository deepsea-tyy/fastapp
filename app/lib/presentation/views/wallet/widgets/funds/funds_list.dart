import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// 资金列表
class FundsList extends StatelessWidget {
  const FundsList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'currency': 'USDT',
        'currencyName': 'TetherUS',
        'iconColor': Colors.green,
        'iconText': 'T',
        'balance': 0.00,
        'available': 0.00,
        'frozen': 0.00,
      },
      {
        'currency': 'BTC',
        'currencyName': 'Bitcoin',
        'iconColor': Colors.orange,
        'iconText': 'B',
        'balance': 0.00,
        'available': 0.00,
        'frozen': 0.00,
      },
      {
        'currency': 'BNB',
        'currencyName': 'BNB',
        'iconColor': Colors.amber,
        'iconText': 'B',
        'balance': 0.00,
        'available': 0.00,
        'frozen': 0.00,
      },
    ];

    if (items.isEmpty) {
      return const EmptyState(text: '暂无资产');
    }

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i = 0; i < items.length; i++)
          _buildAssetItem(
            currency: items[i]['currency'] as String,
            currencyName: items[i]['currencyName'] as String,
            iconColor: items[i]['iconColor'] as Color,
            iconText: items[i]['iconText'] as String,
            balance: items[i]['balance'] as double,
            available: items[i]['available'] as double,
            frozen: items[i]['frozen'] as double,
            isLast: i == items.length - 1,
          ),
      ],
    );
  }

  Widget _buildAssetItem({
    required String currency,
    required String currencyName,
    required Color iconColor,
    required String iconText,
    required double balance,
    required double available,
    required double frozen,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      balance.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      Text(
                        '可用余额',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        available.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '冻结',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        frozen.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
