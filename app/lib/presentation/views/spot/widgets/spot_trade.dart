import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_order_book.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_symbol_header.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/current_orders_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/held_assets_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/spot_order_form.dart';
import 'package:fastapp/presentation/views/spot/widgets/spot/symbol_selector_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// 现货交易页面
class SpotTrade extends StatefulWidget {
  const SpotTrade({super.key});

  @override
  State<SpotTrade> createState() => _SpotTradeState();
}

class _SpotTradeState extends State<SpotTrade> {
  int _selectedBottomTab = 0;
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

  void _showSymbolSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SymbolSelectorBottomSheet(),
    );
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
        TradeSymbolHeader(
          tradeType: TradeType.spot,
          onSymbolTap: () => _showSymbolSelectorBottomSheet(context),
        ),
        // 订单表单和订单簿 - 完整显示，不裁剪
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单表单
            SizedBox(
              width: formWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: SpotOrderForm(
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
                _selectedBottomTab == 1
                    ? const HeldAssetsContent()
                    : const CurrentOrdersContent(tradeType: TradeType.spot),
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
          _buildTab('当前委托 (0)', 0),
          const SizedBox(width: 24),
          _buildTab('持有资产 (1)', 1),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.history, color: Colors.grey.shade600),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedBottomTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedBottomTab = index),
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
