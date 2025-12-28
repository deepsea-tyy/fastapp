import 'package:fastapp/constants/exchange_rate.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
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

  static const Map<WalletType, String> _accountLabels = {
    WalletType.SPOT: '现货',
    WalletType.FUTURES: '合约',
    WalletType.FUNDING: '资金',
    WalletType.MARGIN: '杠杆',
    WalletType.EARN: '理财',
    WalletType.OPTIONS: '期权',
  };

  @override
  Widget build(BuildContext context) {
    final store = getIt<WalletStore>();

    return Observer(
      builder: (_) {
        final accounts = store.accountTotals;

        if (accounts.isEmpty) {
          return const EmptyState(text: '暂无资产');
        }

        return Column(
          children: accounts.entries.map((entry) {
            return _buildAccountItem(
              _accountLabels[entry.key] ?? '未知',
              entry.value,
              ExchangeRate.getUsdToCnySync(),
              showCny: entry.key != WalletType.FUNDING,
            );
          }).toList(),
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

