import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  static const _pageSize = 20;
  static const _tabs = ['登录记录', '安全操作记录'];
  static const _dateInputFormat = 'yyyy-MM-dd HH:mm:ss';
  static const _dateOutputFormat = 'yyyy-MM-dd HH:mm';
  
  final UserApi _userApi = getIt<UserApi>();
  int _selectedTab = 0; // 0: 登录记录, 1: 安全操作记录
  
  late final PaginationController<ActivityItem> _paginationController;

  @override
  void initState() {
    super.initState();
    _paginationController = PaginationController<ActivityItem>(
      pageSize: _pageSize,
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
      final response = await _userApi.getAccountLogs(
        page: page,
        pageSize: pageSize,
        type: _selectedTab == 0 ? 1 : null,
      );

      // 响应拦截器已处理错误，到这里说明请求成功
      final listData = response['list'] ?? (response['data'] as Map<String, dynamic>?)?['list'];
      final list = listData is List ? listData : (listData is Map ? listData['data'] as List<dynamic>? ?? [] : []);
      return list.map(_parseActivityItem).toList();
    } catch (e) {
      // 错误已由拦截器处理
      return [];
    }
  }

  /// 解析活动项
  ActivityItem _parseActivityItem(dynamic item) {
    final map = item as Map<String, dynamic>;
    final type = map['type'] as int? ?? 1;
    
    return ActivityItem(
      date: _formatDate(map['created_at'] as String?),
      source: _buildSource(map),
      status: _getOperationType(type),
      ipAddress: map['ip'] as String? ?? '',
      type: type,
    );
  }

  /// 格式化日期
  String _formatDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    try {
      final dateTime = DateFormat(_dateInputFormat).parse(createdAt);
      return DateFormat(_dateOutputFormat).format(dateTime);
    } catch (e) {
      return createdAt;
    }
  }

  /// 构建来源信息
  String _buildSource(Map<String, dynamic> map) {
    final os = map['os'] as String? ?? '';
    final locationParts = [
      map['country'],
      map['region'],
      map['city'],
    ].whereType<String>().where((part) => part.isNotEmpty);
    
    if (locationParts.isEmpty) return os.isEmpty ? '未知' : os;
    return '$os · ${locationParts.join(' ')}';
  }

  /// 操作类型映射
  static const Map<int, String> _operationTypes = {
    1: '登录',
    2: '注册',
    3: '重置密码',
    4: '绑定手机',
    5: '绑定邮箱',
    6: '解绑手机',
    7: '解绑邮箱',
    8: '禁用账户',
    9: '删除账户',
    10: '绑定2FA',
    11: '解绑2FA',
  };

  /// 获取操作类型名称
  String _getOperationType(int type) => _operationTypes[type] ?? '未知操作';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SettingAppBar(title: '安全记录'),
            _buildTabBar(),
            Expanded(child: _buildActivityList()),
          ],
        ),
      ),
    );
  }

  /// 构建标签页
  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = _selectedTab == index;
          
          return Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 24.0 : 0),
            child: InkWell(
              onTap: () {
                if (_selectedTab != index) {
                  setState(() => _selectedTab = index);
                  _paginationController.refresh();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onSurface 
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    Container(
                      width: 28,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
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
    final activities = _paginationController.dataList;
    
    if (activities.isEmpty && !_paginationController.isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _paginationController.refresh(),
      child: ListView.builder(
        controller: _paginationController.scrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: activities.length + 1,
        itemBuilder: (context, index) {
          if (index == activities.length) {
            return _paginationController.buildLoadMoreIndicator();
          }
          return _buildActivityItem(activities[index]);
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
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

  /// 构建活动项
  Widget _buildActivityItem(ActivityItem item) {
    return SettingCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.type),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(item.type),
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
          InfoRow(label: '操作类型', value: item.status),
          const SizedBox(height: 8),
          InfoRow(label: '来源', value: item.source),
          const SizedBox(height: 8),
          InfoRow(label: 'IP地址', value: item.ipAddress),
        ],
      ),
    );
  }

  /// 状态颜色映射
  static const Map<int, Color> _statusColors = {
    1: Colors.green,
    2: Colors.green,
    3: Colors.blue,
    4: Colors.blue,
    5: Colors.blue,
    6: Colors.orange,
    7: Colors.orange,
    8: Colors.red,
    9: Colors.red,
    10: Colors.blue,
    11: Colors.orange,
  };

  /// 状态图标映射
  static const Map<int, IconData> _statusIcons = {
    1: Icons.check,
    2: Icons.check,
    3: Icons.lock,
    4: Icons.lock,
    5: Icons.lock,
    6: Icons.lock_open,
    7: Icons.lock_open,
    8: Icons.warning,
    9: Icons.warning,
    10: Icons.lock,
    11: Icons.lock_open,
  };

  /// 获取状态颜色
  Color _getStatusColor(int type) => _statusColors[type] ?? Colors.grey;

  /// 获取状态图标
  IconData _getStatusIcon(int type) => _statusIcons[type] ?? Icons.info;
}

/// 活动项数据模型
class ActivityItem {
  final String date;
  final String source;
  final String status;
  final String ipAddress;
  final int type;

  ActivityItem({
    required this.date,
    required this.source,
    required this.status,
    required this.ipAddress,
    required this.type,
  });
}
