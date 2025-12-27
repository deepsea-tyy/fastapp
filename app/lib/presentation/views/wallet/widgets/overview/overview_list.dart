import 'package:fastapp/constants/exchange_rate.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/currency/currency_list.dart';
import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 资产列表头部组件
class AssetListHeader extends StatelessWidget {
  const AssetListHeader({super.key});

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
          const Text(
            '账户',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

        final totalBalance = contractBalance + spotBalance + fundsBalance;

        if (totalBalance == 0) {
          return const EmptyState(text: '暂无资产');
        }

        return Column(
          children: [
            _buildAccountItem('合约', contractBalance, ExchangeRate.getUsdToCnySync()),
            _buildAccountItem('现货', spotBalance, ExchangeRate.getUsdToCnySync()),
            _buildAccountItem('资金', fundsBalance, ExchangeRate.getUsdToCnySync(), showCny: false),
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
