import 'package:flutter/material.dart';

/// 资产指标组件
class AssetMetrics extends StatelessWidget {
  final String dailyPnL;
  final String pnlPercent;
  final String balance;
  final String balanceSubtitle;
  final String costPrice;
  final String latestPrice;

  const AssetMetrics({
    super.key,
    required this.dailyPnL,
    required this.pnlPercent,
    required this.balance,
    required this.balanceSubtitle,
    required this.costPrice,
    required this.latestPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一行：单日盈亏 | 盈亏%
        Row(
          children: [
            Expanded(
              child: _MetricItem(label: '单日盈亏', value: dailyPnL, valueColor: Colors.red),
            ),
            Expanded(
              child: _MetricItem(label: '盈亏%', value: pnlPercent, valueColor: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 第二行：资产余额 | 成本价 | 最新价格(USDC)
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                label: '资产余额',
                value: balance,
                valueColor: Colors.black87,
                subtitle: balanceSubtitle,
              ),
            ),
            Expanded(
              child: _MetricItem(label: '成本价', value: costPrice, valueColor: Colors.black87),
            ),
            Expanded(
              child: _MetricItem(label: '最新价格(USDC)', value: latestPrice, valueColor: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? subtitle;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }
}
