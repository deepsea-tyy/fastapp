import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/spot/spot_strategy_market_screen.dart';

/// 交易菜单组件
class TradeMenu {
  static void show(BuildContext context, {GlobalKey? buttonKey}) {
    RenderBox? button;
    if (buttonKey?.currentContext != null) {
      button = buttonKey!.currentContext!.findRenderObject() as RenderBox?;
    } else {
      button = context.findRenderObject() as RenderBox?;
    }
    
    if (button == null) return;
    
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + button.size.width - 180,
        position.dy + button.size.height,
        position.dx + button.size.width + 20,
        position.dy + button.size.height,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white,
      items: [
        _buildMenuItem(
          icon: Icons.people_alt_outlined,
          label: '跟单',
          onTap: () {
            Navigator.pop(context);
            // TODO: 处理跟单功能
          },
        ),
        _buildMenuItem(
          icon: Icons.smart_toy_outlined,
          label: '交易机器人',
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SpotStrategyMarketScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.edit_document,
          label: '功能管理',
          onTap: () {
            Navigator.pop(context);
            // TODO: 处理功能管理
          },
        ),
      ],
    );
  }

  static PopupMenuItem<void> _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem<void>(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
