import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/domain/entity/order/order.dart';
import 'package:fastapp/domain/entity/order/order_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 订单详情组件
class OrderDetail extends StatelessWidget {
  final Order order;
  final VoidCallback? onCancel;

  const OrderDetail({
    super.key,
    required this.order,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final isBuy = order.side.name == 'buy';
    final fillPercent = order.quantity > 0
        ? (order.filledQuantity / order.quantity * 100)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 订单状态卡片
          _buildStatusCard(context, order, isBuy),
          const SizedBox(height: 16),
          
          // 订单基本信息
          _buildInfoSection(
            context,
            '订单信息',
            [
              _buildInfoRow(context, '订单ID', order.id),
              _buildInfoRow(context, '交易对', order.symbol),
              _buildInfoRow(context, '订单类型', _getOrderTypeName(order.type)),
              _buildInfoRow(context, '订单方向', isBuy ? '买入' : '卖出'),
              _buildInfoRow(context, '订单状态', _getOrderStatusName(order.status)),
            ],
          ),
          const SizedBox(height: 16),
          
          // 价格和数量信息
          _buildInfoSection(
            context,
            '价格和数量',
            [
              _buildInfoRow(
                context,
                '价格',
                order.price != null
                    ? order.price!.toStringAsFixed(2)
                    : '市价',
              ),
              _buildInfoRow(
                context,
                '数量',
                order.quantity.toStringAsFixed(4),
              ),
              _buildInfoRow(
                context,
                '已成交数量',
                order.filledQuantity.toStringAsFixed(4),
              ),
              _buildInfoRow(
                context,
                '成交进度',
                '${fillPercent.toStringAsFixed(2)}%',
              ),
              if (order.avgPrice != null)
                _buildInfoRow(
                  context,
                  '平均成交价',
                  order.avgPrice!.toStringAsFixed(2),
                ),
              _buildInfoRow(
                context,
                '已成交金额',
                order.filledAmount.toStringAsFixed(2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 时间信息
          _buildInfoSection(
            context,
            '时间信息',
            [
              _buildInfoRow(
                context,
                '创建时间',
                dateFormat.format(DateTime.fromMillisecondsSinceEpoch(order.createdAt)),
              ),
              _buildInfoRow(
                context,
                '更新时间',
                dateFormat.format(DateTime.fromMillisecondsSinceEpoch(order.updatedAt)),
              ),
            ],
          ),
          
          // 取消按钮
          if (order.canCancel && onCancel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('取消订单'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Order order, bool isBuy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBuy
              ? Colors.green.withOpacity(0.3)
              : Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isBuy
                  ? Colors.green.withOpacity(0.1)
                  : Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isBuy ? '买入' : '卖出',
              style: TextStyle(
                color: isBuy
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getOrderStatusName(order.status),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getOrderTypeName(orderType) {
    switch (orderType) {
      case OrderType.limit:
        return '限价';
      case OrderType.market:
        return '市价';
      case OrderType.stopLoss:
        return '止损';
      case OrderType.takeProfit:
        return '止盈';
    }
  }

  String _getOrderStatusName(OrderStatus status) {
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
}

