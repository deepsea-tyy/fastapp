import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/order/order.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/entity/order/order_status.dart';
import 'package:fastapp/presentation/store/orders/order_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/empty_balance_state.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/trade_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 当前委托内容组件
/// 
/// 显示当前可取消的订单列表（待成交、部分成交）
class CurrentOrdersContent extends StatelessWidget {
  final TradeType tradeType;
  final bool hasBalance;
  final VoidCallback? onAddBalance;

  const CurrentOrdersContent({
    super.key,
    required this.tradeType,
    this.hasBalance = false,
    this.onAddBalance,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasBalance) {
      return EmptyBalanceState(
        tradeType: tradeType,
        onAddBalance: onAddBalance,
      );
    }

    // 有余额时显示订单列表
    return Observer(
      builder: (_) {
        final orderStore = getIt<OrderStore>();
        final currentOrders = orderStore.currentOrders;

        if (orderStore.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (currentOrders.isEmpty) {
          return _buildEmptyState();
        }

        return _buildOrderList(context, currentOrders, orderStore);
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无当前委托',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Order> orders, OrderStore orderStore) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(context, order, orderStore);
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order, OrderStore orderStore) {
    final isBuy = order.side == OrderSide.buy;
    final statusText = _getStatusText(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBuy ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isBuy ? '买入' : '卖出',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isBuy ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('价格', order.price?.toStringAsFixed(4) ?? '-'),
                _buildInfoItem('数量', order.quantity.toStringAsFixed(4)),
                _buildInfoItem('总额', (order.price != null ? order.price! * order.quantity : order.filledAmount).toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: orderStore.isCancelling
                      ? null
                      : () => _handleCancelOrder(context, order, orderStore),
                  child: orderStore.isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('取消'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '待成交';
      case OrderStatus.partiallyFilled:
        return '部分成交';
      case OrderStatus.filled:
        return '已成交';
      case OrderStatus.cancelled:
        return '已取消';
      case OrderStatus.rejected:
        return '已拒绝';
      case OrderStatus.expired:
        return '已过期';
    }
  }

  Future<void> _handleCancelOrder(BuildContext context, Order order, OrderStore orderStore) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认取消'),
        content: Text('确定要取消订单 ${order.id} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await orderStore.cancelOrder(order.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('订单已取消')),
        );
      }
    }
  }
}
