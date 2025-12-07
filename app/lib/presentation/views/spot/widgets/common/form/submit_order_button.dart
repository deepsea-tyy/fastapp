import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:flutter/material.dart';

/// 提交订单按钮组件
class SubmitOrderButton extends StatelessWidget {
  final TradeType tradeType;
  final OrderSide tradeSide;
  final String baseCurrency;
  final bool isSubmitting;
  final VoidCallback? onPressed;

  const SubmitOrderButton({
    super.key,
    required this.tradeType,
    required this.tradeSide,
    required this.baseCurrency,
    required this.isSubmitting,
    this.onPressed,
  });

  String _getButtonText() {
    final prefix = tradeSide == OrderSide.buy
        ? tradeType.buyButtonPrefix
        : tradeType.sellButtonPrefix;
    return '$prefix $baseCurrency';
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSubmitting ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isSubmitting
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _getButtonText(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
    );
  }
}
