import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/futures/position.dart';
import 'package:fastapp/presentation/store/futures/futures_trade_store.dart';
import 'package:fastapp/presentation/views/common/app_bar.dart';
import 'package:fastapp/presentation/views/common/symbol_selector.dart';
import 'package:fastapp/presentation/views/spot/widgets/order_book.dart';
import 'package:fastapp/presentation/views/spot/widgets/order_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 永续合约交易页面
class FuturesTradeScreen extends StatefulWidget {
  const FuturesTradeScreen({super.key});

  @override
  State<FuturesTradeScreen> createState() => _FuturesTradeScreenState();
}

class _FuturesTradeScreenState extends State<FuturesTradeScreen> {
  final FuturesTradeStore _store = getIt<FuturesTradeStore>();

  @override
  void initState() {
    super.initState();
    _store.loadOrderBookData();
    _store.loadBalance();
    _store.loadPosition();
    _store.loadFundingRate();
    _store.loadMarkPrice();
    _store.loadLeverage();
  }

  void _refreshAll() {
    _store.loadOrderBookData();
    _store.loadBalance();
    _store.loadPosition();
    _store.loadFundingRate();
    _store.loadMarkPrice();
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
            onPressed: _refreshAll,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 交易对和杠杆选择器
          _buildTopBar(context),
          
          // 持仓信息卡片（如有持仓）
          Observer(
            builder: (_) => _store.currentPosition != null
                ? _buildPositionCard(context, _store.currentPosition!)
                : const SizedBox.shrink(),
          ),
          
          // 资金费率和标记价格
          _buildInfoBar(context),
          
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
                    child: Column(
                      children: [
                        // 杠杆选择器
                        _buildLeverageSelector(context),
                        const SizedBox(height: 8),
                        // 交易表单
                        const Expanded(child: OrderForm()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final symbols = ['BTC/USDT', 'ETH/USDT', 'BNB/USDT', 'SOL/USDT'];
    return ObservableSymbolSelector(
      symbols: symbols,
      selectedSymbolGetter: () => _store.selectedSymbol,
      onSymbolSelected: (symbol) => _store.setSelectedSymbol(symbol),
    );
  }

  Widget _buildLeverageSelector(BuildContext context) {
    final leverages = [1, 2, 5, 10, 20, 50, 100];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Row(
        children: [
          Text(
            '杠杆: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) => Wrap(
                spacing: 8,
                children: leverages.map((lev) {
                  return ChoiceChip(
                    label: Text('${lev}x'),
                    selected: _store.leverage == lev,
                    onSelected: (selected) {
                      if (selected) {
                        _store.setLeverageValue(lev);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(BuildContext context, Position position) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        border: Border.all(
          color: position.isProfit
              ? Colors.green
              : position.isLoss
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '持仓方向',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                position.side == PositionSide.long ? '做多' : '做空',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '持仓数量',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                position.quantity.toStringAsFixed(4),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '未实现盈亏',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                position.unrealizedPnl.toStringAsFixed(2),
                style: TextStyle(
                  color: position.isProfit
                      ? Colors.green
                      : position.isLoss
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '杠杆',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${position.leverage}x',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_store.markPrice != null)
              _buildInfoItem(
                context,
                '标记价格',
                _store.markPrice!.price.toStringAsFixed(2),
              ),
            if (_store.fundingRate != null)
              _buildInfoItem(
                context,
                '资金费率',
                '${(_store.fundingRate!.rate * 100).toStringAsFixed(4)}%',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

