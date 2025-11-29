import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/views/common/app_bar.dart';
import 'package:fastapp/presentation/views/market/widgets/kline_chart.dart';
import 'package:fastapp/presentation/views/market/widgets/ticker_list.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 行情主页面
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketStore _marketStore = getIt<MarketStore>();
  final KlineStore _klineStore = getIt<KlineStore>();
  int _selectedTabIndex = 0; // 0: K线图, 1: Ticker列表

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: '行情',
        actions: [
          IconButton(
            icon: Icon(
              Icons.bar_chart,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.pushNamed(context, Routes.depth);
            },
            tooltip: '深度图',
          ),
        ],
      ),
      body: Column(
        children: [
          // 交易对选择和时间周期选择（K线图模式）
          if (_selectedTabIndex == 0) _buildKlineControls(),
          
          // Tab切换
          _buildTabBar(),
          
          // 内容区域
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildKlineView()
                : _buildTickerView(),
          ),
        ],
      ),
    );
  }

  Widget _buildKlineControls() {
    final theme = Theme.of(context);
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(16.0),
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // 时间周期选择
            Row(
              children: _klineStore.intervals.map((interval) {
                final isSelected = _klineStore.currentInterval == interval;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ElevatedButton(
                      onPressed: () {
                        _klineStore.setCurrentInterval(interval);
                        _klineStore.loadKlineData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        foregroundColor: isSelected
                            ? theme.scaffoldBackgroundColor
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        interval,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // 指标选择
            Row(
              children: [
                Expanded(
                  child: _buildIndicatorDropdown(
                    theme,
                    _klineStore.mainIndicator,
                    ['MA', 'BOLL'],
                    (value) => _klineStore.setMainIndicator(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildIndicatorDropdown(
                    theme,
                    _klineStore.secondaryIndicator,
                    ['MACD', 'RSI', 'KDJ'],
                    (value) => _klineStore.setSecondaryIndicator(value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDropdown(
    ThemeData theme,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return DropdownButton<String>(
      value: value,
      isExpanded: true,
      dropdownColor: theme.colorScheme.surface,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 12.0,
      ),
      items: items.map((indicator) {
        return DropdownMenuItem(
          value: indicator,
          child: Text(indicator),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('K线图', 0),
          ),
          Expanded(
            child: _buildTabButton('行情列表', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildKlineView() {
    return Observer(
      builder: (_) => KlineChart(
        symbol: _klineStore.currentSymbol,
        interval: _klineStore.currentInterval,
      ),
    );
  }

  Widget _buildTickerView() {
    return const TickerList();
  }
}

