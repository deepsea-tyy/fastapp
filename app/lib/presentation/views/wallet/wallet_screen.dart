import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/common/app_bar.dart';
import 'package:fastapp/presentation/views/wallet/widgets/balance_card.dart';
import 'package:fastapp/presentation/views/wallet/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 资产管理页面
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletStore _store = getIt<WalletStore>();

  @override
  void initState() {
    super.initState();
    _store.loadAsset();
    _store.loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: '资产',
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              _store.refreshAsset();
              _store.refreshTransactions();
            },
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 总资产卡片
          const BalanceCard(),
          
          // 币种余额列表
          _buildBalanceList(context),
          
          // 交易记录列表
          const Expanded(
            child: TransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceList(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_store.isLoadingAsset && _store.balances.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (_store.balances.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            itemCount: _store.balances.length,
            itemBuilder: (context, index) {
              final balance = _store.balances[index];
              return _buildBalanceItem(context, balance);
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceItem(BuildContext context, balance) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final valueStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
    final hintStyle = TextStyle(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontSize: 10,
    );

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(balance.currency, style: textStyle),
          const SizedBox(height: 8),
          Text(
            balance.total.toStringAsFixed(4),
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '可用: ${balance.available.toStringAsFixed(4)}',
            style: hintStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
