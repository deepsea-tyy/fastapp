import 'package:fastapp/presentation/views/spot/widgets/spot/assets/current_trading_pair_assets.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/assets/other_non_zero_assets.dart';
import 'package:flutter/material.dart';

/// 持有币种内容组件
class HeldAssetsContent extends StatelessWidget {
  final VoidCallback? onBuySellPressed;
  final VoidCallback? onAddFundsPressed;

  const HeldAssetsContent({
    super.key,
    this.onBuySellPressed,
    this.onAddFundsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前交易对资产
          const CurrentTradingPairAssets(),
          // 其他非0资产
          const OtherNonZeroAssets(),
          // 底部按钮
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBuySellPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '买入/卖出',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: onAddFundsPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '添加资金',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
