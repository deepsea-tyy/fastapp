import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// C2C 交易页面
class C2CScreen extends StatefulWidget {
  const C2CScreen({super.key});

  @override
  State<C2CScreen> createState() => _C2CScreenState();
}

class _C2CScreenState extends State<C2CScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCurrency = 'USDT';
  String _selectedPayment = '全部';

  final List<String> _currencies = ['USDT', 'BTC', 'ETH', 'USDC'];
  final List<String> _payments = ['全部', '支付宝', '微信', '银行卡', 'PayPal'];

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
      appBar: AppBar(
        title: const Text('C2C 交易'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: 跳转到订单历史
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTradeList(true),
                _buildTradeList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderTheme.defaultColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('币种', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currencies.length,
              itemBuilder: (context, index) {
                final currency = _currencies[index];
                final isSelected = _selectedCurrency == currency;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(currency, isSelected, () {
                    setState(() => _selectedCurrency = currency);
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text('支付方式', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                final isSelected = _selectedPayment == payment;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(payment, isSelected, () {
                    setState(() => _selectedPayment = payment);
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final backgroundTheme = context.backgroundTheme;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : backgroundTheme.input,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : textTheme.primary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderTheme.defaultColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: textTheme.primary,
        unselectedLabelColor: textTheme.secondary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: '购买'),
          Tab(text: '出售'),
        ],
      ),
    );
  }

  Widget _buildTradeList(bool isBuy) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildTradeItem(isBuy);
      },
    );
  }

  Widget _buildTradeItem(bool isBuy) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;
    final statusTheme = context.statusTheme;
    final borderTheme = context.borderTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTheme.defaultColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundTheme.input,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.person, size: 24, color: textTheme.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '商家名称',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '认证',
                            style: TextStyle(
                              fontSize: 10,
                              color: statusTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('1256单', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
                        const SizedBox(width: 8),
                        Text('99.8%', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('价格', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
                  const SizedBox(height: 4),
                  Text(
                    '¥7.18',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textTheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('数量', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
                  const SizedBox(height: 4),
                  Text(
                    '50,000 $_selectedCurrency',
                    style: TextStyle(fontSize: 14, color: textTheme.primary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('限额', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
                  const SizedBox(height: 4),
                  Text(
                    '¥100-¥50,000',
                    style: TextStyle(fontSize: 14, color: textTheme.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPaymentMethod(Icons.account_balance_wallet, '支付宝'),
              const SizedBox(width: 8),
              _buildPaymentMethod(Icons.payment, '微信'),
              const SizedBox(width: 8),
              _buildPaymentMethod(Icons.account_balance, '银行卡'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 跳转到交易详情
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBuy ? statusTheme.success : statusTheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                isBuy ? '购买 $_selectedCurrency' : '出售 $_selectedCurrency',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String label) {
    final backgroundTheme = context.backgroundTheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundTheme.input,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textTheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textTheme.secondary),
          ),
        ],
      ),
    );
  }
}
