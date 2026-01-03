import 'package:fastapp/presentation/views/spot/widgets/common/trade_menu.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_top_navigation.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage_trade.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot_trade.dart';
import 'package:fastapp/presentation/views/spot/widgets/swap_trade.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';

/// 现货交易页面
///
/// 纯布局组件，负责：
/// 1. 顶部导航栏切换
/// 2. 子页面切换（闪兑、现货、杠杆）
///
/// 数据加载和订阅由各子组件自行管理
class SpotScreen extends StatefulWidget {
  const SpotScreen({super.key});

  @override
  State<SpotScreen> createState() => _SpotScreenState();
}

class _SpotScreenState extends State<SpotScreen> {
  int _selectedTopTab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            TradeTopNavigation(
              selectedTab: _selectedTopTab,
              onTabChanged: (index) {
                if (index != 3) {
                  setState(() {
                    _selectedTopTab = index;
                  });
                }
              },
              onMenuPressed: () => TradeMenu.show(context),
              onC2CPressed: () {
                Navigator.of(context).pushNamed(Routes.c2c);
              },
            ),
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 1.2,
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
        return const SwapTrade();
      case 1:
        return const SpotTrade();
      case 2:
        return const LeverageTrade();
      default:
        return const SpotTrade();
    }
  }
}
