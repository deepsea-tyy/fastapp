import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/domain/entity/user/user.dart';
import 'package:fastapp/di/service_locator.dart';

/// 用户中心页面
class UserCenterScreen extends StatefulWidget {
  const UserCenterScreen({super.key});

  @override
  State<UserCenterScreen> createState() => _UserCenterScreenState();
}

class _UserCenterScreenState extends State<UserCenterScreen> {
  final UserStore _userStore = getIt<UserStore>();
  ReactionDisposer? _loginStatusDisposer;

  // 常量配置
  static const _iconButtonConstraints = BoxConstraints();
  static const _iconButtonPadding = EdgeInsets.zero;
  static const _quickAccessItems = [
    _QuickAccessItem(icon: Icons.people_outline, label: 'C2C买币', color: Colors.amber),
    _QuickAccessItem(icon: Icons.account_balance_wallet_outlined, label: '理财', color: Colors.black),
    _QuickAccessItem(icon: Icons.local_fire_department, label: '热门活动', color: Colors.amber),
    _QuickAccessItem(icon: Icons.person_add_outlined, label: '邀请奖励', color: Colors.amber),
    _QuickAccessItem(icon: Icons.edit_outlined, label: '编辑', color: Colors.black),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfoIfNeeded();
    // 监听登录状态变化，自动加载用户信息
    _loginStatusDisposer = reaction(
      (_) => _userStore.isLoggedIn,
      (isLoggedIn) {
        if (isLoggedIn && _userStore.currentUser == null) {
          _userStore.getUserInfo();
        }
      },
    );
  }

  @override
  void dispose() {
    _loginStatusDisposer?.call();
    super.dispose();
  }

  void _loadUserInfoIfNeeded() {
    if (_userStore.isLoggedIn && _userStore.currentUser == null) {
      _userStore.getUserInfo();
    }
  }

  Future<void> _refreshUserInfo() async {
    if (_userStore.isLoggedIn) await _userStore.getUserInfo();
  }

  /// 获取显示名称
  String _getDisplayName(User? user, bool isLoggedIn) {
    if (!isLoggedIn || user == null) {
      return '未登录';
    }
    
    // 优先显示昵称
    if (user.profile?.nickname?.isNotEmpty == true) {
      return user.profile!.nickname!;
    }
    
    // 其次显示用户名
    if (user.username?.isNotEmpty == true) {
      return user.username!;
    }
    
    // 最后显示手机号或邮箱
    if (user.mobile?.isNotEmpty == true) {
      return user.mobile!;
    }
    
    if (user.email?.isNotEmpty == true) {
      return user.email!;
    }
    
    return '未设置';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Observer(
                builder: (_) {
                  // 监听登录状态变化，如果已登录但用户信息为空，显示加载状态
                  if (_userStore.isLoggedIn && _userStore.isUserInfoLoading && _userStore.currentUser == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: _refreshUserInfo,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildUserInfoSection(context),
                          _buildQuickAccessSection(context),
                        ],
                      ),
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

  /// 构建顶部标题栏
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _buildIconButton(icon: Icons.crop_free, onPressed: () {}),
          _buildIconButton(icon: Icons.headphones_outlined, onPressed: () {}),
          _buildIconButton(
            icon: Icons.settings,
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
        ],
      ),
    );
  }

  /// 构建 IconButton（统一配置）
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      padding: _iconButtonPadding,
      constraints: _iconButtonConstraints,
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfoSection(BuildContext context) {
    return Observer(
      builder: (_) {
        final user = _userStore.currentUser;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isLoggedIn = _userStore.isLoggedIn;
        
        // 获取显示名称：优先显示昵称，如果没有则显示用户名，如果用户名为空则显示手机号或邮箱
        final displayName = _getDisplayName(user, isLoggedIn);
        
        // 获取 KYC 认证状态
        final isKycVerified = user?.isKyc == 1;
        
        return InkWell(
          onTap: () async {
            final route = isLoggedIn ? Routes.profile : Routes.login;
            await Navigator.of(context).pushNamed(route);
            // 从其他页面返回时刷新用户信息（特别是身份认证页面）
            if (isLoggedIn && mounted) {
              _refreshUserInfo();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildAvatar(user?.profile?.avatar, user?.code?.toString() ?? ''),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${user?.id ?? 0}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag('普通用户', Colors.amber),
                          if (isKycVerified) ...[
                            const SizedBox(width: 8),
                            _buildTag('已认证', Colors.green[300]!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建头像
  Widget _buildAvatar(String? avatarUrl, String userCode) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
      child: Stack(
        children: [
          Center(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
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
                    _getInitials(userCode),
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
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return const Icon(Icons.person, size: 40, color: Colors.white);
  }

  /// 获取首字母
  static String _getInitials(String name) {
    return name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase();
  }

  /// 构建标签
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 构建快捷入口区域
  Widget _buildQuickAccessSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '快捷入口',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  const Checkbox(value: true, onChanged: null),
                  Text(
                    '添加到首页服务',
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickAccessGrid(context),
        ],
      ),
    );
  }

  /// 构建快捷入口网格
  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _quickAccessItems.length,
      itemBuilder: (context, index) => _buildQuickAccessItem(context, _quickAccessItems[index]),
    );
  }

  /// 构建单个快捷入口项
  Widget _buildQuickAccessItem(BuildContext context, _QuickAccessItem item) {
    final theme = Theme.of(context);
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
              border: Border.all(color: item.color, width: 2),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
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

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
