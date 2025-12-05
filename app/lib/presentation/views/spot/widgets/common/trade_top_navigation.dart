import 'package:fastapp/presentation/views/spot/widgets/common/trade_menu.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:flutter/material.dart';

/// 交易顶部导航栏组件
class TradeTopNavigation extends StatefulWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onMenuPressed;
  final VoidCallback? onC2CPressed; // 新增C2C点击回调

  const TradeTopNavigation({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onMenuPressed,
    this.onC2CPressed,
  });

  @override
  State<TradeTopNavigation> createState() => _TradeTopNavigationState();
}

class _TradeTopNavigationState extends State<TradeTopNavigation> {
  final GlobalKey _menuButtonKey = GlobalKey();

  void _showMenu(BuildContext context) {
    TradeMenu.show(context, buttonKey: _menuButtonKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTopTab('闪兑', 0, false),
          const SizedBox(width: 16),
          _buildTopTab('现货', 1, false),
          const SizedBox(width: 16),
          _buildTopTab('杠杆', 2, false),
          const SizedBox(width: 16),
          _buildTopTab('C2C', 3, true), // C2C tab 作为导航链接
          const Spacer(),
          IconButton(
            key: _menuButtonKey,
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTab(String label, int index, bool isNavigationLink) {
    final isSelected = widget.selectedTab == index;
    return GestureDetector(
      onTap: () {
        if (isNavigationLink && label == 'C2C') {
          // C2C tab 直接导航到C2C页面
          if (widget.onC2CPressed != null) {
            widget.onC2CPressed!();
          } else {
            // 默认导航行为
            Navigator.of(context).pushNamed(Routes.c2c);
          }
        } else {
          // 普通tab切换
          widget.onTabChanged(index);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }
}
