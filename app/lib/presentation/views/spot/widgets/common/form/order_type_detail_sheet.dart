import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/form/order_type_tabs.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/form/order_type_content.dart';
import 'package:flutter/material.dart';

// 订单类型详情弹框
class OrderTypeDetailSheet extends StatefulWidget {
  final SpotTradeStore store;

  const OrderTypeDetailSheet({super.key, required this.store});

  @override
  State<OrderTypeDetailSheet> createState() => _OrderTypeDetailSheetState();
}

class _OrderTypeDetailSheetState extends State<OrderTypeDetailSheet> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          OrderTypeTabs(
            tabs: const [orderTypeLimit, orderTypeMarket, orderTypeStopLoss, orderTypeTakeProfit, orderTypeTrailing],
            selectedTab: _selectedTab,
            onTabChanged: (index) => setState(() => _selectedTab = index),
          ),
          Container(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SpotOrderTypeContent(selectedTab: _selectedTab),
            ),
          ),
        ],
      ),
    );
  }
}
