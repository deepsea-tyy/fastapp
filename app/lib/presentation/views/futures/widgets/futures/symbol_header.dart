import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/calculator_bottom_sheet.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/symbol_selector_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 交易对头部组件
class SymbolHeader extends StatelessWidget {
  final bool isCoinMargined; // true: 币本位, false: U本位
  
  const SymbolHeader({
    super.key,
    this.isCoinMargined = false,
  });

  @override
  Widget build(BuildContext context) {
    final SpotTradeStore store = getIt<SpotTradeStore>();
    
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showSymbolSelectorBottomSheet(context),
              child: Row(
                children: [
                  Text(
                    '${store.selectedSymbol}${isCoinMargined ? 'CM' : ''} 永续',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+0.87%',
                style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.candlestick_chart, color: Colors.grey.shade600),
              onPressed: () {
                final orderBookData = store.orderBookData;
                final ticker = TickerData(
                  symbol: store.selectedSymbol,
                  lastPrice: orderBookData?.lastPrice ?? 0.0,
                  openPrice: orderBookData?.lastPrice ?? 0.0,
                  highPrice: orderBookData?.lastPrice ?? 0.0,
                  lowPrice: orderBookData?.lastPrice ?? 0.0,
                  volume: 0.0,
                  amount: 0.0,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MarketDetailScreen(
                      ticker: ticker,
                      isFutures: true,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.calculate_outlined, color: Colors.grey.shade600),
              onPressed: () => _showCalculatorBottomSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalculatorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CalculatorBottomSheet(),
    );
  }

  void _showSymbolSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SymbolSelectorBottomSheet(),
    );
  }
}
