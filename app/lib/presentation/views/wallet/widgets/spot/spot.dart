import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/views/wallet/widgets/action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_list_header.dart';
import 'package:flutter/material.dart';

class SpotTab extends StatefulWidget {
  const SpotTab({super.key});

  @override
  State<SpotTab> createState() => _SpotTabState();
}

class _SpotTabState extends State<SpotTab> {
  WalletType _selectedType = WalletType.SPOT;

  final List<({String label, WalletType type})> _tabs = [
    (label: '现货账户', type: WalletType.SPOT),
    (label: '杠杆账户', type: WalletType.MARGIN),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: _tabs.map((tab) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTabItem(tab.label, tab.type),
            )).toList(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SpotAssets(walletType: _selectedType),
                const SizedBox(height: 16),
                const ActionButtons(),
                const SizedBox(height: 16),
                const SpotListHeader(),
                SpotList(walletType: _selectedType),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String text, WalletType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
