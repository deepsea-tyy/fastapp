import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// Ticker列表组件
class TickerList extends StatefulWidget {
  const TickerList({super.key});

  @override
  State<TickerList> createState() => _TickerListState();
}

class _TickerListState extends State<TickerList> {
  final MarketStore _store = getIt<MarketStore>();

  @override
  void initState() {
    super.initState();
    _store.loadAllTickers();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_store.isLoading && _store.tickerList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (_store.errorMessage != null && _store.tickerList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                    onPressed: () => _store.refreshTickers(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_store.tickerList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '暂无数据',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14.0,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _store.refreshTickers(),
          color: Theme.of(context).colorScheme.primary,
          child: ListView.builder(
            itemCount: _store.tickerList.length,
            itemBuilder: (context, index) {
              final ticker = _store.tickerList[index];
              final isPositive = ticker.changePercent >= 0;

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4,
                ),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticker.symbol,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '24h量: ${ticker.volume.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ticker.lastPrice.toStringAsFixed(2),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isPositive ? '+' : ''}${ticker.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Theme.of(context).colorScheme.error,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

