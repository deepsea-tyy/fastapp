import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/order/order.dart';
import 'package:fastapp/presentation/store/orders/order_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

/// 订单列表组件
class OrderList extends StatelessWidget {
  final List<Order> orders;
  final bool showCancelButton;

  const OrderList({
    super.key,
    required this.orders,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final OrderStore store = getIt<OrderStore>();

    if (orders.isEmpty) {
      return Center(
        child: Text(
          '暂无订单',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => store.refreshOrders(),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderItem(context, order, store);
        },
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order, OrderStore store) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final isBuy = order.side.name == 'buy';
    final fillPercent = order.quantity > 0
        ? (order.filledQuantity / order.quantity * 100)
        : 0.0;

    return InkWell(
      onTap: () {
        // 可以导航到详情页面
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单头部信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBuy
                            ? Colors.green.withOpacity(0.1)
                            : Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isBuy ? '买入' : '卖出',
                        style: TextStyle(
                          color: isBuy
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.symbol,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(context, order.status),
              ],
            ),
            const SizedBox(height: 8),
            
            // 订单详情
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '价格',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.price != null
                            ? order.price!.toStringAsFixed(2)
                            : '市价',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '数量',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.quantity.toStringAsFixed(4),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '已成交',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${fillPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 时间信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(DateTime.fromMillisecondsSinceEpoch(order.createdAt)),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                if (showCancelButton && order.canCancel)
                  TextButton(
                    onPressed: () => _showCancelDialog(context, order, store),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, orderStatus) {
    Color color;
    String text;

    switch (orderStatus) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = '待成交';
        break;
      case OrderStatus.partiallyFilled:
        color = Colors.blue;
        text = '部分成交';
        break;
      case OrderStatus.filled:
        color = Colors.green;
        text = '已成交';
        break;
      case OrderStatus.cancelled:
        color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        text = '已取消';
        break;
      case OrderStatus.rejected:
        color = Theme.of(context).colorScheme.error;
        text = '已拒绝';
        break;
      case OrderStatus.expired:
        color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        text = '已过期';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Order order, OrderStore store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取消订单'),
        content: Text('确定要取消订单 ${order.id} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await store.cancelOrder(order.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('订单取消成功')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(store.errorMessage ?? '订单取消失败'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

