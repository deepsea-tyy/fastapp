import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 订单簿组件（通用）
class TradeOrderBook extends StatefulWidget {
  final double? formHeight;

  const TradeOrderBook({super.key, this.formHeight});

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

  // 计算固定元素高度
  static const double _headerHeight = 40.0;
  static const double _currentPriceHeight = 80.0;
  static const double _bottomControlsHeight = 32.0;
  static const double _padding = 8.0;
  // 调试边距：horizontal: 4, vertical: 2，所以垂直边距是 2 * 2 = 4
  static const double _debugPaddingVertical = 4.0; // vertical: 2 * 2，每个 Padding 上下各 2
  // 固定元素总高度：表头 + 最新价格 + 底部控制 + 表头上下padding + 3个调试Padding的垂直边距
  static const double _totalFixedHeight =
      _headerHeight + _currentPriceHeight + _bottomControlsHeight + _padding * 2 + _debugPaddingVertical * 3;

  // 计算买卖盘的可用高度
  double _calculateSideHeight() {
    final bookHeight = widget.formHeight;
    if (bookHeight == null || bookHeight <= 0) {
      return 200.0 / 2; // 默认高度的一半
    }
    final availableHeight = (bookHeight - _totalFixedHeight).clamp(0, double.infinity);
    return availableHeight > 0 ? availableHeight / 2 : 100.0;
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

        // 计算买卖盘高度
        final sideHeight = _calculateSideHeight();
        
        // 计算订单簿总高度（如果 formHeight 存在，使用它；否则使用计算出的高度）
        final totalBookHeight = widget.formHeight != null && widget.formHeight! > 0
            ? widget.formHeight!
            : _totalFixedHeight + sideHeight * 2;

        return SizedBox(
          height: totalBookHeight,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // 表头
              _buildHeader(quoteCurrency, baseCurrency),

              // 卖盘（asks）- 靠上显示
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                child: SizedBox(
                  height: sideHeight,
                  child: ClipRect(
                    clipBehavior: Clip.hardEdge,
                    child: _buildSide(
                      orderBookData.asks,
                      isBuy: false,
                      store: _store,
                      availableHeight: sideHeight - 4, // 减去 padding 的垂直边距
                    ),
                  ),
                ),
              ),

              // 使用 Expanded 让最新价格在买卖盘之间居中，上下留白均匀
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildCurrentPrice(orderBookData.lastPrice),
                  ),
                ),
              ),

              // 买盘（bids）- 靠下显示
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                child: SizedBox(
                  height: sideHeight,
                  child: ClipRect(
                    clipBehavior: Clip.hardEdge,
                    child: _buildSide(
                      orderBookData.bids,
                      isBuy: true,
                      store: _store,
                      availableHeight: sideHeight - 4, // 减去 padding 的垂直边距
                    ),
                  ),
                ),
              ),

              // 底部控制
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
                child: _buildBottomControls(),
              ),
            ],
          ),
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

  Widget _buildSide(
    List<DepthData> depths, {
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
      final itemCount = (availableHeight / itemHeight).floor();
      displayCount = itemCount > 0 ? itemCount : 1;
      displayCount = displayCount > 50 ? 50 : displayCount; // 限制最大显示数量
    } else {
      displayCount = 7; // 默认数量
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

    // 使用 Column 而不是 ListView，因为我们有固定高度和固定数量的项目
    // 这样可以避免 ListView 的布局问题
    // 使用 mainAxisSize.max 确保占满可用空间，减少留白
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: displayDepths.map((depth) {
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
      }).toList(),
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
