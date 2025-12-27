import 'package:fastapp/presentation/views/wallet/widgets/action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/funds/funds_list_header.dart';
import 'package:flutter/material.dart';

/// 资金 Tab
class FundsTab extends StatelessWidget {
  const FundsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const FundsAssets(),
          const SizedBox(height: 16),
          const ActionButtons(),
          const SizedBox(height: 16),
          const FundsListHeader(),
          const FundsList(),
        ],
      ),
    );
  }
}
