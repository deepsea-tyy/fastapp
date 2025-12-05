import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/current_orders_content.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/held_positions_content.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/futures_order_book.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/futures_order_form.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/symbol_header.dart';
import 'package:fastapp/presentation/views/grid/grid_trading_screen.dart';
import 'package:flutter/material.dart';

/// 期货交易页面（复制自杠杆交易）
class FuturesTrade extends StatefulWidget {
  const FuturesTrade({super.key});

  @override
  State<FuturesTrade> createState() => _FuturesTradeState();
}

class _FuturesTradeState extends State<FuturesTrade> {
  int _selectedBottomTab = 0; // 0: 持有仓位, 1: 当前委托, 2: 合约网格
  final GlobalKey _formKey = GlobalKey();
  double? _formHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormHeight();
    });
  }

  void _updateFormHeight() {
    if (_formKey.currentContext != null) {
      final RenderBox? renderBox = _formKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final newHeight = renderBox.size.height;
        if (_formHeight != newHeight && newHeight > 0) {
          if (mounted) {
            setState(() {
              _formHeight = newHeight;
            });
          }
        }
      }
    }
  }

  void _scheduleHeightUpdate() {
    // 使用 addPostFrameCallback 确保在布局完成后更新高度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormHeight();
      // 再次调度一次，确保在动画完成后也能更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFormHeight();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 在每次构建后检查form高度
    _scheduleHeightUpdate();

    return Column(
      children: [
        // 交易对头部
        const SymbolHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 订单表单和订单簿（始终显示）
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: FuturesOrderForm(
                            key: _formKey,
                            onHeightChanged: _updateFormHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: FuturesOrderBook(formHeight: _formHeight),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 标签栏
                _buildTabs(),
                // 根据选中的标签显示对应内容
                _selectedBottomTab == 0
                    ? const HeldPositionsContent()
                    : _selectedBottomTab == 1
                        ? const CurrentOrdersContent()
                        : const Center(child: Text('合约网格功能开发中')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTab('持有仓位 (0)', 0),
          const SizedBox(width: 24),
          _buildTab('当前委托 (0)', 1),
          const SizedBox(width: 24),
          _buildTab('合约网格', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedBottomTab == index;
    return InkWell(
      onTap: () {
        if (index == 2) {
          // 点击合约网格跳转到交易机器人页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GridTradingScreen(),
            ),
          );
        } else {
          setState(() => _selectedBottomTab = index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
