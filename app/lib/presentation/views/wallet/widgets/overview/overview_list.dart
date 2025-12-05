import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/currency/currency_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 资产列表头部组件
class AssetListHeader extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const AssetListHeader({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildCurrencyTab('币种', selectedTab == '币种'),
          const SizedBox(width: 24),
          _buildCurrencyTab('账户', selectedTab == '账户'),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CurrencyList(),
                ),
              );
            },
            child: Icon(
              Icons.search,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => onTabChanged(text),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.black87 : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 20,
              height: 2,
              color: Colors.amber,
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

/// 币种资产列表
class CurrencyAssetList extends StatelessWidget {
  const CurrencyAssetList({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletStore store = getIt<WalletStore>();

    return Observer(
      builder: (_) {
        if (store.isLoadingAsset && store.balances.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (store.balances.isEmpty) {
          return const EmptyState(text: '暂无资产');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: store.balances.length,
          itemBuilder: (context, index) {
            final balance = store.balances[index];
            return _buildAssetItem(balance);
          },
        );
      },
    );
  }

  Widget _buildAssetItem(balance) {
    final currency = balance.currency;
    final total = balance.total;
    final usdtValue = total * 1.0; // 假设汇率
    final todayPnL = 0.0;
    final todayPnLPercent = -0.70;
    final avgCost = 3.62;

    final iconColor = _getCurrencyIconColor(currency);
    final iconText = _getCurrencyIconText(currency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                iconText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCurrencyFullName(currency),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          total.toStringAsFixed(8),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (currency != 'USDT') ...[
                          const SizedBox(height: 4),
                          Text(
                            '$usdtValue USDT',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (currency != 'USDT') ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '平均成本',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '$avgCost USDT',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '今日盈亏',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${todayPnL.toStringAsFixed(2)} USDT(${todayPnLPercent >= 0 ? '+' : ''}${todayPnLPercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: todayPnL >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCurrencyIconColor(String currency) {
    switch (currency) {
      case 'USDT':
        return Colors.green;
      case 'TON':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getCurrencyIconText(String currency) {
    switch (currency) {
      case 'USDT':
        return 'T';
      case 'TON':
        return 'T';
      default:
        return currency.substring(0, 1).toUpperCase();
    }
  }

  String _getCurrencyFullName(String currency) {
    switch (currency) {
      case 'USDT':
        return 'TetherUS';
      case 'TON':
        return 'Toncoin';
      default:
        return currency;
    }
  }
}

/// 账户资产列表
class AccountAssetList extends StatelessWidget {
  const AccountAssetList({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletStore store = getIt<WalletStore>();

    return Observer(
      builder: (_) {
        final asset = store.asset;
        final contractBalance = asset?.balances
                .where((b) => b.currency == 'USDT')
                .fold(0.0, (sum, b) => sum + b.total) ??
            0.78221273;
        final spotBalance = 0.00118263;
        final fundsBalance = 0.00;

        final exchangeRate = 7.08; // 假设汇率

        final totalBalance = contractBalance + spotBalance + fundsBalance;

        if (totalBalance == 0) {
          return const EmptyState(text: '暂无资产');
        }

        return Column(
          children: [
            _buildAccountItem('合约', contractBalance, exchangeRate),
            _buildAccountItem('现货', spotBalance, exchangeRate),
            _buildAccountItem('资金', fundsBalance, exchangeRate, showCny: false),
          ],
        );
      },
    );
  }

  Widget _buildAccountItem(String label, double usdtValue, double exchangeRate,
      {bool showCny = true}) {
    final cnyValue = usdtValue * exchangeRate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '账户',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          usdtValue.toStringAsFixed(8),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'USDT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (showCny && usdtValue > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '人民币等值',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '≈ ¥${cnyValue < 1 ? cnyValue.toStringAsFixed(8) : cnyValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
