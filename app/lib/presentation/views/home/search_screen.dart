import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../common/search_input_widget.dart';
import 'package:fastapp/presentation/store/search/search_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/utils/icon_mapper.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/presentation/views/feed/widgets/feed_detail.dart';
import 'package:fastapp/data/network/models/search_index_item.dart';
import 'package:fastapp/presentation/views/home/search_result_screen.dart';

/// 搜索页面
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> _historyRecords = [];
  late final SearchStore _searchStore;
  late final MarketStore _marketStore;
  late final MarketDataStore _marketDataStore;
  late final SharedPreferenceHelper _sharedPrefHelper;

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );


  @override
  void initState() {
    super.initState();
    _searchStore = getIt<SearchStore>();
    _marketStore = getIt<MarketStore>();
    _marketDataStore = getIt<MarketDataStore>();
    _sharedPrefHelper = getIt<SharedPreferenceHelper>();
    _searchStore.refresh();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    final history = _sharedPrefHelper.searchHistory;
    setState(() {
      _historyRecords = history;
    });
  }

  void _addToHistory(String keyword) {
    if (keyword.trim().isEmpty) {
      return;
    }

    setState(() {
      _historyRecords.remove(keyword);
      _historyRecords.insert(0, keyword);
      // 最多保存 20 条历史记录
      if (_historyRecords.length > 20) {
        _historyRecords = _historyRecords.sublist(0, 20);
      }
    });

    _sharedPrefHelper.saveSearchHistory(_historyRecords);
  }

  Future<List<SearchResultItem>> _handleSearch(String keyword) async {
    final query = keyword.trim().toUpperCase();
    if (query.isEmpty) return [];

    final results = <SearchResultItem>[];
    final processedSymbols = <String>{};

    // 辅助函数：查找 ticker 数据
    TickerData? findTicker(String symbol) {
      try {
        final symbolNoSlash = symbol.replaceAll('/', '');
        return _marketStore.tickerList.firstWhere(
          (t) {
            final tSymbolNoSlash = t.symbol.replaceAll('/', '');
            return t.symbol == symbol || tSymbolNoSlash == symbolNoSlash;
          },
        );
      } catch (_) {
        return null;
      }
    }

    // 辅助函数：判断是否匹配
    bool matches(String text) => text.toUpperCase().contains(query);

    // 辅助函数：判断是否有有效价格
    bool hasValidPrice(TickerData? ticker) =>
        ticker != null &&
        !ticker.lastPrice.isNaN &&
        !ticker.lastPrice.isInfinite &&
        ticker.lastPrice > 0;

    // 搜索合约交易对
    for (final pair in _marketDataStore.allFutures) {
      if (matches(pair.symbol) || matches(pair.baseCurrencySymbol) || matches(pair.quoteCurrencySymbol)) {
        final ticker = findTicker(pair.symbol);
        final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
        final logo = currency?.logo;
        final logoUrl = logo != null && logo.isNotEmpty
            ? ImageUtils.formatSingleImagePath(logo)
            : null;

        results.add(SearchResultItem(
          id: pair.symbol,
          title: pair.baseCurrencySymbol,
          subtitle: '/${pair.quoteCurrencySymbol} · 合约',
          imageUrl: logoUrl,
          extra: {
            'tickerData': ticker?.toJson(),
            'isFutures': true,
            'contractMultiplier': pair.contractMultiplier,
            'maxLeverage': pair.maxLeverage,
          },
        ));
        processedSymbols.add(pair.baseCurrencySymbol);
      }
    }

    // 搜索现货交易对
    for (final pair in _marketDataStore.allSpotPairs) {
      if (matches(pair.symbol) || matches(pair.baseCurrencySymbol) || matches(pair.quoteCurrencySymbol)) {
        final ticker = findTicker(pair.symbol);
        final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
        final logo = currency?.logo;
        final logoUrl = logo != null && logo.isNotEmpty
            ? ImageUtils.formatSingleImagePath(logo)
            : null;

        results.add(SearchResultItem(
          id: pair.symbol,
          title: pair.baseCurrencySymbol,
          subtitle: '/${pair.quoteCurrencySymbol} · 现货',
          imageUrl: logoUrl,
          extra: {
            'tickerData': ticker?.toJson(),
            'isFutures': false,
          },
        ));
        processedSymbols.add(pair.baseCurrencySymbol);
      }
    }

    // 搜索币种（排除已添加的）
    for (final currency in _marketDataStore.allCurrencies) {
      if (!processedSymbols.contains(currency.symbol) &&
          (matches(currency.symbol) || (currency.name.isNotEmpty && matches(currency.name)))) {
        final logo = currency.logo;
        final logoUrl = logo != null && logo.isNotEmpty ? ImageUtils.formatSingleImagePath(logo) : null;

        results.add(SearchResultItem(
          id: currency.symbol,
          title: currency.symbol,
          subtitle: currency.name.isNotEmpty ? currency.name : '币种',
          imageUrl: logoUrl,
          extra: {'currencySymbol': currency.symbol},
        ));
      }
    }

    // 排序：有价格的优先
    results.sort((a, b) {
      final aTickerData = a.extra?['tickerData'];
      final bTickerData = b.extra?['tickerData'];
      final aTicker = aTickerData != null ? TickerData.fromJson(aTickerData as Map<String, dynamic>) : null;
      final bTicker = bTickerData != null ? TickerData.fromJson(bTickerData as Map<String, dynamic>) : null;

      final aHasPrice = hasValidPrice(aTicker);
      final bHasPrice = hasValidPrice(bTicker);

      if (aHasPrice != bHasPrice) return aHasPrice ? -1 : 1;
      return 0;
    });

    return results;
  }

  void _handleItemTap(SearchResultItem item) {
    _addToHistory(item.title);

    // 如果 extra 字段包含 TickerData，跳转到交易详情页
    if (item.extra != null && item.extra!.containsKey('tickerData') && item.extra!['tickerData'] != null) {
      final tickerData = TickerData.fromJson(item.extra!['tickerData'] as Map<String, dynamic>);
      final isFutures = item.extra!['isFutures'] as bool? ?? false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarketDetailScreen(
            ticker: tickerData,
            isFutures: isFutures,
          ),
        ),
      );
    } else {
      // 没有行情数据时，显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.title} 暂无行情数据')),
      );
    }
  }

  /// 类型映射：targetType -> FeedComment.target_type
  static const _targetTypeMap = {
    'feed': 1,        // 短贴
    'feed_article': 2, // 标题贴
    'notice': 3,      // 公告
    'news': 4,        // 新闻
    'article': 6,     // 文章
  };

  /// 处理热搜排行榜项点击
  void _handleRankingItemTap(SearchIndexItem item) {
    final type = _targetTypeMap[item.targetType];

    if (type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('不支持的内容类型: ${item.targetType}')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedDetail(
          postId: item.targetId,
          userId: 0,
          username: '',
          time: '',
          content: '',
          title: item.title,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHistorySection(),
                    _buildHotKeywordsSection(),
                    _buildUpcomingSection(),
                    _buildHotSearchSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Observer(
      builder: (_) {
        final topKeyword = _searchStore.topHotKeyword;
        final hasKeyword = topKeyword?.keyword?.isNotEmpty ?? false;
        final hasIcon = topKeyword?.icon?.isNotEmpty ?? false;

        // 确定图标颜色，参考 top_bar.dart 的处理方式
        final iconColor = hasIcon
            ? (IconMapper.parseColor(topKeyword!.color) ??
                IconMapper.getColor(topKeyword!.icon))
            : null;

        return SearchInputWidget(
          hintText: hasKeyword ? topKeyword!.keyword : '搜索',
          prefixIcon: hasIcon ? IconMapper.getIcon(topKeyword!.icon) : Icons.search,
          iconColor: iconColor,
          backgroundColor: Colors.grey[100],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          autofocus: true,
          showBackButton: true,
          onBack: () => Navigator.pop(context),
          onSearch: _handleSearch,
          onItemTap: _handleItemTap,
          onNavigateToSearch: _addToHistory,
        );
      },
    );
  }

  Widget _buildHistorySection() {
    if (_historyRecords.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('历史记录', style: _sectionTitleStyle),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () {
                  setState(() => _historyRecords.clear());
                  _sharedPrefHelper.clearSearchHistory();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _historyRecords.map((record) {
              return GestureDetector(
                onTap: () {
                  _addToHistory(record);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultScreen(
                        initialKeyword: record,
                      ),
                    ),
                  );
                },
                child: _buildTag(record, const Color(0xFFEEEEEE)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotKeywordsSection() {
    return Observer(
      builder: (_) {
        if (_searchStore.hotKeywords.length <= 1) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('热搜', style: _sectionTitleStyle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _searchStore.hotKeywords.skip(1).map((keyword) {
                  final color = (keyword.color != null
                      ? IconMapper.parseColor(keyword.color!)
                      : null) ?? const Color(0xFFE0E0E0);
                  return GestureDetector(
                    onTap: () {
                      _addToHistory(keyword.keyword);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultScreen(
                            initialKeyword: keyword.keyword,
                          ),
                        ),
                      );
                    },
                    child: _buildTag(keyword.keyword, color, Colors.white),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('即将开启', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASTERIDR 即将上线',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '结束日期 2025-11-29',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotSearchSection() {
    return Observer(
      builder: (_) {
        if (_searchStore.rankingList.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('热搜排行榜', style: _sectionTitleStyle),
              const SizedBox(height: 12),
              ..._searchStore.rankingList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return InkWell(
                  onTap: () => _handleRankingItemTap(item),
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: index < 3 ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.tags.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                ...item.tags.take(2).indexed.map((record) {
                                  final (index, tag) = record;
                                  return Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: index == 0 ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(tag, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                        if (item.badge != null) _buildBadge(item.badge!),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTag(String text, Color bgColor, [Color? textColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: text == 'HOT' ? Colors.amber : Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
