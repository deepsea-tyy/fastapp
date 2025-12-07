import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

/// 交易对选择底部弹窗
class SymbolSelectorBottomSheet extends StatefulWidget {
  const SymbolSelectorBottomSheet({super.key});

  @override
  State<SymbolSelectorBottomSheet> createState() => _SymbolSelectorBottomSheetState();
}

class _SymbolSelectorBottomSheetState extends State<SymbolSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '新币';

  // 模拟数据
  final List<Map<String, dynamic>> _symbols = [
    {'name': 'AT', 'price': '0.1368', 'change': '-1.51%', 'isPositive': false, 'icon': '🔺'},
    {'name': 'BANK', 'price': '0.0471', 'change': '+2.61%', 'isPositive': true, 'icon': '🏦'},
  ];

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
          buildDragHandle(),
          const SizedBox(height: 16),
          // 搜索框
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['自选', '持有币种', '新币', 'USDC', 'USDT', 'FDUSD', 'USDⓈ'];
    
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
            padding: const EdgeInsets.only(right: 16),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
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
            flex: 2,
            child: Text(
              '名称',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '最新价格',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '24h 涨跌',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _symbols.length,
      itemBuilder: (context, index) {
        final symbol = _symbols[index];
        return _buildSymbolItem(symbol);
      },
    );
  }

  Widget _buildSymbolItem(Map<String, dynamic> symbol) {
    final isPositive = symbol['isPositive'] as bool;
    
    return InkWell(
      onTap: () {
        // TODO: 选择交易对
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // 图标和名称
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        symbol['name'].substring(0, 1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    symbol['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
            // 涨跌幅
            Expanded(
              flex: 2,
              child: Text(
                symbol['change'],
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
