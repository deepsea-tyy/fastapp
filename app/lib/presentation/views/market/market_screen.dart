import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/core/services/app_startup_state.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/presentation/views/market/market_search_screen.dart';
import 'package:fastapp/presentation/views/market/widgets/market_list_item.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';


/// 行情主页面（简化版）
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketStore _marketStore = getIt<MarketStore>();
  final MarketDataStore _marketDataStore = getIt<MarketDataStore>();
  int _selectedMainTab = 0;
  int _selectedCategoryTab = 0;
  String? _sortField;
  bool _sortAscending = true;

  static const _mainTabs = ['现货', 'U本位合约', '币本位合约', '期权'];

  @override
  void initState() {
    super.initState();
    afterPageContentDownloaded(() async {
      // 先加载市场数据配置（币种、现货交易对等）
      if (!_marketDataStore.isInitialized && !_marketDataStore.isLoading) {
        await _marketDataStore.loadMarketData();
      }
      // 等待市场数据加载完成后再加载 ticker 数据（需要从市场数据中获取交易对符号）
      if (_marketDataStore.isInitialized) {
        _loadTickersForCurrentTab();
        // WebSocket 连接已在 App 启动时完成，这里不需要再次连接
      }
    });
  }

  /// 根据当前一级筛选类型加载对应的 ticker 数据
  /// 仅在初始化时调用，用于首次加载数据
  void _loadTickersForCurrentTab() {
    if (!_marketDataStore.isInitialized) return;
    
    final validSymbols = _getValidSymbolsForTab(_selectedMainTab, _selectedCategoryTab);
    
    if (validSymbols.isEmpty) {
      _marketStore.tickerList.clear();
      return;
    }
    
    // 目前 loadAllTickers 只加载现货交易对
    // TODO: 后续需要扩展 API 支持加载合约和期权的 ticker 数据
    if (_selectedMainTab == 0) {
      _marketStore.loadAllTickers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部搜索栏
            _buildSearchBar(),

            // 主导航栏
            _buildMainNavigation(),

            // 次级分类导航
            _buildCategoryNavigation(),

            // 列表头部
            _buildListHeader(),

            // 内容区域
            Expanded(
              child: _buildMarketList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MarketSearchScreen()),
        ),
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
                child: Text(
                  '搜索币种/币对/合约',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainNavigation() {
    return _buildHorizontalTabBar(
      tabs: _mainTabs,
      selectedIndex: _selectedMainTab,
      onTap: (index) => setState(() => _selectedMainTab = index),
      itemMargin: const EdgeInsets.only(right: 24),
      showBottomBorder: true,
    );
  }

  Widget _buildCategoryNavigation() {
    return Observer(
      builder: (_) {
        final chains = _marketDataStore.chains;
        final categories = ['全部', ...chains];
        return _buildHorizontalTabBar(
          tabs: categories,
          selectedIndex: _selectedCategoryTab,
          onTap: (index) => setState(() => _selectedCategoryTab = index),
          itemMargin: const EdgeInsets.only(right: 16),
          showBottomBorder: false,
        );
      },
    );
  }

  Widget _buildHorizontalTabBar({
    required List<String> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTap,
    required EdgeInsets itemMargin,
    required bool showBottomBorder,
  }) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: itemMargin,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: showBottomBorder
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    )
                  : null,
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildSortHeader('名称', 'name'),
          ),
          Expanded(
            flex: 3,
            child: _buildSortHeader('最新价格', 'price', isRight: true),
          ),
          Expanded(
            flex: 2,
            child: _buildSortHeader('24h涨跌', 'change', isRight: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSortHeader(String label, String field, {bool isRight = false}) {
    final isSelected = _sortField == field;
    return GestureDetector(
      onTap: () => setState(() {
        if (_sortField == field) {
          if (_sortAscending) {
            // 第二次点击：切换为降序
            _sortAscending = false;
          } else {
            // 第三次点击：清除排序
            _sortField = null;
            _sortAscending = true;
          }
        } else {
          // 切换到新字段：默认升序
          _sortField = field;
          _sortAscending = true;
        }
      }),
      child: Row(
        mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Icon(
            isSelected
                ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketList() {
    final selectedMainTab = _selectedMainTab;
    final selectedCategoryTab = _selectedCategoryTab;
    final sortField = _sortField;  // 捕获排序字段
    final sortAscending = _sortAscending;  // 捕获排序方向

    return Observer(
      builder: (_) {
        // 显示加载状态
        if (_marketStore.isLoading && _marketStore.tickerList.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }

        // 显示错误状态
        if (_marketStore.errorMessage != null && _marketStore.tickerList.isEmpty) {
          return _buildErrorState(_marketStore.errorMessage ?? '加载失败');
        }

        final validSymbols = _getValidSymbolsForTab(selectedMainTab, selectedCategoryTab);
        final tickerMap = _buildValidTickerMap();

        var tickers = validSymbols
            .where((symbol) => tickerMap.containsKey(symbol))
            .map((symbol) => tickerMap[symbol]!)
            .toList();

        if (sortField != null && tickers.isNotEmpty) {
          tickers.sort((a, b) {
            final result = switch (sortField) {
              'name' => (a.symbol ?? '').compareTo(b.symbol ?? ''),
              'price' => _compareNumbers(a.lastPrice, b.lastPrice),
              'change' => _compareNumbers(a.changePercent, b.changePercent),
              _ => 0,
            };
            return sortAscending ? result : -result;
          });
        }

        // 显示空数据状态
        if (tickers.isEmpty) {
          return _marketStore.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.amber))
              : _buildEmptyState();
        }

        return Column(
          children: [
            // 部分加载进度提示
            if (_marketStore.isPartiallyLoaded && _marketStore.totalTickerCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.amber.shade50,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '正在加载更多数据 (${_marketStore.loadedTickerCount}/${_marketStore.totalTickerCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // 列表内容
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _marketStore.refreshTickers(),
                color: Colors.amber,
                child: ListView.builder(
                  itemCount: tickers.length,
                  itemBuilder: (context, index) {
                    final ticker = tickers[index];
                    final baseCurrencySymbol = _getBaseCurrencySymbol(ticker.symbol);
                    final currency = _marketDataStore.getCurrency(baseCurrencySymbol);

                    return MarketListItem(
                      ticker: ticker,
                      logoUrl: currency?.logo != null
                          ? ImageUtils.formatSingleImagePath(currency!.logo)
                          : null,
                      fullName: currency?.name,
                      onTap: () {
                        // 直接根据一级筛选判断是否是合约类型
                        // _selectedMainTab: 0=现货, 1=U本位合约, 2=币本位合约, 3=期权
                        final isFutures = _selectedMainTab == 1 || _selectedMainTab == 2;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MarketDetailScreen(
                              ticker: ticker,
                              isFutures: isFutures,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _compareTickers(dynamic a, dynamic b) {
    if (_sortField == null) return 0;

    final result = switch (_sortField) {
      'name' => (a.symbol ?? '').compareTo(b.symbol ?? ''),
      'price' => _compareNumbers(a.lastPrice, b.lastPrice),
      'change' => _compareNumbers(a.changePercent, b.changePercent),
      _ => 0,
    };
    return _sortAscending ? result : -result;
  }

  int _compareNumbers(num a, num b) {
    return (a.isNaN || b.isNaN) ? 0 : a.compareTo(b);
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _marketStore.refreshTickers(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 64),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请下拉刷新或稍后再试',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _marketStore.refreshTickers(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('刷新'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 根据指定的 tab 和 category 获取有效交易对符号列表
  List<String> _getValidSymbolsForTab(int mainTab, int categoryTab) {
    final chains = _marketDataStore.chains;
    final selectedChain = categoryTab > 0 && categoryTab <= chains.length ? chains[categoryTab - 1] : null;

    final pairs = switch (mainTab) {
      0 => _marketDataStore.allSpotPairs,
      1 => _marketDataStore.usdtFutures,
      2 => _marketDataStore.coinFutures,
      3 => _marketDataStore.allOptions,
      _ => <dynamic>[],
    };

    return pairs
        .where((pair) => pair.isEnabled && (selectedChain == null || _isPairMatchChain(pair, selectedChain)))
        .map((pair) => pair.symbol as String)
        .toList();
  }

  /// 检查交易对是否匹配指定链
  bool _isPairMatchChain(dynamic pair, String chain) {
    final currency = _marketDataStore.getCurrency(pair.baseCurrencySymbol);
    return currency != null && !currency.isBaseCurrency && pair.chain == chain;
  }

  /// 构建有效的 ticker 映射
  Map<String, dynamic> _buildValidTickerMap() {
    return Map.fromEntries(
      _marketStore.tickerList
          .where((t) => t.symbol.isNotEmpty && t.lastPrice > 0 && t.lastPrice.isFinite)
          .map((ticker) => MapEntry(ticker.symbol, ticker)),
    );
  }

  /// 从交易对符号中提取基础币种符号
  String _getBaseCurrencySymbol(String symbol, [int? mainTab]) {
    if (symbol.contains('/')) return symbol.split('/')[0];

    final tab = mainTab ?? _selectedMainTab;
    return switch (tab) {
      0 => _marketDataStore.getSpotPair(symbol)?.baseCurrencySymbol,
      1 || 2 => _marketDataStore.getFuturesPair(symbol)?.baseCurrencySymbol,
      3 => _marketDataStore.getOptionPair(symbol)?.baseCurrencySymbol,
      _ => null,
    } ?? symbol;
  }

}
