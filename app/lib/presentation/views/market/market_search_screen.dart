import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/market/futures_pair.dart';
import 'package:fastapp/domain/entity/market/spot_pair.dart';
import 'package:fastapp/domain/entity/market/currency.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/core/services/app_startup_state.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/presentation/views/common/search_input_widget.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 搜索结果类型
enum SearchResultType {
  spot,    // 现货
  futures, // 合约
  currency, // 币种
}

/// 搜索结果模型
class SearchResult {
  final SearchResultType type;
  final String symbol;
  final String displayName;
  final String? baseCurrency;
  final String? quoteCurrency;
  final TickerData? ticker;
  final SpotPair? spotPair;
  final FuturesPair? futuresPair;
  final Currency? currency;

  SearchResult({
    required this.type,
    required this.symbol,
    required this.displayName,
    this.baseCurrency,
    this.quoteCurrency,
    this.ticker,
    this.spotPair,
    this.futuresPair,
    this.currency,
  });
}

/// 市场搜索页面
class MarketSearchScreen extends StatefulWidget {
  const MarketSearchScreen({super.key});

  @override
  State<MarketSearchScreen> createState() => _MarketSearchScreenState();
}

class _MarketSearchScreenState extends State<MarketSearchScreen> {
  final MarketStore _marketStore = getIt<MarketStore>();
  final MarketDataStore _marketDataStore = getIt<MarketDataStore>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    afterPageContentDownloaded(() async {
      _focusNode.requestFocus();
      // 加载市场数据配置（用于获取合约信息显示符号和倍数）
      if (!_marketDataStore.isInitialized && !_marketDataStore.isLoading) {
        await _marketDataStore.loadMarketData();
      }
      // 直接使用已有的 ticker 数据，不重新请求
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildSearchList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWithCancel(
      controller: _searchController,
      focusNode: _focusNode,
      hintText: '搜索币种/币对/合约',
      onChanged: (_) => setState(() {}),
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildSearchList() {
    return Observer(
      builder: (_) {
        if (_marketStore.isLoading && _marketStore.tickerList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        if (_marketStore.errorMessage != null && _marketStore.tickerList.isEmpty) {
          return _buildEmptyState(Icons.error_outline, _marketStore.errorMessage ?? '加载失败', null);
        }

        final query = _searchController.text.trim().toUpperCase();
        final results = _performSearch(query);

        if (query.isNotEmpty && results.isEmpty) {
          return _buildEmptyState(Icons.search_off, '暂无结果', '请尝试其他关键词');
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => _buildSearchResultItem(results[index], index),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String? subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: icon == Icons.search_off ? 64 : 48),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: icon == Icons.search_off ? 16 : 14, fontWeight: icon == Icons.search_off ? FontWeight.w500 : FontWeight.normal)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  /// 执行搜索，返回搜索结果列表
  List<SearchResult> _performSearch(String query) {
    final results = <SearchResult>[];
    final processedCurrencySymbols = <String>{};
    final queryUpper = query.isEmpty ? null : query;

    // 辅助函数
    TickerData? _findTicker(String symbol) {
      try {
        return _marketStore.tickerList.firstWhere(
          (t) => t.symbol == symbol || t.symbol.replaceAll('/', '') == symbol,
        );
      } catch (_) {
        return null;
      }
    }

    bool _matches(String text) => queryUpper == null || text.toUpperCase().contains(queryUpper);
    bool _hasValidPrice(TickerData? ticker) => ticker != null && 
        !ticker.lastPrice.isNaN && 
        !ticker.lastPrice.isInfinite && 
        ticker.lastPrice > 0;

    // 添加合约交易对
    for (final pair in _marketDataStore.allFutures) {
      if (_matches(pair.symbol) || _matches(pair.baseCurrencySymbol) || _matches(pair.quoteCurrencySymbol)) {
        results.add(SearchResult(
          type: SearchResultType.futures,
          symbol: pair.symbol,
          displayName: pair.symbol,
          baseCurrency: pair.baseCurrencySymbol,
          quoteCurrency: pair.quoteCurrencySymbol,
          ticker: _findTicker(pair.symbol),
          futuresPair: pair,
        ));
        processedCurrencySymbols.add(pair.baseCurrencySymbol);
      }
    }

    // 添加现货交易对
    for (final pair in _marketDataStore.allSpotPairs) {
      if (_matches(pair.symbol) || _matches(pair.baseCurrencySymbol) || _matches(pair.quoteCurrencySymbol)) {
        results.add(SearchResult(
          type: SearchResultType.spot,
          symbol: pair.symbol,
          displayName: pair.symbol,
          baseCurrency: pair.baseCurrencySymbol,
          quoteCurrency: pair.quoteCurrencySymbol,
          ticker: _findTicker(pair.symbol),
          spotPair: pair,
        ));
        processedCurrencySymbols.add(pair.baseCurrencySymbol);
      }
    }

    // 添加币种
    for (final currency in _marketDataStore.allCurrencies) {
      if (!processedCurrencySymbols.contains(currency.symbol) &&
          (_matches(currency.symbol) || (currency.name.isNotEmpty && _matches(currency.name)))) {
        results.add(SearchResult(
          type: SearchResultType.currency,
          symbol: currency.symbol,
          displayName: currency.name,
          baseCurrency: currency.symbol,
          currency: currency,
        ));
      }
    }

    // 排序：有价格的优先，然后按类型（合约 > 现货 > 币种）
    const typeOrder = {SearchResultType.futures: 0, SearchResultType.spot: 1, SearchResultType.currency: 2};
    results.sort((a, b) {
      final aHasPrice = _hasValidPrice(a.ticker);
      final bHasPrice = _hasValidPrice(b.ticker);
      if (aHasPrice != bHasPrice) return aHasPrice ? -1 : 1;
      return (typeOrder[a.type] ?? 2).compareTo(typeOrder[b.type] ?? 2);
    });

    return results;
  }

  /// 构建搜索结果项
  Widget _buildSearchResultItem(SearchResult result, int index) {
    final baseCurrency = result.baseCurrency ?? result.symbol;
    final currency = result.currency ?? _marketDataStore.getCurrency(baseCurrency);
    final logo = currency?.logo;
    final logoUrl = logo != null && logo.isNotEmpty
        ? ImageUtils.formatSingleImagePath(logo)
        : null;
    final ticker = result.ticker;
    final hasPrice = ticker != null && !ticker.lastPrice.isNaN && !ticker.lastPrice.isInfinite && ticker.lastPrice > 0;
    final futuresPair = result.futuresPair;
    final typeInfo = _getTypeInfo(result.type);

    // 合约标签
    final contractMultiplier = futuresPair != null ? double.tryParse(futuresPair.contractMultiplier) : null;
    final showMultiplier = contractMultiplier != null && contractMultiplier > 1;
    final maxLeverage = futuresPair?.maxLeverage;
    final showLeverage = result.type == SearchResultType.futures && maxLeverage != null && maxLeverage.isNotEmpty;

    return InkWell(
      onTap: () {
        if (hasPrice && ticker != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MarketDetailScreen(
                ticker: ticker,
                isFutures: result.type == SearchResultType.futures,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.displayName} 暂无行情数据')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: Colors.white,
        child: Row(
          children: [
            Text('${index + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  _buildCurrencyIcon(logoUrl, baseCurrency),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(baseCurrency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            if (result.quoteCurrency != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text('/${result.quoteCurrency}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ),
                            if (showMultiplier) ...[
                              const SizedBox(width: 8),
                              _buildTag('${contractMultiplier!.toInt()}x', Colors.grey.shade200, Colors.grey.shade700),
                            ],
                            if (showLeverage) ...[
                              const SizedBox(width: 8),
                              _buildTag('${maxLeverage}x', Colors.orange.shade100, Colors.orange.shade700),
                            ],
                            const SizedBox(width: 8),
                            _buildTag(typeInfo.label, typeInfo.color.withValues(alpha: 0.1), typeInfo.color),
                          ],
                        ),
                        if (result.type == SearchResultType.currency && result.currency?.name != null && result.currency!.name.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(result.currency!.name, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            hasPrice
                ? _buildPriceInfo(ticker!.lastPrice, ticker.changePercent)
                : Text('--', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  /// 获取类型信息
  ({String label, Color color}) _getTypeInfo(SearchResultType type) {
    return switch (type) {
      SearchResultType.spot => (label: '现货', color: Colors.blue),
      SearchResultType.futures => (label: '合约', color: Colors.orange),
      SearchResultType.currency => (label: '币种', color: Colors.green),
    };
  }

  /// 构建币种图标
  Widget _buildCurrencyIcon(String? logoUrl, String baseCurrency) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
      child: logoUrl != null
          ? ClipOval(
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(baseCurrency),
              ),
            )
          : _buildPlaceholderIcon(baseCurrency),
    );
  }

  /// 构建标签
  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500)),
    );
  }

  /// 构建价格信息
  Widget _buildPriceInfo(double price, double changePercent) {
    final isPositive = changePercent >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_formatPrice(price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 12, color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price.isNaN || price.isInfinite) return '0.00';
    
    final decimals = price >= 1000 ? 2 : price >= 1 ? 2 : price >= 0.01 ? 4 : 6;
    final formatted = price.toStringAsFixed(decimals);
    
    if (price >= 1000) {
      final parts = formatted.split('.');
      final integer = _addThousandSeparator(parts[0]);
      return parts.length > 1 ? '$integer.${parts[1]}' : integer;
    }
    
    return formatted;
  }

  String _addThousandSeparator(String number) {
    if (number.isEmpty) return '0';
    final reversed = number.split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, (i + 3 > reversed.length) ? reversed.length : i + 3));
    }
    return chunks.join(',').split('').reversed.join();
  }

  Widget _buildPlaceholderIcon(String baseCurrency) {
    return Center(
      child: Text(
        baseCurrency.isNotEmpty ? baseCurrency.substring(0, 1) : '?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }
}
