import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:flutter/material.dart';

/// 买入/卖出选择器组件
class TradeSideSelector extends StatelessWidget {
  final OrderSide currentSide;
  final ValueChanged<OrderSide> onSideChanged;

  const TradeSideSelector({
    super.key,
    required this.currentSide,
    required this.onSideChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onSideChanged(OrderSide.buy),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: currentSide == OrderSide.buy ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '买入',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: currentSide == OrderSide.buy ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () => onSideChanged(OrderSide.sell),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: currentSide == OrderSide.sell ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '卖出',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: currentSide == OrderSide.sell ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
