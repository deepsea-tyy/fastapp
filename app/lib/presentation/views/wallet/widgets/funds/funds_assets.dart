import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/views/wallet/widgets/common/unified_assets_card.dart';
import 'package:flutter/material.dart';

/// 预估总资产卡片（资金）
class FundsAssets extends StatelessWidget {
  final WalletType walletType;

  const FundsAssets({super.key, required this.walletType});

  @override
  Widget build(BuildContext context) {
    return UnifiedAssetsCard(walletType: walletType);
  }
}
