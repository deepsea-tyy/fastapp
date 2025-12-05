import 'package:flutter/material.dart';

/// 交易对选择器底部弹窗
class SymbolSelectorBottomSheet extends StatefulWidget {
  final String currentSymbol;
  final ValueChanged<String> onSymbolSelected;

  const SymbolSelectorBottomSheet({
    super.key,
    required this.currentSymbol,
    required this.onSymbolSelected,
  });

  @override
  State<SymbolSelectorBottomSheet> createState() => _SymbolSelectorBottomSheetState();

  static void show(
    BuildContext context, {
    required String currentSymbol,
    required ValueChanged<String> onSymbolSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SymbolSelectorBottomSheet(
        currentSymbol: currentSymbol,
        onSymbolSelected: onSymbolSelected,
      ),
    );
  }
}

class _SymbolSelectorBottomSheetState extends State<SymbolSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 1; // 默认选中"持有币种"
  String _searchQuery = '';

  final List<String> _tabs = ['自选', '持有币种', '新币', 'USDC', 'USDT', 'FDUSD'];

  // 模拟数据
  final List<Map<String, dynamic>> _symbols = [
    {
      'symbol': 'TON',
      'name': 'TON',
      'price': 1.599,
      'change24h': 6.39,
    },
    {
      'symbol': 'BTC',
      'name': 'BTC',
      'price': 43250.5,
      'change24h': 2.15,
    },
    {
      'symbol': 'ETH',
      'name': 'ETH',
      'price': 2650.8,
      'change24h': -1.23,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSymbols {
    if (_searchQuery.isEmpty) {
      return _symbols;
    }
    return _symbols
        .where((symbol) =>
            symbol['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            symbol['symbol'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 搜索栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
          ),

          // 标签栏
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 16.0 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTabIndex = index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.black87 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: 28,
                          height: 3,
                          child: isSelected
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 列表头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '名称',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    '最新价格',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    '24h涨跌',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 列表内容
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSymbols.length,
              itemBuilder: (context, index) {
                final symbol = _filteredSymbols[index];
                final isSelected = widget.currentSymbol == symbol['symbol'];
                final change24h = symbol['change24h'] as double;
                final isPositive = change24h >= 0;

                return InkWell(
                  onTap: () {
                    widget.onSymbolSelected(symbol['symbol'] as String);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade50 : Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 图标
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade200, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              (symbol['name'] as String).substring(0, 1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 名称
                        Expanded(
                          child: Text(
                            symbol['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // 最新价格
                        SizedBox(
                          width: 100,
                          child: Text(
                            symbol['price'].toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // 24h涨跌
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${isPositive ? '+' : ''}${change24h.toStringAsFixed(2)}%',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
