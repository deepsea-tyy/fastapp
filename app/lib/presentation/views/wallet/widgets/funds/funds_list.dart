import 'dart:async';
import 'package:fastapp/data/network/websocket/app_websocket.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/app/currency_store.dart';
import 'package:fastapp/presentation/store/app/exchange_rate_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_currency_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/currency/asset_detail_screen.dart';
import 'package:fastapp/presentation/views/wallet/widgets/empty_state.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/currency_formatter.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 资金列表
class FundsList extends StatefulWidget {
  final WalletType walletType;

  const FundsList({super.key, required this.walletType});

  @override
  State<FundsList> createState() => _FundsListState();
}

class _FundsListState extends State<FundsList> {
  final WalletStore _walletStore = getIt<WalletStore>();
  final MarketDataStore _marketDataStore = getIt<MarketDataStore>();
  final MarketStore _marketStore = getIt<MarketStore>();
  final WalletCurrencyStore _walletCurrencyStore = getIt<WalletCurrencyStore>();
  final CurrencyStore _currencyStore = getIt<CurrencyStore>();
  final ExchangeRateStore _exchangeRateStore = getIt<ExchangeRateStore>();
  final AppWebSocket _webSocket = getIt<AppWebSocket>();

  final Map<String, TickerData> _tickerMap = {};
  StreamSubscription<WebSocketMessage>? _tickerSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToTickers();
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToTickers() {
    _tickerSubscription = _webSocket.messageStream.listen((message) {
      if (message.type == WebSocketMessageType.ticker && message.data is TickerData) {
        if (mounted) {
          setState(() {
            _tickerMap[message.symbol] = message.data as TickerData;
          });
        }
      } else if (message.type == WebSocketMessageType.hotTickers && message.data is List) {
        if (mounted) {
          setState(() {
            for (final ticker in message.data as List<TickerData>) {
              _tickerMap[ticker.symbol] = ticker;
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final balances = _walletStore.accountBalance?.getBalancesByType(widget.walletType);
        final quoteCurrency = _walletCurrencyStore.currency;
        final fiatCurrency = _currencyStore.currency;

        if (balances == null || balances.isEmpty) {
          return const EmptyState(text: '暂无资产');
        }

        // 直接在 Observer 中访问 tickerList 以确保依赖追踪
        final tickerList = _marketStore.tickerList;

        // 直接在 Observer 中计算汇率，确保依赖追踪
        double walletExchangeRate = 1.0;
        if (quoteCurrency == 'USDT') {
          walletExchangeRate = 1.0;
        } else {
          // 尝试多种格式查找汇率ticker
          final possibleRateSymbols = [
            '${quoteCurrency}_USDT',    // BTC_USDT
            '${quoteCurrency}/USDT',    // BTC/USDT
            '${quoteCurrency}USDT',     // BTCUSDT
          ];

          for (final rateSymbol in possibleRateSymbols) {
            try {
              final rateTicker = tickerList.firstWhere((t) => t.symbol == rateSymbol);
              if (rateTicker.lastPrice > 0) {
                walletExchangeRate = 1.0 / rateTicker.lastPrice;
                break;
              }
            } catch (_) {
              // 继续尝试下一个格式
            }
          }
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: balances.length,
          itemBuilder: (context, index) {
            final balance = balances[index];
            final currency = _marketDataStore.getCurrency(balance.symbol);

            // 优先使用 marketStore 数据（会随币种切换自动更新），fallback 到 WebSocket 实时数据
            // 尝试多种 ticker symbol 格式
            TickerData? ticker;
            final possibleSymbols = [
              '${balance.symbol}_USDT',    // BTC_USDT
              '${balance.symbol}/USDT',    // BTC/USDT
              '${balance.symbol}USDT',     // BTCUSDT
            ];

            // 先从 marketStore 查找
            for (final tickerSymbol in possibleSymbols) {
              try {
                ticker = tickerList.firstWhere((t) => t.symbol == tickerSymbol);
                break;
              } catch (_) {
                // 继续尝试下一个格式
              }
            }

            // 如果 marketStore 中没有，尝试从 WebSocket 数据获取
            if (ticker == null) {
              for (final tickerSymbol in possibleSymbols) {
                ticker = _tickerMap[tickerSymbol];
                if (ticker != null) break;
              }
            }

            return _buildAssetItem(
              symbol: balance.symbol,
              available: balance.available,
              frozen: balance.frozen,
              total: balance.total,
              logoUrl: currency?.logo,
              chain: currency?.type == 1 ? null : currency?.chain,
              ticker: ticker,
              quoteCurrency: quoteCurrency,
              walletExchangeRate: walletExchangeRate,
              isLast: index == balances.length - 1,
            );
          },
        );
      },
    );
  }

  Widget _buildAssetItem({
    required String symbol,
    required double available,
    required double frozen,
    required double total,
    String? logoUrl,
    String? chain,
    TickerData? ticker,
    required String quoteCurrency,
    required double walletExchangeRate,
    bool isLast = false,
  }) {
    // 计算USDT价值
    final double usdtValue;
    if (symbol == 'USDT') {
      usdtValue = total;
    } else {
      usdtValue = ticker != null ? total * ticker.lastPrice : 0.0;
    }

    // 转换为钱包货币
    final walletValue = usdtValue * walletExchangeRate;

    final formattedLogoUrl = ImageUtils.formatSingleImagePath(logoUrl);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssetDetailScreen(
            symbol: symbol,
            name: chain ?? symbol,
            iconColor: Colors.grey,
            iconText: symbol.isNotEmpty ? symbol[0] : 'C',
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl != null
                ? Image.network(
                    formattedLogoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultIcon(symbol),
                  )
                : _buildDefaultIcon(symbol),
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
                          symbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chain ?? '',
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
                          total.toStringAsFixed(4),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '≈ ${CurrencyFormatter.formatFiatCurrencyForApprox(quoteCurrency)}${walletValue.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      Text(
                        '可用余额',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        available.toStringAsFixed(4),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '冻结',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        frozen.toStringAsFixed(4),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDefaultIcon(String symbol) {
    return Center(
      child: Text(
        symbol.isNotEmpty ? symbol[0] : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
