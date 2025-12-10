import 'package:flutter/material.dart';
import 'widgets.dart';

/// 账户活动页面
class AccountActivityScreen extends StatefulWidget {
  const AccountActivityScreen({super.key});

  @override
  State<AccountActivityScreen> createState() => _AccountActivityScreenState();
}

class _AccountActivityScreenState extends State<AccountActivityScreen> {
  int _selectedTab = 0; // 0: 登录活动, 1: 安全操作记录
  String _selectedTimeRange = '1个月';
  String _selectedStatus = '全部';

  // TODO: 从后端获取数据
  final List<ActivityItem> _loginActivities = [
    ActivityItem(
      date: '2025-11-29 21:13:44',
      source: 'android',
      status: '成功',
      ipAddress: '109.110.162.168',
    ),
    ActivityItem(
      date: '2025-11-29 21:13:42',
      source: 'android',
      status: '成功',
      ipAddress: '109.110.162.168',
    ),
    ActivityItem(
      date: '2025-11-28 08:22:52',
      source: 'android',
      status: '成功',
      ipAddress: '109.110.162.168',
    ),
  ];

  final List<ActivityItem> _securityActivities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(title: '账户活动'),
            // 标签页
            _buildTabBar(),
            // 筛选器
            _buildFilters(),
            // 活动列表
            Expanded(
              child: _buildActivityList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标签页
  Widget _buildTabBar() {
    final tabs = ['登录活动', '安全操作记录'];
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTab == index;
          
          return Padding(
            padding: EdgeInsets.only(right: index < tabs.length - 1 ? 24.0 : 0),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onSurface 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
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
        }).toList(),
      ),
    );
  }

  /// 构建筛选器
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildFilterDropdown(
            value: _selectedTimeRange,
            items: ['1个月', '3个月', '6个月', '1年', '全部'],
            onChanged: (value) {
              setState(() => _selectedTimeRange = value!);
            },
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(
            value: _selectedStatus,
            items: ['全部', '成功', '失败'],
            onChanged: (value) {
              setState(() => _selectedStatus = value!);
            },
          ),
        ],
      ),
    );
  }

  /// 构建筛选下拉框
  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        isDense: true,
      ),
    );
  }

  /// 构建活动列表
  Widget _buildActivityList() {
    final activities = _selectedTab == 0 ? _loginActivities : _securityActivities;
    
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无活动记录',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _buildActivityItem(activities[index]);
      },
    );
  }

  /// 构建活动项
  Widget _buildActivityItem(ActivityItem item) {
    return SettingCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态和日期
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.status,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 来源
          _buildInfoRow('来源', item.source),
          const SizedBox(height: 8),
          // 状态
          _buildInfoRow('状态', item.status),
          const SizedBox(height: 8),
          // IP地址
          _buildInfoRow('IP地址', item.ipAddress),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// 活动项数据模型
class ActivityItem {
  final String date;
  final String source;
  final String status;
  final String ipAddress;

  ActivityItem({
    required this.date,
    required this.source,
    required this.status,
    required this.ipAddress,
  });
}
