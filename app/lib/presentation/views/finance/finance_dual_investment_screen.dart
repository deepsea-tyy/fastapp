import 'package:flutter/material.dart';
import 'models/finance_product.dart';
import 'constants/finance_constants.dart';
import 'widgets/common_widgets.dart';

/// 双币投资页面
class FinanceDualInvestmentScreen extends StatefulWidget {
  const FinanceDualInvestmentScreen({super.key});

  @override
  State<FinanceDualInvestmentScreen> createState() => _FinanceDualInvestmentScreenState();
}

class _FinanceDualInvestmentScreenState extends State<FinanceDualInvestmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCrypto = 'BTC';
  String _selectedPair = 'BTC/USDT';
  String _currentPrice = '89,441.75';
  
  // 期限选项
  final List<String> _durations = ['全部', '3 天', '4 天', '5 天', '6 天', '7 天', '11 天', '1 月'];
  int _selectedDurationIndex = 0;

  // 双币投资产品列表
  final List<DualInvestmentProduct> _products = [
    DualInvestmentProduct(
      targetPrice: '88,500',
      priceChange: '-1.05%',
      apr: '67.32%',
      expiryDate: '2025年12月8日',
    ),
    DualInvestmentProduct(
      targetPrice: '89,000',
      priceChange: '-0.49%',
      apr: '65.15%',
      expiryDate: '2025年12月8日',
    ),
    DualInvestmentProduct(
      targetPrice: '87,500',
      priceChange: '-2.17%',
      apr: '42.05%',
      expiryDate: '2025年12月8日',
    ),
    DualInvestmentProduct(
      targetPrice: '88,000',
      priceChange: '-1.61%',
      apr: '37.8%',
      expiryDate: '2025年12月8日',
    ),
    DualInvestmentProduct(
      targetPrice: '86,500',
      priceChange: '-3.28%',
      apr: '28.09%',
      expiryDate: '2025年12月8日',
    ),
    DualInvestmentProduct(
      targetPrice: '87,000',
      priceChange: '-2.72%',
      apr: '26.08%',
      expiryDate: '2025年12月8日',
    ),
    DualInvestmentProduct(
      targetPrice: '86,000',
      priceChange: '-3.84%',
      apr: '21.06%',
      expiryDate: '2025年12月8日',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinanceConstants.backgroundColor,
      appBar: FinanceAppBar(
        title: '双币投资',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab区域
          FinanceTabBar(
            controller: _tabController,
            tabs: const ['低买', '高卖'],
          ),
          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBuyLowTab(),
                _buildSellHighTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyLowTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 当前价格显示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '$_selectedPair 现货价格',
                  style: FinanceConstants.secondaryStyle(null),
                ),
                const Spacer(),
                Text(
                  _currentPrice,
                  style: FinanceConstants.headingStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 加密货币选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCryptoChip('BTC', Icons.currency_bitcoin, FinanceConstants.colorBTC),
                  const SizedBox(width: 8),
                  _buildCryptoChip('ETH', Icons.circle, FinanceConstants.colorETH),
                  const SizedBox(width: 8),
                  _buildCryptoChip('BNB', Icons.circle, FinanceConstants.colorBNB),
                  const SizedBox(width: 8),
                  _buildCryptoChip('SOL', Icons.circle, FinanceConstants.colorSOL),
                  const SizedBox(width: 8),
                  _buildCryptoChip('XRP', Icons.circle, Colors.black),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 交易对选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildPairChip('BTC/USDT'),
                const SizedBox(width: 8),
                _buildPairChip('BTC/USDC'),
                const SizedBox(width: 8),
                _buildPairChip('BTC/FDUSD'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 选择结算日期和目标价格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '选择结算日期和目标价格',
              style: FinanceConstants.headingStyle,
            ),
          ),
          const SizedBox(height: 16),
          // 期限选择
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _durations.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _durations.length) {
                  return _buildCustomDateButton();
                }
                return _buildDurationChip(_durations[index], index);
              },
            ),
          ),
          const SizedBox(height: 24),
          // 列表表头
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '目标价格',
                  style: TextStyle(
                    fontSize: FinanceConstants.fontSizeMedium,
                    color: FinanceConstants.textTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  '年化收益率',
                  style: TextStyle(
                    fontSize: FinanceConstants.fontSizeMedium,
                    color: FinanceConstants.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '操作',
                  style: TextStyle(
                    fontSize: FinanceConstants.fontSizeMedium,
                    color: FinanceConstants.textTertiary,
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 到期日期提示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '结算于 2025年12月8日',
              style: FinanceConstants.secondaryStyle(null),
            ),
          ),
          const SizedBox(height: 16),
          // 产品列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = _products[index];
              return _buildProductItem(product);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSellHighTab() {
    return _buildBuyLowTab(); // 暂时复用低买页面结构
  }

  Widget _buildCryptoChip(String name, IconData icon, Color color) {
    final isSelected = _selectedCrypto == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCrypto = name;
          _selectedPair = '$name/USDT';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FinanceConstants.primaryColorLight : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? FinanceConstants.primaryColorDark : FinanceConstants.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: FinanceConstants.fontSizeRegular,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? FinanceConstants.textPrimary : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPairChip(String pair) {
    final isSelected = _selectedPair == pair;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPair = pair;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FinanceConstants.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusSmall),
          border: Border.all(
            color: isSelected ? FinanceConstants.textPrimary : FinanceConstants.borderColor,
          ),
        ),
        child: Text(
          pair,
          style: TextStyle(
            fontSize: FinanceConstants.fontSizeMedium,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(String duration, int index) {
    final isSelected = _selectedDurationIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDurationIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? FinanceConstants.primaryColorLight : Colors.transparent,
          borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusSmall),
          border: Border.all(
            color: isSelected ? FinanceConstants.primaryColorDark : FinanceConstants.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          duration,
          style: TextStyle(
            fontSize: FinanceConstants.fontSizeMedium,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? FinanceConstants.textPrimary : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusSmall),
        border: Border.all(
          color: FinanceConstants.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '1',
            style: TextStyle(
              fontSize: FinanceConstants.fontSizeMedium,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.calendar_today,
            size: 16,
            color: FinanceConstants.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(DualInvestmentProduct product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinanceConstants.backgroundColor,
        borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusMedium),
        border: Border.all(color: FinanceConstants.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    product.targetPrice,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceChange,
                    style: TextStyle(
                      fontSize: FinanceConstants.fontSizeNormal,
                      color: product.priceChange.startsWith('-')
                          ? FinanceConstants.errorColor
                          : FinanceConstants.positiveColor,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child:           Text(
            product.apr,
            style: TextStyle(
              fontSize: FinanceConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: FinanceConstants.successColor,
            ),
            textAlign: TextAlign.center,
          ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: SubscribeButton(onPressed: () {}),
            ),
          ),
        ],
      ),
    );
  }
}
