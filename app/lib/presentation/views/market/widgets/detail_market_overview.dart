import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 市场概览组件
/// 优化：最新价格从 K 线数据中获取，避免与 ticker 数据冗余
/// 24h统计数据（最高、最低、成交量）仍使用 ticker 数据
class DetailMarketOverview extends StatelessWidget {
  final TickerData ticker;
  final bool isPositive;
  final double cnyPrice;
  final KlineStore? klineStore; // 可选，如果提供则从 K 线数据获取最新价格

  const DetailMarketOverview({
    super.key,
    required this.ticker,
    required this.isPositive,
    required this.cnyPrice,
    this.klineStore,
  });

  /// 从 K 线数据获取最新价格，如果没有则使用 ticker 数据
  double _getLatestPrice() {
    if (klineStore != null && klineStore!.klineData.isNotEmpty) {
      // 从 K 线数据中获取最新价格（最后一条 K 线的收盘价）
      final latestKline = klineStore!.klineData.last;
      return latestKline.close;
    }
    // 降级到 ticker 数据
    return ticker.lastPrice;
  }

  @override
  Widget build(BuildContext context) {
    // 如果提供了 klineStore，使用 Observer 监听 K 线数据变化
    final priceWidget = klineStore != null
        ? Observer(
            builder: (_) {
              final latestPrice = _getLatestPrice();
              final latestCnyPrice = latestPrice * (cnyPrice / ticker.lastPrice);
              // 计算涨跌幅（基于最新价格和开盘价）
              final changePercent = ticker.openPrice > 0
                  ? ((latestPrice - ticker.openPrice) / ticker.openPrice) * 100
                  : ticker.changePercent;
              final isPricePositive = changePercent >= 0;

              return _buildPriceSection(latestPrice, latestCnyPrice, changePercent, isPricePositive);
            },
          )
        : _buildPriceSection(ticker.lastPrice, cnyPrice, ticker.changePercent, isPositive);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 左侧：最新价格
          Expanded(
            child: priceWidget,
          ),
          // 右侧：24h数据（这些数据只能从 ticker 获取，因为 K 线是按周期聚合的）
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

  /// 构建价格显示区域
  Widget _buildPriceSection(
    double latestPrice,
    double latestCnyPrice,
    double changePercent,
    bool isPricePositive,
  ) {
    return Column(
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
          DetailUtils.formatPrice(latestPrice),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isPricePositive ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${DetailUtils.formatPrice(latestCnyPrice)} ${isPricePositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 14,
            color: isPricePositive ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '标记价格 ${DetailUtils.formatPrice(latestPrice + 3)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
