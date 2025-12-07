import 'package:fastapp/presentation/views/spot/widgets/common/empty_balance_state.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:flutter/material.dart';

/// 当前委托内容组件
class CurrentOrdersContent extends StatelessWidget {
  final TradeType tradeType;
  final bool hasBalance;
  final VoidCallback? onAddBalance;

  const CurrentOrdersContent({
    super.key,
    required this.tradeType,
    this.hasBalance = false,
    this.onAddBalance,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasBalance) {
      return EmptyBalanceState(
        tradeType: tradeType,
        onAddBalance: onAddBalance,
      );
    }

    // 有余额时显示订单列表
    return Container();
  }
}
