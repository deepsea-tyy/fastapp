import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_order_book.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_symbol_header.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/current_orders_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/held_assets_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/leverage_order_form.dart';
import 'package:flutter/material.dart';

/// 杠杆交易页面
class LeverageTrade extends StatefulWidget {
  const LeverageTrade({super.key});

  @override
  State<LeverageTrade> createState() => _LeverageTradeState();
}

class _LeverageTradeState extends State<LeverageTrade> {
  int _selectedBottomTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TradeSymbolHeader(
          tradeType: TradeType.leverage,
          onSymbolTap: null, // 杠杆暂不支持选择交易对
        ),
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
                      child: LeverageOrderForm(),
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
                    child: const TradeOrderBook(tradeType: TradeType.leverage),
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
                _selectedBottomTab == 1
                    ? const HeldAssetsContent()
                    : const CurrentOrdersContent(tradeType: TradeType.leverage),
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
          _buildTab('当前委托 (0)', 0),
          const SizedBox(width: 24),
          _buildTab('持仓 (1)', 1),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.history, color: Colors.grey.shade600),
            onPressed: () {},
          ),
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
}
