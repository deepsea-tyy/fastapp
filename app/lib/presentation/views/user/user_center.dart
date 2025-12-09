import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/di/service_locator.dart';

/// 用户中心页面
class UserCenterScreen extends StatefulWidget {
  const UserCenterScreen({super.key});

  @override
  State<UserCenterScreen> createState() => _UserCenterScreenState();
}

class _UserCenterScreenState extends State<UserCenterScreen> {
  final UserStore _userStore = getIt<UserStore>();

  @override
  void initState() {
    super.initState();
    // 如果已登录，获取用户信息
    if (_userStore.isLoggedIn) {
      _userStore.getUserInfo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新可见时（例如从其他页面返回），如果已登录但用户信息未加载，则刷新用户信息
    if (_userStore.isLoggedIn && _userStore.currentUser == null) {
      _userStore.getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.crop_free),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.headphones_outlined),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.settings);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_userStore.isUserInfoLoading && _userStore.currentUser == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // 用户信息区域
                        _buildUserInfoSection(context),
                        
                        // 快捷入口区域
                        _buildQuickAccessSection(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfoSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        final username = user?.username ?? '未登录';
        final userId = user?.id ?? 0;
        final userCode = user?.code?.toString() ?? '';
        final nickname = user?.profile?.nickname;
        final avatar = user?.profile?.avatar;
        
        // 获取用户名首字母作为头像显示
        String getInitials(String name) {
          if (name.isEmpty) return 'U';
          return name.substring(0, 1).toUpperCase();
        }

        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.profile);
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: avatar != null && avatar.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  avatar,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                      if (userCode.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.amber[700],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                getInitials(userCode),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: $userId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nickname?.isNotEmpty == true ? nickname! : username,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag('普通用户', Colors.amber),
                          const SizedBox(width: 8),
                          _buildTag('已认证', Colors.green[300]!),
                        ],
                      ),
                    ],
                  ),
                ),
                // 右侧箭头
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建标签
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建快捷入口区域
  Widget _buildQuickAccessSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和复选框
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '快捷入口',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  Text(
                    '添加到首页服务',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 快捷入口网格
          _buildQuickAccessGrid(context),
        ],
      ),
    );
  }

  /// 构建快捷入口网格
  Widget _buildQuickAccessGrid(BuildContext context) {
    final items = [
      _QuickAccessItem(
        icon: Icons.people_outline,
        label: 'C2C买币',
        color: Colors.amber,
      ),
      _QuickAccessItem(
        icon: Icons.account_balance_wallet_outlined,
        label: '理财',
        color: Colors.black,
      ),
      _QuickAccessItem(
        icon: Icons.local_fire_department,
        label: '热门活动',
        color: Colors.amber,
      ),
      _QuickAccessItem(
        icon: Icons.person_add_outlined,
        label: '邀请奖励',
        color: Colors.amber,
      ),
      _QuickAccessItem(
        icon: Icons.edit_outlined,
        label: '编辑',
        color: Colors.black,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildQuickAccessItem(context, items[index]);
      },
    );
  }

  /// 构建单个快捷入口项
  Widget _buildQuickAccessItem(BuildContext context, _QuickAccessItem item) {
    return InkWell(
      onTap: () {
        // TODO: 处理快捷入口点击
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: item.color,
                width: 2,
              ),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 快捷入口项数据模型
class _QuickAccessItem {
  final IconData icon;
  final String label;
  final Color color;

  _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
