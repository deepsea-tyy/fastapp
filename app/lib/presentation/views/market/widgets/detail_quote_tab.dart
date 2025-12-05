import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_indicator_selector.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_interval_selector.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_kline_chart.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_market_overview.dart';
import 'package:fastapp/presentation/views/market/widgets/detail_order_book.dart';
import 'package:flutter/material.dart';

/// 报价标签页
class DetailQuoteTab extends StatefulWidget {
  final TickerData ticker;
  final bool isPositive;
  final double cnyPrice;
  final List<String> intervals;
  final Map<String, String> intervalMap;
  final String selectedInterval;
  final List<String> selectedIndicators;
  final List<String> indicators;
  final KlineStore klineStore;
  final bool isRealtime;
  final ValueChanged<String> onIntervalChanged;
  final ValueChanged<String> onIndicatorToggled;
  final VoidCallback onDepthTap;
  final VoidCallback onSettingsTap;

  const DetailQuoteTab({
    super.key,
    required this.ticker,
    required this.isPositive,
    required this.cnyPrice,
    required this.intervals,
    required this.intervalMap,
    required this.selectedInterval,
    required this.selectedIndicators,
    required this.indicators,
    required this.klineStore,
    required this.isRealtime,
    required this.onIntervalChanged,
    required this.onIndicatorToggled,
    required this.onDepthTap,
    required this.onSettingsTap,
  });

  @override
  State<DetailQuoteTab> createState() => _DetailQuoteTabState();
}

class _DetailQuoteTabState extends State<DetailQuoteTab> {
  ChartMode _chartMode = ChartMode.kline;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 市场概览数据
          DetailMarketOverview(
            ticker: widget.ticker,
            isPositive: widget.isPositive,
            cnyPrice: widget.cnyPrice,
          ),
          
          // 时间周期选择
          DetailIntervalSelector(
            intervals: widget.intervals,
            intervalMap: widget.intervalMap,
            selectedInterval: _chartMode == ChartMode.depth ? '' : widget.selectedInterval,
            onIntervalChanged: (interval) {
              setState(() {
                _chartMode = ChartMode.kline;
              });
              widget.onIntervalChanged(interval);
            },
            onDepthTap: () {
              setState(() {
                _chartMode = _chartMode == ChartMode.kline ? ChartMode.depth : ChartMode.kline;
              });
              widget.onDepthTap();
            },
            onSettingsTap: widget.onSettingsTap,
            isDepthSelected: _chartMode == ChartMode.depth,
          ),
          
          // K线图或深度图
          // 高度由 k_chart_plus 内部处理，使用 LayoutBuilder 的约束自适应
          DetailKlineChart(
            symbol: widget.ticker.symbol,
            interval: widget.intervalMap[widget.selectedInterval] ?? '1m',
            showVolume: widget.selectedIndicators.contains('VOL'),
            mode: _chartMode,
            selectedIndicators: widget.selectedIndicators,
            isRealtime: widget.isRealtime,
          ),
          
          // 底部指标选择器（仅在K线图模式下显示）
          if (_chartMode == ChartMode.kline)
            DetailIndicatorSelector(
              indicators: widget.indicators,
              selectedIndicators: widget.selectedIndicators,
              onIndicatorToggled: widget.onIndicatorToggled,
            ),
          
          // 底部订单簿
          const SizedBox(
            height: 300,
            child: DetailOrderBook(),
          ),
        ],
      ),
    );
  }

}
