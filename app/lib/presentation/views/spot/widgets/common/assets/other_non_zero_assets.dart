import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/assets/asset_metrics.dart';
import 'package:fastapp/presentation/views/wallet/currency/asset_detail_screen.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 其他非0资产组件
class OtherNonZeroAssets extends StatelessWidget {
  const OtherNonZeroAssets({super.key});

  @override
  Widget build(BuildContext context) {
    final walletStore = getIt<WalletStore>();
    final spotTradeStore = getIt<SpotTradeStore>();
    final marketDataStore = getIt<MarketDataStore>();
    final marketStore = getIt<MarketStore>();

    return Observer(
      builder: (_) {
        // 获取现货账户余额
        final balances = walletStore.accountBalance?.getBalancesByType(WalletType.SPOT) ?? [];
        
        // 解析当前交易对符号，排除当前交易对的币种
        final symbol = spotTradeStore.selectedSymbol;
        final parts = symbol.split('/');
        final currentBaseCurrency = parts.isNotEmpty ? parts[0] : '';
        final currentQuoteCurrency = parts.length > 1 ? parts[1] : '';

        // 过滤出其他非零资产（排除当前交易对的币种）
        final otherBalances = balances.where((balance) {
          return balance.total > 0 && 
                 balance.symbol != currentBaseCurrency && 
                 balance.symbol != currentQuoteCurrency;
        }).toList();

        if (otherBalances.isEmpty) {
          return const SizedBox.shrink();
        }

        // 获取 ticker 列表用于计算价格
        final tickerList = marketStore.tickerList;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '其他非0资产',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              // 资产列表
              ...otherBalances.asMap().entries.map((entry) {
                final index = entry.key;
                final balance = entry.value;
                final currency = marketDataStore.getCurrency(balance.symbol);
                
                // 查找 ticker 数据
                TickerData? ticker;
                final possibleSymbols = [
                  '${balance.symbol}_USDT',
                  '${balance.symbol}/USDT',
                  '${balance.symbol}USDT',
                ];

                for (final tickerSymbol in possibleSymbols) {
                  try {
                    ticker = tickerList.firstWhere((t) => t.symbol == tickerSymbol);
                    break;
                  } catch (_) {
                    // 继续尝试下一个格式
                  }
                }

                // 计算 USDT 价值
                final double usdtValue = balance.symbol == 'USDT' 
                    ? balance.total 
                    : (ticker != null ? balance.total * ticker.lastPrice : 0.0);

                // 格式化盈亏
                final profit = balance.profit ?? 0.0;
                // 优先使用 profitRate，否则计算百分比
                final profitPercent = balance.profitRate ?? 
                    (usdtValue > 0 && profit != 0 
                        ? (profit / (usdtValue - profit)) * 100 
                        : 0.0);

                final asset = _AssetData(
                  symbol: balance.symbol,
                  name: currency?.name ?? balance.symbol,
                  iconColor: _getColorForSymbol(balance.symbol),
                  iconText: balance.symbol.isNotEmpty ? balance.symbol[0] : '?',
                  dailyPnL: '${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)}',
                  pnlPercent: '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                  balance: balance.total.toStringAsFixed(4),
                  balanceSubtitle: '≈ $usdtValue USDT',
                  costPrice: ticker != null ? ticker.lastPrice.toStringAsFixed(2) : '0.00',
                  latestPrice: ticker?.lastPrice.toStringAsFixed(4) ?? '0.0000',
                );

                return Column(
                  children: [
                    if (index > 0) const Divider(height: 32),
                    _AssetListItem(asset: asset, currency: currency),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// 根据币种符号获取颜色
  Color _getColorForSymbol(String symbol) {
    final colors = {
      'BTC': Colors.orange,
      'ETH': Colors.blue,
      'USDT': Colors.teal,
      'BNB': Colors.yellow.shade700,
      'USDC': Colors.blue.shade300,
      'TON': Colors.blue.shade400,
    };
    return colors[symbol] ?? Colors.grey;
  }
}

/// 资产数据模型
class _AssetData {
  final String symbol;
  final String name;
  final Color iconColor;
  final String iconText;
  final String dailyPnL;
  final String pnlPercent;
  final String balance;
  final String balanceSubtitle;
  final String costPrice;
  final String latestPrice;

  _AssetData({
    required this.symbol,
    required this.name,
    required this.iconColor,
    required this.iconText,
    required this.dailyPnL,
    required this.pnlPercent,
    required this.balance,
    required this.balanceSubtitle,
    required this.costPrice,
    required this.latestPrice,
  });
}

/// 资产列表项组件
class _AssetListItem extends StatelessWidget {
  final _AssetData asset;
  final dynamic currency;

  const _AssetListItem({required this.asset, this.currency});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(
              symbol: asset.symbol,
              name: asset.name,
              iconColor: asset.iconColor,
              iconText: asset.iconText,
              walletType: WalletType.SPOT,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 资产概览行
          Row(
            children: [
              _buildIcon(asset.symbol, this.currency?.logo),
              const SizedBox(width: 12),
              Text(
                asset.symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                asset.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AssetDetailScreen(
                        symbol: asset.symbol,
                        name: asset.name,
                        iconColor: asset.iconColor,
                        iconText: asset.iconText,
                        walletType: WalletType.SPOT,
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 详细数据区域
          AssetMetrics(
            dailyPnL: asset.dailyPnL,
            pnlPercent: asset.pnlPercent,
            balance: asset.balance,
            balanceSubtitle: asset.balanceSubtitle,
            costPrice: asset.costPrice,
            latestPrice: asset.latestPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String symbol, String? logoUrl) {
    final formattedLogoUrl = logoUrl != null ? ImageUtils.formatSingleImagePath(logoUrl) : null;
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: formattedLogoUrl != null && formattedLogoUrl != ImageUtils.defaultImage
          ? Image.network(
              formattedLogoUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefaultIcon(symbol),
            )
          : _buildDefaultIcon(symbol),
    );
  }

  Widget _buildDefaultIcon(String symbol) {
    final colors = {
      'BTC': Colors.orange,
      'ETH': Colors.blue,
      'USDT': Colors.teal,
      'BNB': Colors.yellow.shade700,
      'USDC': Colors.blue.shade300,
      'TON': Colors.blue.shade400,
    };
    final color = colors[symbol] ?? Colors.grey;
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
