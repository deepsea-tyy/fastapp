import 'package:fastapp/presentation/views/wallet/widgets/action_buttons.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_assets.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/spot/spot_list_header.dart';
import 'package:flutter/material.dart';

/// 现货 Tab
class SpotTab extends StatefulWidget {
  const SpotTab({super.key});

  @override
  State<SpotTab> createState() => _SpotTabState();
}

class _SpotTabState extends State<SpotTab> {
  int _selectedIndex = 0;

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
              _buildTabItem('现货账户', 0),
              const SizedBox(width: 8),
              _buildTabItem('杠杆账户(全仓)', 1),
              const SizedBox(width: 8),
              _buildTabItem('杠杆账户(逐仓)', 2),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SpotAssets(),
                const SizedBox(height: 16),
                const ActionButtons(),
                const SizedBox(height: 16),
                const SpotListHeader(),
                const SpotList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
