import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 订单簿组件
class SpotOrderBook extends StatefulWidget {
  final double? formHeight;
  
  const SpotOrderBook({super.key, this.formHeight});

  @override
  State<SpotOrderBook> createState() => _SpotOrderBookState();
}

class _SpotOrderBookState extends State<SpotOrderBook> {
  late final SpotTradeStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<SpotTradeStore>();
    // 如果数据为空且不在加载中，则加载数据
    if (_store.orderBookData == null && !_store.isLoadingOrderBook) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _store.loadOrderBookData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_store.isLoadingOrderBook && _store.orderBookData == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (_store.errorMessage != null && _store.orderBookData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.grey.shade400, size: 32),
                const SizedBox(height: 8),
                Text('加载失败', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          );
        }

        final orderBookData = _store.orderBookData;
        if (orderBookData == null) {
          return Center(
            child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          );
        }

        final parts = _store.selectedSymbol.split('/');
        final baseCurrency = parts.isNotEmpty ? parts[0] : 'TON';
        final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // 表头
              _buildHeader(quoteCurrency, baseCurrency),
              
              // 卖盘（asks）
              Expanded(
                child: _buildSideWithLayout(
                  orderBookData.asks,
                  isBuy: false,
                  store: _store,
                ),
              ),
              
              // 最新价格
              _buildCurrentPrice(orderBookData.lastPrice),
              
              // 买盘（bids）
              Expanded(
                child: _buildSideWithLayout(
                  orderBookData.bids,
                  isBuy: true,
                  store: _store,
                ),
              ),
              
              // 底部控制
              _buildBottomControls(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideWithLayout(
    List<DepthData> depths,
    {
    required bool isBuy,
    required SpotTradeStore store,
  }) {
    return Builder(
      builder: (context) {
        // 使用传入的formHeight来计算订单簿的可用高度
        final bookHeight = widget.formHeight;
        
        if (bookHeight == null || bookHeight <= 0) {
          // 如果formHeight未设置，使用默认值
          return _buildSide(
            depths,
            isBuy: isBuy,
            store: store,
            availableHeight: 200.0,
          );
        }
        
        // 计算固定元素高度
        const double headerHeight = 40.0; // 表头高度
        const double currentPriceHeight = 80.0; // 最新价格区域高度
        const double bottomControlsHeight = 32.0; // 底部控制区域高度
        const double padding = 8.0; // 上下padding
        const double totalFixedHeight = headerHeight + currentPriceHeight + bottomControlsHeight + padding * 2;
        
        // 计算买卖盘的可用高度（form高度减去固定元素高度，然后除以2）
        final availableHeight = (bookHeight - totalFixedHeight).clamp(0, double.infinity);
        final sideHeight = availableHeight > 0 ? availableHeight / 2 : 100.0; // 默认100px
        
        return _buildSide(
          depths,
          isBuy: isBuy,
          store: store,
          availableHeight: sideHeight,
        );
      },
    );
  }

  Widget _buildHeader(String quoteCurrency, String baseCurrency) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '价格 ($quoteCurrency)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              '数量 ($baseCurrency)',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSide(
    List<DepthData> depths,
    {
    required bool isBuy,
    required SpotTradeStore store,
    required double availableHeight,
  }) {
    if (depths.isEmpty) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      );
    }

    const double itemHeight = 28.0;
    
    // 根据可用高度计算可以显示多少条数据
    int displayCount;
    if (availableHeight.isFinite && availableHeight > 0) {
      // 计算可以显示多少条数据
      final itemCount = (availableHeight / itemHeight).floor();
      displayCount = itemCount > 0 ? itemCount : 1;
      // 限制最大显示数量，避免显示过多
      displayCount = displayCount > 50 ? 50 : displayCount;
    } else {
      // 如果高度未确定，使用默认数量
      displayCount = 7;
    }
    
    // 取需要显示的数据量
    var displayDepths = depths.take(displayCount).toList();
    if (isBuy) {
      displayDepths = displayDepths.reversed.toList();
    }
    
    if (displayDepths.isEmpty) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      );
    }

    final maxQuantity = displayDepths.map((d) => d.quantity).reduce((a, b) => a > b ? a : b);

    final items = displayDepths.map((depth) {
      final widthPercent = (depth.quantity / maxQuantity) * 100;
      return Expanded(
        child: InkWell(
          onTap: () => store.setPriceFromOrderBook(depth.price),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              children: [
                // 背景条（从右侧开始）
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: widthPercent / 100,
                      child: Container(
                        color: isBuy
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                
                // 内容
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        depth.price.toStringAsFixed(3),
                        style: TextStyle(
                          color: isBuy ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatQuantity(depth.quantity),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: items,
    );
  }

  Widget _buildCurrentPrice(double price) {
    final cnyPrice = price * 7.08; // 假设汇率
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            price.toStringAsFixed(3),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '≈ ¥${cnyPrice.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return GestureDetector(
      onTap: () {
        // TODO: 显示精度选择
      },
      child: Container(
        width: double.infinity,
        height: 32.0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0.001', style: TextStyle(fontSize: 12, color: Colors.black87)),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  String _formatQuantity(double quantity) {
    if (quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(2)}K';
    } else {
      return quantity.toStringAsFixed(2);
    }
  }
}
