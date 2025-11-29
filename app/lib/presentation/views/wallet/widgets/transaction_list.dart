import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/transaction.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

/// 交易记录列表组件
class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletStore store = getIt<WalletStore>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 筛选器
        _buildFilterBar(context, store),
        
        // 交易记录列表
        Expanded(
          child: Observer(
            builder: (_) {
              if (store.isLoadingTransactions && store.transactions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final filteredTransactions = store.filteredTransactions;

              if (filteredTransactions.isEmpty) {
                return Center(
                  child: Text(
                    '暂无交易记录',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => store.refreshTransactions(),
                child: ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _buildTransactionItem(context, transaction);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, WalletStore store) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Observer(
              builder: (_) => DropdownButton<String?>(
                value: store.selectedCurrency,
                hint: const Text('全部币种'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('全部币种')),
                  ...store.balances.map((balance) => DropdownMenuItem<String?>(
                        value: balance.currency,
                        child: Text(balance.currency),
                      )),
                ],
                onChanged: (value) => store.setSelectedCurrency(value),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Observer(
              builder: (_) => DropdownButton<TransactionType?>(
                value: store.selectedType,
                hint: const Text('全部类型'),
                isExpanded: true,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<TransactionType?>(value: null, child: Text('全部类型')),
                  ...TransactionType.values.map((type) => DropdownMenuItem<TransactionType?>(
                        value: type,
                        child: Text(_getTransactionTypeName(type)),
                      )),
                ],
                onChanged: (value) => store.setSelectedType(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final isPositive = transaction.type == TransactionType.deposit ||
        (transaction.type == TransactionType.trade && transaction.amount > 0);

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
        child: Row(
          children: [
            // 类型图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTransactionTypeColor(transaction.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getTransactionTypeIcon(transaction.type),
                color: _getTransactionTypeColor(transaction.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // 交易信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTransactionTypeName(transaction.type),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(4)} ${transaction.currency}',
                        style: TextStyle(
                          color: isPositive
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transaction.createdAt)),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      _buildStatusChip(context, transaction.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, TransactionStatus status) {
    Color color;
    String text;

    switch (status) {
      case TransactionStatus.success:
        color = Colors.green;
        text = '成功';
        break;
      case TransactionStatus.pending:
        color = Colors.orange;
        text = '处理中';
        break;
      case TransactionStatus.failed:
        color = Theme.of(context).colorScheme.error;
        text = '失败';
        break;
      case TransactionStatus.cancelled:
        color = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
        text = '已取消';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  String _getTransactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return '充值';
      case TransactionType.withdrawal:
        return '提现';
      case TransactionType.trade:
        return '交易';
      case TransactionType.transfer:
        return '转账';
      case TransactionType.other:
        return '其他';
    }
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.orange;
      case TransactionType.trade:
        return Colors.blue;
      case TransactionType.transfer:
        return Colors.purple;
      case TransactionType.other:
        return Colors.grey;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.trade:
        return Icons.swap_horiz;
      case TransactionType.transfer:
        return Icons.swap_vert;
      case TransactionType.other:
        return Icons.more_horiz;
    }
  }
}

