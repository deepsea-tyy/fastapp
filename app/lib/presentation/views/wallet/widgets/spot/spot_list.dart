import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// 现货列表
class SpotList extends StatelessWidget {
  const SpotList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'currency': 'TON',
        'currencyName': 'Toncoin',
        'iconColor': Colors.blue,
        'iconText': 'T',
        'balance': 0.00079,
        'value': 0.00123793,
        'averageCost': 3.65,
        'todayPnL': 0.00,
        'todayPnLPercent': -0.76,
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
            value: items[i]['value'] as double,
            averageCost: items[i]['averageCost'] as double,
            todayPnL: items[i]['todayPnL'] as double,
            todayPnLPercent: items[i]['todayPnLPercent'] as double,
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
    required double value,
    required double averageCost,
    required double todayPnL,
    required double todayPnLPercent,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          balance.toStringAsFixed(5),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$value USDT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '平均成本',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$averageCost USDT',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '今日盈亏',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${todayPnL.toStringAsFixed(2)} USDT(${todayPnLPercent >= 0 ? '+' : ''}${todayPnLPercent.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: todayPnL >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
