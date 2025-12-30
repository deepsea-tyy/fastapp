import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/app/currency_store.dart';
import 'package:fastapp/presentation/store/app/exchange_rate_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/ticker_cache_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_currency_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/user/setting/widgets/currency_selector_bottom_sheet.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/currency_formatter.dart';
import 'package:fastapp/utils/wallet_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 统一的资产卡片组件
/// 支持三种数据源模式：
/// 1. 总览模式 - 使用 asset.totalAsset 和 asset.balances
/// 2. 账户模式 - 使用 accountBalance 按 walletType 筛选
///
/// 使用缓存的 ticker 价格减少总资产的实时跳动
class UnifiedAssetsCard extends StatefulWidget {
  /// 钱包类型（账户模式使用）
  final WalletType? walletType;

  /// 是否为总览模式
  final bool isOverviewMode;

  /// 自定义标题（默认为"预估总资产"）
  final String? customTitle;

  /// 盈亏标签（默认为"今日盈亏"）
  final String? profitLossLabel;

  /// 额外的底部组件
  final Widget? bottomWidget;

  const UnifiedAssetsCard({
    super.key,
    this.walletType,
    this.isOverviewMode = false,
    this.customTitle,
    this.profitLossLabel,
    this.bottomWidget,
  });

  @override
  State<UnifiedAssetsCard> createState() => _UnifiedAssetsCardState();
}

class _UnifiedAssetsCardState extends State<UnifiedAssetsCard> {
  @override
  void initState() {
    super.initState();
    // 启动 ticker 缓存刷新
    final marketStore = getIt<MarketStore>();
    final tickerCacheStore = getIt<TickerCacheStore>();
    tickerCacheStore.startRefresh(() => marketStore.tickerList);
  }

  @override
  void dispose() {
    // 停止刷新（可选，因为是全局单例）
    // final tickerCacheStore = getIt<TickerCacheStore>();
    // tickerCacheStore.stopRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = getIt<WalletStore>();
    final marketDataStore = getIt<MarketDataStore>();
    final marketStore = getIt<MarketStore>();
    final walletCurrencyStore = getIt<WalletCurrencyStore>();
    final currencyStore = getIt<CurrencyStore>();
    final exchangeRateStore = getIt<ExchangeRateStore>();

    return Observer(
      builder: (_) {
        // 计算资产数据
        final assetData = _calculateAssetData(
          store,
          marketStore,
          walletCurrencyStore,
          currencyStore,
          exchangeRateStore,
        );

        if (assetData == null) {
          return _buildEmptyState();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildTotalAsset(
                context,
                store,
                marketDataStore,
                assetData.totalAsset,
                assetData.quoteCurrency,
              ),
              const SizedBox(height: 8),
              _buildFiatValue(assetData),
              _buildProfitLoss(assetData),
              if (widget.bottomWidget != null) ...[
                const SizedBox(height: 4),
                widget.bottomWidget!,
              ],
            ],
          ),
        );
      },
    );
  }

  /// 计算资产数据
  _AssetData? _calculateAssetData(
    WalletStore store,
    MarketStore marketStore,
    WalletCurrencyStore walletCurrencyStore,
    CurrencyStore currencyStore,
    ExchangeRateStore exchangeRateStore,
  ) {
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

    double totalBalanceInUsdt;
    double todayPnLInUsdt;

    if (widget.isOverviewMode) {
      // 总览模式：使用 asset 数据
      final asset = store.asset;
      if (asset == null) return null;

      totalBalanceInUsdt = asset.totalAsset;
      todayPnLInUsdt = asset.balances.fold(0.0, (sum, b) => sum + (b.profit ?? 0.0));
    } else {
      // 账户模式：使用 accountBalance 数据
      final accountBalance = store.accountBalance;
      if (accountBalance == null || widget.walletType == null) return null;

      final balances = accountBalance.getBalancesByType(widget.walletType!);
      totalBalanceInUsdt = 0.0;

      for (final balance in balances) {
        if (balance.symbol == 'USDT') {
          totalBalanceInUsdt += balance.total;
        } else {
          // 使用缓存的 ticker 价格而不是实时价格
          final tickerCacheStore = getIt<TickerCacheStore>();
          final ticker = tickerCacheStore.cachedTickerList.firstWhere(
            (t) => t.symbol == '${balance.symbol}USDT',
            orElse: () => tickerCacheStore.cachedTickerList.firstWhere(
              (t) => t.symbol == '${balance.symbol}_USDT',
              orElse: () => tickerCacheStore.cachedTickerList.first,
            ),
          );
          totalBalanceInUsdt += balance.total * ticker.lastPrice;
        }
      }

      todayPnLInUsdt = balances.fold(0.0, (sum, b) => sum + (b.profit ?? 0.0));
    }

    // 转换为选定货币
    final totalAsset = totalBalanceInUsdt * walletExchangeRate;
    final totalAssetInFiat = totalBalanceInUsdt * fiatExchangeRate;
    final todayPnL = todayPnLInUsdt * walletExchangeRate;
    final todayPnLPercent = totalAsset > 0 ? (todayPnL / totalAsset * 100) : 0.0;

    return _AssetData(
      quoteCurrency: quoteCurrency,
      fiatCurrency: fiatCurrency,
      totalAsset: totalAsset,
      totalAssetInFiat: totalAssetInFiat,
      todayPnL: todayPnL,
      todayPnLPercent: todayPnLPercent,
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.customTitle ?? '预估总资产',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.description_outlined,
            size: 20,
            color: Colors.grey.shade600,
          ),
          onPressed: () => WalletNavigator.toBalanceLog(context),
        ),
      ],
    );
  }

  /// 构建总资产
  Widget _buildTotalAsset(
    BuildContext context,
    WalletStore store,
    MarketDataStore marketDataStore,
    double totalAsset,
    String quoteCurrency,
  ) {
    return GestureDetector(
      onTap: () => _showQuoteCurrencyPicker(context, store, marketDataStore),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            totalAsset.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            CurrencyFormatter.formatCurrencyDisplay(quoteCurrency),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  /// 构建法币价值
  Widget _buildFiatValue(_AssetData assetData) {
    // 法币价值一直显示，除非钱包计价币种本身就是法币
    if (assetData.quoteCurrency == assetData.fiatCurrency) {
      return const SizedBox.shrink();
    }

    return Text(
      '≈ ${CurrencyFormatter.formatFiatCurrencyForApprox(assetData.fiatCurrency)}${assetData.totalAssetInFiat < 1 ? assetData.totalAssetInFiat.toStringAsFixed(8) : assetData.totalAssetInFiat.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }

  /// 构建今日盈亏
  Widget _buildProfitLoss(_AssetData assetData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.profitLossLabel ?? '今日盈亏',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${assetData.todayPnL.toStringAsFixed(2)} (${assetData.todayPnL >= 0 ? '+' : ''}${assetData.todayPnLPercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                fontSize: 14,
                color: assetData.todayPnL >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        Opacity(
          opacity: 0.3,
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  /// 显示货币选择器
  void _showQuoteCurrencyPicker(
    BuildContext context,
    WalletStore store,
    MarketDataStore marketDataStore,
  ) {
    final walletCurrencyStore = getIt<WalletCurrencyStore>();
    final exchangeRateStore = getIt<ExchangeRateStore>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelectorBottomSheet(
        currentCurrency: walletCurrencyStore.currency,
        currencies: walletCurrencyStore.supportedCurrencies,
        exchangeRateStore: exchangeRateStore,
        onCurrencySelected: (currency) {
          walletCurrencyStore.changeCurrency(currency);
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '暂无数据',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

/// 资产数据模型
class _AssetData {
  final String quoteCurrency;
  final String fiatCurrency;
  final double totalAsset;
  final double totalAssetInFiat;
  final double todayPnL;
  final double todayPnLPercent;

  _AssetData({
    required this.quoteCurrency,
    required this.fiatCurrency,
    required this.totalAsset,
    required this.totalAssetInFiat,
    required this.todayPnL,
    required this.todayPnLPercent,
  });
}
