import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../common/search_input_widget.dart';
import 'package:fastapp/presentation/store/search/search_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';

/// 搜索结果页面
class SearchResultScreen extends StatefulWidget {
  final String? initialKeyword;

  const SearchResultScreen({super.key, this.initialKeyword});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final MarketStore _marketStore;
  late final MarketDataStore _marketDataStore;

  String _selectedCategory = '所有';
  final List<String> _categories = ['所有', '现货', '合约', 'Ai交易', '理财'];

  List<_SearchGroup> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _marketStore = getIt<MarketStore>();
    _marketDataStore = getIt<MarketDataStore>();

    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _controller.text = widget.initialKeyword!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialKeyword!);
      });
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String keyword) {
    final query = keyword.trim().toUpperCase();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final spotResults = <_SearchResultItem>[];
    final futuresResults = <_SearchResultItem>[];

    // 辅助函数：查找 ticker 数据
    TickerData? findTicker(String symbol) {
      try {
        return _marketStore.tickerList.firstWhere(
          (t) => t.symbol == symbol || t.symbol.replaceAll('/', '') == symbol,
        );
      } catch (_) {
        return null;
      }
    }

    // 辅助函数：判断是否匹配
    bool matches(String text) => text.toUpperCase().contains(query);

    // 搜索现货交易对
    if (_selectedCategory == '所有' || _selectedCategory == '现货') {
      for (final pair in _marketDataStore.allSpotPairs) {
        if (matches(pair.symbol) || matches(pair.baseCurrencySymbol) || matches(pair.quoteCurrencySymbol)) {
          final ticker = findTicker(pair.symbol);
          final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
          final logo = currency?.logo;
          final logoUrl = logo != null && logo.isNotEmpty
              ? ImageUtils.formatSingleImagePath(logo)
              : null;

          spotResults.add(_SearchResultItem(
            symbol: pair.baseCurrencySymbol,
            quoteCurrency: pair.quoteCurrencySymbol,
            leverage: null,
            imageUrl: logoUrl,
            price: ticker?.lastPrice.toString() ?? '',
            changePercent: ticker?.changePercent ?? 0,
            ticker: ticker,
            isFutures: false,
          ));
        }
      }
    }

    // 搜索合约交易对
    if (_selectedCategory == '所有' || _selectedCategory == '合约') {
      for (final pair in _marketDataStore.allFutures) {
        if (matches(pair.symbol) || matches(pair.baseCurrencySymbol) || matches(pair.quoteCurrencySymbol)) {
          final ticker = findTicker(pair.symbol);
          final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
          final logo = currency?.logo;
          final logoUrl = logo != null && logo.isNotEmpty
              ? ImageUtils.formatSingleImagePath(logo)
              : null;

          futuresResults.add(_SearchResultItem(
            symbol: pair.baseCurrencySymbol,
            quoteCurrency: pair.quoteCurrencySymbol,
            leverage: '5x',
            imageUrl: logoUrl,
            price: ticker?.lastPrice.toString() ?? '',
            changePercent: ticker?.changePercent ?? 0,
            ticker: ticker,
            isFutures: true,
          ));
        }
      }
    }

    final groups = <_SearchGroup>[];
    if (spotResults.isNotEmpty) {
      groups.add(_SearchGroup(title: '现货', items: spotResults));
    }
    if (futuresResults.isNotEmpty) {
      groups.add(_SearchGroup(title: '合约', items: futuresResults));
    }

    setState(() => _searchResults = groups);
  }

  void _handleItemTap(_SearchResultItem item) {
    if (item.ticker != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarketDetailScreen(
            ticker: item.ticker!,
            isFutures: item.isFutures,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(child: _buildResultsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: '搜索',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      onChanged: _performSearch,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _searchResults = []);
                      },
                      child: Icon(Icons.clear, size: 18, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (_, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              _performSearch(_controller.text);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  )
                else
                  const SizedBox(height: 3),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          _controller.text.isEmpty ? '' : '暂无结果',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (_, groupIndex) {
        final group = _searchResults[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Icon(Icons.chevron_right, size: 20, color: Colors.grey)),
                ],
              ),
            ),
            ...group.items.map((item) => _buildResultItem(item)),
          ],
        );
      },
    );
  }

  Widget _buildResultItem(_SearchResultItem item) {
    return InkWell(
      onTap: () => _handleItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            if (item.imageUrl != null)
              ClipOval(
                child: Image.network(
                  item.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.currency_bitcoin, size: 20, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_bitcoin, size: 20, color: Colors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.symbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${item.quoteCurrency}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (item.leverage != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.leverage!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.price.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.price,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${item.changePercent >= 0 ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: item.changePercent >= 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchGroup {
  final String title;
  final List<_SearchResultItem> items;

  _SearchGroup({required this.title, required this.items});
}

class _SearchResultItem {
  final String symbol;
  final String quoteCurrency;
  final String? leverage;
  final String? imageUrl;
  final String price;
  final double changePercent;
  final TickerData? ticker;
  final bool isFutures;

  _SearchResultItem({
    required this.symbol,
    required this.quoteCurrency,
    this.leverage,
    this.imageUrl,
    required this.price,
    required this.changePercent,
    this.ticker,
    required this.isFutures,
  });
}
