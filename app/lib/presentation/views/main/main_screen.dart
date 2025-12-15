import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/presentation/views/home/home_screen.dart';
import 'package:fastapp/presentation/views/market/market_screen.dart';
import 'package:fastapp/presentation/views/spot/spot_screen.dart';
import 'package:fastapp/presentation/views/futures/futures_trade_screen.dart';
import 'package:fastapp/presentation/views/wallet/wallet_screen.dart';
import 'package:fastapp/presentation/views/main/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 主页面容器，管理底部导航栏和不同 tab 的切换
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<HomeStore>();
    final themeStore = getIt<ThemeStore>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 页面内容
          Observer(
            builder: (_) => IndexedStack(
              index: store.bottomNavIndex,
              children: const [
                HomeScreen(),
                MarketScreen(),
                SpotScreen(),
                FuturesTradeScreen(),
                WalletScreen(),
              ],
            ),
          ),

          // 悬浮按钮（使用 Positioned 固定在右下角）
          Positioned(
            right: 16,
            bottom: 80, // 底部导航栏高度 + 间距
            child: Observer(
              builder: (_) => FloatingActionButton(
                onPressed: () => themeStore.toggleTheme(),
                tooltip: '切换主题',
                child: Icon(
                  themeStore.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

