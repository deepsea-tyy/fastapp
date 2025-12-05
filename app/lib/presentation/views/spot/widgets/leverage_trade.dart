import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/current_orders_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/held_assets_content.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/leverage_order_book.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/leverage_order_form.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/symbol_header.dart';
import 'package:flutter/material.dart';

/// 杠杆交易页面
class LeverageTrade extends StatefulWidget {
  const LeverageTrade({super.key});

  @override
  State<LeverageTrade> createState() => _LeverageTradeState();
}

class _LeverageTradeState extends State<LeverageTrade> {
  int _selectedBottomTab = 0; // 当前委托标签选中
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
                          child: SpotOrderForm(
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
                              child: LeverageOrderBook(formHeight: _formHeight),
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
                _selectedBottomTab == 1
                    ? const HeldAssetsContent()
                    : const CurrentOrdersContent(),
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
          _buildTab('仓位 (1)', 1),
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
