import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/common/app_bar.dart';
import 'package:fastapp/presentation/views/common/symbol_selector.dart';
import 'package:fastapp/presentation/views/spot/widgets/order_book.dart';
import 'package:fastapp/presentation/views/spot/widgets/order_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 现货交易页面
class SpotTradeScreen extends StatefulWidget {
  const SpotTradeScreen({super.key});

  @override
  State<SpotTradeScreen> createState() => _SpotTradeScreenState();
}

class _SpotTradeScreenState extends State<SpotTradeScreen> {
  final SpotTradeStore _store = getIt<SpotTradeStore>();

  @override
  void initState() {
    super.initState();
    _store.loadOrderBookData();
    _store.loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: '',
        titleWidget: Observer(
          builder: (_) => Text(
            _store.selectedSymbol,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              _store.loadOrderBookData();
              _store.loadBalance();
            },
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 交易对选择器（简化版，可以后续扩展）
          _buildSymbolSelector(context),
          
          // 主要内容区域
          Expanded(
            child: Row(
              children: [
                // 左侧：订单簿
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                    ),
                    child: const OrderBook(),
                  ),
                ),
                
                // 右侧：交易表单
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: const OrderForm(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector(BuildContext context) {
    final symbols = ['BTC/USDT', 'ETH/USDT', 'BNB/USDT', 'SOL/USDT'];
    return ObservableSymbolSelector(
      symbols: symbols,
      selectedSymbolGetter: () => _store.selectedSymbol,
      onSymbolSelected: (symbol) => _store.setSelectedSymbol(symbol),
    );
  }
}

