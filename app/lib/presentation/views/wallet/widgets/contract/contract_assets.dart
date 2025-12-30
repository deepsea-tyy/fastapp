import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/app/currency_store.dart';
import 'package:fastapp/presentation/store/app/exchange_rate_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/ticker_cache_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_currency_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/widgets/common/unified_assets_card.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 预估总资产卡片（合约）
class ContractAssets extends StatelessWidget {
  const ContractAssets({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedAssetsCard(
      walletType: WalletType.FUTURES,
      customTitle: '保证金余额',
      profitLossLabel: '今日已实现盈亏',
      bottomWidget: _buildBalanceBreakdown(),
    );
  }

  /// 构建余额明细
  Widget _buildBalanceBreakdown() {
    return Observer(
      builder: (_) {
        final store = getIt<WalletStore>();
        final marketStore = getIt<MarketStore>();
        final walletCurrencyStore = getIt<WalletCurrencyStore>();
        final currencyStore = getIt<CurrencyStore>();
        final exchangeRateStore = getIt<ExchangeRateStore>();

        final accountBalance = store.accountBalance;
        if (accountBalance == null) {
          return const SizedBox.shrink();
        }

        final quoteCurrency = walletCurrencyStore.currency;
        final fiatCurrency = currencyStore.currency;

        // 获取汇率
        final walletExchangeRate = CurrencyFormatter.getWalletExchangeRate(
          quoteCurrency,
          marketStore,
        );
        final fiatExchangeRate = CurrencyFormatter.getFiatExchangeRate(
          fiatCurrency,
          exchangeRateStore,
        );

        // 计算钱包余额（使用 FUTURES 账户）
        final balances = accountBalance.getBalancesByType(WalletType.FUTURES);
        double walletBalanceInUsdt = 0.0;

        for (final balance in balances) {
          if (balance.symbol == 'USDT') {
            walletBalanceInUsdt += balance.available;
          } else {
            // 使用缓存的 ticker 价格
            final tickerCacheStore = getIt<TickerCacheStore>();
            final ticker = tickerCacheStore.cachedTickerList.firstWhere(
              (t) => t.symbol == '${balance.symbol}USDT',
              orElse: () => tickerCacheStore.cachedTickerList.firstWhere(
                (t) => t.symbol == '${balance.symbol}_USDT',
                orElse: () => tickerCacheStore.cachedTickerList.first,
              ),
            );
            walletBalanceInUsdt += balance.available * ticker.lastPrice;
          }
        }

        final walletBalance = walletBalanceInUsdt * walletExchangeRate;
        final walletBalanceInFiat = walletBalanceInUsdt * fiatExchangeRate;

        // TODO: 未实现盈亏需要从合约持仓数据中获取
        final unrealizedPnL = 0.0;
        final unrealizedPnLInFiat = 0.0;

        return Row(
          children: [
            Expanded(
              child: _buildBalanceItem(
                '钱包余额(${CurrencyFormatter.formatCurrencyDisplay(quoteCurrency)})',
                walletBalance,
                quoteCurrency != fiatCurrency
                    ? '≈ ${CurrencyFormatter.formatFiatCurrencyForApprox(fiatCurrency)}${walletBalanceInFiat < 1 ? walletBalanceInFiat.toStringAsFixed(8) : walletBalanceInFiat.toStringAsFixed(2)}'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBalanceItem(
                '未实现盈亏(${CurrencyFormatter.formatCurrencyDisplay(quoteCurrency)})',
                unrealizedPnL,
                quoteCurrency != fiatCurrency
                    ? '≈ ${CurrencyFormatter.formatFiatCurrencyForApprox(fiatCurrency)}${unrealizedPnLInFiat < 1 ? unrealizedPnLInFiat.toStringAsFixed(8) : unrealizedPnLInFiat.toStringAsFixed(2)}'
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建单个余额项
  Widget _buildBalanceItem(String title, double amount, String? fiatValue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (fiatValue != null) ...[
            const SizedBox(height: 4),
            Text(
              fiatValue,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

