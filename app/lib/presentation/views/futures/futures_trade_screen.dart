import 'package:fastapp/presentation/views/futures/options_trade_screen.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures_trade.dart';
import 'package:flutter/material.dart';

/// 永续合约交易页面
class FuturesTradeScreen extends StatefulWidget {
  const FuturesTradeScreen({super.key});

  @override
  State<FuturesTradeScreen> createState() => _FuturesTradeScreenState();
}

class _FuturesTradeScreenState extends State<FuturesTradeScreen> {
  int _selectedTopTab = 0; // 0: U本位, 1: 币本位, 2: 期权
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopNavigation(context),
            
            // 内容区域
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTopTab) {
      case 0:
        return const FuturesTrade(); // U本位
      case 1:
        return const Center(child: Text('币本位功能开发中')); // 币本位（暂未实现）
      // case 2 是期权，但不会到达这里，因为期权点击时会跳转新页面
      default:
        return const FuturesTrade();
    }
  }

  Widget _buildTopNavigation(BuildContext context) {
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
          _buildTopTab('U本位', 0),
          const SizedBox(width: 16),
          _buildTopTab('币本位', 1),
          const SizedBox(width: 16),
          _buildTopTab('期权', 2),
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

  Widget _buildTopTab(String label, int index) {
    final isSelected = _selectedTopTab == index;
    return GestureDetector(
      onTap: () {
        if (index == 2) {
          // 点击期权，跳转到期权交易页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OptionsTradeScreen(),
            ),
          );
        } else {
          setState(() {
            _selectedTopTab = index;
          });
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

  void _showMenu(BuildContext context) {
    RenderBox? button;
    if (_menuButtonKey.currentContext != null) {
      button = _menuButtonKey.currentContext!.findRenderObject() as RenderBox?;
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
            // TODO: 处理交易机器人功能
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

  PopupMenuItem<void> _buildMenuItem({
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

