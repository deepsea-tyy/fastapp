import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:flutter/material.dart';

/// 交易页面容器组件
/// 封装了 SpotTrade 和 LeverageTrade 的公共逻辑
class TradeContainer extends StatefulWidget {
  /// 交易类型
  final TradeType tradeType;

  /// 交易对头部组件
  final Widget symbolHeader;

  /// 订单表单组件构建器
  final Widget Function(GlobalKey formKey, VoidCallback onHeightChanged) orderFormBuilder;

  /// 订单簿组件构建器
  final Widget Function(double? formHeight) orderBookBuilder;

  /// 当前委托内容组件
  final Widget currentOrdersContent;

  /// 持有资产/仓位内容组件
  final Widget heldAssetsContent;

  /// 当前委托数量
  final int currentOrdersCount;

  /// 持有资产/仓位数量
  final int heldAssetsCount;

  const TradeContainer({
    super.key,
    required this.tradeType,
    required this.symbolHeader,
    required this.orderFormBuilder,
    required this.orderBookBuilder,
    required this.currentOrdersContent,
    required this.heldAssetsContent,
    this.currentOrdersCount = 0,
    this.heldAssetsCount = 0,
  });

  @override
  State<TradeContainer> createState() => _TradeContainerState();
}

class _TradeContainerState extends State<TradeContainer> {
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

  @override
  Widget build(BuildContext context) {
    // 使用 MediaQuery 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final totalPadding = 8.0 + 8.0 + 8.0; // 左padding + 中间间距 + 右padding
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
        widget.symbolHeader,
        // 订单表单和订单簿 - 固定在顶部，不滚动
        // 使用 Flexible 限制高度，LayoutBuilder 获取可用高度，ConstrainedBox 限制表单高度
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 获取可用高度（减去 padding）
              final availableHeight = constraints.maxHeight - 8; // 减去底部 padding
              return ClipRect(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 订单表单
                    SizedBox(
                      width: formWidth,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: SizedBox(
                          height: availableHeight,
                          child: ClipRect(
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              alignment: Alignment.topCenter,
                              child: widget.orderFormBuilder(_formKey, _updateFormHeight),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 订单簿
                    SizedBox(
                      width: bookWidth,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
                          ),
                          child: widget.orderBookBuilder(_formHeight),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
                    ? widget.heldAssetsContent
                    : widget.currentOrdersContent,
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
          _buildTab('当前委托 (${widget.currentOrdersCount})', 0),
          const SizedBox(width: 24),
          _buildTab('${widget.tradeType.positionTabLabel} (${widget.heldAssetsCount})', 1),
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
