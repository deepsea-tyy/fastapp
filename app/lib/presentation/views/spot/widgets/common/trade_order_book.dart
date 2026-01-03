import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

/// 订单簿组件（通用）
/// 
/// 重新设计的订单簿，具有以下特性：
/// - 清晰的视觉层次
/// - 累计深度显示
/// - 优化的颜色方案
/// - 更好的交互体验
/// - 现货不显示标记价格，期货/杠杆显示标记价格
/// - 直接使用 DepthStore 确保实时更新
class TradeOrderBook extends StatefulWidget {
  final TradeType tradeType;

  const TradeOrderBook({
    super.key,
    this.tradeType = TradeType.spot,
  });

  @override
  State<TradeOrderBook> createState() => _TradeOrderBookState();
}

class _TradeOrderBookState extends State<TradeOrderBook> {
  late final SpotTradeStore _spotTradeStore;
  late final DepthStore _depthStore;
  double? _previousPrice;
  ReactionDisposer? _symbolReaction;
  ReactionDisposer? _priceReaction;

  @override
  void initState() {
    super.initState();
    _spotTradeStore = getIt<SpotTradeStore>();
    _depthStore = getIt<DepthStore>();

    final symbol = _spotTradeStore.selectedSymbol;
    print('[TradeOrderBook] initState: symbol=$symbol, depthStore.currentSymbol=${_depthStore.currentSymbol}, isSubscribed=${_depthStore.isSubscribed}');

    // 注意：DepthStore 的订阅由 SpotTrade 统一管理，这里不重复设置
    // 这样避免重复订阅和时序问题

    // 监听交易对变化（仅用于日志）
    _symbolReaction = reaction(
      (_) => _spotTradeStore.selectedSymbol,
      (symbol) {
        print('[TradeOrderBook] symbol changed: $symbol, depthStore.currentSymbol=${_depthStore.currentSymbol}');
      },
    );

    // 监听价格变化
    _priceReaction = reaction(
      (_) => _depthStore.depthData?.lastPrice,
      (double? newPrice) {
        if (mounted && newPrice != null) {
          setState(() {
            _previousPrice = newPrice;
          });
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final depthData = _depthStore.depthData;
        final selectedSymbol = _spotTradeStore.selectedSymbol;
        
        print('[TradeOrderBook] build: depthData=${depthData != null}, currentSymbol=${_depthStore.currentSymbol}, selectedSymbol=$selectedSymbol, isSubscribed=${_depthStore.isSubscribed}, isLoading=${_depthStore.isLoading}');

        if (_depthStore.isLoading && depthData == null) {
          print('[TradeOrderBook] build: showing loading state');
          return _buildLoadingState();
        }

        if (_depthStore.errorMessage != null && depthData == null) {
          print('[TradeOrderBook] build: showing error state: ${_depthStore.errorMessage}');
          return _buildErrorState();
        }

        // 只检查 depthData 是否为空，symbol 同步由 SpotTrade 管理
        // 移除 symbol 匹配检查，避免数据加载过程中误判为空状态
        if (depthData == null) {
          print('[TradeOrderBook] build: showing empty state - depthData is null');
          return _buildEmptyState();
        }
        
        print('[TradeOrderBook] build: rendering data - bids=${depthData.bids.length}, asks=${depthData.asks.length}');

        final bids = depthData.bids;
        final asks = depthData.asks;
        final lastPrice = depthData.lastPrice;
        final timestamp = depthData.timestamp;

        // 计算价格变化（用于UI显示）
        final priceChanged = _previousPrice != null && _previousPrice != lastPrice;

        return LayoutBuilder(
            builder: (context, constraints) {
              // 计算固定元素的高度
              const priceHeight = 40.0;
              const itemHeight = 24.0;

              final availableForOrders = (constraints.maxHeight - priceHeight).clamp(80.0, double.infinity);
              final sideHeight = availableForOrders / 2;
              final itemsPerSide = (sideHeight / itemHeight).floor().clamp(3, 25);

            return Column(
              key: ValueKey('orderbook_$timestamp'),
              mainAxisSize: MainAxisSize.max,
              children: [
                // 卖盘（asks）- 从上到下价格递增
                Expanded(
                  child: _buildOrderSide(
                    asks,
                    isBuy: false,
                    maxItems: itemsPerSide,
                  ),
                ),

                // 最新价格区域（简化版）
                _buildSimplePriceSection(lastPrice, priceChanged, _previousPrice),

                // 买盘（bids）- 从下到上价格递减
                Expanded(
                  child: _buildOrderSide(
                    bids,
                    isBuy: true,
                    maxItems: itemsPerSide,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
            SizedBox(height: 12),
            Text(
              '加载订单簿...',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
            const SizedBox(height: 12),
            const Text(
              '加载失败',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              _depthStore.errorMessage ?? '',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _depthStore.loadDepthData(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('重试', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 40),
            const SizedBox(height: 12),
            const Text(
              '暂无数据',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _depthStore.loadDepthData(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('加载数据', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }


  /// 构建订单一侧（买盘或卖盘）
  Widget _buildOrderSide(
    List<DepthData> depths, {
    required bool isBuy,
    required int maxItems,
  }) {
    if (depths.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      );
    }

    // 取需要显示的数据
    var displayDepths = depths.take(maxItems).toList();
    if (isBuy) {
      // 买盘：价格从高到低显示，需要反转
      displayDepths = displayDepths.reversed.toList();
    }

    if (displayDepths.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      );
    }

    // 计算最大累计数量用于背景条显示
    final maxCumulative = displayDepths
        .map((d) => d.cumulativeQuantity)
        .reduce((a, b) => a > b ? a : b);

    final listView = ListView.builder(
      key: ValueKey(isBuy ? 'bids_list' : 'asks_list'),
      physics: const ClampingScrollPhysics(),
      itemCount: displayDepths.length,
      itemExtent: 24.0,
      shrinkWrap: false,
      itemBuilder: (context, index) {
        final depth = displayDepths[index];
        return _buildOrderItem(
          depth,
          isBuy: isBuy,
          maxCumulative: maxCumulative,
        );
      },
    );
    
    return listView;
  }

  /// 构建单个订单项（简化版：只显示价格和数量）
  Widget _buildOrderItem(
    DepthData depth, {
    required bool isBuy,
    required double maxCumulative,
  }) {
    final widthPercent = (depth.cumulativeQuantity / maxCumulative) * 100;
    final color = isBuy ? Colors.green : Colors.red;
    final bgColor = isBuy 
        ? Colors.green.withValues(alpha: 0.08)
        : Colors.red.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _spotTradeStore.setPriceFromOrderBook(depth.price),
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            children: [
              // 背景条（从左侧开始，表示累计深度）
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: widthPercent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(2),
                          bottomRight: const Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 内容：只显示价格和数量
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 价格
                  Text(
                    _formatPrice(depth.price),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  // 数量
                  Expanded(
                    child: Text(
                      _formatQuantity(depth.quantity),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
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

  /// 构建简化版价格区域（只显示价格）
  Widget _buildSimplePriceSection(
    double lastPrice,
    bool priceChanged,
    double? previousPrice,
  ) {
    final isUp = previousPrice != null && lastPrice > previousPrice;
    final lastPriceColor = priceChanged
        ? (isUp ? Colors.green.shade700 : Colors.red.shade700)
        : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatPrice(lastPrice),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: lastPriceColor,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          if (priceChanged && previousPrice != null) ...[
            const SizedBox(width: 6),
            Icon(
              isUp ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: lastPriceColor,
            ),
          ],
        ],
      ),
    );
  }

  /// 格式化价格
  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(3);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  /// 格式化数量
  String _formatQuantity(double quantity) {
    if (quantity >= 1000000) {
      return '${(quantity / 1000000).toStringAsFixed(2)}M';
    } else if (quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(2)}K';
    } else if (quantity >= 1) {
      return quantity.toStringAsFixed(2);
    } else if (quantity >= 0.01) {
      return quantity.toStringAsFixed(4);
    } else {
      return quantity.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    // 清理 reactions
    _symbolReaction?.call();
    _priceReaction?.call();
    super.dispose();
  }
}
