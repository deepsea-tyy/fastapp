import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/common/selection_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// 订单类型选择器组件
class OrderTypeSelector extends StatelessWidget {
  final OrderType currentType;
  final ValueChanged<OrderType> onTypeChanged;
  final VoidCallback? onInfoTap;

  const OrderTypeSelector({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
    this.onInfoTap,
  });

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.limit:
        return orderTypeLimit;
      case OrderType.market:
        return orderTypeMarket;
      case OrderType.stopLoss:
        return orderTypeStopLoss;
      case OrderType.takeProfit:
        return orderTypeTakeProfit;
    }
  }

  void _showOrderTypeSelectionSheet(BuildContext context) {
    final orderTypes = [
      {'label': orderTypeLimit, 'type': OrderType.limit},
      {'label': orderTypeMarket, 'type': OrderType.market},
      {'label': orderTypeStopLoss, 'type': OrderType.stopLoss},
      {'label': orderTypeTakeProfit, 'type': OrderType.takeProfit},
      {'label': orderTypeTrailing, 'type': null},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SelectionBottomSheet<OrderType?>(
        title: '订单类型',
        useListTileStyle: true,
        selectedValue: currentType,
        onSelected: (type) {
          if (type != null) {
            onTypeChanged(type);
            Navigator.of(context).pop();
          }
        },
        options: orderTypes
            .map((item) => SelectionOption<OrderType?>(
                  title: item['label'] as String,
                  value: item['type'] as OrderType?,
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          InkWell(
            onTap: onInfoTap,
            child: Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _showOrderTypeSelectionSheet(context),
              child: Row(
                children: [
                  Expanded(child: Text(_getOrderTypeLabel(currentType), style: const TextStyle(fontSize: 14, color: Colors.black87))),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
