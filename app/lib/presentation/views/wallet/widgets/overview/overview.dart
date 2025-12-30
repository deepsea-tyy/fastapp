import 'package:fastapp/presentation/views/wallet/widgets/action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/overview_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/overview_list.dart';
import 'package:flutter/material.dart';

/// 总览 Tab
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OverviewAssets(),
        const SizedBox(height: 16),
        const ActionButtons(),
        const SizedBox(height: 16),
        const AssetListHeader(),
        const Expanded(
          child: SingleChildScrollView(
            child: AccountAssetList(),
          ),
        ),
      ],
    );
  }
}
