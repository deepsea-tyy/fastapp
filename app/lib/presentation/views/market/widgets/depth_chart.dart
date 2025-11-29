import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/presentation/store/market/depth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 深度图组件
class DepthChart extends StatelessWidget {
  const DepthChart({super.key});

  @override
  Widget build(BuildContext context) {
    final DepthStore _store = getIt<DepthStore>();

    return Observer(
      builder: (_) {
        if (_store.isLoading && _store.depthData == null) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (_store.errorMessage != null && _store.depthData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _store.errorMessage ?? '加载失败',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _store.refreshDepthData(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final depthData = _store.depthData;
        if (depthData == null) {
          return Center(
            child: Text(
              '暂无数据',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14.0,
              ),
            ),
          );
        }

        return Column(
          children: [
            // 最新价格显示
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '最新价: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    depthData.lastPrice.toStringAsFixed(2),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // 深度图
            Expanded(
              child: Row(
                children: [
                  // 买盘（左侧）
                  Expanded(
                    child: _buildDepthSide(
                      context,
                      depthData.bids,
                      isBuy: true,
                    ),
                  ),
                  
                  // 分隔线
                  Container(
                    width: 1,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  
                  // 卖盘（右侧）
                  Expanded(
                    child: _buildDepthSide(
                      context,
                      depthData.asks,
                      isBuy: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDepthSide(BuildContext context, List<DepthData> depths, {required bool isBuy}) {
    final maxQuantity = depths.isNotEmpty
        ? depths.map((d) => d.cumulativeQuantity).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return ListView.builder(
      reverse: isBuy, // 买盘从高到低显示
      itemCount: depths.length,
      itemBuilder: (context, index) {
        final depth = depths[index];
        final widthPercent = (depth.cumulativeQuantity / maxQuantity) * 100;

        return Container(
          height: 30,
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
                          ? Colors.green.withOpacity(0.2)
                          : Theme.of(context).colorScheme.error.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              
              // 内容
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      depth.price.toStringAsFixed(2),
                      style: TextStyle(
                        color: isBuy ? Colors.green : Theme.of(context).colorScheme.error,
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      depth.quantity.toStringAsFixed(4),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

