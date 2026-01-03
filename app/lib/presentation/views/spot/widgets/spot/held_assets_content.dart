import 'package:fastapp/presentation/views/spot/widgets/spot/assets/current_trading_pair_assets.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/assets/other_non_zero_assets.dart';
import 'package:flutter/material.dart';

/// 持有币种内容组件
class HeldAssetsContent extends StatelessWidget {
  const HeldAssetsContent({super.key});

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
        ],
      ),
    );
  }
}
