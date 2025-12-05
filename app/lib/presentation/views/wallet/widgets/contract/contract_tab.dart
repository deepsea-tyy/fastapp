import 'package:fastapp/presentation/views/wallet/widgets/contract/contract_action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/contract/contract_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/contract/contract_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/contract/contract_list_header.dart';
import 'package:flutter/material.dart';

/// 合约 Tab
class ContractTab extends StatefulWidget {
  const ContractTab({super.key});

  @override
  State<ContractTab> createState() => _ContractTabState();
}

class _ContractTabState extends State<ContractTab> {
  int _selectedIndex = 0;
  String _selectedSubTab = '持有仓位';

  Widget _buildTabItem(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildTabItem('U本位', 0),
              const SizedBox(width: 8),
              _buildTabItem('币本位', 1),
              const SizedBox(width: 8),
              _buildTabItem('期权', 2),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ContractAssets(),
                const SizedBox(height: 16),
                const ContractActionButtons(),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(minHeight: 300),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContractListHeader(
                        selectedTab: _selectedSubTab,
                        onTabChanged: (tab) {
                          setState(() {
                            _selectedSubTab = tab;
                          });
                        },
                      ),
                      ContractList(selectedTab: _selectedSubTab),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
