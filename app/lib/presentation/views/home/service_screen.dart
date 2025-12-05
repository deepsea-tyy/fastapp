import 'package:flutter/material.dart';

/// 服务页面
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 常用功能列表
  final List<ServiceItem> _commonServices = [
    ServiceItem(icon: Icons.swap_horiz, label: '划转'),
    ServiceItem(icon: Icons.account_balance_wallet, label: '币安钱包'),
    ServiceItem(icon: Icons.shopping_cart, label: '购买加密货币'),
    ServiceItem(icon: Icons.add_circle_outline, label: '买币/充币'),
    ServiceItem(icon: Icons.block, label: '禁用账户'),
    ServiceItem(icon: Icons.description, label: '账户结单'),
    ServiceItem(icon: Icons.science, label: '模拟交易'),
    ServiceItem(icon: Icons.rocket_launch, label: 'Launchpool'),
    ServiceItem(icon: Icons.account_balance, label: '数字货币充值'),
    ServiceItem(icon: Icons.card_giftcard, label: '邀请奖励'),
    ServiceItem(icon: Icons.payment, label: '支付'),
    ServiceItem(icon: Icons.receipt_long, label: '订单管理'),
    ServiceItem(icon: Icons.sell, label: '卖出至法币'),
    ServiceItem(icon: Icons.security, label: '账户安全'),
  ];

  // 活动和奖励列表
  final List<ServiceItem> _activityServices = [
    ServiceItem(icon: Icons.star, label: 'WOTD'),
    ServiceItem(icon: Icons.local_fire_department, label: '热门活动'),
    ServiceItem(icon: Icons.new_releases, label: '新币上线活动'),
    ServiceItem(icon: Icons.emoji_events, label: '交易合约赢奖励'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '服务',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索更多服务',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          // Tab导航
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.amber.shade700,
              unselectedLabelColor: Colors.black87,
              indicatorColor: Colors.amber.shade700,
              indicatorWeight: 2,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(text: '常用功能'),
                Tab(text: '活动和奖励'),
                Tab(text: '交易'),
                Tab(text: '理财'),
                Tab(text: '金融业务'),
                Tab(text: '资讯'),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommonServicesTab(),
                _buildActivityServicesTab(),
                _buildEmptyTab('交易'),
                _buildEmptyTab('理财'),
                _buildEmptyTab('金融业务'),
                _buildEmptyTab('资讯'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceGrid(_commonServices),
          const SizedBox(height: 24),
          const Text(
            '活动和奖励',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildServiceGrid(_activityServices),
        ],
      ),
    );
  }

  Widget _buildActivityServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildServiceGrid(_activityServices),
    );
  }

  Widget _buildEmptyTab(String title) {
    return Center(
      child: Text(
        '$title 功能开发中',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildServiceGrid(List<ServiceItem> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return _buildServiceItem(item);
      },
    );
  }

  Widget _buildServiceItem(ServiceItem item) {
    return GestureDetector(
      onTap: () {
        // TODO: 导航到对应功能页面
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 28,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final IconData icon;
  final String label;

  ServiceItem({required this.icon, required this.label});
}