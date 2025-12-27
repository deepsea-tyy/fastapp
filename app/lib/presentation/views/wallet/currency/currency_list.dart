import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:flutter/material.dart';

/// 币种列表页面
class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _popularCurrencies = [
    {
      'currency': 'USDT',
      'currencyName': 'TetherUS',
      'price': null,
      'changePercent': null,
    },
    {
      'currency': 'BTC',
      'currencyName': 'Bitcoin',
      'price': 86907.60,
      'changePercent': 0.84,
    },
    {
      'currency': 'BNB',
      'currencyName': 'BNB',
      'price': 830.21,
      'changePercent': 0.48,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketDataStore = getIt<MarketDataStore>();

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
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索币种',
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
                  });
                },
              ),
            ),
          ),
          // 热门币种列表
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '热门',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _popularCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = _popularCurrencies[index];
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
                      final currencyData =
                          marketDataStore.getCurrency(currency['currency']);
                      return _buildCurrencyItem(currency, currencyData?.logo);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(Map<String, dynamic> currency, String? logoUrl) {
    final symbol = currency['currency'] as String;
    return InkWell(
      onTap: () {
        _showTopUpMethodBottomSheet(context, currency);
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
                color: logoUrl == null ? _getIconColor(symbol) : null,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl != null
                  ? Image.network(
                      logoUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          symbol.isNotEmpty ? symbol[0] : 'C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        symbol.isNotEmpty ? symbol[0] : 'C',
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
            if (currency['price'] != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency['price'].toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${currency['changePercent'].toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
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

  void _showTopUpMethodBottomSheet(
    BuildContext context,
    Map<String, dynamic> currency,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: const Text(
                '选择充值方式',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 选项列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTopUpOption(
                    context,
                    icon: Icons.download,
                    title: '链上充值',
                    description: '将其他交易平台/钱包中的加密货币存入币安账户',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: 跳转到链上充值页面
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTopUpOption(
                    context,
                    icon: Icons.account_circle_outlined,
                    title: '通过币安支付收款',
                    description: '接收其他币安用户转币',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: 跳转到币安支付收款页面
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTopUpOption(
                    context,
                    icon: Icons.people_outline,
                    title: 'C2C 交易',
                    description: '点对点交易,价格从优,支持本地支付方式',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: 跳转到C2C交易页面
                    },
                  ),
                ],
              ),
            ),
            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return Colors.orange;
      case 'ETH':
        return Colors.blue;
      case 'USDT':
        return Colors.green;
      case 'BNB':
        return Colors.amber;
      case 'SOL':
        return Colors.purple;
      case 'ADA':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
