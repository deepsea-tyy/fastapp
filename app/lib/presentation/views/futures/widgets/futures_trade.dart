import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/current_orders_content.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/held_positions_content.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/futures_order_form.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/symbol_header.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_order_book.dart';
import 'package:fastapp/presentation/views/grid/grid_trading_screen.dart';
import 'package:flutter/material.dart';

/// 期货交易页面（复制自杠杆交易）
class FuturesTrade extends StatefulWidget {
  final bool isCoinMargined; // true: 币本位, false: U本位
  
  const FuturesTrade({
    super.key,
    this.isCoinMargined = false,
  });

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

  @override
  Widget build(BuildContext context) {
    // 使用 MediaQuery 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final totalPadding = 8.0 + 8.0; // 左padding + 中间间距（订单簿右边没有边距）
    final usableWidth = screenWidth - totalPadding;
    
    // 按照 3:2 的比例分配宽度
    final formWidth = usableWidth * 3 / 5;
    final bookWidth = usableWidth * 2 / 5;
    
    // 延迟更新高度，避免在 build 中频繁调用 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateFormHeight();
      }
    });

    return Column(
      children: [
        // 交易对头部
        SymbolHeader(isCoinMargined: widget.isCoinMargined),
        // 订单表单和订单簿 - 完整显示，不裁剪
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单表单
            SizedBox(
              width: formWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: FuturesOrderForm(
                  key: _formKey,
                  onHeightChanged: _updateFormHeight,
                ),
              ),
            ),
            // 订单簿
            SizedBox(
              width: bookWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                  ),
                  child: TradeOrderBook(formHeight: _formHeight),
                ),
              ),
            ),
          ],
        ),
        // 可滚动内容区域
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }
}
