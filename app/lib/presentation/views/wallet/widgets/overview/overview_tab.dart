import 'package:fastapp/presentation/views/wallet/widgets/action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/overview_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/overview_list.dart';
import 'package:flutter/material.dart';

/// 总览 Tab
class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  String _selectedCurrencyTab = '币种';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OverviewAssets(),
        const SizedBox(height: 16),
        const ActionButtons(),
        const SizedBox(height: 16),
        AssetListHeader(
          selectedTab: _selectedCurrencyTab,
          onTabChanged: (tab) {
            setState(() {
              _selectedCurrencyTab = tab;
            });
          },
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedCurrencyTab == '账户' ? 1 : 0,
            children: [
              SingleChildScrollView(
                key: const PageStorageKey('currency_tab_scroll'),
                child: const CurrencyAssetList(),
              ),
              SingleChildScrollView(
                key: const PageStorageKey('account_tab_scroll'),
                child: const AccountAssetList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
