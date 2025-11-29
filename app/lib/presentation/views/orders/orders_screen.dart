import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/orders/order_store.dart';
import 'package:fastapp/presentation/views/common/app_bar.dart';
import 'package:fastapp/presentation/views/orders/widgets/order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 订单管理页面
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  final OrderStore _store = getIt<OrderStore>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _store.loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: '订单管理',
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => _store.refreshOrders(),
            tooltip: '刷新',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: '当前订单'),
            Tab(text: '历史订单'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 筛选器
          _buildFilterBar(context),
          
          // 订单列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Observer(
                  builder: (_) {
                    if (_store.isLoading && _store.currentOrders.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return OrderList(
                      orders: _store.currentOrders,
                      showCancelButton: true,
                    );
                  },
                ),
                Observer(
                  builder: (_) {
                    if (_store.isLoading && _store.historyOrders.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return OrderList(
                      orders: _store.historyOrders,
                      showCancelButton: false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final symbols = ['全部', 'BTC/USDT', 'ETH/USDT', 'BNB/USDT', 'SOL/USDT'];
    final statuses = ['全部', '待成交', '部分成交', '已成交', '已取消'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Observer(
              builder: (_) => DropdownButton<String?>(
                value: _store.selectedSymbol,
                hint: const Text('全部交易对'),
                isExpanded: true,
                underline: const SizedBox(),
                items: symbols.map((symbol) {
                  return DropdownMenuItem<String?>(
                    value: symbol == '全部' ? null : symbol,
                    child: Text(symbol),
                  );
                }).toList(),
                onChanged: (value) => _store.setSelectedSymbol(value),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Observer(
              builder: (_) => DropdownButton<String?>(
                value: _store.selectedStatus?.name,
                hint: const Text('全部状态'),
                isExpanded: true,
                underline: const SizedBox(),
                items: statuses.map((status) {
                  return DropdownMenuItem<String?>(
                    value: status == '全部' ? null : _getStatusName(status),
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    _store.setSelectedStatus(null);
                  } else {
                    // 这里需要根据状态名称找到对应的枚举值
                    // 简化处理，实际应该使用枚举
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getStatusName(String status) {
    switch (status) {
      case '待成交':
        return 'pending';
      case '部分成交':
        return 'partiallyFilled';
      case '已成交':
        return 'filled';
      case '已取消':
        return 'cancelled';
      default:
        return null;
    }
  }
}

