import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/views/market/market_detail_screen.dart';
import 'package:fastapp/presentation/views/market/market_search_screen.dart';
import 'package:fastapp/presentation/views/market/widgets/market_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 行情主页面
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketStore _marketStore = getIt<MarketStore>();
  int _selectedMainTab = 1; // 0: 自选, 1: 市场, 2: Alpha, 3: 金融增长, 4: 广场, 5: 大数据
  int _selectedCategoryTab = 0; // 0: 加密货币, 1: 现货, 2: U本位合约, 3: 币本位合约, 4: 期权
  int _selectedFilterTab = 0; // 0: 全部, 1: BNB Chain, 2: Solana, 3: RWA, 4: Meme, 5: F
  String? _sortField; // null, 'name', 'price', 'change'
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marketStore.loadAllTickers();
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
                child: Text('搜索币种/币对/合约', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
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
    return Column(
      children: [
        _buildHorizontalTabList(
          tabs: ['全部', 'BNB Chain', 'Solana', 'RWA', 'Meme', 'F'],
          selectedIndex: _selectedCategoryTab,
          onTap: (index) => setState(() => _selectedCategoryTab = index),
          itemBuilder: (label, isSelected) => Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalTabList({
    required List<String> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTap,
    required Widget Function(String label, bool isSelected) itemBuilder,
    Widget? trailing,
  }) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = selectedIndex == index;
            final isLast = index == tabs.length - 1;
            final marginRight = trailing == null && isLast ? 0.0 : (trailing == null ? 16.0 : 8.0);
            
            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                margin: EdgeInsets.only(right: marginRight),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: itemBuilder(entry.value, isSelected),
              ),
            );
          }),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildSortHeader('名称', 'name')),
          Expanded(flex: 3, child: _buildSortHeader('最新价格', 'price', isRight: true)),
          Expanded(flex: 2, child: _buildSortHeader('24h 涨跌', 'change', isRight: true)),
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
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
          return Center(
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
        
        // 排序
        if (_sortField != null && tickers.isNotEmpty) {
          tickers.sort(_compareTickers);
        }

        // 显示空数据状态
        if (tickers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _marketStore.refreshTickers(),
          color: Colors.amber,
          child: ListView.builder(
            itemCount: tickers.length,
            itemBuilder: (context, index) {
              final ticker = tickers[index];
              final parts = ticker.symbol.split('/');
              final baseCurrency = parts.isNotEmpty ? parts[0] : ticker.symbol;
              
              return MarketListItem(
                ticker: ticker,
                fullName: _getFullName(baseCurrency),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MarketDetailScreen(ticker: ticker)),
                ),
              );
            },
          ),
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
            child: Text(message, style: TextStyle(color: Colors.grey.shade600, fontSize: 14), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _marketStore.refreshTickers(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87),
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
          Text('暂无数据', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('请下拉刷新或稍后再试', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _marketStore.refreshTickers(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('刷新'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87),
          ),
        ],
      ),
    );
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

