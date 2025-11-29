import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 订单簿组件
class OrderBook extends StatelessWidget {
  const OrderBook({super.key});

  @override
  Widget build(BuildContext context) {
    final SpotTradeStore store = getIt<SpotTradeStore>();

    return Observer(
      builder: (_) {
        if (store.isLoadingOrderBook && store.orderBookData == null) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (store.errorMessage != null && store.orderBookData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '加载失败',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        final orderBookData = store.orderBookData;
        if (orderBookData == null) {
          return Center(
            child: Text(
              '暂无数据',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          );
        }

        return Column(
          children: [
            // 表头
            _buildHeader(context),
            const SizedBox(height: 8),
            
            // 卖盘（asks）
            Expanded(
              child: _buildSide(
                context,
                orderBookData.asks,
                isBuy: false,
                store: store,
              ),
            ),
            
            // 最新价格
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  ),
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  orderBookData.lastPrice.toStringAsFixed(2),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // 买盘（bids）
            Expanded(
              child: _buildSide(
                context,
                orderBookData.bids,
                isBuy: true,
                store: store,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '价格',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '数量',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '累计',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSide(
    BuildContext context,
    List<DepthData> depths,
    {
    required bool isBuy,
    required SpotTradeStore store,
  }) {
    if (depths.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      );
    }

    final maxQuantity = depths.map((d) => d.cumulativeQuantity).reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      reverse: isBuy, // 买盘从高到低显示
      itemCount: depths.length,
      itemBuilder: (context, index) {
        final depth = depths[index];
        final widthPercent = (depth.cumulativeQuantity / maxQuantity) * 100;

        return InkWell(
          onTap: () => store.setPriceFromOrderBook(depth.price),
          child: Container(
            height: 32,
            margin: const EdgeInsets.symmetric(vertical: 1),
            child: Stack(
              children: [
                // 背景条
                Positioned.fill(
                  child: Align(
                    alignment: isBuy ? Alignment.centerRight : Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: widthPercent / 100,
                      child: Container(
                        color: isBuy
                            ? Colors.green.withOpacity(0.1)
                            : Theme.of(context).colorScheme.error.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                
                // 内容
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          depth.price.toStringAsFixed(2),
                          style: TextStyle(
                            color: isBuy
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          depth.quantity.toStringAsFixed(4),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          depth.cumulativeQuantity.toStringAsFixed(4),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

