import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/orders/order_store.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/current_orders_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_order_book.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_symbol_header.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/held_assets_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/spot_order_form.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/symbol_selector_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 现货交易页面
///
/// 负责：
/// 1. 页面布局
/// 2. 订单表单和订单列表管理
///
/// 订单簿数据由 TradeOrderBook 自行管理
class SpotTrade extends StatefulWidget {
  const SpotTrade({super.key});

  @override
  State<SpotTrade> createState() => _SpotTradeState();
}

class _SpotTradeState extends State<SpotTrade> with AutomaticKeepAliveClientMixin {
  late final SpotTradeStore _spotTradeStore;
  late final OrderStore _orderStore;
  int _selectedBottomTab = 0;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _spotTradeStore = getIt<SpotTradeStore>();
    _orderStore = getIt<OrderStore>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      // 加载余额和订单数据
      await Future.wait([
        _spotTradeStore.loadBalance(),
        _orderStore.loadOrders(limit: 50),
      ]);

      _isInitialized = true;
    } catch (e) {
      _isInitialized = true;
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _spotTradeStore.loadBalance(),
      _orderStore.refreshOrders(),
    ]);
  }

  void _showSymbolSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SymbolSelectorBottomSheet(),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTab(spotTabCurrentOrders, 0),
          const SizedBox(width: 24),
          _buildTab(spotTabHeldAssets, 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedBottomTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedBottomTab = index),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 1.2;

    return Observer(
      builder: (_) {
        final symbol = _spotTradeStore.selectedSymbol;

        return SizedBox(
          height: availableHeight,
          child: Column(
            children: [
              TradeSymbolHeader(
                tradeType: TradeType.spot,
                onSymbolTap: () => _showSymbolSelectorBottomSheet(context),
              ),
              // 订单表单和订单簿
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 订单表单
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SingleChildScrollView(
                            child: SpotOrderForm(),
                          ),
                        ),
                      ),
                      // 订单簿 - 传入 symbol，自己管理数据
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                          ),
                          child: TradeOrderBook(
                            symbol: symbol,
                            tradeType: TradeType.spot,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 订单列表区域
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildTabs(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _selectedBottomTab == 1
                              ? const HeldAssetsContent()
                              : CurrentOrdersContent(
                                  tradeType: TradeType.spot,
                                  hasBalance: _spotTradeStore.availableBalance != null,
                                  onAddBalance: () {
                                    // TODO: 导航到添加资金页面
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
