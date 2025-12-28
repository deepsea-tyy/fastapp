import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/views/wallet/widgets/action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_list_header.dart';
import 'package:flutter/material.dart';

/// 资金 Tab
class FundsTab extends StatefulWidget {
  const FundsTab({super.key});

  @override
  State<FundsTab> createState() => _FundsTabState();
}

class _FundsTabState extends State<FundsTab> {
  final WalletType _walletType = WalletType.FUNDING;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FundsAssets(walletType: _walletType),
          const SizedBox(height: 16),
          const ActionButtons(),
          const SizedBox(height: 16),
          const FundsListHeader(),
          FundsList(walletType: _walletType),
        ],
      ),
    );
  }
}
