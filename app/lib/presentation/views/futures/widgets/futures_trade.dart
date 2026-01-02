import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/current_orders_content.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/held_positions_content.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/futures_order_form.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/symbol_header.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_order_book.dart';
import 'package:fastapp/presentation/views/grid/grid_trading_screen.dart';
import 'package:flutter/material.dart';

/// 期货交易页面（复制自杠杆交易）
class FuturesTrade extends StatefulWidget {
  final bool isCoinMargined; // true: 币本位, false: U本位
  
  const FuturesTrade({
    super.key,
    this.isCoinMargined = false,
  });

  @override
  State<FuturesTrade> createState() => _FuturesTradeState();
}

class _FuturesTradeState extends State<FuturesTrade> {
  int _selectedBottomTab = 0; // 0: 持有仓位, 1: 当前委托, 2: 合约网格

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 交易对头部
        SymbolHeader(isCoinMargined: widget.isCoinMargined),
        // 订单表单和订单簿 - 占用大部分空间
        Expanded(
          flex: 3,
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
                      child: FuturesOrderForm(),
                    ),
                  ),
                ),
                // 订单簿 - 占比 2/5
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                    ),
                    child: const TradeOrderBook(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 可滚动内容区域
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标签栏
                _buildTabs(),
                // 根据选中的标签显示对应内容
                _selectedBottomTab == 0
                    ? const HeldPositionsContent()
                    : _selectedBottomTab == 1
                        ? const CurrentOrdersContent()
                        : const Center(child: Text('合约网格功能开发中')),
              ],
            ),
          ),
        ),
      ],
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
          _buildTab('持有仓位 (0)', 0),
          const SizedBox(width: 24),
          _buildTab('当前委托 (0)', 1),
          const SizedBox(width: 24),
          _buildTab('合约网格', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedBottomTab == index;
    return InkWell(
      onTap: () {
        if (index == 2) {
          // 点击合约网格跳转到交易机器人页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GridTradingScreen(),
            ),
          );
        } else {
          setState(() => _selectedBottomTab = index);
        }
      },
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
}
