import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 订单簿组件（通用）
class TradeOrderBook extends StatefulWidget {
  const TradeOrderBook({super.key});

  @override
  State<TradeOrderBook> createState() => _TradeOrderBookState();
}

class _TradeOrderBookState extends State<TradeOrderBook> {
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

  // 固定的买卖盘显示行数
  static const int _displayItemCount = 7;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {

        if (_store.isLoadingOrderBook && _store.orderBookData == null) {
          return Container(
            height: 400,
            color: Colors.grey.shade100,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 16),
                  Text('加载订单簿...', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          );
        }

        if (_store.errorMessage != null && _store.orderBookData == null) {
          return Container(
            height: 400,
            color: Colors.red.shade50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                    const SizedBox(height: 16),
                    const Text('加载失败', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text(
                      _store.errorMessage ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _store.loadOrderBookData();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final orderBookData = _store.orderBookData;
        if (orderBookData == null) {
          return Container(
            height: 400,
            color: Colors.yellow.shade50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 48),
                  const SizedBox(height: 16),
                  const Text('暂无数据', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _store.loadOrderBookData();
                    },
                    child: const Text('加载数据'),
                  ),
                ],
              ),
            ),
          );
        }


        final parts = _store.selectedSymbol.split('/');
        final baseCurrency = parts.isNotEmpty ? parts[0] : 'TON';
        final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';

        // 使用 LayoutBuilder 获取可用高度，动态显示订单数量
        return LayoutBuilder(
          builder: (context, constraints) {

            // 计算固定元素的高度
            const headerHeight = 40.0;
            const priceHeight = 60.0;
            const controlsHeight = 40.0;
            const padding = 20.0;
            const itemHeight = 28.0;

            final fixedHeight = headerHeight + priceHeight + controlsHeight + padding;
            final availableForOrders = (constraints.maxHeight - fixedHeight).clamp(100.0, double.infinity);

            // 每边可用高度的一半
            final sideHeight = availableForOrders / 2;
            final itemsPerSide = (sideHeight / itemHeight).floor().clamp(3, 20);


            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // 表头
                _buildHeader(quoteCurrency, baseCurrency),

                // 卖盘（asks）
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                    child: _buildSideScrollable(
                      orderBookData.asks,
                      isBuy: false,
                      store: _store,
                      maxItems: itemsPerSide,
                    ),
                  ),
                ),

                // 最新价格
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: _buildCurrentPrice(orderBookData.lastPrice),
                ),

                // 买盘（bids）
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                    child: _buildSideScrollable(
                      orderBookData.bids,
                      isBuy: true,
                      store: _store,
                      maxItems: itemsPerSide,
                    ),
                  ),
                ),

                // 底部控制
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                  child: _buildBottomControls(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(String quoteCurrency, String baseCurrency) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 0, 8),
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

  Widget _buildSideScrollable(
    List<DepthData> depths, {
    required bool isBuy,
    required SpotTradeStore store,
    required int maxItems,
  }) {
    if (depths.isEmpty) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      );
    }

    const double itemHeight = 28.0;

    // 取需要显示的数据
    var displayDepths = depths.take(maxItems).toList();
    if (isBuy) {
      displayDepths = displayDepths.reversed.toList();
    }

    if (displayDepths.isEmpty) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      );
    }

    final maxQuantity = displayDepths.map((d) => d.quantity).reduce((a, b) => a > b ? a : b);

    // 使用 ListView.builder 填充 Expanded 空间
    return ListView.builder(
      itemCount: displayDepths.length,
      itemExtent: itemHeight,
      itemBuilder: (context, index) => _buildDepthItem(
        displayDepths[index],
        isBuy,
        store,
        maxQuantity,
        itemHeight,
      ),
    );
  }

  Widget _buildSide(
    List<DepthData> depths, {
    required bool isBuy,
    required SpotTradeStore store,
  }) {
    if (depths.isEmpty) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      );
    }

    const double itemHeight = 28.0;

    // 使用固定的显示数量
    var displayDepths = depths.take(_displayItemCount).toList();
    if (isBuy) {
      displayDepths = displayDepths.reversed.toList();
    }

    if (displayDepths.isEmpty) {
      return Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      );
    }

    final maxQuantity = displayDepths.map((d) => d.quantity).reduce((a, b) => a > b ? a : b);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: displayDepths
          .map((depth) => _buildDepthItem(depth, isBuy, store, maxQuantity, itemHeight))
          .toList(),
    );
  }

  Widget _buildDepthItem(
    DepthData depth,
    bool isBuy,
    SpotTradeStore store,
    double maxQuantity,
    double itemHeight,
  ) {
    final widthPercent = (depth.quantity / maxQuantity) * 100;
    return SizedBox(
      height: itemHeight,
      child: InkWell(
        onTap: () => store.setPriceFromOrderBook(depth.price),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
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
  }

  Widget _buildCurrentPrice(double price) {
    final cnyPrice = price * 7.08; // 假设汇率

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6), // 减小上下间距，紧凑排版
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 紧凑排版
        children: [
          Text(
            price.toStringAsFixed(3),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 2), // 减小间距
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
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
