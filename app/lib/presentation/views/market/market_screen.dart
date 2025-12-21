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
  int _selectedMainTab = 0; // 0: 加密货币, 1: 现货, 2: U本位合约, 3: 币本位合约, 4: 期权
  int _selectedCategoryTab = 0; // 0: 全部, 1: BNB Chain, 2: Solana, 3: RWA, 4: Meme, 5: F
  String? _sortField; // null, 'name', 'price', 'change'
  bool _sortAscending = true;

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
        _marketStore.loadAllTickers();
      }
    });
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
    final mainTabs = ['加密货币', '现货', 'U本位合约', '币本位合约', '期权'];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...mainTabs.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = _selectedMainTab == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedMainTab = index),
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
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
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryNavigation() {
    final categories = ['全部', 'BNB Chain', 'Solana', 'RWA', 'Meme', 'F'];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = _selectedCategoryTab == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryTab = index),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          }),
        ],
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
      onTap: () {
        setState(() {
          if (_sortField == field) {
            _sortAscending = !_sortAscending;
          } else {
            _sortField = field;
            _sortAscending = true;
          }
        });
      },
      child: Row(
        mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
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
    return Observer(
      builder: (_) {
        // 显示加载状态
        if (_marketStore.isLoading && _marketStore.tickerList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          );
        }

        // 显示错误状态
        if (_marketStore.errorMessage != null && _marketStore.tickerList.isEmpty) {
          return _buildErrorState(_marketStore.errorMessage ?? '加载失败');
        }

        var tickers = List.from(_marketStore.tickerList);

        // 过滤掉无效的数据（价格无效的项）
        tickers = tickers.where((ticker) {
          return !ticker.lastPrice.isNaN && 
                 !ticker.lastPrice.isInfinite && 
                 ticker.lastPrice > 0 &&
                 ticker.symbol.isNotEmpty;
        }).toList();

        // 排序
        if (_sortField != null && tickers.isNotEmpty) {
          tickers.sort(_compareTickers);
        }

        // 显示空数据状态
        if (tickers.isEmpty) {
          // 如果正在加载，显示加载状态；否则显示空状态
          if (_marketStore.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          }
          return _buildEmptyState();
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
                    fullName: currency?.name ?? _getFullName(baseCurrencySymbol),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MarketDetailScreen(ticker: ticker),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  int _compareTickers(dynamic a, dynamic b) {
    if (_sortField == null) return 0;

    int result = 0;
    switch (_sortField) {
      case 'name':
        result = (a.symbol ?? '').compareTo(b.symbol ?? '');
        break;
      case 'price':
        final priceA = a.lastPrice;
        final priceB = b.lastPrice;
        result = (priceA.isNaN || priceB.isNaN) ? 0 : priceA.compareTo(priceB);
        break;
      case 'change':
        final changeA = a.changePercent;
        final changeB = b.changePercent;
        result = (changeA.isNaN || changeB.isNaN) ? 0 : changeA.compareTo(changeB);
        break;
    }
    return _sortAscending ? result : -result;
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

  /// 从交易对符号中提取基础币种符号
  String _getBaseCurrencySymbol(String symbol) {
    if (symbol.contains('/')) {
      return symbol.split('/')[0];
    }
    return _marketDataStore.getSpotPair(symbol)?.baseCurrencySymbol ?? symbol;
  }

  String? _getFullName(String currency) {
    const fullNameMap = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'SOL': 'Solana',
      '1INCH': '1inch',
      'AAVE': 'Aave',
      'ACM': 'AC Milan Fan Token',
      'ADA': 'Cardano',
      'ALGO': 'Algorand',
      'ALICE': 'My Neighbor Alice',
      'ANKR': 'Ankr',
      'ARDR': 'Ardor',
    };
    return fullNameMap[currency];
  }
}
