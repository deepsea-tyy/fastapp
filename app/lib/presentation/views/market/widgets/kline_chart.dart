import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/kline_data.dart';
import 'package:fastapp/presentation/store/market/kline_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:k_chart_plus/k_chart_plus.dart';

/// K线图组件
class KlineChart extends StatefulWidget {
  final String symbol;
  final String interval;

  const KlineChart({
    super.key,
    required this.symbol,
    required this.interval,
  });

  @override
  State<KlineChart> createState() => _KlineChartState();
}

class _KlineChartState extends State<KlineChart> {
  final KlineStore _store = getIt<KlineStore>();

  @override
  void initState() {
    super.initState();
    _store.setCurrentSymbol(widget.symbol);
    _store.setCurrentInterval(widget.interval);
    _store.loadKlineData();
  }

  @override
  void didUpdateWidget(KlineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol || oldWidget.interval != widget.interval) {
      _store.setCurrentSymbol(widget.symbol);
      _store.setCurrentInterval(widget.interval);
      _store.loadKlineData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_store.isLoading && _store.klineData.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (_store.errorMessage != null && _store.klineData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _store.errorMessage ?? '加载失败',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _store.refreshKlineData(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        // 转换数据格式为k_chart_plus需要的格式
        final kChartData = _store.klineData.map((kline) {
          return KLineEntity.fromCustom(
            open: kline.open,
            high: kline.high,
            low: kline.low,
            close: kline.close,
            vol: kline.volume,
            amount: kline.amount,
            time: kline.timestamp,
          );
        }).toList();

        final chartStyle = ChartStyle();
        final chartColors = ChartColors()
          ..bgColor = Theme.of(context).scaffoldBackgroundColor
          ..ma5Color = Theme.of(context).colorScheme.primary
          ..ma10Color = Colors.green
          ..ma30Color = Theme.of(context).colorScheme.error
          ..upColor = Colors.green
          ..dnColor = Theme.of(context).colorScheme.error;

        return KChartWidget(
          kChartData,
          chartStyle,
          chartColors,
          isTrendLine: false,
          isLine: false, // 显示K线图
          mainStateLi: {_getMainState(_store.mainIndicator)},
          secondaryStateLi: {_getSecondaryState(_store.secondaryIndicator)},
          volHidden: false, // 显示成交量
          onLoadMore: (bool isReload) async {
            // 加载更多数据
            if (!isReload && _store.klineData.isNotEmpty) {
              final oldestTime = _store.klineData.first.timestamp;
              await _store.loadKlineData(
                endTime: oldestTime - 1,
                limit: 100,
              );
            }
          },
        );
      },
    );
  }

  MainState _getMainState(String indicator) {
    switch (indicator) {
      case 'MA':
        return MainState.MA;
      case 'BOLL':
        return MainState.BOLL;
      default:
        return MainState.MA;
    }
  }

  SecondaryState _getSecondaryState(String indicator) {
    switch (indicator) {
      case 'MACD':
        return SecondaryState.MACD;
      case 'RSI':
        return SecondaryState.RSI;
      case 'KDJ':
        return SecondaryState.KDJ;
      default:
        return SecondaryState.MACD;
    }
  }

  @override
  void dispose() {
    // Store由依赖注入管理，不需要手动dispose
    super.dispose();
  }
}

