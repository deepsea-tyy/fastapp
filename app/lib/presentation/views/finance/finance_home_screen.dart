import 'package:flutter/material.dart';
import 'finance_product_detail_screen.dart';
import 'finance_dual_investment_screen.dart';
import 'finance_on_chain_screen.dart';
import 'models/finance_product.dart';
import 'constants/finance_constants.dart';
import 'widgets/common_widgets.dart';

/// 理财主页
class FinanceHomeScreen extends StatefulWidget {
  const FinanceHomeScreen({super.key});

  @override
  State<FinanceHomeScreen> createState() => _FinanceHomeScreenState();
}

class _FinanceHomeScreenState extends State<FinanceHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 推荐产品列表
  final List<FinanceProduct> _recommendedProducts = [
    FinanceProduct.recommended(
      name: 'USDT',
      icon: Icons.account_balance_wallet,
      iconColor: FinanceConstants.colorUSDT,
      rate: '6.51%',
    ),
    FinanceProduct.recommended(
      name: 'TRX',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorTRX,
      rate: '2.3%',
    ),
    FinanceProduct.recommended(
      name: 'ETH',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorETH,
      rate: '2.4%',
    ),
  ];

  // 低风险产品列表
  final List<FinanceProduct> _lowRiskProducts = [
    FinanceProduct.simple(
      name: 'USDC',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorUSDC,
      rate: '4.91%',
    ),
    FinanceProduct.simple(
      name: 'BTC',
      icon: Icons.currency_bitcoin,
      iconColor: FinanceConstants.colorBTC,
      rate: '0.27%',
    ),
    FinanceProduct.simple(
      name: 'SOL',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorSOL,
      rate: '1.8%~5.1%',
    ),
    FinanceProduct.simple(
      name: 'USDT',
      icon: Icons.account_balance_wallet,
      iconColor: FinanceConstants.colorUSDT,
      rate: '6.51%',
    ),
    FinanceProduct.simple(
      name: 'TRX',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorTRX,
      rate: '1.56%~2.3%',
    ),
    FinanceProduct.simple(
      name: 'ETH',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorETH,
      rate: '1.37%~2.4%',
    ),
  ];

  // 高收益产品列表 - 双币投资
  final List<FinanceProduct> _dualInvestmentProducts = [
    FinanceProduct.simple(
      name: 'BTC',
      icon: Icons.currency_bitcoin,
      iconColor: FinanceConstants.colorBTC,
      rate: '3.65%~109.55%',
    ),
    FinanceProduct.simple(
      name: 'ETH',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorETH,
      rate: '3.66%~160.09%',
    ),
    FinanceProduct.simple(
      name: 'BNB',
      icon: Icons.circle,
      iconColor: FinanceConstants.colorBNB,
      rate: '3.65%~71.33%',
    ),
  ];

  // 链上赚币产品列表
  final List<FinanceProduct> _onChainProducts = [
    FinanceProduct.simple(
      name: 'BTC 质押',
      icon: Icons.currency_bitcoin,
      iconColor: FinanceConstants.colorBTC,
      rate: '0.7%~1.6%',
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
        title: '理财',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 推荐区域（固定在顶部）
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '推荐',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          '更多',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 自动申购卡片
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '自动申购',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '点击开始自动理财。',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '激活',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 双币投资卡片
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FinanceDualInvestmentScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade100,
                            Colors.blue.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '双币投资',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '高年化收益，低风险投资',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '查看',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 推荐产品卡片
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return RecommendedProductCard(
                          product: _recommendedProducts[index],
                          onTap: () => _navigateToDetail(_recommendedProducts[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tab区域
          FinanceTabBar(
            controller: _tabController,
            tabs: const ['低风险', '高收益'],
          ),
          const SizedBox(height: 16),
          // 产品列表表头
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  '产品',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                const Text(
                  '参考年化',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 80),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 产品列表（根据选中的Tab显示）
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 低风险产品列表
                ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _lowRiskProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return ProductListItem(
                      product: _lowRiskProducts[index],
                      onTap: () => _navigateToDetail(_lowRiskProducts[index]),
                    );
                  },
                ),
                // 高收益产品列表（分组显示）
                _buildHighYieldTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighYieldTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 双币投资分组
          SectionHeader(
            title: '双币投资',
            subtitle: '低买高卖，享高额收益',
            onTap: () => _navigateTo(const FinanceDualInvestmentScreen()),
          ),
          const SizedBox(height: 12),
          ..._dualInvestmentProducts.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ProductListItem(
                product: product,
                onTap: () => _navigateToDetail(product),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          // 链上赚币分组
          SectionHeader(
            title: '链上赚币',
            subtitle: '一键申购即可获得链上奖励',
            onTap: () => _navigateTo(const FinanceOnChainScreen()),
          ),
          const SizedBox(height: 12),
          ..._onChainProducts.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ProductListItem(
                product: product,
                onTap: () => _navigateToDetail(product),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void _navigateToDetail(FinanceProduct product) {
    _navigateTo(
      FinanceProductDetailScreen(
        productName: product.name,
        productRate: product.rate,
        productColor: product.iconColor,
        productIcon: product.icon,
      ),
    );
  }
}
