import 'package:flutter/material.dart';

/// 币种列表页面
class CurrencySelect extends StatefulWidget {
  const CurrencySelect({super.key});

  @override
  State<CurrencySelect> createState() => _CurrencySelectState();
}

class _CurrencySelectState extends State<CurrencySelect> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  final List<Map<String, dynamic>> _currencies = [
    {
      'currency': 'USDT',
      'currencyName': 'TetherUS',
      'iconColor': Colors.teal,
      'iconText': 'T',
      'balance': 0.78221273,
      'cnyValue': 5.53,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 返回按钮和标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const Text(
                  '选择币种',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // 搜索栏和取消按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: '搜索币种/币对/合约',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _isSearching = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ),
                if (_isSearching) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _isSearching = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 标题和排序
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '币种列表',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.sort,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    // TODO: 排序功能
                  },
                ),
              ],
            ),
          ),
          // 币种列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _currencies.length,
              itemBuilder: (context, index) {
                final currency = _currencies[index];
                if (_searchQuery.isNotEmpty &&
                    !currency['currency']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) &&
                    !currency['currencyName']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink();
                }
                return _buildCurrencyItem(currency);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(Map<String, dynamic> currency) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(currency['currency']);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currency['iconColor'] as Color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  currency['iconText'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency['currency'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currency['currencyName'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (currency['balance'] as double).toStringAsFixed(8),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '≈ ¥${(currency['cnyValue'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
