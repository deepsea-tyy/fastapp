import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/presentation/views/common/pagination_controller.dart';
import 'widgets.dart';

/// 账户活动页面
class AccountActivityScreen extends StatefulWidget {
  const AccountActivityScreen({super.key});

  @override
  State<AccountActivityScreen> createState() => _AccountActivityScreenState();
}

class _AccountActivityScreenState extends State<AccountActivityScreen> {
  final UserApi _userApi = getIt<UserApi>();
  int _selectedTab = 0; // 0: 登录活动, 1: 安全操作记录
  final List<ActivityItem> _securityActivities = [];
  
  late final PaginationController<ActivityItem> _paginationController;

  @override
  void initState() {
    super.initState();
    _paginationController = PaginationController<ActivityItem>(
      pageSize: 20,
      onStateChanged: () => setState(() {}),
      isMounted: () => mounted,
      loadDataCallback: _loadData,
    );
    _paginationController.init();
    _paginationController.loadMore();
  }

  @override
  void dispose() {
    _paginationController.dispose();
    super.dispose();
  }

  Future<List<ActivityItem>> _loadData(int page, int pageSize) async {
    try {
      final response = await _userApi.getLoginLogs(page: page, pageSize: pageSize);
      final code = response['code'] as int?;
      
      if (code == 200) {
        final data = response['data'] as Map<String, dynamic>?;
        // 处理 simplePaginate 返回的数据结构
        // 可能是 {list: {data: [...], has_more: true}} 或 {list: [...]}
        dynamic listData = data?['list'];
        List<dynamic> list = [];
        
        if (listData is Map) {
          // 如果是 Paginator 对象，提取 data 数组
          list = listData['data'] as List<dynamic>? ?? [];
        } else if (listData is List) {
          // 如果直接是数组
          list = listData;
        }
        
        return list.map((item) {
          final map = item as Map<String, dynamic>;
          // 构建来源信息（操作系统 + 位置）
          final os = map['os'] as String? ?? '';
          final country = map['country'] as String? ?? '';
          final region = map['region'] as String? ?? '';
          final city = map['city'] as String? ?? '';
          
          String source = os;
          if (country.isNotEmpty || region.isNotEmpty || city.isNotEmpty) {
            final locationParts = <String>[];
            if (country.isNotEmpty) locationParts.add(country);
            if (region.isNotEmpty) locationParts.add(region);
            if (city.isNotEmpty) locationParts.add(city);
            if (locationParts.isNotEmpty) {
              source = '$os · ${locationParts.join(' ')}';
            }
          }
          
          return ActivityItem(
            date: map['created_at'] as String? ?? '',
            source: source.isEmpty ? '未知' : source,
            status: '成功',
            ipAddress: map['ip'] as String? ?? '',
          );
        }).toList();
      } else {
        final message = response['message'] as String? ?? '获取登录日志失败';
        MessageService.error(message);
        return [];
      }
    } catch (e) {
      MessageService.error('获取登录日志失败: ${e.toString()}');
      return [];
    }
  }

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

  /// 构建活动列表
  Widget _buildActivityList() {
    final activities = _selectedTab == 0 
        ? _paginationController.dataList 
        : _securityActivities;
    
    if (activities.isEmpty && !_paginationController.isLoading) {
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

    return RefreshIndicator(
      onRefresh: _selectedTab == 0 
          ? () => _paginationController.refresh() 
          : () async {},
      child: ListView.builder(
        controller: _selectedTab == 0 
            ? _paginationController.scrollController 
            : null,
        padding: const EdgeInsets.all(16.0),
        itemCount: activities.length + (_selectedTab == 0 ? 1 : 0),
        itemBuilder: (context, index) {
          if (_selectedTab == 0 && index == activities.length) {
            return _paginationController.buildLoadMoreIndicator();
          }
          return _buildActivityItem(activities[index]);
        },
      ),
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
