import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/app/currency_store.dart';
import 'package:fastapp/presentation/store/app/exchange_rate_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_currency_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/currency_formatter.dart';
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
    final marketStore = getIt<MarketStore>();
    final walletCurrencyStore = getIt<WalletCurrencyStore>();
    final currencyStore = getIt<CurrencyStore>();
    final exchangeRateStore = getIt<ExchangeRateStore>();

    return Observer(
      builder: (_) {
        final accounts = store.accountTotals;
        final quoteCurrency = walletCurrencyStore.currency;
        final fiatCurrency = currencyStore.currency;

        if (accounts.isEmpty) {
          return const EmptyState(text: '暂无资产');
        }

        // 获取钱包货币汇率
        final walletExchangeRate = CurrencyFormatter.getWalletExchangeRate(
          quoteCurrency,
          marketStore,
        );

        return Column(
          children: accounts.entries.map((entry) {
            return _buildAccountItem(
              context,
              _accountLabels[entry.key] ?? '未知',
              entry.value,
              walletExchangeRate,
              quoteCurrency,
              exchangeRateStore,
              fiatCurrency,
              showFiat: entry.key != WalletType.FUNDING && quoteCurrency != fiatCurrency,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAccountItem(
    BuildContext context,
    String label,
    double usdtValue,
    double walletExchangeRate,
    String quoteCurrency,
    ExchangeRateStore exchangeRateStore,
    String fiatCurrency, {
    bool showFiat = true,
  }) {
    final walletValue = usdtValue * walletExchangeRate;

    // 获取法币汇率
    final fiatExchangeRate = CurrencyFormatter.getFiatExchangeRate(
      fiatCurrency,
      exchangeRateStore,
    );
    final fiatValue = usdtValue * fiatExchangeRate;

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
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          walletValue.toStringAsFixed(8),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          CurrencyFormatter.formatCurrencyDisplay(quoteCurrency),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (showFiat && usdtValue > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '≈ ${CurrencyFormatter.formatFiatCurrencyForApprox(fiatCurrency)}${fiatValue < 1 ? fiatValue.toStringAsFixed(8) : fiatValue.toStringAsFixed(2)}',
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

