import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_utils.dart';
import 'package:flutter/material.dart';

/// 市场概览组件
class DetailMarketOverview extends StatelessWidget {
  final TickerData ticker;
  final bool isPositive;
  final double cnyPrice;

  const DetailMarketOverview({
    super.key,
    required this.ticker,
    required this.isPositive,
    required this.cnyPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 左侧：最新价格
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '最新价格',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DetailUtils.formatPrice(ticker.lastPrice),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${DetailUtils.formatPrice(cnyPrice)} ${isPositive ? '+' : ''}${ticker.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: isPositive ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '标记价格 ${DetailUtils.formatPrice(ticker.lastPrice + 3)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // 右侧：24h数据
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildDataRow('24h最高价', DetailUtils.formatPrice(ticker.highPrice)),
                const SizedBox(height: 8),
                _buildDataRow('24h最低价', DetailUtils.formatPrice(ticker.lowPrice)),
                const SizedBox(height: 8),
                _buildDataRow('24h成交量(BTC)', DetailUtils.formatVolume(ticker.volume)),
                const SizedBox(height: 8),
                _buildDataRow('24h成交额(USDT)', '${DetailUtils.formatVolume(ticker.amount)}亿'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
