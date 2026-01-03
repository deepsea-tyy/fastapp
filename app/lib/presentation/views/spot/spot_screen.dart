import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_menu.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_top_navigation.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage_trade.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot_trade.dart';
import 'package:fastapp/presentation/views/spot/widgets/swap_trade.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';

/// 现货交易页面
/// 
/// 负责：
/// 1. WebSocket 连接初始化
/// 2. 全局基础数据加载（Ticker、用户资产）
/// 3. 订单簿订阅由 spot_trade.dart 管理
class SpotScreen extends StatefulWidget {
  const SpotScreen({super.key});

  @override
  State<SpotScreen> createState() => _SpotScreenState();
}

class _SpotScreenState extends State<SpotScreen> {
  int _selectedTopTab = 1;
  late final MarketStore _marketStore;
  late final WalletStore _walletStore;
  late final AppWebSocket _webSocket;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _marketStore = getIt<MarketStore>();
    _walletStore = getIt<WalletStore>();
    _webSocket = getIt<AppWebSocket>();
    
    // 初始化基础数据（订单簿订阅由 spot_trade.dart 管理）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化基础数据
  Future<void> _initializeData() async {
    if (_isInitialized) return;
    
    try {
      // 确保 WebSocket 已连接
      if (!_webSocket.isConnected) {
        await _marketStore.ensureWebSocketConnected();
      }
      
      // 加载所有 Ticker 数据（用于价格显示）
      if (_marketStore.tickerList.isEmpty) {
        await _marketStore.loadAllTickers();
      }
      
      // 加载用户资产数据（用于显示持有资产列表）
      if (_walletStore.accountBalance == null) {
        await _walletStore.loadAsset();
      }
      
      _isInitialized = true;
    } catch (e) {
      // 错误已在 Store 中处理，允许降级到 HTTP
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 键盘弹出时调整布局，兼容移动端
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏 - 固定在顶部
            TradeTopNavigation(
              selectedTab: _selectedTopTab,
              onTabChanged: (index) {
                // C2C tab (索引3) 不改变tab状态
                if (index != 3) {
                  setState(() {
                    _selectedTopTab = index;
                  });
                }
              },
              onMenuPressed: () => TradeMenu.show(context),
              onC2CPressed: () {
                // 点击C2C时导航到C2C页面
                Navigator.of(context).pushNamed(Routes.c2c);
              },
            ),
            // 内容区域 - 可滚动
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 1.2, // 增加整体高度到屏幕高度的1.2倍
                  child: _buildTabContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTopTab) {
      case 0:
        return const SwapTrade(); // 闪兑
      case 1:
        return const SpotTrade(); // 现货
      case 2:
        return const LeverageTrade(); // 杠杆显示杠杆交易页面
      // case 3 是C2C，但不会到达这里，因为C2C点击时不会改变_selectedTopTab
      default:
        return const SpotTrade();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
