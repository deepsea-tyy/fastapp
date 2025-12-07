import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

/// 订单类型选择弹窗
class OrderTypeBottomSheet extends StatelessWidget {
  final OrderType currentType;
  final ValueChanged<OrderType> onTypeChanged;

  const OrderTypeBottomSheet({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDragHandle(),
              
              // 标题
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '订单类型',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // 订单类型选项列表
              _buildOrderTypeOption(context, orderTypeLimit, OrderType.limit),
              _buildOrderTypeOption(context, orderTypeMaker, OrderType.limit), // 暂时用limit代替
              _buildOrderTypeOption(context, orderTypeMarket, OrderType.market),
              _buildOrderTypeOption(context, orderTypeStopLoss, OrderType.stopLoss),
              _buildOrderTypeOption(context, orderTypeStopLossMarket, OrderType.takeProfit),
              _buildOrderTypeOption(context, orderTypeConditional, OrderType.limit), // 暂时用limit代替
              _buildOrderTypeOption(context, orderTypeTrailing, OrderType.limit), // 暂时用limit代替
              _buildOrderTypeOption(context, orderTypeTimedOrder, OrderType.limit), // 暂时用limit代替
              _buildOrderTypeOption(context, orderTypeSegmentOrder, OrderType.limit), // 暂时用limit代替
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeOption(BuildContext context, String title, OrderType type) {
    final isSelected = _getOrderTypeLabel(currentType) == title;
    return InkWell(
      onTap: () {
        onTypeChanged(type);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.black87,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.limit:
        return orderTypeLimit;
      case OrderType.market:
        return orderTypeMarket;
      case OrderType.stopLoss:
        return orderTypeStopLoss;
      case OrderType.takeProfit:
        return orderTypeStopLossMarket;
    }
  }
}
