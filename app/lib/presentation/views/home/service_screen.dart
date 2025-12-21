import 'package:flutter/material.dart';
import 'widgets/quick/service_item_model.dart';
import 'widgets/quick/service_repository.dart';
import 'widgets/quick/service_constants.dart';
import 'widgets/quick/service_grid_components.dart';
import 'widgets/quick/quick_entrance_edit_screen.dart';

/// 服务页面
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {

  // 常用功能列表
  List<AppServiceItem> get _commonServices => ServiceRepository.getCommonServices();

  // 活动和奖励列表
  List<AppServiceItem> get _activityServices => ServiceRepository.getActivityServices();

  // 交易服务列表
  List<AppServiceItem> get _tradeServices => ServiceRepository.getTradeServices();

  // 理财服务列表
  List<AppServiceItem> get _financeServices => ServiceRepository.getFinanceServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServiceConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('服务中心'),
        actions: [
          // 快捷设置按钮
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: '编辑快捷入口',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuickEntranceEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 快捷设置提示卡片
          _buildQuickSettingBanner(),
          // 服务列表
          Expanded(
            child: ServiceTabView(
              sections: [
                ServiceSection(title: '常用功能', services: _commonServices),
                ServiceSection(title: '活动和奖励', services: _activityServices),
                ServiceSection(title: '交易', services: _tradeServices),
                ServiceSection(title: '理财', services: _financeServices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettingBanner() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
              color: Colors.blue.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard_customize,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '自定义快捷入口',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '从下方服务中选择您常用的功能',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuickEntranceEditScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('设置'),
          ),
        ],
      ),
    );
  }
}