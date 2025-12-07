import 'package:fastapp/presentation/views/spot/widgets/common/trade_menu.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_top_navigation.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage_trade.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot_trade.dart';
import 'package:fastapp/presentation/views/spot/widgets/swap_trade.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';

/// 现货交易页面
class SpotScreen extends StatefulWidget {
  const SpotScreen({super.key});

  @override
  State<SpotScreen> createState() => _SpotScreenState();
}

class _SpotScreenState extends State<SpotScreen> {
  int _selectedTopTab = 1;

  @override
  void initState() {
    super.initState();
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
            // 顶部导航栏
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
            Expanded(
              child: _buildTabContent(),
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
}
