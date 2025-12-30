import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/wallet/balance_log_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

/// 钱包流水页面
class BalanceLogScreen extends StatefulWidget {
  const BalanceLogScreen({super.key});

  @override
  State<BalanceLogScreen> createState() => _BalanceLogScreenState();
}

class _BalanceLogScreenState extends State<BalanceLogScreen> {
  final BalanceLogStore _store = getIt<BalanceLogStore>();
  final WalletStore _walletStore = getIt<WalletStore>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.loadLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _store.loadLogs(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Scaffold(
      backgroundColor: backgroundTheme.page ?? Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: backgroundTheme.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '资金流水',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textTheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          return Column(
            children: [
              _buildFilterBar(textTheme, backgroundTheme),
              Expanded(
                child: _buildLogList(textTheme, backgroundTheme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundTheme.card,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              label: _store.selectedWalletType ?? '全部账户',
              onTap: () => _showWalletTypeFilter(textTheme, backgroundTheme),
              textTheme: textTheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(
              label: _store.selectedSymbol ?? '全部币种',
              onTap: () => _showSymbolFilter(textTheme, backgroundTheme),
              textTheme: textTheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterButton(
              label: _getChangeTypeLabel(_store.selectedChangeType),
              onTap: () => _showChangeTypeFilter(textTheme, backgroundTheme),
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required VoidCallback onTap,
    required TextThemeColors textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: textTheme.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: textTheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    if (_store.isLoading && _store.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_store.logs.isEmpty) {
      return Center(
        child: Text(
          '暂无流水记录',
          style: TextStyle(fontSize: 14, color: textTheme.hint),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _store.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _store.logs.length + (_store.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _store.logs.length) {
            return _store.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }

          final log = _store.logs[index];
          return _buildLogItem(log, textTheme, backgroundTheme);
        },
      ),
    );
  }

  Widget _buildLogItem(log, TextThemeColors textTheme,
      BackgroundThemeColors backgroundTheme) {
    final isIncrease = log.isIncrease;
    final amountColor = isIncrease ? Colors.green : Colors.red;
    final amountPrefix = isIncrease ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundTheme.card,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getChangeTypeLabel(log.changeType),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textTheme.primary,
                  ),
                ),
              ),
              Text(
                '$amountPrefix${log.amount.toStringAsFixed(8)} ${log.symbol}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            '账户',
            _getWalletTypeLabel(log.walletType),
            textTheme,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            '时间',
            _formatDateTime(log.createdAt),
            textTheme,
          ),
          if (log.remark != null && log.remark!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              '备注',
              log.remark!,
              textTheme,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildBalanceChange(
                  '可用',
                  log.availableBefore,
                  log.availableAfter,
                  log.symbol,
                  textTheme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceChange(
                  '冻结',
                  log.frozenBefore,
                  log.frozenAfter,
                  log.symbol,
                  textTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, TextThemeColors textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textTheme.hint),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: textTheme.secondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceChange(String label, double before, double after,
      String symbol, TextThemeColors textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: textTheme.hint),
        ),
        const SizedBox(height: 2),
        Text(
          '${before.toStringAsFixed(8)} → ${after.toStringAsFixed(8)}',
          style: TextStyle(fontSize: 11, color: textTheme.secondary),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  String _getWalletTypeLabel(String? walletType) {
    const labels = {
      'SPOT': '现货',
      'FUTURES': '合约',
      'FUNDING': '资金',
      'MARGIN': '杠杆',
      'EARN': '理财',
      'OPTIONS': '期权',
    };
    return labels[walletType] ?? walletType ?? '未知';
  }

  String _getChangeTypeLabel(String? changeType) {
    const labels = {
      'deposit': '充值',
      'withdraw': '提现',
      'trade_buy': '买入',
      'trade_sell': '卖出',
      'transfer_in': '转入',
      'transfer_out': '转出',
      'commission': '手续费',
      'reward': '奖励',
      'airdrop': '空投',
    };
    return labels[changeType] ?? changeType ?? '全部类型';
  }

  void _showWalletTypeFilter(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final options = [
          null,
          WalletType.SPOT.name,
          WalletType.FUTURES.name,
          WalletType.FUNDING.name,
          WalletType.MARGIN.name,
          WalletType.EARN.name,
          WalletType.OPTIONS.name,
        ];
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((type) {
                return ListTile(
                  title: Text(
                    _getWalletTypeLabel(type),
                    style: TextStyle(color: textTheme.primary),
                  ),
                  trailing: _store.selectedWalletType == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _store.setSelectedWalletType(type);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showSymbolFilter(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    final symbols = _walletStore.balances
        .where((b) => b.total > 0)
        .map((b) => b.symbol)
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('全部币种', style: TextStyle(color: textTheme.primary)),
                  trailing: _store.selectedSymbol == null
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _store.setSelectedSymbol(null);
                    Navigator.pop(context);
                  },
                ),
                ...symbols.map((symbol) {
                  return ListTile(
                    title: Text(symbol, style: TextStyle(color: textTheme.primary)),
                    trailing: _store.selectedSymbol == symbol
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      _store.setSelectedSymbol(symbol);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangeTypeFilter(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    final types = [
      null,
      'deposit',
      'withdraw',
      'trade_buy',
      'trade_sell',
      'transfer_in',
      'transfer_out',
      'commission',
      'reward',
      'airdrop',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: types.map((type) {
                return ListTile(
                  title: Text(
                    _getChangeTypeLabel(type),
                    style: TextStyle(color: textTheme.primary),
                  ),
                  trailing: _store.selectedChangeType == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _store.setSelectedChangeType(type);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
