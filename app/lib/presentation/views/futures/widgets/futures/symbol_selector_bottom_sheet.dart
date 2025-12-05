import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:flutter/material.dart';

/// 交易对选择底部弹窗（期货）
class SymbolSelectorBottomSheet extends StatefulWidget {
  const SymbolSelectorBottomSheet({super.key});

  @override
  State<SymbolSelectorBottomSheet> createState() => _SymbolSelectorBottomSheetState();
}

class _SymbolSelectorBottomSheetState extends State<SymbolSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '自选';
  final SpotTradeStore store = getIt<SpotTradeStore>();

  // 模拟数据
  final List<Map<String, dynamic>> _symbols = [
    {
      'name': 'BTCUSDT',
      'label': '永续',
      'price': '91944.9',
      'volume': '118.71亿 USDT',
      'change': '-1.44%',
      'isPositive': false,
      'isFavorite': true,
    },
    {
      'name': 'ETHUSDT',
      'label': '永续',
      'price': '3146.63',
      'volume': '138.21亿 USDT',
      'change': '-1.18%',
      'isPositive': false,
      'isFavorite': true,
    },
    {
      'name': 'BNBUSDT',
      'label': '永续',
      'price': '654.8',
      'volume': '45.32亿 USDT',
      'change': '+2.35%',
      'isPositive': true,
      'isFavorite': false,
    },
    {
      'name': 'SOLUSDT',
      'label': '永续',
      'price': '238.45',
      'volume': '67.89亿 USDT',
      'change': '+3.21%',
      'isPositive': true,
      'isFavorite': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredSymbols {
    final searchText = _searchController.text.toLowerCase();
    return _symbols.where((symbol) {
      final matchesSearch = searchText.isEmpty || 
          symbol['name'].toString().toLowerCase().contains(searchText);
      
      if (_selectedCategory == '自选') {
        return matchesSearch && symbol['isFavorite'] == true;
      }
      
      return matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          const SizedBox(height: 16),
          // 搜索框和市场异动按钮
          _buildSearchBar(),
          const SizedBox(height: 16),
          // 分类标签
          _buildCategoryTabs(),
          const SizedBox(height: 16),
          // 表头
          _buildTableHeader(),
          const SizedBox(height: 8),
          // 交易对列表
          Expanded(
            child: _buildSymbolList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 市场异动按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(
                  '市场异动',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['自选', '全部', '新币上架', '永续', 'USDC永续', '交割'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  '名称',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  '/',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '成交量',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade500),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '最新价格',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade500),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '24h涨跌',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade500),
              ],
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildSymbolList() {
    final filteredSymbols = _filteredSymbols;
    
    if (filteredSymbols.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSymbols.length,
      itemBuilder: (context, index) {
        final symbol = filteredSymbols[index];
        return _buildSymbolItem(symbol);
      },
    );
  }

  Widget _buildSymbolItem(Map<String, dynamic> symbol) {
    final isPositive = symbol['isPositive'] as bool;
    final isFavorite = symbol['isFavorite'] as bool;
    
    return InkWell(
      onTap: () {
        // 选择交易对
        store.setSelectedSymbol(symbol['name'] as String);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 名称和标签
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        symbol['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          symbol['label'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    symbol['volume'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // 价格
            Expanded(
              flex: 2,
              child: Text(
                symbol['price'],
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 涨跌幅
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    symbol['change'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.red.shade600 : Colors.green.shade600,
                    ),
                  ),
                ),
              ),
            ),
            // 收藏按钮
            SizedBox(
              width: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber.shade600 : Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    symbol['isFavorite'] = !isFavorite;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
