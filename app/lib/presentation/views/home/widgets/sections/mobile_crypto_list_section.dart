import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/presentation/views/market/widgets/market_list_item.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class MobileCryptoListSection extends StatelessWidget {
  const MobileCryptoListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeStore = getIt<HomeStore>();
    final marketStore = getIt<MarketStore>();
    final marketDataStore = getIt<MarketDataStore>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最新行情',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Observer(
            builder: (_) {
              final tickers = marketStore.tickerList
                  .where((t) => t.symbol.isNotEmpty && t.lastPrice > 0 && t.lastPrice.isFinite)
                  .take(4)
                  .toList();

              if (tickers.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: marketStore.isLoading
                        ? const CircularProgressIndicator(color: Colors.amber)
                        : Text('暂无行情数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ),
                );
              }

              return Column(
                children: tickers.map((ticker) {
                  final symbol = _getBaseCurrencySymbol(ticker.symbol, marketDataStore);
                  final currency = marketDataStore.getCurrency(symbol);

                  return MarketListItem(
                    ticker: ticker,
                    logoUrl: currency?.logo != null ? ImageUtils.formatSingleImagePath(currency!.logo) : null,
                    fullName: currency?.name,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MarketDetailScreen(ticker: ticker, isFutures: false),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // 切换到底部导航的"行情" tab（index: 1）
                homeStore.setBottomNavIndex(1);
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
              label: Text(
                '查看全部',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 从交易对符号中提取基础币种符号
  String _getBaseCurrencySymbol(String symbol, MarketDataStore store) {
    return symbol.contains('/') ? symbol.split('/')[0] : store.getSpotPair(symbol)?.baseCurrencySymbol ?? symbol;
  }
}

