import 'package:fastapp/presentation/views/spot/widgets/spot/empty_balance_state.dart';
import 'package:flutter/material.dart';

/// 当前委托内容组件
class CurrentOrdersContent extends StatelessWidget {
  final bool hasBalance;
  final VoidCallback? onAddBalance;

  const CurrentOrdersContent({
    super.key,
    this.hasBalance = false,
    this.onAddBalance,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasBalance) {
      return EmptyBalanceState(onAddBalance: onAddBalance);
    }
    
    // 有余额时显示订单列表
    return Container();
  }
}
