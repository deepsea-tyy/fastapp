import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
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
import 'package:mobx/mobx.dart';

/// 现货交易页面
/// 
/// 负责：
/// 1. 页面级别的数据初始化和生命周期管理
/// 2. 统一的错误处理和加载状态
/// 3. 组件布局和交互协调
class SpotTrade extends StatefulWidget {
  const SpotTrade({super.key});

  @override
  State<SpotTrade> createState() => _SpotTradeState();
}

class _SpotTradeState extends State<SpotTrade> with AutomaticKeepAliveClientMixin {
  late final SpotTradeStore _spotTradeStore;
  late final OrderStore _orderStore;
  late final DepthStore _depthStore;
  int _selectedBottomTab = 0;
  bool _isInitialized = false;
  ReactionDisposer? _symbolReaction;
  ReactionDisposer? _depthDataReaction;

  @override
  bool get wantKeepAlive => true; // 保持页面状态，避免切换标签时重新初始化

  @override
  void initState() {
    super.initState();
    _spotTradeStore = getIt<SpotTradeStore>();
    _orderStore = getIt<OrderStore>();
    _depthStore = getIt<DepthStore>();
    
    // 同步 DepthStore 的交易对，确保 WebSocket 订阅正确
    _depthStore.setCurrentSymbol(_spotTradeStore.selectedSymbol);
    
    // 监听交易对变化，同步到 DepthStore
    _symbolReaction = reaction(
      (_) => _spotTradeStore.selectedSymbol,
      (symbol) {
        print('[SpotTrade] symbol changed: $symbol');
        _depthStore.setCurrentSymbol(symbol);
        // 交易对变化后，重新同步订单簿数据
        // 注意：这里不立即同步，因为 setCurrentSymbol 会触发数据重新加载
        // 数据加载完成后，reaction 会自动同步
      },
    );
    
    // 初始化数据加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化页面数据
  Future<void> _initializeData() async {
    if (_isInitialized) return;
    
    try {
      // 同步 DepthStore 的交易对（确保 WebSocket 订阅正确）
      _depthStore.setCurrentSymbol(_spotTradeStore.selectedSymbol);
      
      // 并行加载订单簿、深度图和余额数据
      await Future.wait([
        _spotTradeStore.loadOrderBookData(),
        _depthStore.loadDepthData(), // 加载深度图数据并订阅 WebSocket
        _spotTradeStore.loadBalance(),
      ]);
      
      // 同步订单簿数据：如果 DepthStore 有更新的数据，同步到 SpotTradeStore
      // 这样订单簿可以通过 WebSocket 实时更新
      _syncOrderBookFromDepthStore();
      
      // 加载当前委托订单（仅加载待成交和部分成交的订单）
      await _orderStore.loadOrders(
        limit: 50,
      );
      
      _isInitialized = true;
    } catch (e) {
      // 错误已在 Store 中处理，这里只标记初始化完成
      _isInitialized = true;
    }
  }

  /// 同步深度图数据到订单簿
  /// 当 DepthStore 通过 WebSocket 更新数据时，同步到 SpotTradeStore
  void _syncOrderBookFromDepthStore() {
    // 清理旧的 reaction（如果存在）
    _depthDataReaction?.call();
    
    // 立即同步一次当前数据（如果存在）
    final currentDepthData = _depthStore.depthData;
    if (currentDepthData != null && mounted) {
      final depthSymbol = _depthStore.currentSymbol;
      final tradeSymbol = _spotTradeStore.selectedSymbol;
      if (depthSymbol == tradeSymbol) {
        runInAction(() {
          _spotTradeStore.orderBookData = currentDepthData;
        });
      }
    }
    
    // 监听 DepthStore 的数据变化，同步到 SpotTradeStore
    _depthDataReaction = reaction(
      (_) => _depthStore.depthData,
      (depthData) {
        if (depthData != null && mounted) {
          // 只有当交易对匹配时才同步
          final depthSymbol = _depthStore.currentSymbol;
          final tradeSymbol = _spotTradeStore.selectedSymbol;
          if (depthSymbol == tradeSymbol) {
            // 使用 runInAction 确保 MobX 正确追踪变化
            runInAction(() {
              _spotTradeStore.orderBookData = depthData;
            });
          }
        }
      },
    );
  }

  /// 刷新页面数据
  Future<void> _refreshData() async {
    await Future.wait([
      _spotTradeStore.loadOrderBookData(),
      _depthStore.refreshDepthData(), // 刷新深度图数据
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

  void _handleHistoryTap() {
    // TODO: 导航到历史订单页面
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
    super.build(context); // 必须调用，因为使用了 AutomaticKeepAliveClientMixin
    final screenHeight = MediaQuery.of(context).size.height;
    // 增加可用高度，使用更大的高度值
    final availableHeight = screenHeight * 1.2; // 使用屏幕高度的1.2倍
    
    return Observer(
      builder: (_) {
        return SizedBox(
          height: availableHeight,
          child: Column(
            children: [
              TradeSymbolHeader(
                tradeType: TradeType.spot,
                onSymbolTap: () => _showSymbolSelectorBottomSheet(context),
              ),
              // 订单表单和订单簿 - 占用部分空间
              Expanded(
                flex: 1, // 占 1/2 的高度
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 订单表单 - 占比 3/5，可滚动
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SingleChildScrollView(
                            child: SpotOrderForm(),
                          ),
                        ),
                      ),
                      // 订单簿 - 占比 2/5，填充所有可用高度
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                          ),
                          child: const TradeOrderBook(tradeType: TradeType.spot),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 可滚动内容区域 - 占用更多空间
              Expanded(
                flex: 1, // 占 1/2 的高度
                child: Column(
                  children: [
                    // 标签栏 - 固定在顶部，不滚动
                    _buildTabs(),
                    // 内容区域 - 可滚动
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

  @override
  void dispose() {
    // 清理 reactions
    _symbolReaction?.call();
    _depthDataReaction?.call();
    super.dispose();
  }
}
