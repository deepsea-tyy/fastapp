import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Observer(
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
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

